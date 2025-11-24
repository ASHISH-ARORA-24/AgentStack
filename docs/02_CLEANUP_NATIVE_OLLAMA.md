# Cleanup: Remove Native Ollama & Switch to Docker-Only

## Current State

You have models running in **both**:
- Native Ollama on WSL (Port 11434)
  - llama3.2:1b (1.3 GB)
  - qwen2.5:0.5b (397 MB)
  - phi3:mini (2.2 GB)

- Docker Containers
  - ollama1 (Port 11435)
  - ollama2 (Port 11436)

## Goal

**Keep ONLY Docker setup** - Remove native Ollama to save space & simplify management

---

## Step 1: Stop Native Ollama Service

```bash
# Kill Ollama service
sudo systemctl stop ollama

# Remove from autostart (optional)
sudo systemctl disable ollama

# Verify it's stopped
ps aux | grep ollama
```

---

## Step 2: Remove Native Ollama Models

### Remove Individual Models

```bash
# Remove all models
ollama rm llama3.2:1b
ollama rm qwen2.5:0.5b
ollama rm phi3:mini

# Verify deletion
ollama list
```

### Remove Ollama Data Directory (Complete Cleanup)

```bash
# This removes ALL Ollama data including models
rm -rf ~/.ollama/

# Verify
ls -la ~/.ollama/  # Should not exist or be empty
```

---

## Step 3: Uninstall Native Ollama (Optional)

If you want to completely remove Ollama:

```bash
# Remove Ollama binary
sudo rm -rf /usr/local/bin/ollama

# Remove Ollama user and group
sudo userdel ollama
sudo groupdel ollama

# Verify
which ollama  # Should return "not found"
```

---

## Step 4: Verify Docker Setup is Working

```bash
# Check containers
docker ps

# Check models in container 1
curl http://localhost:11435/api/tags | jq '.models[].name'

# Check models in container 2
curl http://localhost:11436/api/tags | jq '.models[].name'
```

---

## Step 5: Verify No Port Conflicts

```bash
# Should show only docker containers, not native ollama
sudo lsof -i :11434
sudo lsof -i :11435
sudo lsof -i :11436
```

---

## Cleanup Commands Summary

Run these in order:

```bash
# Stop native Ollama
sudo systemctl stop ollama

# Remove models
ollama rm llama3.2:1b
ollama rm qwen2.5:0.5b
ollama rm phi3:mini

# Remove data
rm -rf ~/.ollama/

# Verify docker containers are working
docker ps
curl http://localhost:11435/api/tags
curl http://localhost:11436/api/tags
```

---

## Space Saved

- **llama3.2:1b**: 1.3 GB
- **qwen2.5:0.5b**: 397 MB
- **phi3:mini**: 2.2 GB
- **Total**: ~3.9 GB freed up

---

## New Setup (Docker-Only)

After cleanup, you'll have:

```
Port 11435 → Docker Container 1
  - qwen2.5:0.5b (397 MB) - Very Fast

Port 11436 → Docker Container 2
  - phi3:mini (2.2 GB) - Fast
```

**Total Docker Size**: ~2.6 GB (models only, excludes container overhead)

---

## Restart If Needed

If you stop containers:

```bash
# Restart Docker containers
docker-compose up -d

# Models are already in volumes, no need to re-download
curl http://localhost:11435/api/tags
curl http://localhost:11436/api/tags
```

---

## Important Notes

⚠️ **Before you delete:**
- Make sure Docker containers are running (`docker-compose up -d`)
- Make sure models are already in Docker (`docker exec agentstack_ollama1 ollama list`)
- Docker volumes will persist the models

✅ **After cleanup:**
- Docker setup is your only LLM source
- Simpler to manage
- Uses less disk space
- All services will connect to ports 11435 & 11436
