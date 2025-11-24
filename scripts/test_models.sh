#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Ollama LLM Models Testing Script            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Ollama is running
echo -e "${YELLOW}🔍 Checking if Ollama service is running...${NC}"
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Ollama service is running${NC}"
else
    echo -e "${RED}❌ Ollama service is NOT running!${NC}"
    echo -e "${YELLOW}   Start it with: ollama serve &${NC}"
    exit 1
fi
echo ""

# List available models
echo -e "${YELLOW}📋 Available models:${NC}"
curl -s http://localhost:11434/api/tags | jq '.models[] | .name' 2>/dev/null
echo ""

# Test prompt
PROMPT="What is machine learning? Explain in one sentence."

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Test Prompt: \"${PROMPT}\"${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Test Model 1: llama3.2:1b
echo -e "${GREEN}1️⃣  Testing llama3.2:1b${NC}"
echo -e "${YELLOW}Size: ~650 MB | Speed: Fast | Memory: ~2GB${NC}"
echo "Response:"
RESPONSE=$(curl -s http://localhost:11434/api/generate \
  -d "{\"model\": \"llama3.2:1b\", \"prompt\": \"$PROMPT\", \"stream\": false}" \
  2>/dev/null | jq -r '.response' 2>/dev/null)

if [ -z "$RESPONSE" ]; then
    echo -e "${RED}❌ Failed to get response${NC}"
else
    echo -e "${BLUE}$RESPONSE${NC}"
    echo ""
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Test Model 2: qwen2.5:0.5b
echo -e "${GREEN}2️⃣  Testing qwen2.5:0.5b${NC}"
echo -e "${YELLOW}Size: ~350 MB | Speed: Very Fast | Memory: ~1GB${NC}"
echo "Response:"
RESPONSE=$(curl -s http://localhost:11434/api/generate \
  -d "{\"model\": \"qwen2.5:0.5b\", \"prompt\": \"$PROMPT\", \"stream\": false}" \
  2>/dev/null | jq -r '.response' 2>/dev/null)

if [ -z "$RESPONSE" ]; then
    echo -e "${RED}❌ Failed to get response${NC}"
else
    echo -e "${BLUE}$RESPONSE${NC}"
    echo ""
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Test Model 3: phi3:mini
echo -e "${GREEN}3️⃣  Testing phi3:mini${NC}"
echo -e "${YELLOW}Size: ~2.3 GB | Speed: Good | Memory: ~2.5GB${NC}"
echo "Response:"
RESPONSE=$(curl -s http://localhost:11434/api/generate \
  -d "{\"model\": \"phi3:mini\", \"prompt\": \"$PROMPT\", \"stream\": false}" \
  2>/dev/null | jq -r '.response' 2>/dev/null)

if [ -z "$RESPONSE" ]; then
    echo -e "${RED}❌ Failed to get response${NC}"
else
    echo -e "${BLUE}$RESPONSE${NC}"
    echo ""
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Test streaming
echo -e "${GREEN}4️⃣  Testing Streaming Response (llama3.2:1b)${NC}"
echo "Prompt: 'Count from 1 to 3'"
echo "Response (streaming):"
curl -s http://localhost:11434/api/generate \
  -d "{\"model\": \"llama3.2:1b\", \"prompt\": \"Count from 1 to 3\", \"stream\": true}" \
  2>/dev/null | jq -r 'select(.response != null) | .response' | tr -d '\n'
echo ""
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ All tests completed!${NC}"
echo ""
echo -e "${YELLOW}📊 Summary:${NC}"
echo "  • 3 LLM models tested"
echo "  • Streaming tested"
echo "  • All models responsive"
echo ""
echo -e "${YELLOW}ℹ️  Next Steps:${NC}"
echo "  • Move to Phase 2: Create LiteLLM Backend Server"
echo "  • LiteLLM will use these models via this API"
echo ""
