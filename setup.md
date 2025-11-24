Step 1 — Install Ollama inside WSL Ubuntu

Run:

curl -fsSL https://ollama.com/install.sh | sh

⏳ Step 2 — Start the Ollama server
ollama serve


If it prints something like:

listening on 127.0.0.1:11434


➡️ it's running successfully.

⚠ If you see this error
Error: listen tcp 127.0.0.1:11434: bind: address already in use


It means Ollama is already running on Windows (port 11434 is taken by Windows Ollama).

To check and kill:

sudo lsof -i :11434
sudo kill <PID>


to run in background :
Option 2 — Use & only (process stops if terminal closes)
ollama serve &

ollama pull llama3.2:1b
ollama pull qwen2.5:0.5b
ollama pull phi3:mini