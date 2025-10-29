# VERSUS - Global Comparison Platform

Versus is a global comparison platform, providing unbiased and user-friendly comparisons across various categories. By providing accurate and objective information, as well as structured, easy-to-visualize data, we aim to ease decision-making. It is an Open source web application to make comparisons between whatever you want.

This modern full-stack application features Django backend, React frontend, and automated CI/CD deployment to AWS EKS.

# JIRA Ticket

[CI/CD Versus App](https://312school.atlassian.net/browse/MRP25AREDH-17?atlOrigin=eyJpIjoiYmJmZDVmM2RkZjQyNDIwZDgzMDliMzA3OTU2Njc5ZTQiLCJwIjoiaiJ9)

## � Table of Contents

1. [📖 Story Behind This Project](#-story-behind-this-project)
2. [🏗️ Architecture Overview](#️-architecture-overview)
3. [🚀 Quick Start](#-quick-start)
   - [Prerequisites](#prerequisites)
   - [Environment Access](#environment-access)
4. [🛠️ Technology Stack](#️-technology-stack)
   - [Backend](#backend)
   - [Frontend](#frontend)
   - [Infrastructure](#infrastructure)
5. [🐳 Container & Production Deployment Focus](#-container--production-deployment-focus)
6. [🔄 CI/CD Pipeline](#-cicd-pipeline)
   - [GitHub Actions Workflow](#github-actions-workflow)
   - [Pipeline Steps](#pipeline-steps)
   - [Environment Variables](#environment-variables)
7. [📁 Project Structure](#-project-structure)
8. [🗄️ Database Configuration](#️-database-configuration)
   - [AWS RDS MySQL](#aws-rds-mysql)
   - [Database Migration Process](#database-migration-process)
9. [🌐 Ingress & Networking](#-ingress--networking)
10. [🔐 TLS Certificate Management](#-tls-certificate-management)
11. [🌍 Route 53 DNS Configuration](#-route-53-dns-configuration)
12. [🚢 Deployment Commands](#-deployment-commands)
13. [🔍 Monitoring & Debugging](#-monitoring--debugging)
14. [🧹 Cleanup & Destruction](#-cleanup--destruction)
15. [🔐 Security & IAM](#-security--iam)
16. [💪 Project Blockers & Challenges](#-project-blockers--challenges)
17. [🐛 Troubleshooting](#-troubleshooting)
18. [🤝 Contributing](#-contributing)
19. [📞 Support](#-support)

## �📖 Story Behind This Project

*Jenkinsfile* and *docker-compose.yaml* files once were used to build, test, and run the 'versus' application on-premises by DevOps Engineers. Now it has been modernized with a complete CI/CD pipeline to deploy the application to AWS EKS cluster with automated builds, testing, and deployment.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Frontend     │    │     Backend     │    │   AWS RDS MySQL │
│    (Port 8080)  │────│   (Port 8080)   │────│   (Port 3306)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
┌───────────────────────────────────────────────────────────────┐
│                    Kubernetes EKS Cluster                     │
│  ┌─────────────┐       ┌─────────────┐       ┌─────────────┐  │
│  │   Ingress   │       │  Services   │       │ Deployments │  │
│  │ (nginx-nlb) │       │             │       │             │  │
│  └─────────────┘       └─────────────┘       └─────────────┘  │
└───────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- kubectl installed and configured
- Helm 3.x installed
- Docker installed (for local development)

### Environment Access
- **Development**: https://versus-redhat-dev.312redhat.com
- **Staging**: https://versus-redhat-staging.312redhat.com  
- **Production**: https://versus-redhat.312redhat.com

## 🛠️ Technology Stack

### Backend
- **Framework**: Django 4.x
- **Database**: AWS RDS MySQL 5.7
- **Container**: Docker with multi-stage build
- **Port**: 8080

### Frontend  
- **Framework**: React 18.x
- **Web Server**: nginx
- **Container**: Docker with multi-stage build
- **Port**: 8080

### Infrastructure
- **Container Orchestration**: Amazon EKS (Kubernetes 1.31)
- **Container Registry**: Amazon ECR
- **Database**: AWS RDS MySQL
- **Load Balancer**: AWS Network Load Balancer (NLB)
- **Ingress Controller**: nginx ingress controller
- **SSL/TLS**: Let's Encrypt via cert-manager

## � Container & Production Deployment Focus

This project focuses on **containerized deployment to AWS EKS**. The application components are:

### Production Environment Configuration

**Frontend Environment Variables** (configured in `.env.production`):
```bash
REACT_APP_API_URL=https://versus-redhat-api-dev.312redhat.com
```
> Updated to point to backend subdomain through ingress routing

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

The project uses automated CI/CD with environment-specific deployments:

```yaml
Branch Strategy:
├── feature/** → dev environment
├── staging    → staging environment  
└── main       → production environment
```

### Pipeline Steps
1. **Code Checkout**: Clone repository
2. **AWS Authentication**: OIDC-based authentication
3. **Container Build**: Multi-platform Docker builds (AMD64)
4. **Container Push**: Push to Amazon ECR
5. **Helm Deployment**: Deploy to EKS with environment-specific values
6. **Verification**: Validate deployment health

### Environment Variables

#### **Method 1: Repository-Level Variables (Simplified)**
Configure these variables at repository level in GitHub Repository Settings → Variables:
```
AWS_REGION=us-east-1
EKS_CLUSTER=temporary-eks-cluster-dev
ECR_FRONTEND=340924313311.dkr.ecr.us-east-1.amazonaws.com/versus-app/frontend
ECR_BACKEND=340924313311.dkr.ecr.us-east-1.amazonaws.com/versus-app/backend
NAMESPACE=versus-app
IAM_ROLE=arn:aws:iam::340924313311:role/GitHubActions-VersusApp-Role
```

**Note**: With this method, the workflow automatically sets hostnames based on branch:
- `feature/**` branches → dev environment (`versus-redhat-api-dev.312redhat.com`)
- `staging` branch → staging environment (`versus-redhat-api-staging.312redhat.com`)  
- `main` branch → production environment (`versus-redhat-api.312redhat.com`)

#### **Method 2: Environment-Specific Variables (Advanced)**
Alternatively, you can configure environment-specific variables in GitHub Repository Settings → Environments:

**Create `dev` environment** with variables:
```
BACKEND_HOST=versus-redhat-api-dev.312redhat.com
FRONTEND_HOST=versus-redhat-dev.312redhat.com
```

**Create `staging` environment** with variables:
```
BACKEND_HOST=versus-redhat-api-staging.312redhat.com
FRONTEND_HOST=versus-redhat-staging.312redhat.com
```

**Create `production` environment** with variables:
```
BACKEND_HOST=versus-redhat-api.312redhat.com
FRONTEND_HOST=versus-redhat.312redhat.com
```

**Repository-level variables (same for all environments):**
```
AWS_REGION=us-east-1
EKS_CLUSTER=temporary-eks-cluster-dev
ECR_FRONTEND=340924313311.dkr.ecr.us-east-1.amazonaws.com/versus-app/frontend
ECR_BACKEND=340924313311.dkr.ecr.us-east-1.amazonaws.com/versus-app/backend
NAMESPACE=versus-app
IAM_ROLE=arn:aws:iam::340924313311:role/GitHubActions-VersusApp-Role
```

**Note**: If using Method 2, update the workflow to use `${{ vars.BACKEND_HOST }}` and `${{ vars.FRONTEND_HOST }}` instead of the hardcoded logic.

## 📁 Project Structure

```
versus-25a-redhat/
├── .github/workflows/
│   └── versus-cicd.yaml           # Main CI/CD pipeline
│   
├── app-chart/                     # Helm chart templates
│   ├── Chart.yaml                 # Helm chart metadata
│   ├── templates/
│   │   ├── deployment.yaml        # Kubernetes deployment
│   │   ├── service.yaml           # Kubernetes service
│   │   └── ingress.yaml           # Kubernetes ingress
│   └── values/
│       ├── dev/                   # Development environment values
│       │   ├── backend-values.yaml
│       │   └── frontend-values.yaml
│       ├── staging/               # Staging environment values
│       │   ├── backend-values.yaml
│       │   └── frontend-values.yaml
│       └── production/            # Production environment values
│           ├── backend-values.yaml
│           └── frontend-values.yaml
├── backend/                       # Django application
│   ├── api/                       # Django API module
│   │   ├── __init__.py
│   │   ├── admin.py
│   │   ├── apps.py
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── tests.py
│   │   ├── views.py
│   │   ├── common/
│   │   ├── fixtures/
│   │   └── migrations/
│   ├── main/                      # Django project settings
│   │   ├── __init__.py
│   │   ├── asgi.py
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   ├── Dockerfile                 # Backend container definition
│   ├── requirements.txt           # Python dependencies
│   ├── manage.py                  # Django management script
│   ├── app.yaml                   # Google Cloud App Engine config
│   └── README.md
├── frontend/                      # React application
│   ├── public/                    # Static assets
│   ├── src/                       # React source code
│   │   ├── index.js
│   │   ├── routes.jsx
│   │   └── setupTests.js
│   ├── Dockerfile                 # Frontend container definition
│   ├── package.json               # Node.js dependencies
│   ├── yarn.lock                  # Dependency lock file
│   ├── nginx.conf                 # Nginx configuration
│   ├── .env.development           # Development environment variables (empty)
│   ├── .env.production            # Production environment variables (empty)
│   └── README.md
│   
├── docker-compose.yaml            # Local development setup
├── Jenkinsfile                    # Jenkins CI/CD (legacy)
├── README.md                      # Original project README
└── versus-README.md              # This comprehensive guide
```

## 🗄️ Database Configuration

### AWS RDS MySQL
- **Host**: `versusdb.czxfqxkm6ggp.us-east-1.rds.amazonaws.com`
- **Database**: `versusdb`
- **User**: `versususer`
- **Port**: `3306`
- **Seeded Data**: 229 objects loaded

### Database Migration Process

**Migration from Local MySQL Pod to AWS RDS:**

1. **Initial Setup**: Started with local MySQL pod in Kubernetes
2. **AWS RDS Creation**: Created production MySQL 5.7 instance on AWS RDS
3. **Security Configuration**: Configured security groups for EKS cluster access
4. **Secret Management**: Created `mysql-secret` with RDS credentials
5. **Django Migration**: Ran database migrations on RDS instance
6. **Data Seeding**: Loaded 229 objects using `loaddata data.json`
7. **Connection Testing**: Verified backend connectivity to RDS

### Database Connection
The backend connects using Kubernetes secrets:
```yaml
secret:
  name: mysql-secret
  keys:
    - MYSQL_HOST
    - MYSQL_PORT  
    - MYSQL_DATABASE
    - MYSQL_USER
    - MYSQL_PASSWORD
```

**Migration Commands Used:**
```bash
# Create database secret
kubectl create secret generic mysql-secret \
  --from-literal=MYSQL_HOST=versusdb.czxfqxkm6ggp.us-east-1.rds.amazonaws.com \
  --from-literal=MYSQL_PORT=3306 \
  --from-literal=MYSQL_DATABASE=versusdb \
  --from-literal=MYSQL_USER=versususer \
  --from-literal=MYSQL_PASSWORD=<password> \
  -n versus-app

# Run migrations on RDS
kubectl exec -it <backend-pod> -n versus-app -- sh
python manage.py migrate

# Load fixture data
kubectl exec -it <backend-pod> -n versus-app -- sh
python manage.py loaddata data.json
```

## 🌐 Ingress & Networking

### Subdomain Routing
- **Frontend**: Routes `/` to React application
- **Backend API**: Routes `/api` to Django application

### Environment Hosts
| Environment | Frontend Host | Backend Host |
|------------|---------------|--------------|
| Development | versus-redhat-dev.312redhat.com | versus-redhat-api-dev.312redhat.com |
| Staging | versus-redhat-staging.312redhat.com | versus-redhat-api-staging.312redhat.com |
| Production | versus-redhat.312redhat.com | versus-redhat-api.312redhat.com |

## 🔐 TLS Certificate Management

### Automated Certificate Provisioning

The project uses **cert-manager** with **Let's Encrypt** for fully automated TLS certificate management:

#### **Dynamic Certificate Creation**
- **cert-manager** automatically provisions SSL certificates for each environment
- **Let's Encrypt** provides free, valid certificates with 90-day auto-renewal
- **Environment-specific** certificates based on deployment hosts

#### **Current TLS Configuration**
```yaml
Certificates Created:
├── versus-app-frontend-tls  → Frontend domains
└── versus-app-backend-tls   → Backend API domains

Certificate Details:
├── Issuer: Let's Encrypt Authority X3 (Production)
├── Validity: 90 days with auto-renewal
├── Challenge: HTTP-01 via nginx ingress
└── Management: Fully automated via cert-manager
```

#### **Certificate Verification Commands**
```bash
# Check certificate status
kubectl get certificates -n versus-app

# View certificate details
kubectl describe certificate versus-app-frontend-tls -n versus-app

# Check certificate content
kubectl get secret versus-app-frontend-tls -n versus-app -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -subject -issuer -dates

# Or
kubectl get secret versus-app-frontend-tls -n versus-app -o yaml

# Monitor certificate renewal
kubectl get events -n versus-app --field-selector reason=Issued
```

#### **TLS Implementation Benefits**
- ✅ **Zero manual intervention** required
- ✅ **Automatic certificate renewal** every 90 days
- ✅ **Environment isolation** with separate certificates
- ✅ **Production-grade security** with trusted CA
- ✅ **Cost-effective** using free Let's Encrypt certificates

## 🌍 Route 53 DNS Configuration

### Manual Hosted Zone Setup Required

**Important**: Route 53 hosted zones must be created manually for each environment tier.

#### **Required Hosted Zones**

| Environment | Hosted Zone Domain | Purpose |
|------------|-------------------|---------|
| Development | `versus-redhat-dev.312redhat.com` | Dev environment DNS |
| Staging | `versus-redhat-staging.312redhat.com` | Staging environment DNS |
| Production | `versus-redhat.312redhat.com` | Production environment DNS |

#### **Manual Setup Steps**

1. **Create Hosted Zones in AWS Route 53 (via AWS Console UI):**
   
   **Option A: Using AWS Console (Recommended)**
   - Navigate to Route 53 in AWS Console
   - Click "Create hosted zone"
   - Enter domain name: `versus-redhat-dev.312redhat.com`
   - Select "Public hosted zone"
   - Click "Create hosted zone"
   - Repeat for staging and production domains
   
   **Option B: Using AWS CLI**
   ```bash
   # Development hosted zone
   aws route53 create-hosted-zone \
     --name versus-redhat-dev.312redhat.com \
     --caller-reference $(date +%s)
   
   # Staging hosted zone  
   aws route53 create-hosted-zone \
     --name versus-redhat-staging.312redhat.com \
     --caller-reference $(date +%s)
   
   # Production hosted zone
   aws route53 create-hosted-zone \
     --name versus-redhat.312redhat.com \
     --caller-reference $(date +%s)
   ```

2. **Configure DNS Records:**
   ```bash
   # After EKS ingress deployment, get NLB address
   kubectl get ingress -n versus-app
   
   # Create A records pointing to NLB
   # Example for development:
   # versus-redhat-dev.312redhat.com → NLB-ADDRESS  
   # versus-redhat-api-dev.312redhat.com → NLB-ADDRESS
   ```

3. **Update Parent Domain NS Records:**
   - Configure parent domain (`312redhat.com`) to delegate to environment subdomains
   - Point subdomain NS records to Route 53 hosted zone name servers

#### **DNS Architecture**
```
312redhat.com (Parent Domain)
├── versus-redhat-dev.312redhat.com (Dev Hosted Zone)
│   ├── A record → EKS NLB (Frontend)
│   └── versus-redhat-api-dev.312redhat.com → EKS NLB (Backend)
├── versus-redhat-staging.312redhat.com (Staging Hosted Zone)
│   ├── A record → EKS NLB (Frontend)
│   └── versus-redhat-api-staging.312redhat.com → EKS NLB (Backend)
└── versus-redhat.312redhat.com (Production Hosted Zone)
    ├── A record → EKS NLB (Frontend)
    └── versus-redhat-api.312redhat.com → EKS NLB (Backend)
```

#### **Why Manual Setup?**
- **Security**: DNS changes require careful planning and approval
- **Cost Control**: Prevents accidental hosted zone creation charges
- **Environment Isolation**: Each tier has independent DNS management
- **Compliance**: Manual oversight ensures proper domain governance

## 🚢 Deployment Commands

### Manual Deployment
```bash
# Deploy backend
helm upgrade --install versus-app-backend ./app-chart \
  --set image.repository="$ECR_BACKEND" \
  --set image.tag="dev-$(git rev-parse --short HEAD)" \
  -f app-chart/values/dev/backend-values.yaml \
  -n versus-app

# Deploy frontend  
helm upgrade --install versus-app-frontend ./app-chart \
  --set image.repository="$ECR_FRONTEND" \
  --set image.tag="dev-$(git rev-parse --short HEAD)" \
  -f app-chart/values/dev/frontend-values.yaml \
  -n versus-app
```

### Automated Deployment
Push to any monitored branch to trigger automatic deployment:
```bash
git push origin feature/my-feature  # → dev environment
git push origin staging             # → staging environment  
git push origin main               # → production environment
```

## 🔍 Monitoring & Debugging

### Check Deployment Status
```bash
# View pods
kubectl get pods -n versus-app

# Check deployments
kubectl get deployments -n versus-app

# View ingress
kubectl get ingress -n versus-app

# Check services
kubectl get services -n versus-app
```

### View Logs
```bash
# Backend logs
kubectl logs -l app=versus-app-backend -n versus-app

# Frontend logs  
kubectl logs -l app=versus-app-frontend -n versus-app
```

### Rollback Deployment
```bash
# Rollback backend
helm rollback versus-app-backend -n versus-app

# Rollback frontend
helm rollback versus-app-frontend -n versus-app
```

## 🧹 Cleanup & Destruction

### Preserve Infrastructure Cleanup
The CI/CD workflow includes a commented cleanup section that can be uncommented when needed:
```bash
# Located in .github/workflows/versus-cicd.yaml (currently commented out)
# Uncomment the cleanup steps at the end of the workflow to enable automatic cleanup
```

### Complete Cleanup
```bash
# Remove Helm releases
helm uninstall versus-app-backend -n versus-app
helm uninstall versus-app-frontend -n versus-app

# Remove namespace 
kubectl delete namespace versus-app
```

## 🔐 Security & IAM

### GitHub Actions OIDC Role
- **Role ARN**: `arn:aws:iam::340924313311:role/GitHubActions-VersusApp-Role`
- **Permissions**: ECR push/pull, EKS cluster access
- **Trust Policy**: GitHub OIDC provider for `312school/versus-25a-redhat`

### Secret Management
- Database credentials stored in Kubernetes secrets
- No sensitive data in Git repository
- Environment variables managed through GitHub Variables

## � Project Blockers & Challenges

During the development of this project, I encountered several significant blockers that required resolution:

### **1. Docker Platform Compatibility Issues**
- **Problem**: ARM64 vs AMD64 architecture conflicts between local development (M1/M2 Macs) and EKS cluster
- **Symptoms**: Images built locally wouldn't run on EKS nodes
- **Solution**: Added `--platform linux/amd64` flag to all Docker builds in CI/CD pipeline
- **Impact**: 2-3 hours debugging deployment failures

### **2. GitHub Actions Environment Variable Configuration**
- **Problem**: Environment variables were commented out in workflow, causing Docker builds to fail
- **Symptoms**: `ERROR: failed to build: invalid tag ':dev-91aaa87': invalid reference format`
- **Root Cause**: `$ECR_BACKEND` and `$ECR_FRONTEND` resolving to empty strings
- **Solution**: Uncommented env section and properly configured GitHub repository variables
- **Impact**: 1-2 hours debugging CI/CD failures

### **3. AWS RDS Connection & Migration Challenges**
- **Problem**: Transitioning from local MySQL pod to AWS RDS for production reliability
- **Challenges**: 
  - Network connectivity configuration
  - Security group rules setup
  - Database credentials management in Kubernetes secrets
  - Django database migration execution
- **Solution**: Properly configured RDS security groups, created mysql-secret, ran migrations
- **Impact**: 4-5 hours for complete database migration

### **4. Ingress Controller & Subdomain Routing**
- **Problem**: Complex subdomain-based routing for frontend and backend API
- **Challenges**:
  - Nginx ingress controller configuration
  - AWS NLB integration with nginx ingress
  - SSL/TLS certificate management
  - Path-based vs host-based routing decisions
- **Solution**: Implemented host-based routing with separate subdomains for API and frontend
- **Impact**: 3-4 hours configuring ingress and testing routing

### **5. Helm Chart Environment Management**
- **Problem**: Static values files not suitable for dynamic CI/CD environments
- **Challenges**:
  - Hardcoded ECR repository URLs in values files
  - Environment-specific configuration management
  - Image tag dynamic updates
- **Solution**: Created environment-specific folders with placeholder values, override via `--set` flags
- **Impact**: 2-3 hours refactoring Helm charts

### **6. OIDC Authentication Setup**
- **Problem**: GitHub Actions needed secure access to AWS services without long-term credentials
- **Challenges**:
  - IAM role trust policy configuration
  - OIDC provider setup
  - Permission scoping for ECR and EKS
- **Solution**: Configured GitHubActions-VersusApp-Role with proper trust relationships
- **Impact**: 2-3 hours setting up secure authentication

### **7. Frontend Environment Variable Injection**
- **Problem**: React app needed different API URLs for different environments
- **Challenges**:
  - Build-time vs runtime environment variables
  - Docker container immutability
  - Nginx configuration templating
- **Solution**: Created environment-specific .env files and nginx configuration
- **Impact**: 1-2 hours configuring frontend environment handling

### **8. Kubernetes ReplicaSet Accumulation**
- **Problem**: Old ReplicaSets accumulating from multiple deployments
- **Symptoms**: Multiple 0/0/0 ReplicaSets cluttering cluster
- **Root Cause**: Normal Kubernetes behavior for deployment history
- **Solution**: Understanding this is normal; optional cleanup with `revisionHistoryLimit`
- **Impact**: 30 minutes investigation and cleanup

### **9. TLS Certificate Automation Migration**
- **Problem**: Transitioning from manually created TLS certificates to automated cert-manager
- **Challenges**:
  - Understanding cert-manager installation and configuration
  - Let's Encrypt ACME challenge setup with nginx ingress
  - Certificate secret naming conflicts with existing manual certificates
  - HTTP-01 challenge routing through NLB and nginx ingress
- **Solution**: Implemented cert-manager with ClusterIssuer, dynamic secret names based on app names
- **Impact**: 3-4 hours researching cert-manager, testing ACME challenges, and verifying certificate creation

### **10. Route 53 DNS Complexity**
- **Problem**: Multi-tier subdomain architecture requiring careful DNS planning
- **Challenges**:
  - Creating separate hosted zones for each environment (dev/staging/production)
  - Coordinating subdomain delegation from parent domain (312redhat.com)
  - Managing A records for both frontend and backend subdomains
  - Understanding AWS NLB DNS propagation timing
- **Solution**: Manual hosted zone creation with proper NS record delegation
- **Impact**: 2-3 hours planning DNS architecture and configuring Route 53

### **11. Container Resource Management**
- **Problem**: Kubernetes pods failing due to insufficient resources or poor resource allocation
- **Challenges**:
  - Determining appropriate CPU and memory requests/limits for Django and React containers
  - Understanding Kubernetes resource scheduling and node capacity
  - Optimizing Docker image sizes for faster pulls and deployments
  - Monitoring resource usage patterns across environments
- **Solution**: Configured reasonable resource requests/limits in Helm templates based on application behavior
- **Impact**: 1-2 hours testing different resource configurations and monitoring performance

### **12. Environment Variable Security and Management**
- **Problem**: Safely managing sensitive environment variables across GitHub Actions and Kubernetes
- **Challenges**:
  - Understanding difference between GitHub repository variables and secrets
  - Properly configuring database credentials in Kubernetes secrets
  - Ensuring environment variables are correctly passed from CI/CD to containers
  - Avoiding exposure of sensitive data in logs or container environment
- **Solution**: Used GitHub variables for non-sensitive config, Kubernetes secrets for DB credentials
- **Impact**: 1-2 hours understanding GitHub Actions security model and Kubernetes secret management

### **13. Multi-Environment Configuration Complexity**
- **Problem**: Managing configuration differences across dev, staging, and production environments
- **Challenges**:
  - Dynamic branch-to-environment mapping in GitHub Actions
  - Environment-specific Helm values without code duplication
  - Coordinating different hostnames, database connections, and resource allocations
  - Ensuring consistent deployment process across all environments
- **Solution**: Created environment-specific Helm values files with dynamic workflow variables
- **Impact**: 2-3 hours designing flexible configuration architecture

### **10. React Environment Variable Build vs Runtime Configuration**
- **Issue**: Frontend making API calls to `/undefined/api/v1/categories/` instead of proper backend URLs
- **Root Cause**: React environment variables (`REACT_APP_*`) must be available at **build time**, not runtime
- **Problem**: Setting `REACT_APP_API_URL` in Kubernetes deployment happens after Docker build completes
- **Challenges**:
  - Understanding React static bundle compilation vs dynamic environment variables
  - Coordinating build-time configuration with environment-specific deployment values
  - Modifying CI/CD to extract values from Helm files and pass as Docker build arguments
  - Ensuring each environment gets the correct API URL baked into the frontend bundle
- **Solution**: Modified Dockerfile to accept `ARG REACT_APP_API_URL`, updated CI/CD to extract `apiUrl` from environment-specific Helm values and pass as `--build-arg`
- **Impact**: 4-5 hours debugging undefined API calls, understanding React build process, and implementing proper build-time configuration

### **Lessons Learned**
1. **Always specify Docker platform** for cross-architecture compatibility
2. **GitHub Actions variables must be properly configured** before workflow execution
3. **AWS RDS requires careful network and security configuration** for EKS integration
4. **Ingress routing strategy** should be planned early in the project
5. **Helm charts should be designed for flexibility** from the start
6. **OIDC authentication** is more secure than long-term AWS credentials
7. **Environment-specific configuration** requires thoughtful architecture
8. **Kubernetes maintains deployment history** which is normal operational behavior
9. **cert-manager simplifies TLS management** but requires understanding of ACME challenges
10. **DNS planning is critical** for multi-environment subdomain architecture
11. **Resource management affects deployment success** and application performance
12. **Security boundaries** between CI/CD variables and runtime secrets are important
13. **Configuration complexity grows exponentially** with multiple environments

## �🐛 Troubleshooting

### Common Issues

**1. Image Pull Errors**
```bash
# Check ECR authentication
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 340924313311.dkr.ecr.us-east-1.amazonaws.com
```

**2. API Returns 500 Internal Server Error**
**Symptoms**: `https://versus-redhat-api-dev.312redhat.com/api/v1/categories/` returns 500 error
**Root Cause**: Database authentication failure - password mismatch between Kubernetes secret and AWS RDS

```bash
# Step 1: Test API endpoint
curl -k https://versus-redhat-api-dev.312redhat.com/api/v1/categories/

# Step 2: Check backend logs for database errors
kubectl logs -l app=versus-app-backend -n versus-app --tail=10

# Step 3: Test database connection (get pod name first)
kubectl get pods -n versus-app -l app=versus-app-backend
kubectl exec -it <backend-pod-name> -n versus-app -- python manage.py check

# Step 4: If database auth fails, update secret with correct password
kubectl create secret generic mysql-secret \
  --from-literal=MYSQL_HOST=versusdb.czxfqxkm6ggp.us-east-1.rds.amazonaws.com \
  --from-literal=MYSQL_PORT=3306 \
  --from-literal=MYSQL_DATABASE=versusdb \
  --from-literal=MYSQL_USER=versususer \
  --from-literal=MYSQL_PASSWORD='<correct_password_from_secrets_manager>' \
  -n versus-app \
  --dry-run=client -o yaml | kubectl apply -f -

# Step 5: Restart deployment
kubectl rollout restart deployment/versus-app-backend-deployment -n versus-app
```

**3. Database Connection Issues**
```bash
# Verify MySQL secret exists
kubectl get secret mysql-secret -n versus-app -o yaml
```

**3. Ingress Not Working**
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Verify NLB creation
kubectl describe ingress -n versus-app
```

**4. Frontend Making API Calls to `/undefined/api/v1/`**
**Symptoms**: Frontend loads but API calls fail with requests to `/undefined/api/v1/categories/` instead of the correct backend URL
**Root Cause**: React environment variables must be set at **build time**, not runtime

**Problem Analysis:**
- React apps are **static** - once built with `yarn build`, the JavaScript bundle is fixed
- Setting `REACT_APP_API_URL` in Kubernetes environment variables happens **after** the build process
- The React code `process.env.REACT_APP_API_URL` gets compiled to `undefined` if not available during build

**Solution Implemented:**
```bash
# 1. Modified Dockerfile to accept build arguments
ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=$REACT_APP_API_URL

# 2. Updated CI/CD to extract API URL from environment-specific values
API_URL=$(grep "apiUrl:" "app-chart/values/${ENVIRONMENT_STAGE}/frontend-values.yaml" | awk '{print $2}')
docker build --build-arg REACT_APP_API_URL="$API_URL" -t frontend ./frontend

# 3. Removed runtime environment variable from Helm (no longer needed)
```

**Verification:**
```bash
# Check frontend logs for correct API calls
kubectl logs -l app=versus-app-frontend -n versus-app --tail=10
# Should show: GET https://versus-redhat-api.../api/v1/categories/
# NOT: GET /undefined/api/v1/categories/
```

**5. Frontend Shows Empty Categories/Products**
**Symptoms**: `https://versus-redhat-dev.312redhat.com/category/3` (Bars) or `/category/4` (Coffee shops) show no products
**Root Cause**: Categories exist but have no associated products in the fixture data

```bash
# Step 1: Verify which categories have products
kubectl exec -it <backend-pod-name> -n versus-app -- python manage.py shell -c "
from api.models import Category, Product
for cat in Category.objects.all():
    products = Product.objects.filter(category=cat)
    print(f'{cat.id}: {cat.name} - {products.count()} products')
"

# Step 2: Check fixture data contents
curl -k https://versus-redhat-api-dev.312redhat.com/api/v1/categories/ | jq '.results[] | {id, name, products: .products | length}'

# Current fixture data includes:
# - Universities (8 products)  
# - Restaurants (4 products)
# - Bars (0 products) - Empty placeholder
# - Coffee shops (0 products) - Empty placeholder

# Step 3: Load fixture data if not already loaded
kubectl exec -it <backend-pod-name> -n versus-app -- python manage.py loaddata data.json
```

**Note**: Categories 3 (Bars) and 4 (Coffee shops) are placeholder categories in the current dataset and don't contain products yet. This is expected behavior for the demo application.

**5. Old ReplicaSets**
```bash
# Clean up old ReplicaSets (normal Kubernetes behavior)
kubectl get replicasets -n versus-app
kubectl delete replicaset <old-replicaset-name> -n versus-app
```

## 🤝 Contributing

1. Create feature branch: `git checkout -b feature/MRP25AREDH-17-CICD-Versus`
2. Make changes and test locally
3. Push to feature branch (deploys to dev environment)
4. Create Pull Request to staging
5. After testing, merge to main for production deployment

## 📞 Support

For issues and questions:
- Check GitHub Actions logs for CI/CD problems
- Review Kubernetes events: `kubectl get events -n versus-app`
- Monitor application logs as shown in debugging section

---

**Last Updated**: October 2025  
**Kubernetes Version**: 1.31  
**Maintained By**: DevOps Team

[def]: https://312school.atlassian.net/browse/MRP25AREDH-17?atlOrigin=eyJpIjoiYmJmZDVmM2RkZjQyNDIwZDgzMDliMzA3OTU2Njc5ZTQiLCJwIjoiaiJ9