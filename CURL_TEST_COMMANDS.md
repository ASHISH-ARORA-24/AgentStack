# 🧪 CURL Test Commands for All 3 Models

## Quick Reference

### 1️⃣ Check if Models are Loaded

```bash
# LLAMA 3.2:1b (Port 11434)
curl -s http://localhost:11434/api/tags

# QWEN 2.5:0.5b (Port 11435)
curl -s http://localhost:11435/api/tags

# PHI 3:mini (Port 11436)
curl -s http://localhost:11436/api/tags
```

**Expected response:** JSON with model name, size, and details

---

## 2️⃣ Generate Text with Each Model

### LLAMA 3.2:1b
```bash
curl -X POST http://localhost:11434/api/generate \
  -d '{"model":"llama3.2:1b","prompt":"Hello, how are you?","stream":false}'
```

### QWEN 2.5:0.5b
```bash
curl -X POST http://localhost:11435/api/generate \
  -d '{"model":"qwen2.5:0.5b","prompt":"Hello, how are you?","stream":false}'
```

### PHI 3:mini
```bash
curl -X POST http://localhost:11436/api/generate \
  -d '{"model":"phi3:mini","prompt":"Hello, how are you?","stream":false}'
```

---

## 3️⃣ One-liner Test (All 3 Models)

```bash
echo "=== LLAMA ===" && curl -s http://localhost:11434/api/tags && echo && \
echo "=== QWEN ===" && curl -s http://localhost:11435/api/tags && echo && \
echo "=== PHI ===" && curl -s http://localhost:11436/api/tags
```

---

## 4️⃣ Test with Pretty JSON Output

```bash
# Install jq first (if needed)
sudo apt install jq

# Then use:
curl -s http://localhost:11434/api/tags | jq .
curl -s http://localhost:11435/api/tags | jq .
curl -s http://localhost:11436/api/tags | jq .
```

---

## 5️⃣ Generate and Show Only Response

```bash
# LLAMA
curl -s -X POST http://localhost:11434/api/generate \
  -d '{"model":"llama3.2:1b","prompt":"What is AI?","stream":false}' | \
  grep -o '"response":"[^"]*"'

# QWEN
curl -s -X POST http://localhost:11435/api/generate \
  -d '{"model":"qwen2.5:0.5b","prompt":"What is AI?","stream":false}' | \
  grep -o '"response":"[^"]*"'

# PHI (with timeout since it's slower)
timeout 60 curl -s -X POST http://localhost:11436/api/generate \
  -d '{"model":"phi3:mini","prompt":"What is AI?","stream":false}' | \
  grep -o '"response":"[^"]*"'
```

---

## 6️⃣ Run the Test Script

```bash
./test_api.sh
```

This will:
- ✅ Check if all 3 models are loaded
- ✅ Test each with a prompt
- ✅ Show response examples
- ✅ Display curl commands for manual use

---

## 📊 Expected Results

| Model | Port | Command | Expected Response |
|-------|------|---------|-------------------|
| **Llama 3.2:1b** | 11434 | `curl -s http://localhost:11434/api/tags` | ✅ JSON with llama3.2:1b model |
| **Qwen 2.5:0.5b** | 11435 | `curl -s http://localhost:11435/api/tags` | ✅ JSON with qwen2.5:0.5b model |
| **Phi 3:mini** | 11436 | `curl -s http://localhost:11436/api/tags` | ✅ JSON with phi3:mini model |

---

## 🔍 Troubleshooting

### Connection refused?
```bash
# Check if containers are running
docker ps | grep agentstack
```

### Model not responding?
```bash
# Check container logs
docker logs agentstack_llama3.2
docker logs agentstack_qwen2.5
docker logs agentstack_phi3
```

### Port already in use?
```bash
# Check what's using the ports
lsof -i :11434
lsof -i :11435
lsof -i :11436
```

---

## 💡 Tips

1. **Llama is fastest** - usually responds in 3-5 seconds
2. **Qwen is medium speed** - responds in 2-4 seconds
3. **Phi is slowest** - may take 30-45 seconds on first run
4. **Use `stream":true`** for streaming responses (gets data as it's generated)
5. **Add `-v` flag** to curl for verbose output with timing info

---

## ✅ Phase 1 Complete!

All 3 models are:
- ✅ Downloaded
- ✅ Loaded
- ✅ Responding to API calls
- ✅ Ready for Phase 2 (LiteLLM Backend)

**Ready to proceed? See `docs/04_LITELLM_PLANNING.md`**
