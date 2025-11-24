# Phase 1.5: Docker-Compose Setup with Lightweight LLM Models

## Overview

While you can run Ollama natively (covered in Phase 1), you can also run lightweight LLM models via Docker containers. This gives you:

- **Isolation**: Models run in containers
- **Portability**: Easy to move across systems
- **Multiple Models**: Run different models simultaneously without conflict
- **Easy Cleanup**: Stop and remove containers without affecting the host

**Architecture Update:**
```
┌─────────────────────────────────────────────────────────┐
│               STREAMLIT FRONTEND                        │
│              (Port: 8501)                               │
└────────────────┬────────────────────────────────────────┘
                 │
┌────────────────┴────────────────────────────────────────┐
│            LITELLM PROXY SERVER                         │
│              (Port: 8000)                               │
└────┬───────────────────────┬───────────────────────────┘
     │                       │
┌────┴──────────────┐  ┌──────┴──────────────────┐
│   OLLAMA SERVICE  │  │  DOCKER CONTAINERS      │
│  (Port: 11434)    │  │  (Multiple Models)      │
│                   │  │                         │
│ Native on WSL     │  │ • ollama/ollama:latest  │
│                   │  │   Port: 11435           │
│                   │  │                         │
│                   │  │ • ollama/ollama:latest  │
│                   │  │   Port: 11436           │
└───────────────────┘  └─────────────────────────┘
```

---

## Why Docker Containers for LLMs?

### Benefits
✅ **Isolation** - Each model in its own container
✅ **Resource Control** - Limit CPU/memory per container
✅ **Easy Scaling** - Add more models quickly
✅ **Reproducibility** - Same setup across machines
✅ **No Conflicts** - Different versions of same model

### Lightweight Model Options

| Model | Size | Container Size | RAM | Speed |
|-------|------|-----------------|-----|-------|
| qwen2.5:0.5b | 350 MB | ~400 MB | 1 GB | Very Fast ⚡⚡ |
| phi3:mini | 2.3 GB | ~2.5 GB | 2.5 GB | Fast ⚡ |
| tinyllama:1b | 600 MB | ~650 MB | 1.5 GB | Very Fast ⚡⚡ |
| neural-chat:7b | 4.0 GB | ~4.5 GB | 4 GB | Moderate |

**Recommended for Docker**: qwen2.5:0.5b + phi3:mini (lightest & fastest)

---

## Docker-Compose Configuration

### Prerequisites

```bash
docker --version    # Should show Docker version
docker-compose --version  # Should show Docker Compose version
```

If not installed:
```bash
# Install Docker Desktop for Windows (includes docker-compose)
# Download from: https://www.docker.com/products/docker-desktop
```

---

## Step 1: Understanding the docker-compose.yml

Key services:

1. **ollama1** - First lightweight model (qwen2.5:0.5b)
   - Port: 11435
   - Memory: 2GB limit
   - Volume: Stores models persistently

2. **ollama2** - Second lightweight model (phi3:mini)
   - Port: 11436
   - Memory: 3GB limit
   - Volume: Stores models persistently

### Docker-Compose File Structure

```yaml
version: '3.8'

services:
  # Service 1: Lightweight model
  ollama1:
    image: ollama/ollama:latest
    ports:
      - "11435:11434"
    volumes:
      - ollama1_data:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0:11434
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G

  # Service 2: Lightweight model
  ollama2:
    image: ollama/ollama:latest
    ports:
      - "11436:11434"
    volumes:
      - ollama2_data:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0:11434
    deploy:
      resources:
        limits:
          memory: 3G
        reservations:
          memory: 2G

volumes:
  ollama1_data:
  ollama2_data:
```

---

## Step 2: Start Docker Containers

### Build and Start

```bash
# Navigate to project directory
cd \\wsl.localhost\Ubuntu-24.04\home\ashish\project\AgentStack

# Start containers in foreground (for debugging)
docker-compose up

# OR start in background (recommended)
docker-compose up -d
```

### Expected Output

```
Creating network "agentstack_default" with the default driver
Creating agentstack_ollama1_1 ... done
Creating agentstack_ollama2_1 ... done
```

---

## Step 3: Verify Containers Are Running

```bash
docker ps
```

### Expected Output

```
CONTAINER ID   IMAGE                 PORTS                   STATUS
a1b2c3d4e5f6   ollama/ollama:latest  0.0.0.0:11435->11434   Up 2 minutes
g7h8i9j0k1l2   ollama/ollama:latest  0.0.0.0:11436->11434   Up 2 minutes
```

---

## Step 4: Download Models to Each Container

### Terminal 1: Download model to ollama1 (Port 11435)

```bash
curl http://localhost:11435/api/pull -d '{"name": "qwen2.5:0.5b"}'
```

**Streaming Output:**
```
{"status":"pulling manifest"}
{"status":"downloading","digest":"sha256:...","total":...,"completed":...}
...
{"status":"success"}
```

### Terminal 2: Download model to ollama2 (Port 11436)

```bash
curl http://localhost:11436/api/pull -d '{"name": "phi3:mini"}'
```

**Wait for both to complete** (5-10 minutes depending on internet speed)

---

## Step 5: Verify Models Are Downloaded

### Check Container 1

```bash
curl http://localhost:11435/api/tags
```

### Check Container 2

```bash
curl http://localhost:11436/api/tags
```

### Expected Response (for each)

```json
{
  "models": [
    {
      "name": "qwen2.5:0.5b",
      "modified_at": "2025-01-15T10:30:00Z",
      "size": 350000000,
      "digest": "..."
    }
  ]
}
```

