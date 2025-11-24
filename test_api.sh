#!/bin/bash

# Test all 3 models with curl commands
# Usage: ./test_api.sh

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    AGENTSTACK MODEL TESTS                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Check loaded models
echo -e "${BLUE}1️⃣  CHECKING LOADED MODELS${NC}"
echo ""

echo -e "${GREEN}LLAMA 3.2:1b (Port 11434)${NC}"
curl -s http://localhost:11434/api/tags | grep -o '"name":"[^"]*"' || echo "❌ Not responding"
echo ""

echo -e "${GREEN}QWEN 2.5:0.5b (Port 11435)${NC}"
curl -s http://localhost:11435/api/tags | grep -o '"name":"[^"]*"' || echo "❌ Not responding"
echo ""

echo -e "${GREEN}PHI 3:mini (Port 11436)${NC}"
curl -s http://localhost:11436/api/tags | grep -o '"name":"[^"]*"' || echo "❌ Not responding"
echo ""

# Test 2: API calls with responses
echo -e "${BLUE}2️⃣  TEST API CALLS${NC}"
echo ""

echo -e "${YELLOW}LLAMA - Generating response...${NC}"
curl -s -X POST http://localhost:11434/api/generate \
  -d '{"model":"llama3.2:1b","prompt":"What is AI?","stream":false}' \
  | grep -o '"response":"[^"]*"' | sed 's/"response":"//' | sed 's/"$//' || echo "⏳ Processing..."
echo ""

echo -e "${YELLOW}QWEN - Generating response...${NC}"
curl -s -X POST http://localhost:11435/api/generate \
  -d '{"model":"qwen2.5:0.5b","prompt":"What is AI?","stream":false}' \
  | grep -o '"response":"[^"]*"' | sed 's/"response":"//' | sed 's/"$//' || echo "⏳ Processing..."
echo ""

echo -e "${YELLOW}PHI - Generating response... (may take 30+ seconds)${NC}"
timeout 45 curl -s -X POST http://localhost:11436/api/generate \
  -d '{"model":"phi3:mini","prompt":"What is AI?","stream":false}' \
  | grep -o '"response":"[^"]*"' | sed 's/"response":"//' | sed 's/"$//' || echo "⏳ Still processing..."
echo ""

# Test 3: Direct curl commands for manual use
echo -e "${BLUE}3️⃣  CURL COMMANDS FOR MANUAL TESTING${NC}"
echo ""

echo "Copy and paste these commands to test individually:"
echo ""
echo -e "${YELLOW}Check Llama:${NC}"
echo "curl -s http://localhost:11434/api/tags"
echo ""

echo -e "${YELLOW}Check Qwen:${NC}"
echo "curl -s http://localhost:11435/api/tags"
echo ""

echo -e "${YELLOW}Check Phi:${NC}"
echo "curl -s http://localhost:11436/api/tags"
echo ""

echo -e "${YELLOW}Generate with Llama:${NC}"
echo "curl -X POST http://localhost:11434/api/generate -d '{\"model\":\"llama3.2:1b\",\"prompt\":\"Hello\",\"stream\":false}'"
echo ""

echo -e "${YELLOW}Generate with Qwen:${NC}"
echo "curl -X POST http://localhost:11435/api/generate -d '{\"model\":\"qwen2.5:0.5b\",\"prompt\":\"Hello\",\"stream\":false}'"
echo ""

echo -e "${YELLOW}Generate with Phi:${NC}"
echo "curl -X POST http://localhost:11436/api/generate -d '{\"model\":\"phi3:mini\",\"prompt\":\"Hello\",\"stream\":false}'"
echo ""

echo "✅ All models are ready for testing!"
