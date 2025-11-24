#!/bin/bash

# Test 3 Docker Ollama Containers
# Tests: llama3.2:1b (11434), qwen2.5:0.5b (11435), phi3:mini (11436)

set -e

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                    AgentStack - Docker Models Test (3 Containers)          ║"
echo "║                                                                            ║"
echo "║  Container 1: agentstack_llama3.2  (Port 11434) - llama3.2:1b              ║"
echo "║  Container 2: agentstack_qwen2.5   (Port 11435) - qwen2.5:0.5b             ║"
echo "║  Container 3: agentstack_phi3      (Port 11436) - phi3:mini                ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test function
test_model() {
    local port=$1
    local model=$2
    local container=$3
    
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Testing: ${container} (Port ${port})${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Check if container is running
    if ! docker ps | grep -q "$container"; then
        echo -e "${RED}✗ Container $container is not running${NC}"
        return 1
    fi
    echo -e "${GREEN}✓ Container is running${NC}"
    
    # Check if port is accessible
    if timeout 2 bash -c "echo >/dev/tcp/localhost/$port" 2>/dev/null; then
        echo -e "${GREEN}✓ Port $port is accessible${NC}"
    else
        echo -e "${RED}✗ Port $port is not accessible${NC}"
        return 1
    fi
    
    # Check if model is loaded
    echo -e "\n${YELLOW}→ Checking loaded models...${NC}"
    if curl -s "http://localhost:$port/api/tags" | grep -q "$model"; then
        echo -e "${GREEN}✓ Model $model is loaded${NC}"
    else
        echo -e "${YELLOW}⊘ Model $model is not loaded yet (may be downloading)${NC}"
        echo -e "${YELLOW}  Loaded models:${NC}"
        curl -s "http://localhost:$port/api/tags" 2>/dev/null | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | sed 's/^/    - /'
        return 0
    fi
    
    # Test simple prompt
    echo -e "\n${YELLOW}→ Testing with simple prompt: 'Hello'${NC}"
    response=$(curl -s http://localhost:$port/api/generate \
        -d "{\"model\":\"$model\",\"prompt\":\"Hello, what is 2+2?\",\"stream\":false}" \
        | grep -o '"response":"[^"]*"' | cut -d'"' -f4)
    
    if [ -n "$response" ]; then
        echo -e "${GREEN}✓ Model responded successfully${NC}"
        echo -e "${BLUE}Response (first 100 chars): ${NC}${response:0:100}..."
    else
        echo -e "${RED}✗ Model did not respond${NC}"
        return 1
    fi
}

# Run tests
echo ""
test_model 11434 "llama3.2:1b" "agentstack_llama3.2"
test_model 11435 "qwen2.5:0.5b" "agentstack_qwen2.5"
test_model 11436 "phi3:mini" "agentstack_phi3"

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Testing complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
