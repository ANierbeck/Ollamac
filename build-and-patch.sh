#!/bin/bash
set -e

# Clean DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/Ollamac-* 2>/dev/null

# Start build in background
xcodebuild -scheme Ollamac -destination 'platform=macOS' "$@" &
BUILD_PID=$!

# Wait for OllamaKit to be checked out
while [ ! -f ~/Library/Developer/Xcode/DerivedData/Ollamac-*/SourcePackages/checkouts/OllamaKit/Sources/OllamaKit/Utils/OKHTTPClient.swift ]; do
  sleep 0.5
done

# Patch the file
chmod -R u+w ~/Library/Developer/Xcode/DerivedData/Ollamac-* 2>/dev/null
python3 -c "
import re, glob
files = glob.glob('/Users/anierbeck/Library/Developer/Xcode/DerivedData/Ollamac-*/SourcePackages/checkouts/OllamaKit/Sources/OllamaKit/Utils/OKHTTPClient.swift')
for f in files:
    with open(f, 'r') as file:
        content = file.read()
    content = re.sub(r'func stream<T: Decodable>', 'func stream<T: Decodable & Sendable>', content)
    with open(f, 'w') as file:
        file.write(content)
    print(f'Patched: {f}')
"

# Wait for build
wait $BUILD_PID
