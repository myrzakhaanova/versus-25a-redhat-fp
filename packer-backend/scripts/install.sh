#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# short pause on cloud-init
sleep 3 || true

# Hardcoding all sources to regional EC2 mirrors (they are already "Hit")
for f in /etc/apt/sources.list /etc/apt/sources.list.d/*.list; do
  [ -f "$f" ] || continue
  sudo sed -i -E 's|http://archive\.ubuntu\.com/ubuntu|http://us-east-1.ec2.archive.ubuntu.com/ubuntu|g' "$f"
  sudo sed -i -E 's|http://security\.ubuntu\.com/ubuntu|http://us-east-1.ec2.archive.ubuntu.com/ubuntu|g' "$f"
done

# Cleaning up broken indexes and running update with IPv4 (sometimes IPv6 is problematic)
sudo rm -rf /var/lib/apt/lists/* /var/lib/apt/lists/partial/* || true
sudo apt-get clean || true
sudo apt-get update -o Acquire::ForceIPv4=true

echo "🧹 Cleaning apt locks..."
sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock || true
sudo dpkg --configure -a || true

echo "📦 Installing base packages..."

sudo add-apt-repository -y universe
sudo apt-get update -o Acquire::ForceIPv4=true
sudo apt-get install -y --no-install-recommends \
  build-essential libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev wget curl llvm \
  libncurses5-dev xz-utils libxml2-dev \
  libxmlsec1-dev libffi-dev liblzma-dev \
  ca-certificates git python3 python3-pip python3-venv nginx rsync

echo "📂 Copying backend files..."
sudo mkdir -p /opt/versus/backend
sudo rsync -a /tmp/src/backend/ /opt/versus/backend/
cd /opt/versus/backend

echo "🔑 Copying environment variables..."
sudo cp /tmp/envfile /opt/versus/backend/.env

echo "📦 System deps for mysqlclient..."
sudo apt-get update -o Acquire::ForceIPv4=true
sudo apt-get install -y --no-install-recommends \
  build-essential python3-dev pkg-config default-libmysqlclient-dev

echo "🐍 Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
pip install gunicorn

echo "⚙️ Setting up Nginx..."
sudo mv /tmp/versus.conf /etc/nginx/sites-available/versus.conf
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/versus.conf /etc/nginx/sites-enabled/versus.conf
sudo nginx -t && sudo systemctl enable nginx && sudo systemctl restart nginx

echo "🧩 Setting up systemd service..."
sudo mv /tmp/versus-backend.service /etc/systemd/system/versus-backend.service
sudo systemctl daemon-reload
sudo systemctl enable versus-backend.service

echo "✅ Installation complete!"