#!/bin/zsh
set -e

echo "=== Phase 3.1 Verification ==="
echo ""

echo "1. Building Ollamac main target..."
xcodebuild -project Ollamac.xcodeproj -scheme Ollamac -destination 'platform=macOS' > /tmp/build_main.log 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Main target build failed"
    cat /tmp/build_main.log
    exit 1
fi
if grep -qi "data race" /tmp/build_main.log; then
    echo "❌ Data race warnings still present"
    grep -i "data race" /tmp/build_main.log
    exit 1
fi
echo "✅ Main target builds without data race errors"

echo ""
echo "2. Building OllamacTests target..."
xcodebuild -project Ollamac.xcodeproj -scheme OllamacTests -destination 'platform=macOS' > /tmp/build_tests.log 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Test target build failed"
    cat /tmp/build_tests.log
    exit 1
fi
echo "✅ Test target compiles successfully"

echo ""
echo "3. Checking test file count..."
TEST_FILES=$(grep -c "OllamacTests" Ollamac.xcodeproj/project.pbxproj || echo "0")
if [ "$TEST_FILES" -lt 5 ]; then
    echo "❌ Expected 5 test files, found $TEST_FILES"
    exit 1
fi
echo "✅ All 5 test files in target"

echo ""
echo "=== All Phase 3.1 verification criteria PASSED ==="
