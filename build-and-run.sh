#!/bin/zsh

# Clean
rm -rf build DerivedData SourcePackages

# Build with minimal concurrency checking
export SWIFT_STRICT_CONCURRENCY=minimal
xcodebuild -project Ollamac.xcodeproj -scheme Ollamac -configuration Debug

# Open the app
open build/Debug/Ollamac.app
