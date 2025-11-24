#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  Cleanup Script: Remove Native Ollama          ║${NC}"
echo -e "${CYAN}║  Keep Docker-Only Setup                        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Ask for confirmation
echo -e "${YELLOW}⚠️  WARNING: This will remove native Ollama${NC}"
echo -e "${YELLOW}   - Stop Ollama service${NC}"
echo -e "${YELLOW}   - Delete all native models${NC}"
echo -e "${YELLOW}   - Free up ~3.9 GB of space${NC}"
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${YELLOW}Aborted.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Step 1: Stop Native Ollama Service${NC}"
echo -e "${BLUE}════════════════════════════════════════════════${NC}"

sudo systemctl stop ollama 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Ollama service stopped${NC}"
else
    echo -e "${YELLOW}⚠️  Ollama service not running (already stopped)${NC}"
fi

# Wait a moment for graceful shutdown
sleep 2

echo ""
echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Step 2: Verify No Ollama Processes${NC}"
echo -e "${BLUE}════════════════════════════════════════════════${NC}"

if pgrep ollama > /dev/null; then
    echo -e "${YELLOW}Found Ollama processes, killing them...${NC}"
    pkill -9 ollama
    sleep 1
fi

if ! pgrep ollama > /dev/null; then
    echo -e "${GREEN}✅ No Ollama processes running${NC}"
else
    echo -e "${RED}❌ Failed to stop Ollama processes${NC}"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Step 3: Remove Native Models${NC}"
echo -e "${BLUE}════════════════════════════════════════════════${NC}"

echo -e "${YELLOW}Listing models to delete:${NC}"
ollama list 2>/dev/null | tail -n +2

echo ""
echo -e "${YELLOW}Removing models...${NC}"

# Remove each model
if command -v ollama &> /dev/null; then
    ollama rm llama3.2:1b 2>/dev/null && echo -e "${GREEN}✅ Removed llama3.2:1b${NC}" || echo -e "${YELLOW}⚠️  llama3.2:1b not found${NC}"
    ollama rm qwen2.5:0.5b 2>/dev/null && echo -e "${GREEN}✅ Removed qwen2.5:0.5b${NC}" || echo -e "${YELLOW}⚠️  qwen2.5:0.5b not found${NC}"
    ollama rm phi3:mini 2>/dev/null && echo -e "${GREEN}✅ Removed phi3:mini${NC}" || echo -e "${YELLOW}⚠️  phi3:mini not found${NC}"
else
    echo -e "${YELLOW}⚠️  Ollama not in PATH${NC}"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Step 4: Remove Ollama Data Directory${NC}"
echo -e "${BLUE}════════════════════════════════════════════════${NC}"

if [ -d ~/.ollama ]; then
    SIZE=$(du -sh ~/.ollama | cut -f1)
    echo -e "${YELLOW}Removing ~/.ollama (Size: $SIZE)...${NC}"
    rm -rf ~/.ollama
    echo -e "${GREEN}✅ Ollama data directory removed${NC}"
else
    echo -e "${YELLOW}⚠️  ~/.ollama doesn't exist${NC}"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Step 5: Verify Docker Setup is Working${NC}"
echo -e "${BLUE}════════════════════════════════════════════════${NC}"

echo -e "${YELLOW}Checking Docker containers...${NC}"

# Check if containers are running
CONTAINER1=$(docker ps | grep agentstack_ollama1)
CONTAINER2=$(docker ps | grep agentstack_ollama2)

if [ -n "$CONTAINER1" ] && [ -n "$CONTAINER2" ]; then
    echo -e "${GREEN}✅ Both Docker containers are running${NC}"
else
    echo -e "${YELLOW}⚠️  Docker containers not running${NC}"
    echo -e "${YELLOW}   Start them with: docker-compose up -d${NC}"
fi

echo ""
echo -e "${YELLOW}Checking models in Docker containers...${NC}"

# Check Container 1
if curl -s http://localhost:11435/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Container 1 (Port 11435) is accessible${NC}"
    echo -e "   Models: $(curl -s http://localhost:11435/api/tags 2>/dev/null | jq '.models[] | .name' 2>/dev/null | tr '\n' ' ')"
else
    echo -e "${RED}❌ Container 1 (Port 11435) is NOT accessible${NC}"
fi

# Check Container 2
if curl -s http://localhost:11436/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Container 2 (Port 11436) is accessible${NC}"
    echo -e "   Models: $(curl -s http://localhost:11436/api/tags 2>/dev/null | jq '.models[] | .name' 2>/dev/null | tr '\n' ' ')"
else
    echo -e "${RED}❌ Container 2 (Port 11436) is NOT accessible${NC}"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Cleanup Summary${NC}"
echo -e "${BLUE}════════════════════════════════════════════════${NC}"

echo -e "${GREEN}✅ Native Ollama removed${NC}"
echo -e "${GREEN}✅ All native models deleted${NC}"
echo -e "${GREEN}✅ Data directory cleaned up${NC}"
echo -e "${GREEN}✅ Docker setup ready${NC}"
echo ""

echo -e "${YELLOW}📝 Next steps:${NC}"
echo "   1. Verify all models are in Docker:"
echo "      docker-compose up -d"
echo "      curl http://localhost:11435/api/tags"
echo "      curl http://localhost:11436/api/tags"
echo ""
echo "   2. Move to Phase 2: Create LiteLLM Backend"
echo "      See: docs/02_DOCKER_INSTALLATION.md"
echo ""
