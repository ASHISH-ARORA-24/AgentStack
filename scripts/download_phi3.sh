#!/bin/bash

echo "📥 Downloading phi3:mini to Container 2 (Port 11436)..."
echo "This may take 10-15 minutes depending on internet speed"
echo ""

curl -s http://localhost:11436/api/pull -X POST -d '{"name":"phi3:mini"}' -H 'Content-Type: application/json' | while IFS= read -r line; do
    if echo "$line" | grep -q '"pulling manifest"'; then
        echo "📦 Pulling manifest..."
    elif echo "$line" | grep -q '"downloading"'; then
        pct=$(echo "$line" | grep -o '"completed":[0-9]*' | cut -d: -f2)
        tot=$(echo "$line" | grep -o '"total":[0-9]*' | cut -d: -f2)
        if [ -n "$pct" ] && [ -n "$tot" ]; then
            percentage=$((pct * 100 / tot))
            echo -ne "\r⬇️  Downloading: ${percentage}%"
        fi
    elif echo "$line" | grep -q '"verifying"'; then
        echo -e "\n✅ Verifying..."
    elif echo "$line" | grep -q '"success"'; then
        echo "✅ Download complete!"
    fi
done

echo ""
echo "✨ phi3:mini is now available on port 11436"
