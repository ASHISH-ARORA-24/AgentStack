# AgentStack - LLM Chat Application

A complete learning project demonstrating how to build a modern AI chat application using local LLM models with Ollama, LiteLLM proxy, and Streamlit frontend.

## 🚀 Current Status

**Active Phase**: Docker-Only Setup (Phase 1C)

### Completed ✅
- Ollama native setup documented
- Docker Compose configuration created
- Container 1 (qwen2.5:0.5b) - Ready on Port 11435
- Native Ollama removed & cleanup complete

### In Progress ⏳
- Container 2 (phi3:mini) downloading (10-15 mins)

### Next Up ➡️
- Phase 2: LiteLLM Backend Server

---

## 🏗️ Current Architecture

### Docker-Only Setup (ACTIVE)
```
┌────────────────────────────────────────────────┐
│         STREAMLIT (Coming in Phase 3)          │
│              Port 8501                         │
└─────────────────┬──────────────────────────────┘
                  │
┌─────────────────┴──────────────────────────────┐
│      LITELLM (Coming in Phase 2)              │
│              Port 8000                         │
└──────────┬─────────────────┬────────────────────┘
           │                 │
    ┌──────┴─────────┐  ┌───┴──────────────┐
    │ DOCKER 1       │  │  DOCKER 2        │
    │ Port 11435     │  │  Port 11436      │
    │ qwen2.5:0.5b   │  │  phi3:mini       │
    │ (397 MB) ✅     │  │  (2.3 GB) ⏳      │
    └────────────────┘  └──────────────────┘
```

## 📊 Communication Flow

1. **User Input** → Streamlit Frontend (Port 8501)
   - User types a message and selects a model
   - Frontend sends HTTP request to LiteLLM

2. **Request Processing** → LiteLLM Proxy (Port 8000)
   - Receives request from Streamlit
   - Routes to appropriate Ollama model
   - Maintains request/response logs

3. **LLM Processing** → Ollama Service (Port 11434)
   - Executes inference on selected model
   - Streams response back to LiteLLM
   - Returns generated text

4. **Response Display** → Streamlit Frontend
   - Displays streamed response in real-time
   - Shows token count and model info
   - Maintains conversation history

## 📁 Project Structure

```
AgentStack/
├── backend/
│   ├── litellm_server.py       # LiteLLM proxy server
│   ├── config.py               # Configuration settings
│   └── requirements.txt         # Backend dependencies
├── frontend/
│   ├── streamlit_app.py         # Streamlit chat interface
│   └── requirements.txt         # Frontend dependencies
├── scripts/
│   ├── setup_ollama.sh          # Ollama installation script
│   ├── download_models.sh       # Download 3 LLM models
│   └── run_project.sh           # Start all services
├── docker-compose.yml           # Container orchestration
├── pyproject.toml               # Project metadata
├── setup.md                     # Setup instructions
└── README.md                    # This file
```

## 🚀 Technology Stack

### Ollama
- **Purpose**: Local LLM model serving
- **Port**: 11434
- **Models**: llama3.2:1b, qwen2.5:0.5b, phi3:mini
- **Why**: Runs entirely on local hardware, no external API calls

### LiteLLM
- **Purpose**: Unified LLM API proxy
- **Port**: 8000
- **Features**: Standardized OpenAI-compatible API, easy model switching
- **Why**: Simplifies API calls, makes switching models seamless

### Streamlit
- **Purpose**: Interactive web UI for chat
- **Port**: 8501
- **Features**: Real-time response streaming, conversation history
- **Why**: Easy to build, fast prototyping, great for demos

## 🔄 Data Flow Example

```
User Message: "Hello"
      ↓
[Streamlit] Makes POST request to LiteLLM:
  {
    "model": "ollama/llama3.2:1b",
    "messages": [{"role": "user", "content": "Hello"}]
  }
      ↓
[LiteLLM] Routes to Ollama and forwards:
  http://localhost:11434/api/generate
      ↓
[Ollama] Generates response with selected model
      ↓
[LiteLLM] Streams response back to Streamlit
      ↓
[Streamlit] Displays response in chat UI
```

## 📋 Step-by-Step Implementation Plan

### Phase 1: ✅ Ollama Setup (COMPLETE)
- [x] Install Ollama in WSL Ubuntu
- [x] Start Ollama service
- [x] Download 3 LLM models
- [x] Verify models are accessible

### Phase 1B: ✅ Docker Container Setup (COMPLETE)
- [x] Create docker-compose.yml with 2 lightweight containers
- [x] Start Docker containers
- [x] Download qwen2.5:0.5b to Container 1
- [x] Download phi3:mini to Container 2 (⏳ in progress)

### Phase 1C: ✅ Cleanup & Docker-Only Setup (ACTIVE)
- [x] Remove native Ollama service
- [x] Delete all native models (freed 3.9 GB)
- [x] Keep ONLY Docker containers
- [x] Verify docker-only access
- ⏳ Wait for phi3:mini download

### Phase 2: LiteLLM Backend (NEXT)
- [ ] Create LiteLLM server configuration
- [ ] Set up model routing (both containers)
- [ ] Create API endpoints
- [ ] Test with curl/Postman

### Phase 3: Streamlit Frontend (COMING)
- [ ] Create chat interface
- [ ] Add model selector
- [ ] Implement message history
- [ ] Add streaming responses

### Phase 4: Integration & Testing (COMING)
- [ ] Connect Streamlit to LiteLLM
- [ ] Test end-to-end flow
- [ ] Add error handling
- [ ] Performance testing

## ✅ Prerequisites

- WSL Ubuntu 24.04
- Python 3.10+
- Docker (optional, for containerization)
- 4GB+ RAM (for running models)
- Internet connection (for initial setup)

## 📝 Notes

- All services run locally without external API calls
- Models run on CPU (can be slow) or GPU (if available)
- Memory usage depends on model size and concurrent requests
- This is a learning project focused on architecture and integration

