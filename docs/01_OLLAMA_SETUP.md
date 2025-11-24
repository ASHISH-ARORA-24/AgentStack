# Phase 1: Ollama Setup & LLM Model Installation

## Overview

Ollama is a local LLM model manager that runs on your WSL Ubuntu system. Unlike containerized solutions, Ollama models are installed directly on the host OS for better performance and access.

**Key Point**: LLMs are NOT containerized - they run natively on your WSL Ubuntu system.

---

## Step 1 — Install Ollama inside WSL Ubuntu

### Command

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### What this does:
- Downloads the Ollama installation script
- Installs Ollama binary and dependencies
- Sets up Ollama to run as a service

### Expected Output:
```
Installing ollama...
[✓] Downloading ollama...
[✓] Installing ollama...
[✓] Ollama installed successfully
```

---

## Step 2 — Start the Ollama Server

### Option 1: Run in Foreground (for testing/debugging)

```bash
ollama serve
```

### Expected Output:
```
time=2025-01-15T10:30:45.123Z level=INFO source=main.go:104 msg="Listening on 127.0.0.1:11434"
```

**✅ Success Indicator**: You see `listening on 127.0.0.1:11434`

The Ollama server is now running on:
- **Address**: `127.0.0.1` (localhost only)
- **Port**: `11434`
- **Access**: `http://localhost:11434`

### Option 2: Run in Background (recommended for development)

```bash
ollama serve &
```

- Runs Ollama in the background
- Returns terminal control to you
- Server continues running even if you close the terminal session

---

## Troubleshooting: Port Already in Use

### ⚠️ Error Message:
```
Error: listen tcp 127.0.0.1:11434: bind: address already in use
```

### Cause:
Ollama is already running on Windows host (port 11434 is taken)

### Solution:

**Check what's using port 11434:**
```bash
sudo lsof -i :11434
```

**Sample Output:**
```
COMMAND    PID    USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
ollama   12345   root    3u  IPv4  55555      0t0  TCP 127.0.0.1:11434 (LISTEN)
```

**Kill the existing process:**
```bash
sudo kill <PID>
```

Replace `<PID>` with the actual process ID from above.

**Then try starting Ollama again:**
```bash
ollama serve
```

---

## Step 3 — Download the 3 LLM Models

Once Ollama server is running (keep it in another terminal), pull the 3 models:

### Model 1: Llama 3.2 (1B parameters)

```bash
ollama pull llama3.2:1b
```

**Size**: ~650 MB
**Speed**: Fast inference, good for general tasks
**Memory**: ~2GB RAM required

### Model 2: Qwen 2.5 (0.5B parameters)

```bash
ollama pull qwen2.5:0.5b
```

**Size**: ~350 MB
**Speed**: Very fast, lightweight
**Memory**: ~1GB RAM required

### Model 3: Phi 3 Mini (Small, efficient)

```bash
ollama pull phi3:mini
```

**Size**: ~2.3 GB
**Speed**: Moderate, good quality responses
**Memory**: ~2.5GB RAM required

---

## Pull Command Output

When pulling a model, you'll see:

```
pulling manifest
pulling c2e3209a3f1f
...
verifying sha256 digest
writing manifest
success
```

Each model downloads in chunks. Larger models take longer.

---

## Verification: Confirm Models Are Installed

List all installed models:

```bash
ollama list
```

### Expected Output:
```
NAME              ID              SIZE    MODIFIED
llama3.2:1b       e1d432d4d...    650MB   2 hours ago
qwen2.5:0.5b      f8a9b2c1e...    350MB   1 hour ago
phi3:mini         a5c8d9e2f...    2.3GB   30 minutes ago
```

---

## Testing: Chat with a Model

### Method 1: Direct Ollama Command (Simplest)

Test a model directly:

```bash
ollama run llama3.2:1b "Hello, who are you?"
```

**Expected Output:**
```
I'm Llama, an AI assistant created by Meta. I'm here to help you with any questions or tasks you might have.
```

### Method 2: Interactive Mode

For conversational testing:

```bash
ollama run llama3.2:1b
```

Type messages and get responses. Press `Ctrl+D` to exit.

**Example Session:**
```
>>> What is the capital of France?
The capital of France is Paris.

>>> Tell me a joke
Why did the scarecrow win an award? Because he was outstanding in his field!

>>> /bye
```

---

## Testing with cURL Commands

Since Ollama exposes an HTTP API on port 11434, you can test using cURL commands.

### Test 1: Basic Generation Request

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:1b",
  "prompt": "What is the capital of France?",
  "stream": false
}'
```

**Response Format:**
```json
{
  "model": "llama3.2:1b",
  "created_at": "2025-01-15T10:45:32.123Z",
  "response": "The capital of France is Paris.",
  "done": true,
  "context": [...],
  "total_duration": 2345678900,
  "load_duration": 123456789,
  "prompt_eval_count": 15,
  "eval_count": 10,
  "eval_duration": 1234567890
}
```

### Test 2: Streaming Response (Real-time)

For streaming responses (useful for UI):

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:1b",
  "prompt": "Explain quantum computing in simple terms",
  "stream": true
}'
```

**Response Format (streamed):**
```
{"model":"llama3.2:1b","created_at":"2025-01-15T10:46:00Z","response":"Quantum","done":false}
{"model":"llama3.2:1b","created_at":"2025-01-15T10:46:01Z","response":" computing","done":false}
{"model":"llama3.2:1b","created_at":"2025-01-15T10:46:02Z","response":" uses...","done":false}
...
{"model":"llama3.2:1b","created_at":"2025-01-15T10:46:10Z","response":"","done":true}
```

---

## Testing All 3 Models Comparison

Test all three models with the same prompt to compare outputs:

