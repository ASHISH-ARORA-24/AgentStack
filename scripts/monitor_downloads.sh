#!/bin/bash

# Monitor Docker Model Downloads
# Usage: ./monitor_downloads.sh
# Shows download progress and status of all 3 containers

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║              AgentStack - Download Monitor (3 Containers)             ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

check_model() {
    local port=$1
    local container=$2
    local model=$3
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Container: $container (Port $port)"
    echo "Model: $model"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check if model is loaded
    response=$(curl -s http://localhost:$port/api/tags 2>/dev/null)
    
    if echo "$response" | grep -q "$model"; then
        echo "✓ Status: LOADED"
        echo "✓ Ready to use!"
    else
        if echo "$response" | grep -q '"models"'; then
            echo "⏳ Status: Downloaded but not loaded yet"
            echo "   (First request will load it into memory)"
        else
            echo "⏳ Status: Still downloading..."
            tail_count=$(docker logs "$container" 2>/dev/null | grep -c "downloading" || echo "0")
            if [ "$tail_count" -gt 0 ]; then
                docker logs "$container" 2>/dev/null | grep "downloading" | tail -1
            fi
        fi
    fi
    
    # Show memory usage
    mem=$(docker stats --no-stream --format "{{.MemUsage}}" "$container" 2>/dev/null || echo "N/A")
    echo "Memory: $mem"
    echo ""
}

# Check all 3 containers
check_model 11434 "agentstack_llama3.2" "llama3.2:1b"
check_model 11435 "agentstack_qwen2.5" "qwen2.5:0.5b"
check_model 11436 "agentstack_phi3" "phi3:mini"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Last Updated: $(date '+%Y-%m-%d %H:%M:%S')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 To watch downloads in real-time:"
echo "   docker logs -f agentstack_llama3.2"
echo "   docker logs -f agentstack_qwen2.5"
echo "   docker logs -f agentstack_phi3"
echo ""
echo "💡 To keep checking status, run:"
echo "   watch -n 5 './scripts/monitor_downloads.sh'"
