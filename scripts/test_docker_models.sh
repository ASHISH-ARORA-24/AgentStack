#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Docker-Based LLM Models Testing Script       ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Docker is running
echo -e "${YELLOW}🔍 Checking if Docker is running...${NC}"
if ! docker ps > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is NOT running!${NC}"
    echo -e "${YELLOW}   Start Docker Desktop or run: sudo service docker start${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Docker is running${NC}"
echo ""

# Check if containers are running
echo -e "${YELLOW}🐳 Checking if containers are running...${NC}"
echo ""

OLLAMA1_RUNNING=$(docker ps | grep agentstack_ollama1)
OLLAMA2_RUNNING=$(docker ps | grep agentstack_ollama2)

if [ -z "$OLLAMA1_RUNNING" ] || [ -z "$OLLAMA2_RUNNING" ]; then
    echo -e "${YELLOW}⚠️  One or both containers are not running!${NC}"
    echo -e "${YELLOW}   Start them with: docker-compose up -d${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Both containers are running${NC}"
echo ""

# Check Container 1 (ollama1 on port 11435)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Container 1: ollama1 (Port 11435)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if curl -s http://localhost:11435/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}✅ ollama1 is accessible${NC}"
    echo ""
    echo -e "${YELLOW}📋 Models available:${NC}"
    curl -s http://localhost:11435/api/tags | jq '.models[] | "\(.name) (\(.size | . / 1000000000 | . * 100 | floor / 100 )GB)"' 2>/dev/null || echo "No models yet"
    echo ""
else
    echo -e "${RED}❌ ollama1 is NOT accessible${NC}"
fi

# Check Container 2 (ollama2 on port 11436)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Container 2: ollama2 (Port 11436)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if curl -s http://localhost:11436/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}✅ ollama2 is accessible${NC}"
    echo ""
    echo -e "${YELLOW}📋 Models available:${NC}"
    curl -s http://localhost:11436/api/tags | jq '.models[] | "\(.name) (\(.size | . / 1000000000 | . * 100 | floor / 100 )GB)"' 2>/dev/null || echo "No models yet"
    echo ""
else
    echo -e "${RED}❌ ollama2 is NOT accessible${NC}"
fi

# Test prompt
TEST_PROMPT="What is machine learning? Answer in one sentence."

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Testing both models with same prompt${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Prompt: \"$TEST_PROMPT\"${NC}"
echo ""

# Test Container 1
echo -e "${GREEN}1️⃣  Model 1: qwen2.5:0.5b (Port 11435)${NC}"
MODEL1_RESPONSE=$(curl -s http://localhost:11435/api/generate \
  -d "{\"model\": \"qwen2.5:0.5b\", \"prompt\": \"$TEST_PROMPT\", \"stream\": false}" \
  2>/dev/null | jq -r '.response' 2>/dev/null)

if [ -z "$MODEL1_RESPONSE" ]; then
    echo -e "${YELLOW}⚠️  Model not yet downloaded or no response${NC}"
else
    echo -e "${BLUE}$MODEL1_RESPONSE${NC}"
fi
echo ""

# Test Container 2
echo -e "${GREEN}2️⃣  Model 2: phi3:mini (Port 11436)${NC}"
MODEL2_RESPONSE=$(curl -s http://localhost:11436/api/generate \
  -d "{\"model\": \"phi3:mini\", \"prompt\": \"$TEST_PROMPT\", \"stream\": false}" \
  2>/dev/null | jq -r '.response' 2>/dev/null)

if [ -z "$MODEL2_RESPONSE" ]; then
    echo -e "${YELLOW}⚠️  Model not yet downloaded or no response${NC}"
else
    echo -e "${BLUE}$MODEL2_RESPONSE${NC}"
fi
echo ""

# Container stats
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Container Resource Usage${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

docker stats --no-stream agentstack_ollama1 agentstack_ollama2 2>/dev/null || echo "Stats unavailable"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Docker Testing Complete!${NC}"
echo ""
echo -e "${YELLOW}📝 Port Mapping:${NC}"
echo "   • Container 1 (qwen2.5:0.5b): http://localhost:11435"
echo "   • Container 2 (phi3:mini): http://localhost:11436"
echo ""
echo -e "${YELLOW}📚 Useful Commands:${NC}"
echo "   • docker-compose logs -f          (view logs)"
echo "   • docker-compose down             (stop containers)"
echo "   • docker-compose restart          (restart containers)"
echo "   • docker stats                    (resource usage)"
echo ""
