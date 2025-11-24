#!/bin/bash

# Setup script for Docker and Docker Compose in WSL Ubuntu
# This script installs all necessary dependencies for running docker-compose

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Docker & Docker Compose Setup Script         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
   echo -e "${RED}❌ Please don't run this script as root${NC}"
   echo -e "${YELLOW}   Run: bash setup_docker.sh${NC}"
   exit 1
fi

# Step 1: Update package manager
echo -e "${YELLOW}📦 Step 1: Updating package manager...${NC}"
sudo apt update
echo -e "${GREEN}✅ Package manager updated${NC}"
echo ""

# Step 2: Install required dependencies
echo -e "${YELLOW}📦 Step 2: Installing dependencies...${NC}"
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
echo -e "${GREEN}✅ Dependencies installed${NC}"
echo ""

# Step 3: Add Docker GPG key
echo -e "${YELLOW}🔐 Step 3: Adding Docker GPG key...${NC}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo -e "${GREEN}✅ Docker GPG key added${NC}"
echo ""

# Step 4: Add Docker repository
echo -e "${YELLOW}📚 Step 4: Adding Docker repository...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo -e "${GREEN}✅ Docker repository added${NC}"
echo ""

# Step 5: Update package manager again
echo -e "${YELLOW}📦 Step 5: Updating package manager (with Docker repo)...${NC}"
sudo apt update
echo -e "${GREEN}✅ Package manager updated${NC}"
echo ""

# Step 6: Install Docker Engine
echo -e "${YELLOW}🐳 Step 6: Installing Docker Engine...${NC}"
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo -e "${GREEN}✅ Docker Engine installed${NC}"
echo ""

# Step 7: Install Docker Compose (standalone)
echo -e "${YELLOW}🐳 Step 7: Installing Docker Compose (standalone)...${NC}"
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo -e "${GREEN}✅ Docker Compose installed${NC}"
echo ""

# Step 8: Add user to docker group
echo -e "${YELLOW}👤 Step 8: Adding user to docker group...${NC}"
sudo usermod -aG docker $USER
echo -e "${YELLOW}   ⚠️  You need to log out and log back in for group changes to take effect${NC}"
echo ""

# Step 9: Start Docker service
echo -e "${YELLOW}🚀 Step 9: Starting Docker service...${NC}"
sudo systemctl start docker
sudo systemctl enable docker
echo -e "${GREEN}✅ Docker service started${NC}"
echo ""

# Step 10: Verify installation
echo -e "${YELLOW}✔️  Step 10: Verifying installation...${NC}"
echo ""

echo -e "${BLUE}Docker version:${NC}"
docker --version

echo -e "${BLUE}Docker Compose version:${NC}"
docker-compose --version

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""

echo -e "${YELLOW}📋 Next steps:${NC}"
echo "  1. Log out and log back in: logout"
echo "  2. Navigate to project: cd ~/project/AgentStack"
echo "  3. Start containers: docker-compose up -d"
echo "  4. Check status: docker-compose ps"
echo ""

echo -e "${YELLOW}📚 Useful commands:${NC}"
echo "  • docker-compose up -d          (start containers)"
echo "  • docker-compose down           (stop containers)"
echo "  • docker-compose logs -f        (view logs)"
echo "  • docker ps                     (list running containers)"
echo "  • docker stats                  (resource usage)"
echo ""
