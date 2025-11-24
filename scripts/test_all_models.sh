#!/bin/bash

# Test all 3 Ollama models with curl
# Tests inference on each model to verify they're working

echo "================================"
echo "  AgentStack Model Test Suite   "
echo "================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test configuration
QWEN_URL="http://localhost:11435/api/generate"
LLAMA_URL="http://localhost:11434/api/generate"
PHI_URL="http://localhost:11436/api/generate"

TEST_PROMPT="What is 2+2? Answer very briefly in one sentence."

# Function to test a model
test_model() {
    local name=$1
    local url=$2
    local model=$3
    
    echo -e "${BLUE}Testing $name...${NC}"
    
    local response=$(curl -s -m 30 "$url" \
        -d "{\"model\":\"$model\",\"prompt\":\"$TEST_PROMPT\",\"stream\":false}" \
        2>/dev/null)
    
    if [ -z "$response" ]; then
        echo -e "${RED}✗ $name: No response from API${NC}"
        return 1
    fi
    
    local answer=$(echo "$response" | grep -o '"response":"[^"]*"' | sed 's/"response":"//;s/"$//' | cut -c1-80)
    
    if [ -z "$answer" ]; then
        echo -e "${RED}✗ $name: Failed to parse response${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ $name: Working${NC}"
    echo "  Response: $answer..."
    echo ""
    return 0
}

# Run tests
echo -e "Testing inference on all 3 models...\n"

success=0
total=3

test_model "Qwen 2.5:0.5b (Port 11435)" "$QWEN_URL" "qwen2.5:0.5b" && ((success++)) || echo ""
test_model "Llama 3.2:1b (Port 11434)" "$LLAMA_URL" "llama3.2:1b" && ((success++)) || echo ""
test_model "Phi 3:mini (Port 11436)" "$PHI_URL" "phi3:mini" && ((success++)) || echo ""

# Summary
echo "================================"
echo "Test Results: $success/$total passed"
echo "================================"

if [ $success -eq $total ]; then
    echo -e "${GREEN}✓ All models working!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some models failed${NC}"
    exit 1
fi
