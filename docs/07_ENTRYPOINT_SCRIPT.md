# Entrypoint Script Implementation

## Overview

The `entrypoint.sh` script provides intelligent model initialization for Docker containers with these key features:

- ✅ **Smart startup**: Ollama starts and is ready in seconds
- ✅ **Asynchronous downloads**: Models download in background while container runs
- ✅ **Smart detection**: If models already exist, skips download (instant startup on restart)
- ✅ **Colored output**: Easy to read logs with color-coded messages
- ✅ **Retry logic**: Handles network failures gracefully
- ✅ **Progress tracking**: Monitors and logs download status

## How It Works

### Startup Sequence

1. **Container starts** → Entrypoint script executes
2. **Ollama service starts** → Background process begins
3. **Waits for readiness** → Checks API availability (max 30 attempts)
4. **Model check** → Verifies if model already loaded
5. **Conditional download** → Only downloads if model missing
6. **Container ready** → Can accept API calls immediately

### Fast Restart Behavior

**First start (no models):**
```
docker-compose up -d
↓
Containers start (5 seconds)
↓
Models download asynchronously
↓
Ready to use in ~20-30 minutes (Qwen), depends on model size
```

**Subsequent restarts (models exist):**
```
docker-compose down
↓
docker-compose up -d
↓
Containers start (5 seconds)
↓
Models already in volumes
↓
Ready to use IMMEDIATELY (same second)
```

## Configuration

### Environment Variables

```yaml
environment:
  - OLLAMA_HOST=0.0.0.0:11434    # API listen address
  - MODEL_NAME=qwen2.5:0.5b       # Model to auto-download
```

Each container has different `MODEL_NAME`:
- **Container 1**: `MODEL_NAME=llama3.2:1b`
- **Container 2**: `MODEL_NAME=qwen2.5:0.5b`
- **Container 3**: `MODEL_NAME=phi3:mini`

### Logging

Logs are written to:
- `/tmp/ollama_model_download.log` - Main log
- `/tmp/ollama_downloads/*.log` - Individual model download logs

View logs:
```bash
# Container logs
docker logs agentstack_qwen2.5

# Live download logs (inside container)
tail -f /tmp/ollama_downloads/*.log
```

## Key Features

### 1. **Smart Ollama Readiness Check**
```bash
Attempts up to 30 times with 2-second delays
Confirms API is responding before proceeding
Fails gracefully if Ollama won't start
```

### 2. **Asynchronous Model Downloads**
```bash
Models download in background
Container stays operational
Multiple models can download in parallel
```

### 3. **Model Deduplication**
```bash
Checks if model already loaded
Skips download if found (instant startup on restart)
Saves bandwidth and time
```

### 4. **Retry Logic**
```bash
3 retry attempts per model
5-second delay between retries
Handles temporary network failures
```

### 5. **Color-Coded Output**
```
[INFO]    - Blue - Informational messages
[SUCCESS] - Green - Successful operations
[WARNING] - Yellow - Warning/retry messages
[ERROR]   - Red - Failure messages
```

## Docker Compose Integration

```yaml
ollama_qwen:
  image: ollama/ollama:latest
  container_name: agentstack_qwen2.5
  ports:
    - "11435:11434"
  volumes:
    - ollama_qwen_data:/root/.ollama
    - ./scripts/entrypoint.sh:/entrypoint.sh  # Mount script
  environment:
    - OLLAMA_HOST=0.0.0.0:11434
    - MODEL_NAME=qwen2.5:0.5b
  entrypoint: bash /entrypoint.sh  # Use custom entrypoint
  restart: unless-stopped
```

## Use Cases

### Development (Fresh Container)
```bash
docker-compose up -d
# Wait 20-30 minutes for models to download
# Use container with all models ready
```

### Production (Restart)
```bash
docker-compose down
docker-compose up -d
# Instant availability (5 seconds)
# Models already persisted in volumes
```

### Model Updates
```bash
# Change MODEL_NAME in docker-compose.yml
docker-compose up -d
# New model downloads, old models still available
```

## Troubleshooting

### Models not downloading?
```bash
# Check container logs
docker logs agentstack_qwen2.5 | grep -i download

# Manually download inside container
docker exec agentstack_qwen2.5 ollama pull qwen2.5:0.5b
```

### Ollama service not starting?
```bash
# Check full logs
docker logs agentstack_qwen2.5

# Restart container
docker-compose restart agentstack_qwen2.5
```

### Check download progress
```bash
# View individual download logs
docker exec agentstack_qwen2.5 tail -f /tmp/ollama_downloads/*.log
```

## Performance Characteristics

| Operation | Time | Notes |
|-----------|------|-------|
| First `docker-compose up` | ~30 seconds | Container starts, waits for Ollama |
| Model download (Qwen 0.5B) | ~3-5 minutes | 397 MB, network dependent |
| Model download (Llama 1B) | ~5-10 minutes | 1.3 GB, network dependent |
| Model download (Phi 3) | ~10-15 minutes | 2.3 GB, network dependent |
| `docker-compose down` | ~5 seconds | Clean shutdown |
| `docker-compose up` (after down) | ~10 seconds | Models already present |

## Comparison: Before vs After

### Before (Manual Downloads)
```
docker-compose up -d
↓
curl http://localhost:11435/api/pull -d '{"name":"qwen2.5:0.5b"}'
↓
Manual wait and monitoring
↓
Works after download completes
```

### After (Entrypoint Script)
```
docker-compose up -d
↓
Entrypoint detects no model
↓
Automatically downloads in background
↓
Works immediately + download happens
```

## Summary

The entrypoint script enables:
- ✅ **Faster startup** - No manual curl commands needed
- ✅ **Flexible restarts** - Instant if models exist
- ✅ **Background downloads** - Container ready while downloading
- ✅ **Intelligent behavior** - Skips redundant downloads
- ✅ **Better logging** - Clear visibility into what's happening
- ✅ **Production-ready** - Handles failures gracefully
