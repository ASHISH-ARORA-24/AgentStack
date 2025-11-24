# Phase 2: LiteLLM Backend Server - Planning & Architecture

## Overview

LiteLLM acts as a **unified proxy** between your Streamlit frontend and the Docker-based Ollama models.

```
User (Streamlit)
      ↓
   [Chat Input]
      ↓
LiteLLM Proxy (8000)
      ↓
┌─────┴──────────┐
│                │
Docker 1    Docker 2
(11435)     (11436)
qwen2.5     phi3:mini
```

---

## Why LiteLLM?

1. **Unified API** - Single endpoint for multiple models
2. **Model Switching** - Easy to switch between models
3. **OpenAI Compatible** - Works with any OpenAI-compatible client
4. **Logging & Monitoring** - Track all requests
5. **Error Handling** - Graceful fallbacks
6. **Cost Tracking** - (Not needed for local, but available)

---

## Architecture

### Components

| Component | Port | Purpose |
|-----------|------|---------|
| Docker Container 1 | 11435 | qwen2.5:0.5b |
| Docker Container 2 | 11436 | phi3:mini |
| LiteLLM Proxy | 8000 | Unified API |
| Streamlit Frontend | 8501 | Chat UI |

### Request Flow

```
Streamlit (8501)
    │ POST /chat
    │ {model: "qwen2.5:0.5b", messages: [...]}
    ▼
LiteLLM (8000)
    │ Route to correct container
    │ http://localhost:11435 or 11436
    ▼
Docker Container (11435/11436)
    │ Run model inference
    ▼
Response → Stream back → Streamlit
```

---

## LiteLLM Installation

### Option 1: pip install (Simplest)

```bash
pip install litellm fastapi uvicorn python-dotenv
```

### Option 2: In Docker (Advanced)

Would require third Dockerfile, adds complexity. **Not recommended for learning.**

---

## LiteLLM Configuration

### Config File Structure

`backend/litellm_config.yaml`:

```yaml
# Model definitions
models:
  - model_name: qwen2.5:0.5b
    litellm_params:
      model: "ollama/qwen2.5:0.5b"
      api_base: "http://localhost:11435"

  - model_name: phi3:mini
    litellm_params:
      model: "ollama/phi3:mini"
      api_base: "http://localhost:11436"

# Router settings
router_settings:
  enable_logging: true
  timeout: 300
  fallback_model: "qwen2.5:0.5b"  # If one fails
```

---

## Backend Server Structure

### Directory Layout

```
backend/
├── litellm_server.py       # Main FastAPI server
├── config.py               # Configuration
├── models.py               # Model definitions
├── routes.py               # API routes
├── requirements.txt        # Dependencies
└── litellm_config.yaml     # LiteLLM config
```

### Main Server (litellm_server.py)

```python
from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
import litellm
from typing import List, Dict

app = FastAPI(title="AgentStack LiteLLM Proxy")

# Configure models
litellm.drop_params = True

@app.post("/v1/chat/completions")
async def chat_completion(request: dict):
    """Route to appropriate model based on request"""
    
    model = request.get("model", "qwen2.5:0.5b")
    messages = request.get("messages", [])
    stream = request.get("stream", False)
    
    # Route based on model selection
    model_endpoints = {
        "qwen2.5:0.5b": "http://localhost:11435",
        "phi3:mini": "http://localhost:11436"
    }
    
    # Make request to appropriate container
    response = litellm.completion(
        model=f"ollama/{model}",
        messages=messages,
        stream=stream,
        api_base=model_endpoints.get(model)
    )
    
    return response

@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "containers": {
            "qwen2.5:0.5b": "http://localhost:11435",
            "phi3:mini": "http://localhost:11436"
        }
    }
```

---

## API Endpoints

### POST /v1/chat/completions (Main endpoint)

**Request:**
```json
{
  "model": "qwen2.5:0.5b",
  "messages": [
    {"role": "user", "content": "Hello!"}
  ],
  "stream": false,
  "temperature": 0.7
}
```

**Response:**
```json
{
  "id": "chatcmpl-12345",
  "object": "text_completion",
  "created": 1234567890,
  "model": "qwen2.5:0.5b",
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "Hello! How can I help you today?"
      }
    }
  ]
}
```

### GET /health

Check status of all models and containers.

### GET /models

List available models and their details.

---

## Testing LiteLLM Locally

### Manual Test Commands

```bash
# Start server
python backend/litellm_server.py

# In another terminal, test:
curl http://localhost:8000/health

curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5:0.5b",
    "messages": [{"role": "user", "content": "Hello"}],
    "stream": false
  }'
```

---

## Common Issues & Solutions

### Issue: LiteLLM can't connect to Docker containers

**Solution:**
```bash
# Verify containers are running
docker ps | grep agentstack_ollama

# Test direct connection
curl http://localhost:11435/api/tags
curl http://localhost:11436/api/tags
```

### Issue: Model not found

**Solution:**
- Check model is downloaded: `curl http://localhost:11435/api/tags`
- Verify model name in config matches exactly

### Issue: Timeout errors

**Solution:**
- Increase timeout in config (default 300s)
- Check if containers are responding: `docker logs agentstack_ollama1`

---

## Performance Considerations

### Model Latency (Approximate)

| Model | First Token | Full Response (10 tokens) |
|-------|-------------|--------------------------|
| qwen2.5:0.5b | 1-2s | 3-5s |
| phi3:mini | 2-3s | 5-8s |

(Times vary based on system load and CPU speed)

### Concurrency

- LiteLLM can handle multiple requests
- Each container can handle 1 inference at a time
- Queue builds automatically

---

## Next Steps

1. **Wait for phi3:mini download** to complete
2. **Create LiteLLM server**
   - Create `backend/` files
   - Configure routes
   - Test with curl

3. **Test routing**
   - Switch between models
   - Verify responses from both
   - Check streaming works

4. **Move to Phase 3: Streamlit**
   - Connect to LiteLLM endpoint
   - Build chat UI
   - Add model selector

---

## Documentation Files

After Phase 2, you'll have:
- ✅ LiteLLM server running on port 8000
- ✅ Both models accessible via single API
- ✅ Request/response logging
- ✅ Health check endpoint
- ✅ Model switching capability

Ready to start Phase 2? Files will be created once phi3:mini download completes.