### Model 1: llama3.2:1b

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:1b",
  "prompt": "Write a haiku about programming",
  "stream": false
}' | jq '.response'
```

### Model 2: qwen2.5:0.5b

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5:0.5b",
  "prompt": "Write a haiku about programming",
  "stream": false
}' | jq '.response'
```

### Model 3: phi3:mini

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "phi3:mini",
  "prompt": "Write a haiku about programming",
  "stream": false
}' | jq '.response'
```

**Note:** Install `jq` to format JSON nicely:
```bash
sudo apt-get update && sudo apt-get install -y jq
```

---

## Testing with Different Parameters

### Test with Temperature (Creativity Level)

Higher temperature = more creative but less coherent

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:1b",
  "prompt": "Tell me something interesting",
  "temperature": 0.7,
  "stream": false
}' | jq '.response'
```

### Test with Top K (Diversity)

Controls how many top candidates to consider

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:1b",
  "prompt": "What is AI?",
  "top_k": 40,
  "top_p": 0.9,
  "stream": false
}' | jq '.response'
```

### Test with Context (Conversation)

Pass previous responses for context:

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:1b",
  "prompt": "What is the capital of France?",
  "context": [],
  "stream": false
}'
```

Save the `context` array from response, then use it in next request for conversation.

---

## Testing: Check Ollama Status

### Check if Ollama is Running

```bash
curl http://localhost:11434/api/tags
```

**Response (lists all available models):**
```json
{
  "models": [
    {
      "name": "llama3.2:1b",
      "modified_at": "2025-01-15T10:30:00Z",
      "size": 650000000,
      "digest": "e1d432d4d..."
    },
    {
      "name": "qwen2.5:0.5b",
      "modified_at": "2025-01-15T10:35:00Z",
      "size": 350000000,
      "digest": "f8a9b2c1e..."
    },
    {
      "name": "phi3:mini",
      "modified_at": "2025-01-15T10:40:00Z",
      "size": 2300000000,
      "digest": "a5c8d9e2f..."
    }
  ]
}
```

### Check Model Details

```bash
curl http://localhost:11434/api/show -d '{"name": "llama3.2:1b"}'
```

---

## Quick Test Script

Create a file `test_models.sh`:

```bash
#!/bin/bash

echo "🧪 Testing Ollama Models..."
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test prompt
PROMPT="What is machine learning?"

echo -e "${BLUE}Testing all 3 models with prompt: \"$PROMPT\"${NC}\n"

echo -e "${GREEN}1. Testing llama3.2:1b${NC}"
curl -s http://localhost:11434/api/generate -d "{\"model\": \"llama3.2:1b\", \"prompt\": \"$PROMPT\", \"stream\": false}" | jq '.response'
echo ""

echo -e "${GREEN}2. Testing qwen2.5:0.5b${NC}"
curl -s http://localhost:11434/api/generate -d "{\"model\": \"qwen2.5:0.5b\", \"prompt\": \"$PROMPT\", \"stream\": false}" | jq '.response'
echo ""

echo -e "${GREEN}3. Testing phi3:mini${NC}"
curl -s http://localhost:11434/api/generate -d "{\"model\": \"phi3:mini\", \"prompt\": \"$PROMPT\", \"stream\": false}" | jq '.response'
echo ""

echo -e "${GREEN}✅ All models tested!${NC}"
```

Run it:
```bash
chmod +x test_models.sh
./test_models.sh
```

---

## Testing Checklist

- [ ] Ollama server running (`ollama serve` or `ollama serve &`)
- [ ] Can list models: `ollama list`
- [ ] Direct test works: `ollama run llama3.2:1b "test"`
- [ ] cURL basic request works: `curl http://localhost:11434/api/tags`
- [ ] cURL generation works: `curl http://localhost:11434/api/generate ...`
- [ ] All 3 models respond correctly
- [ ] Streaming responses work (`"stream": true`)
- [ ] Model comparison shows different outputs

---

## Key Architecture Notes

### Why Models Run Natively (Not in Container)

1. **Performance**: Direct OS access for better GPU/CPU utilization
2. **Accessibility**: Models available to all services on the system
3. **Simplicity**: Easier to manage multiple models across services
4. **Memory**: Shared model cache between different applications

### Port Configuration

- **Ollama Service**: `http://localhost:11434`
- **LiteLLM will connect to**: `http://localhost:11434`
- **Streamlit will connect through**: `LiteLLM` → `Ollama`

### System Resources Required

| Model | Size | RAM | Disk | Speed |
|-------|------|-----|------|-------|
| qwen2.5:0.5b | 350 MB | 1 GB | 500 MB | Very Fast |
| llama3.2:1b | 650 MB | 2 GB | 1 GB | Fast |
| phi3:mini | 2.3 GB | 2.5 GB | 3 GB | Good |
| **Total** | **~3.3 GB** | **~5.5 GB** | **~4.5 GB** | - |

---

## Stopping Ollama

### If running in foreground:
Press `Ctrl+C`

### If running in background:
```bash
pkill -f "ollama serve"
```

Or kill the specific process:
```bash
kill <PID>  # From ollama list or ps output
```

---

## Next Steps

Once all 3 models are downloaded and verified:

1. ✅ Keep Ollama service running (`ollama serve &`)
2. ➡️ Move to Phase 2: Create LiteLLM Backend Server
3. ➡️ Phase 2 will connect to this Ollama service

---

## Troubleshooting Checklist

- [ ] Ollama installed successfully
- [ ] `ollama serve` shows "listening on 127.0.0.1:11434"
- [ ] No port conflict errors
- [ ] All 3 models downloaded (`ollama list` shows all 3)
- [ ] Can run `ollama run llama3.2:1b "test"` successfully
- [ ] Ollama service running in background (`ollama serve &`)

