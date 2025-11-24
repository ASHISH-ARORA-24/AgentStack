# Quick Reference Guide - AgentStack Commands

## Essential Docker Commands

### Check Status
```bash
# List containers
docker ps | grep agentstack_ollama

# Check logs
docker logs agentstack_ollama1 -f
docker logs agentstack_ollama2 -f

# View all logs
docker-compose logs -f
```

### Manage Containers
```bash
# Start containers
docker-compose up -d

# Stop containers (keeps models)
docker-compose stop

# Start containers again
docker-compose start

# Restart
docker-compose restart

# Remove containers (keeps models in volumes)
docker-compose down

# Remove everything including data
docker-compose down -v
```

---

## Testing & Verification

### Check Models Available
```bash
# Container 1 (Port 11435)
curl http://localhost:11435/api/tags

# Container 2 (Port 11436)
curl http://localhost:11436/api/tags
```

### Test Model Generation
```bash
# Simple test
curl http://localhost:11435/api/generate \
  -d '{"model":"qwen2.5:0.5b","prompt":"Hello","stream":false}'

# With options
curl http://localhost:11435/api/generate \
  -d '{
    "model":"qwen2.5:0.5b",
    "prompt":"What is AI?",
    "stream":false,
    "temperature":0.7
  }'
```

### Run Test Scripts
```bash
# Test Docker models
./scripts/test_docker_models.sh

# Or individual tests
bash scripts/test_docker_models.sh
```

---

## Monitoring

### Container Health
```bash
# Real-time stats
docker stats agentstack_ollama1 agentstack_ollama2

# One-time check
docker stats --no-stream
```

### Check API Health
```bash
# Quick check
curl -s http://localhost:11435/api/tags > /dev/null && echo "✅ Container 1 OK" || echo "❌ Container 1 Down"
curl -s http://localhost:11436/api/tags > /dev/null && echo "✅ Container 2 OK" || echo "❌ Container 2 Down"
```

---

## Common Issues

### Container Not Responding
```bash
# Restart
docker-compose restart

# Check logs
docker logs agentstack_ollama1
```

### High Memory Usage
```bash
# Check which container
docker stats

# Restart the heavy one
docker-compose restart ollama2
```

### Port Already in Use
```bash
# Find what's using the port
sudo lsof -i :11435

# Kill it
sudo kill -9 <PID>
```

### Download Stuck
```bash
# Monitor progress
docker logs agentstack_ollama2 -f | grep -i download

# Restart if needed
docker-compose restart ollama2
```

---

## Development Workflow

### Check Everything is OK
```bash
docker ps | grep agentstack_ollama
curl http://localhost:11435/api/tags 2>/dev/null | grep name
curl http://localhost:11436/api/tags 2>/dev/null | grep name
```

### Test New Changes
```bash
# For LiteLLM (when ready)
curl http://localhost:8000/health
curl http://localhost:8000/v1/chat/completions \
  -d '{"model":"qwen2.5:0.5b","messages":[...]}'
```

### Monitor Requests
```bash
# Watch container logs in real-time
docker logs -f agentstack_ollama1
docker logs -f agentstack_ollama2
```

---

## Performance Testing

### Measure Response Time
```bash
# Simple test
time curl http://localhost:11435/api/generate \
  -d '{"model":"qwen2.5:0.5b","prompt":"Hello","stream":false}' \
  -o /dev/null

# With more detail
curl -w "\nTime taken: %{time_total}s\n" \
  http://localhost:11435/api/generate \
  -d '{"model":"qwen2.5:0.5b","prompt":"Hello","stream":false}'
```

### Load Testing
```bash
# Install Apache Bench
sudo apt-get install apache2-utils

# Test 100 requests with 10 concurrent
ab -n 100 -c 10 http://localhost:11435/api/tags
```

---

## Docker Compose Commands Reference

```bash
# Build images (if needed)
docker-compose build

# Start
docker-compose up -d

# Stop
docker-compose stop

# Start again
docker-compose start

# Restart
docker-compose restart

# View logs
docker-compose logs -f

# Execute command in container
docker-compose exec ollama1 ollama list

# Down (remove containers)
docker-compose down

# Down (remove everything including volumes)
docker-compose down -v

# Config check
docker-compose config

# List services
docker-compose ps
```

---

## File Locations

### Models Storage
```bash
# Container 1 models
/var/lib/docker/volumes/agentstack_ollama1_data/_data

# Container 2 models
/var/lib/docker/volumes/agentstack_ollama2_data/_data

# View volumes
docker volume ls | grep agentstack
docker volume inspect agentstack_ollama1_data
```

### Config Files
```bash
docker-compose.yml      # Container configuration
backend/                # LiteLLM server (Phase 2)
frontend/               # Streamlit app (Phase 3)
docs/                   # Documentation
scripts/                # Helper scripts
```

---

## Useful Aliases (Optional)

Add to your `~/.bashrc`:

```bash
# Docker shortcuts
alias dc='docker-compose'
alias dps='docker ps | grep agentstack'
alias dlogs1='docker logs agentstack_ollama1 -f'
alias dlogs2='docker logs agentstack_ollama2 -f'
alias dtest='./scripts/test_docker_models.sh'

# Test models
alias test1='curl http://localhost:11435/api/tags'
alias test2='curl http://localhost:11436/api/tags'
```

Then use: `dps`, `dlogs1`, `dtest`, etc.

---

## Phase 2 Preview (LiteLLM)

```bash
# Start LiteLLM server
python backend/litellm_server.py

# Health check
curl http://localhost:8000/health

# List models
curl http://localhost:8000/v1/models

# Chat completion
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5:0.5b",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

---

## Emergency Restart

If everything breaks:

```bash
# Stop everything
docker-compose down

# Check docker daemon
docker ps

# Restart docker
sudo systemctl restart docker

# Start again
docker-compose up -d

# Verify
docker ps
curl http://localhost:11435/api/tags
```

---

**Bookmark this page for quick reference!**
