# Creating the Test Target in Xcode

This guide explains how to manually create the OllamacTests target in Xcode for the Ollamac project.

## Prerequisites

- Xcode 15.3 or later
- Ollamac project opened (`Ollamac.xcodeproj`)
- All test files already created in the `OllamacTests/` directory

## Step 1: Add New Test Target

1. Open Xcode and load the `Ollamac.xcodeproj` project
2. Go to **File → New → Target...**
3. Select **macOS** tab
4. Choose **Unit Test Bundle** template
5. Enter **Product Name**: `OllamacTests`
6. Select **Language**: Swift
7. Check ☑️ **"Add to my project"**
8. Click **Next**

## Step 2: Configure Target Settings

1. **Bundle Loader**: Select `$(BUILT_PRODUCTS_DIR)/Ollamac.app/Contents/MacOS/Ollamac`
2. **Host Application**: Select `Ollamac`
3. Confirm **Target Name**: `OllamacTests`
4. Click **Finish**

## Step 3: Add Existing Test Files

The test files have already been created in the `OllamacTests/` directory. You need to add them to the Xcode project:

1. In the **Project Navigator** (left panel), right-click on the yellow `OllamacTests` folder
2. Select **"Add Files to 'OllamacTests'..."**
3. Select all test files:
   ```
   OllamacTests.swift
   Mocks/MockChatBackend.swift
   Mocks/MockMCPBackend.swift
   ChatViewModelTests.swift
   MessageViewModelTests.swift
   ```
4. **Options**:
   - ☐ **Copy items if needed** - *UNCHECKED* (files already exist)
   - ☑️ **Create folder references** - CHECKED
   - ☑️ **Add to targets** → Select only `OllamacTests`
5. Click **Add**

## Step 4: Build Settings Configuration

1. Select the `OllamacTests` target
2. Go to **Build Settings** tab
3. Under **Testing** section:
   - **Enable Testability** → `Yes`
   - **Enable Code Coverage** → `Yes` (optional)
4. Under **Swift Compiler - General** section:
   - **Allow testing internal code** → `Yes` (critical for `@testable import Ollamac`)

## Step 5: Verify Target Dependencies

1. Select `OllamacTests` target
2. Go to **General** tab
3. **Dependencies** section:
   - `Ollamac` should be listed as Host Application
4. **Build Phases** tab → **Target Dependencies**:
   - `Ollamac` should be listed as a dependency

## Step 6: Create Test Scheme (Optional)

1. Go to **Product → Scheme → Manage Schemes...**
2. The `OllamacTests` scheme should be automatically created
3. Select it and check:
   - ☑️ **Shared** - CHECKED (for version control)
4. Click **Close**

## Step 7: Run Tests

1. **Product → Test** (⌘+U) or
2. Click the **diamond ▶️ button** next to a test class in the code editor

## Troubleshooting

### Error: "@testable import Ollamac" not working

**Solution**:
- **Build Settings** → **Swift Compiler - General** → **Allow testing internal code** = `Yes`
- **Build Settings** → **Packaging** → **Defines Module** = `Yes`

### Error: "No testable targets"

**Solution**:
- Ensure **Host Application** is correctly set to `Ollamac`
- Recreate the scheme

### Error: "Module 'Ollamac' not found"

**Solution**:
- Check **Target Membership** of test files (must be `OllamacTests`)
- Verify **Import Paths** in Build Settings

## Expected Results

✅ All 6 test files compile without errors  
✅ Tests can be executed with ⌘+U  
✅ CI pipeline (`.github/workflows/tests.yml`) works on GitHub  
✅ `@testable import Ollamac` works in all test files

## Files Created

```
OllamacTests/
├── OllamacTests.swift                    (Base test file)
├── Mocks/
│   ├── MockChatBackend.swift             (Mock ChatBackend implementation)
│   └── MockMCPBackend.swift              (Mock MCPBackend implementation)
├── ChatViewModelTests.swift              (ChatViewModel unit tests)
└── MessageViewModelTests.swift           (MessageViewModel unit tests)

.github/workflows/
└── tests.yml                             (GitHub Actions CI pipeline)
```