---

## Step 6: Test Models

### Test Container 1 (qwen2.5:0.5b on port 11435)

```bash
curl http://localhost:11435/api/generate -d '{
  "model": "qwen2.5:0.5b",
  "prompt": "What is Docker?",
  "stream": false
}' | jq '.response'
```

### Test Container 2 (phi3:mini on port 11436)

```bash
curl http://localhost:11436/api/generate -d '{
  "model": "phi3:mini",
  "prompt": "What is Docker?",
  "stream": false
}' | jq '.response'
```

---

## Docker Container Ports Mapping

This is important for LiteLLM configuration:

| Service | Container Port | Host Port | Accessible At |
|---------|----------------|-----------|----------------|
| ollama1 | 11434 | 11435 | http://localhost:11435 |
| ollama2 | 11434 | 11436 | http://localhost:11436 |
| Native Ollama | 11434 | 11434 | http://localhost:11434 |

---

## Docker-Compose Useful Commands

### View Logs

```bash
# All containers
docker-compose logs

# Specific container
docker-compose logs ollama1

# Follow logs in real-time
docker-compose logs -f ollama2
```

### Stop Containers

```bash
docker-compose stop
```

### Start Containers Again

```bash
docker-compose start
```

### Remove Containers (keep volumes)

```bash
docker-compose down
```

### Remove Everything (including data)

```bash
docker-compose down -v
```

### Restart Services

```bash
docker-compose restart
```

---

## Resource Management

### Check Container Resource Usage

```bash
docker stats
```

### Example Output

```
CONTAINER           CPU %   MEM USAGE / LIMIT
agentstack_ollama1  25.5%   1.2G / 2G
agentstack_ollama2  15.3%   1.8G / 3G
```

### Adjust Memory Limits (in docker-compose.yml)

```yaml
deploy:
  resources:
    limits:
      memory: 2G        # Hard limit
    reservations:
      memory: 1G        # Soft limit (minimum reserved)
```

---

## Volumes & Data Persistence

Models are stored in volumes:

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect agentstack_ollama1_data

# View volume location
docker volume inspect agentstack_ollama1_data | grep Mountpoint
```

Models persist even if containers are stopped/removed (unless you use `docker-compose down -v`)

---

## Networking

Containers in docker-compose automatically share a network:

```
Container A (ollama1) → Can reach Container B (ollama2) on port 11434
```

But from host machine:
```
Host → localhost:11435 → ollama1
Host → localhost:11436 → ollama2
```

**For LiteLLM:**
- If LiteLLM is in Docker: `http://ollama1:11434`, `http://ollama2:11434`
- If LiteLLM is on Host: `http://localhost:11435`, `http://localhost:11436`

---

## Complete Testing Script

Create `scripts/test_docker_models.sh`:

```bash
#!/bin/bash

echo "🐳 Testing Docker-Based LLM Models"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Check Container 1
echo -e "${BLUE}Checking ollama1 (port 11435)...${NC}"
if curl -s http://localhost:11435/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}✅ ollama1 is running${NC}"
    curl -s http://localhost:11435/api/tags | jq '.models[] | .name'
else
    echo -e "${RED}❌ ollama1 is NOT running${NC}"
fi
echo ""

# Check Container 2
echo -e "${BLUE}Checking ollama2 (port 11436)...${NC}"
if curl -s http://localhost:11436/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}✅ ollama2 is running${NC}"
    curl -s http://localhost:11436/api/tags | jq '.models[] | .name'
else
    echo -e "${RED}❌ ollama2 is NOT running${NC}"
fi
echo ""

# Test both models
echo -e "${BLUE}Testing both models with same prompt...${NC}"
PROMPT="Explain AI in one sentence"

echo -e "${GREEN}Model 1 (qwen2.5:0.5b):${NC}"
curl -s http://localhost:11435/api/generate -d "{\"model\": \"qwen2.5:0.5b\", \"prompt\": \"$PROMPT\", \"stream\": false}" | jq '.response'

echo -e "${GREEN}Model 2 (phi3:mini):${NC}"
curl -s http://localhost:11436/api/generate -d "{\"model\": \"phi3:mini\", \"prompt\": \"$PROMPT\", \"stream\": false}" | jq '.response'
```

Run it:
```bash
chmod +x scripts/test_docker_models.sh
./scripts/test_docker_models.sh
```

---

## Hybrid Approach: Native + Docker

You can run **both** native Ollama AND docker containers:

```
Port 11434 → Native Ollama (WSL Ubuntu)
Port 11435 → Docker Container 1 (qwen2.5:0.5b)
Port 11436 → Docker Container 2 (phi3:mini)
```

LiteLLM can connect to all 3 and route requests appropriately!

---

## Troubleshooting

### Port Already in Use

```bash
# Find what's using port 11435
sudo lsof -i :11435

# Kill the process
sudo kill <PID>
```

### Docker Not Running

```bash
# Start Docker daemon
sudo service docker start

# Or on Windows, start Docker Desktop
```

### Container Won't Start

```bash
# Check logs
docker-compose logs ollama1

# Try restarting
docker-compose restart ollama1
```

### Models Not Downloading

```bash
# Check if container has internet
docker exec agentstack_ollama1 ping -c 2 google.com

# Manual pull inside container
docker exec agentstack_ollama1 ollama pull qwen2.5:0.5b
```

---

## Next Steps

1. ✅ Create docker-compose.yml
2. ✅ Start containers
3. ✅ Download models
4. ✅ Test models work
5. ➡️ Move to Phase 2: Create LiteLLM Backend Server (will use all 3 endpoints)

