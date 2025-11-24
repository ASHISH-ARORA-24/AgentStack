# Phase 1: Complete LLM Setup Guide (Native + Docker)

## Overview

This guide shows how to set up LLM models in **TWO WAYS**:

1. **Native Ollama** - Run directly on WSL Ubuntu (Port 11434)
2. **Docker Containers** - Run in isolated containers (Ports 11435, 11436)

You can use **either approach or both together** for a hybrid setup!

---

## Comparison: Native vs Docker

| Feature | Native Ollama | Docker Containers |
|---------|---------------|-------------------|
| **Performance** | Excellent | Good |
| **Setup** | Simple | Slightly complex |
| **Isolation** | None | Complete |
| **Resource Control** | Manual | Automated |
| **Multiple Models** | Can mix | Easy to scale |
| **Persistence** | System folders | Docker volumes |
| **Easy Cleanup** | Manual | `docker-compose down` |

---

## Option A: Native Ollama Setup (Recommended First)

**Use this if you want:**
- Simplest setup
- Direct WSL control
- Single model per terminal

### Quick Start

```bash
# Step 1: Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Step 2: Start Ollama in background
ollama serve &

# Step 3: Download models
ollama pull llama3.2:1b
ollama pull qwen2.5:0.5b
ollama pull phi3:mini

# Step 4: Verify
ollama list
```

**Available at**: `http://localhost:11434`

See detailed guide: `docs/01_OLLAMA_SETUP.md`

---

## Option B: Docker Container Setup

**Use this if you want:**
- Easy scaling
- Resource isolation
- Multiple concurrent models
- Clean setup/teardown

### Quick Start

```bash
# Step 1: Navigate to project
cd \\wsl.localhost\Ubuntu-24.04\home\ashish\project\AgentStack

# Step 2: Start containers
docker-compose up -d

# Step 3: Download models
curl http://localhost:11435/api/pull -d '{"name": "qwen2.5:0.5b"}'
curl http://localhost:11436/api/pull -d '{"name": "phi3:mini"}'

# Step 4: Test
./scripts/test_docker_models.sh
```

**Available at:**
- Container 1: `http://localhost:11435` (qwen2.5:0.5b)
- Container 2: `http://localhost:11436` (phi3:mini)

See detailed guide: `docs/01b_DOCKER_COMPOSE_SETUP.md`

---

## Option C: Hybrid Setup (Recommended for Learning)

Run **BOTH** native and Docker for maximum flexibility!

```
Port 11434 → Native Ollama (llama3.2:1b + others)
Port 11435 → Docker Container 1 (qwen2.5:0.5b)
Port 11436 → Docker Container 2 (phi3:mini)
```

### Hybrid Setup Steps

**Terminal 1: Start Native Ollama**
```bash
ollama serve &
ollama pull llama3.2:1b
```

**Terminal 2: Start Docker Containers**
```bash
docker-compose up -d
curl http://localhost:11435/api/pull -d '{"name": "qwen2.5:0.5b"}'
curl http://localhost:11436/api/pull -d '{"name": "phi3:mini"}'
```

**Terminal 3: Verify All 3**
```bash
# Check native
curl http://localhost:11434/api/tags | jq '.models[].name'

# Check docker 1
curl http://localhost:11435/api/tags | jq '.models[].name'

# Check docker 2
curl http://localhost:11436/api/tags | jq '.models[].name'
```

---

## Testing All Models

### Test Native (Port 11434)

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:1b",
  "prompt": "What is AI?",
  "stream": false
}' | jq '.response'
```

### Test Docker 1 (Port 11435)

```bash
curl http://localhost:11435/api/generate -d '{
  "model": "qwen2.5:0.5b",
  "prompt": "What is AI?",
  "stream": false
}' | jq '.response'
```

### Test Docker 2 (Port 11436)

```bash
curl http://localhost:11436/api/generate -d '{
  "model": "phi3:mini",
  "prompt": "What is AI?",
  "stream": false
}' | jq '.response'
```

### Automated Testing

```bash
# Test native models
./scripts/test_models.sh

# Test docker models
./scripts/test_docker_models.sh
```

---

## Available Resources

| Port | Source | Models | Setup Time |
|------|--------|--------|------------|
| 11434 | Native Ollama | Any | ~2 min install + 10-20 min download |
| 11435 | Docker 1 | qwen2.5:0.5b | ~5 min download |
| 11436 | Docker 2 | phi3:mini | ~10 min download |

**Total Size**: ~3.3 GB (all models)
**Total RAM**: ~5-6 GB (concurrent)
**Disk**: ~4.5 GB

---

## LiteLLM Integration

In Phase 2, LiteLLM will connect to **all available endpoints**:

```python
# LiteLLM can route to any model
models_available = [
    "ollama/llama3.2:1b",      # From port 11434
    "ollama/qwen2.5:0.5b",     # From port 11435
    "ollama/phi3:mini",        # From port 11436
]
```

---

## Troubleshooting

### Port Already in Use

```bash
# Find what's using port
sudo lsof -i :11434

# Kill process
sudo kill <PID>
```

### Docker Not Available

```bash
# Check if Docker is installed
docker --version

# If not, install Docker Desktop
# Download: https://www.docker.com/products/docker-desktop
```

### Models Not Downloading

```bash
# For Native
ollama pull llama3.2:1b -v

# For Docker
docker logs agentstack_ollama1 | tail -20
```

### Container Won't Start

```bash
# Check logs
docker-compose logs

# Restart
docker-compose restart

# Rebuild
docker-compose down && docker-compose up -d
```

---

## Next Phase

Once you have at least **one endpoint working** (native OR docker):

**Phase 2: Create LiteLLM Backend Server**
- Creates a unified proxy for all models
- Standardizes API across models
- Enables easy model switching

See: `docs/02_LITELLM_BACKEND.md`

---

## Quick Decision Guide

Choose your approach:

```
👤 Single user, learning:
   → Use NATIVE OLLAMA (simplest)

🚀 Want to scale, multiple models:
   → Use DOCKER CONTAINERS

🎓 Learning full stack, want options:
   → Use HYBRID (both native + docker)
```

---

## File Reference

- **Documentation**
  - `docs/01_OLLAMA_SETUP.md` - Native Ollama detailed guide
  - `docs/01b_DOCKER_COMPOSE_SETUP.md` - Docker setup detailed guide

- **Configuration**
  - `docker-compose.yml` - Docker container configuration
  - `pyproject.toml` - Python dependencies

- **Scripts**
  - `scripts/test_models.sh` - Test native Ollama
  - `scripts/test_docker_models.sh` - Test Docker containers

- **This File**
  - `docs/01_COMPLETE_LLM_SETUP.md` - Overview & integration guide
