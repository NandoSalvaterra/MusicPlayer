# MusicPlayer

A modular iOS music player application built with SwiftUI and structured using Tuist for project management.

## Architecture

This project is organized into multiple modules:
- **App**: Main iOS application with UI components
- **Data**: Data layer with repositories and models
- **Network**: Networking layer for API communication

## Prerequisites

- Xcode 15.0 or later
- Swift 6.0 or later
- macOS 13.0 or later

## Installation

### 1. Install Tuist

First, you need to install Tuist, which is used for project generation and management.

#### Option A: Using Homebrew (Recommended)
```bash
brew install tuist
```

#### Option B: Using cURL
```bash
curl -Ls https://install.tuist.io | bash
```

#### Option C: Using Mint
```bash
mint install tuist/tuist
```

### 2. Activate Tuist (if needed)

If you installed Tuist using cURL or Mint, you may need to activate it:
```bash
# Add Tuist to your PATH (add this to your ~/.zshrc or ~/.bash_profile)
export PATH="$HOME/.tuist/bin:$PATH"

# Reload your shell configuration
source ~/.zshrc  # or source ~/.bash_profile
```

### 3. Verify Tuist Installation
```bash
tuist --version
```

## Getting Started

### 1. Clone the Repository
```bash
git clone <repository-url>
cd MusicPlayer
```

### 2. Generate the Xcode Project

You can use the provided Makefile commands to manage the project:

```bash
# Generate the Xcode project and workspace
make project
```

This command runs `tuist generate` and creates the necessary Xcode project files.

### 3. Open the Project

After generation, open the workspace file:
```bash
open MusicPlayer.xcworkspace
```

## Makefile Commands

The project includes a Makefile with several useful commands:

- **`make help`** - Show all available commands
- **`make project`** - Generate the Xcode project using Tuist
- **`make edit`** - Open the project in Tuist edit mode for configuration
- **`make clean`** - Clean Tuist cache and temporary files
- **`make destroy`** - Fully remove all Tuist caches and build folders

### Common Workflow

```bash
# 1. Generate the project
make project

# 2. Open in Xcode
open MusicPlayer.xcworkspace

# 3. Build and run the project in Xcode
```

## Project Structure

```
MusicPlayer/
├── App/                    # Main iOS application
│   ├── Sources/           # Swift source files
│   ├── Resources/         # Assets, colors, localizations
│   └── Project.swift      # Tuist project configuration
├── Data/                  # Data layer module
│   ├── Sources/           # Repository and model implementations
│   └── Project.swift      # Tuist project configuration
├── Network/               # Network layer module
│   ├── Sources/           # HTTP client and API endpoints
│   └── Project.swift      # Tuist project configuration
├── Tuist/                 # Tuist configuration
│   └── Package.swift      # Swift Package Manager dependencies
├── Workspace.swift        # Tuist workspace configuration
├── Tuist.swift           # Tuist project settings
└── Makefile              # Build automation commands
```

## Troubleshooting

### Tuist Command Not Found
If you get a "command not found" error for tuist:
1. Make sure Tuist is installed correctly
2. Restart your terminal
3. Check your PATH environment variable

### Generation Errors
If `make project` fails:
```bash
# Clean cache and try again
make clean
make project
```

### Complete Reset
If you encounter persistent issues:
```bash
# Remove all generated files and caches
make destroy
make project
```

## Development

When making changes to the project structure or adding new dependencies, remember to:
1. Update the appropriate `Project.swift` files
2. Run `make project` to regenerate the Xcode project
3. Commit both your changes and any updated project files

For more information about Tuist, visit the [official documentation](https://docs.tuist.io).