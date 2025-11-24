#!/bin/bash

# Entrypoint script for Ollama containers
# Starts Ollama service and downloads models asynchronously
# This allows the container to start quickly while models download in background

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OLLAMA_HOST="${OLLAMA_HOST:-http://0.0.0.0:11434}"
MODEL_NAME="${MODEL_NAME:-llama3.2:1b}"
LOG_FILE="/tmp/ollama_model_download.log"
MAX_RETRIES=3
RETRY_DELAY=5

log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if Ollama is ready
wait_for_ollama() {
    local max_attempts=30
    local attempt=1
    
    log_info "Waiting for Ollama to be ready on $OLLAMA_HOST..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$OLLAMA_HOST/api/tags" > /dev/null 2>&1; then
            log_success "Ollama is ready!"
            return 0
        fi
        
        log_info "Attempt $attempt/$max_attempts - Ollama not ready yet, waiting..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    log_error "Ollama failed to start after $max_attempts attempts"
    return 1
}

# Function to download model with retries
download_model() {
    local model=$1
    local attempt=1
    
    log_info "Starting download of model: $model"
    
    while [ $attempt -le $MAX_RETRIES ]; do
        log_info "Download attempt $attempt/$MAX_RETRIES for $model"
        
        if curl -s "$OLLAMA_HOST/api/pull" \
            -d "{\"name\":\"$model\"}" \
            -H "Content-Type: application/json" > "$LOG_FILE" 2>&1; then
            
            # Check if download was successful by verifying model exists
            if curl -s "$OLLAMA_HOST/api/tags" | grep -q "\"name\":\"$model\""; then
                log_success "Model $model downloaded and loaded successfully!"
                return 0
            else
                log_warning "Model $model downloaded but not yet loaded. Will retry..."
            fi
        else
            log_warning "Download attempt $attempt failed for $model"
        fi
        
        if [ $attempt -lt $MAX_RETRIES ]; then
            log_info "Waiting ${RETRY_DELAY}s before retry..."
            sleep "$RETRY_DELAY"
        fi
        
        attempt=$((attempt + 1))
    done
    
    log_error "Failed to download model $model after $MAX_RETRIES attempts"
    log_warning "Model $model will be downloaded on first use"
    return 1
}

# Function to download models asynchronously
download_models_async() {
    local models=("$@")
    local log_dir="/tmp/ollama_downloads"
    
    mkdir -p "$log_dir"
    
    log_info "Starting asynchronous model downloads..."
    
    for model in "${models[@]}"; do
        (
            download_model "$model" > "$log_dir/${model//\//-}_download.log" 2>&1
        ) &
    done
    
    log_info "Model downloads started in background"
    log_info "Monitor downloads with: tail -f $log_dir/*.log"
}

# Main entrypoint
main() {
    log_info "=== Ollama Container Entrypoint Started ==="
    log_info "Container hostname: $(hostname)"
    log_info "Ollama host: $OLLAMA_HOST"
    log_info "Model to download: $MODEL_NAME"
    
    # Start Ollama service in background
    log_info "Starting Ollama service..."
    ollama serve &
    OLLAMA_PID=$!
    log_success "Ollama service started (PID: $OLLAMA_PID)"
    
    # Wait for Ollama to be ready
    if ! wait_for_ollama; then
        log_error "Failed to start Ollama service"
        kill $OLLAMA_PID 2>/dev/null || true
        exit 1
    fi
    
    # Check if model already exists
    if curl -s "$OLLAMA_HOST/api/tags" | grep -q "\"name\":\"$MODEL_NAME\""; then
        log_success "Model $MODEL_NAME already loaded!"
    else
        # Download model asynchronously
        download_models_async "$MODEL_NAME" &
        DOWNLOAD_PID=$!
        log_info "Model download process started (PID: $DOWNLOAD_PID)"
    fi
    
    log_info "=== Container Ready ==="
    log_info "Ollama API available at $OLLAMA_HOST"
    
    # Keep container running and print download progress
    trap "kill $OLLAMA_PID 2>/dev/null || true" EXIT
    
    while true; do
        sleep 60
        
        # Print current model status
        MODELS=$(curl -s "$OLLAMA_HOST/api/tags" 2>/dev/null | grep -o '"name":"[^"]*"' || echo "No models loaded")
        log_info "Current models: $MODELS"
    done
}

# Run main function
main "$@"
