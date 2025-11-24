# Docker & Docker Compose Installation Guide for WSL Ubuntu

## Problem

You're getting this error:
```
Command 'docker-compose' not found
```

This means Docker and/or Docker Compose are not installed in your WSL Ubuntu environment.

---

## Solution: Automated Installation

### Option 1: Use the Setup Script (Easiest)

```bash
# Navigate to project
cd ~/project/AgentStack

# Make script executable
chmod +x scripts/setup_docker.sh

# Run the installation script
bash scripts/setup_docker.sh
```

The script will:
- ✅ Install Docker Engine
- ✅ Install Docker Compose (standalone)
- ✅ Add your user to the docker group
- ✅ Start Docker service
- ✅ Verify installation

**After installation, log out and log back in:**
```bash
logout
# Log back into WSL
```

---

## Solution: Manual Installation (If Script Fails)

### Step 1: Update Package Manager

```bash
sudo apt update
```

### Step 2: Install Dependencies

```bash
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

### Step 3: Add Docker GPG Key

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

### Step 4: Add Docker Repository

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Step 5: Update Again

```bash
sudo apt update
```

### Step 6: Install Docker Engine

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Step 7: Install Docker Compose (Standalone)

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Step 8: Add User to Docker Group

```bash
sudo usermod -aG docker $USER
```

### Step 9: Start Docker Service

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Step 10: Log Out and Back In

```bash
logout
# Log back into WSL
```

---

## Verification

### Check Docker

```bash
docker --version
```

**Expected Output:**
```
Docker version 24.x.x, build xxxxx
```

### Check Docker Compose

```bash
docker-compose --version
```

**Expected Output:**
```
Docker Compose version 2.x.x
```

### Test Docker

```bash
docker run hello-world
```

**Expected Output:**
```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
...
Hello from Docker!
...
```

---

## Now Start Your Containers

### Navigate to Project

```bash
cd ~/project/AgentStack
```

### Start Containers

```bash
docker-compose up -d
```

**Expected Output:**
```
Creating network "agentstack_default" with the default driver
Creating agentstack_ollama1_1 ... done
Creating agentstack_ollama2_1 ... done
```

### Verify Containers Running

```bash
docker-compose ps
```

**Expected Output:**
```
NAME                    IMAGE                   STATUS              PORTS
agentstack_ollama1_1    ollama/ollama:latest    Up 2 seconds       0.0.0.0:11435->11434/tcp
agentstack_ollama2_1    ollama/ollama:latest    Up 1 second        0.0.0.0:11436->11434/tcp
```

---

## Troubleshooting

### Error: "Cannot connect to Docker daemon"

**Cause:** Docker service is not running

**Solution:**
```bash
sudo systemctl start docker
```

### Error: "Got permission denied"

**Cause:** User not in docker group

**Solution:**
```bash
sudo usermod -aG docker $USER
logout
# Log back in
```

### Error: "docker-compose: command not found"

**Cause:** Docker Compose not installed or not in PATH

**Solution (check if installed):**
```bash
which docker-compose
```

**If not found, reinstall:**
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

### Containers Won't Start

**Check logs:**
```bash
docker-compose logs
```

**Restart:**
```bash
docker-compose restart
```

**Rebuild from scratch:**
```bash
docker-compose down -v
docker-compose up -d
```

---

## Using Docker Compose

### Common Commands

```bash
# Start containers in background
docker-compose up -d

# View logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f ollama1

# Stop containers
docker-compose stop

# Start stopped containers
docker-compose start

# Restart containers
docker-compose restart

# Remove containers (keep volumes)
docker-compose down

# Remove everything including volumes
docker-compose down -v

# Check status
docker-compose ps

# Run command in container
docker-compose exec ollama1 ollama list
```

---

## Next: Download Models

Once containers are running, download the models:

### Terminal 1: Pull qwen2.5:0.5b to ollama1

```bash
curl http://localhost:11435/api/pull -d '{"name": "qwen2.5:0.5b"}'
```

### Terminal 2: Pull phi3:mini to ollama2

```bash
curl http://localhost:11436/api/pull -d '{"name": "phi3:mini"}'
```

### Verify

```bash
# Check ollama1
curl http://localhost:11435/api/tags | jq '.models[].name'

# Check ollama2
curl http://localhost:11436/api/tags | jq '.models[].name'
```

### Test Models

```bash
# Test ollama1
curl http://localhost:11435/api/generate -d '{
  "model": "qwen2.5:0.5b",
  "prompt": "What is Docker?",
  "stream": false
}' | jq '.response'

# Test ollama2
curl http://localhost:11436/api/generate -d '{
  "model": "phi3:mini",
  "prompt": "What is Docker?",
  "stream": false
}' | jq '.response'
```

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `docker-compose up -d` | Start containers in background |
| `docker-compose down` | Stop and remove containers |
| `docker-compose ps` | List running containers |
| `docker-compose logs` | View container logs |
| `docker ps` | List all running containers |
| `docker stats` | Show resource usage |
| `docker-compose exec <service> <cmd>` | Run command in container |

---

## Alternative: Docker Desktop (Windows Host Only)

If you prefer a GUI, you can use **Docker Desktop for Windows**:

1. Download from: https://www.docker.com/products/docker-desktop
2. Install on Windows host
3. Enable WSL 2 integration
4. docker-compose will work from WSL

---

## Next Steps

Once Docker and Docker Compose are installed and containers are running:

1. ✅ Install Docker & Docker Compose
2. ✅ Start containers with `docker-compose up -d`
3. ✅ Download models to each container
4. ✅ Test models work
5. ➡️ Move to Phase 2: Create LiteLLM Backend Server

See: `docs/02_LITELLM_BACKEND.md`
