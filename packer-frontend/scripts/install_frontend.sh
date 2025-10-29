#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

if grep -Rqs "archive.ubuntu.com/ubuntu" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
  sudo sed -i -E 's|http://archive\.ubuntu\.com/ubuntu|http://mirror.aws.ubuntu.com/ubuntu|g' /etc/apt/sources.list
  sudo sed -i -E 's|http://archive\.ubuntu\.com/ubuntu|http://mirror.aws.ubuntu.com/ubuntu|g' /etc/apt/sources.list.d/*.list 2>/dev/null || true
fi
if grep -Rqs "security.ubuntu.com/ubuntu" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
  sudo sed -i -E 's|http://security\.ubuntu\.com/ubuntu|http://mirror.aws.ubuntu.com/ubuntu|g' /etc/apt/sources.list
  sudo sed -i -E 's|http://security\.ubuntu\.com/ubuntu|http://mirror.aws.ubuntu.com/ubuntu|g' /etc/apt/sources.list.d/*.list 2>/dev/null || true
fi

sudo rm -rf /var/lib/apt/lists/* /var/lib/apt/lists/partial/* || true
sudo apt-get clean || true

sudo apt-get update -o Acquire::ForceIPv4=true -o Acquire::AllowInsecureRepositories=true || true
sudo apt-get install -y --no-install-recommends ca-certificates gnupg apt-transport-https

sudo rm -rf /var/lib/apt/lists/* /var/lib/apt/lists/partial/* || true
sudo apt-get clean || true
sudo apt-get update -o Acquire::ForceIPv4=true


echo "📦 Install Node 12 LTS and Yarn 1 (classic)..."

sudo npm uninstall -g yarn || true
sudo rm -rf /usr/local/bin/yarn /usr/local/bin/yarnpkg || true
sudo corepack disable || true

curl -fsSL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs git nginx build-essential python3 make g++ ca-certificates

# Yarn 1 (classic)
sudo npm i -g yarn@1.22.22
yarn --version

echo "🧠 Adding 2G swap (safety for build)..."
sudo fallocate -l 2G /swapfile || true
sudo chmod 600 /swapfile || true
sudo mkswap /swapfile || true
sudo swapon /swapfile || true

echo "🧱 Build React app..."
cd /tmp/src/frontend
yarn install --frozen-lockfile || yarn install

unset NODE_OPTIONS || true
yarn build

echo "📂 Move build to /var/www/frontend..."
sudo mkdir -p /var/www/frontend
sudo rsync -a --delete build/ /var/www/frontend/

echo "🧾 Install Nginx config..."
sudo mv /tmp/frontend.conf /etc/nginx/sites-available/frontend.conf
sudo ln -sf /etc/nginx/sites-available/frontend.conf /etc/nginx/sites-enabled/frontend.conf
sudo rm -f /etc/nginx/sites-enabled/default

echo "✅ Test & enable Nginx..."
sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "🧽 Cleanup build toolchain (optional): keep Node or remove?"

echo "🎉 Frontend AMI ready. Nginx serves /var/www/frontend on port 80."