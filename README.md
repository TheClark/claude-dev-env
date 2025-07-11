# Claude Code Docker Environment for Windows

🚀 **Run Claude Code on large codebases from Windows with all development tools pre-installed**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Required-blue.svg)](https://www.docker.com/)
[![Platform](https://img.shields.io/badge/Platform-Windows%20(WSL2)-blue.svg)](https://github.com/)

## 🎯 Purpose

This Docker environment solves a common problem: **running Claude Code on Windows with large codebases**. It provides:

- ✅ **Claude Code pre-installed** - Starts automatically when you enter the container
- ✅ **Windows path handling** - Seamlessly converts Windows paths to Linux paths
- ✅ **Large codebase support** - Mount any size project without file limitations
- ✅ **All development tools included** - No need to install dependencies on Windows
- ✅ **Persistent environment** - Your settings and work persist between sessions

## 🎯 Quick Start for Windows Users

```powershell
# 1. Clone this repo into your project (or anywhere)
git clone https://github.com/TheClark/claude-dev-env.git claude-setup
cd claude-setup

# 2. Copy the example env file and edit it
copy .env.example .env
# Edit .env with your project path and credentials

# 3. Run the start script
powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1

# 3. Claude Code starts automatically!
```

### 🎉 Now What? Getting Started with Claude Code

Once Claude Code starts, you're ready to work with your codebase! Here's how to get started:

```bash
# Your entire project is mounted at /workspace
cd /workspace

# See your project files
ls -la

# Start working with Claude
# Example: "Help me understand this codebase"
# Example: "Find all API endpoints in this project"
# Example: "Write unit tests for the user service"
```

**Quick tips:**
- 📁 Your Windows project (e.g., `C:\MyProject`) is available at `/workspace` in the container
- 💾 All changes are saved directly to your Windows filesystem in real-time
- 🔄 Exit anytime with `exit` or Ctrl+D - your work persists
- 🚀 Restart instantly with the same start script - no rebuild needed

### Alternative: Using the Setup Wizard

If you prefer a guided setup, use the init script:
```powershell
powershell -ExecutionPolicy Bypass -File .\init.ps1
```

This will:
1. ✅ Check Docker Desktop is running
2. ✅ Ask where your code is located (e.g., `C:\Users\YourName\MyProject`)
3. ✅ Set up your GitHub and Anthropic credentials
4. ✅ Build the Docker image (~3-5 minutes first time)
5. ✅ Launch Claude Code with your project mounted

## 🔧 Why Use This?

### The Problem
- Claude Code on Windows can have issues with large codebases
- Installing all development dependencies on Windows is complex
- Path handling between Windows and Linux tools is problematic
- Environment inconsistencies between team members

### The Solution
- Run Claude Code in a Linux container with your Windows files mounted
- All tools pre-installed: Python, Node.js, Java, Git, and more
- Automatic path conversion (e.g., `C:\MyProject` → `/workspace`)
- Consistent environment that works the same for everyone

## 💡 Typical Use Cases

### Working with Large Codebases
```powershell
# Your large project at C:\Work\BigProject
PROJECT_PATH=C:\Work\BigProject

# Claude Code can now access all files without Windows limitations
# Work with millions of files, deep directory structures, long paths
```

### Multiple Language Projects
```powershell
# Project with Python backend, React frontend, Java services
# All tools are pre-installed - no setup needed!
```

### Team Collaboration
```powershell
# Everyone uses the same environment
# No more "works on my machine" issues
```

## ✨ What's Included

### 🤖 Claude Code Features
- **Pre-installed Claude Code** - Latest version, starts automatically
- **Optimized for large codebases** - No file count or path length limits
- **Persistent sessions** - Your work saves between restarts
- **Credential management** - GitHub and Anthropic API keys configured

### 🚀 What Claude Code Can Do For You

Claude Code isn't just a chatbot - it's a full-featured development assistant that can:

#### 📝 Code & Development
- **Write and refactor code** - Generate new features, improve existing code, fix bugs
- **Understand your codebase** - Analyze architecture, find dependencies, explain complex logic
- **Write tests** - Create unit tests, integration tests, and test documentation
- **Debug issues** - Analyze errors, trace problems, suggest fixes

#### 🔄 Git & Version Control
- **Create commits** - Stage changes and commit with well-written messages
- **Push to remote** - Push your changes to GitHub/GitLab/Bitbucket
- **Create pull requests** - Open PRs with detailed descriptions
- **Review git history** - Analyze commits, diffs, and blame

#### 🐙 GitHub Integration
- **Manage issues** - Create, update, close, and comment on GitHub issues
- **Work with PRs** - Create, review, and manage pull requests
- **Check CI/CD status** - View workflow runs and check results
- **Browse repositories** - Fetch and analyze code from any public repo

#### 🛠️ Development Workflow
- **Run builds** - Execute npm, gradle, maven, make, and other build tools
- **Run tests** - Execute test suites and analyze results
- **Install dependencies** - Manage packages with npm, pip, maven, etc.
- **Database operations** - Connect to and query databases
- **API testing** - Make HTTP requests and test endpoints

#### 📊 Advanced Features
- **Multi-file edits** - Refactor across multiple files simultaneously
- **Code search** - Find patterns, implementations, and usages across large codebases
- **Documentation** - Generate and update technical documentation
- **Performance analysis** - Profile and optimize code
- **Security review** - Identify potential vulnerabilities

Example commands you can try:
```bash
"Help me understand the architecture of this project"
"Find all API endpoints and document them"
"Create a new feature for user authentication"
"Fix the failing tests in the test suite"
"Refactor this class to use modern patterns"
"Create a GitHub issue for the bug we just found"
"Commit these changes with a descriptive message"
"Make a pull request for this feature branch"
```

### 🛠️ Development Tools
- **Languages**: Python 3, Node.js 20, Java 8, Go 1.21, Rust, .NET 8
- **Package Managers**: npm/yarn/pnpm, pip/poetry/pipenv, Maven/Gradle, cargo
- **Version Control**: Git, GitHub CLI, SVN
- **Frontend**: React, Vue, Angular, Vite, TypeScript
- **Backend**: Flask, Django, FastAPI, Express
- **Databases**: PostgreSQL, MySQL, Redis, SQLite clients
- **And much more**: See full list below

## 📋 Prerequisites

### Supported Operating Systems
- ✅ **Windows 10** (version 1903, build 18362 or higher)
- ✅ **Windows 11** (all versions)
- ✅ **Windows Server 2019** or newer
- ✅ **Windows Server 2025** (confirmed working)
- ❌ **Not supported**: Windows Server 2012, Windows Server 2016, older Windows 10 builds

### Requirements
- ✅ **Docker Desktop** - [Download here](https://www.docker.com/products/docker-desktop/)
- ✅ **WSL2** - Usually comes with Docker Desktop
- ✅ **8GB+ RAM** - For smooth performance
- ✅ **10GB free disk space** - For Docker image and tools

⚠️ **Important Note**: Do not use this environment with SMB shares or Windows mapped drives. The Docker volume mounting may not work correctly with these network file systems. Store your project on a local drive for best performance and compatibility.

## 🔧 Installation Options

### Option 1: Quick Setup (Recommended)

```powershell
# Run from PowerShell in your project directory
cd C:\YourProject

# Clone and setup
git clone https://github.com/YOUR_USERNAME/claude-code-docker.git claude-setup
cd claude-setup
powershell -ExecutionPolicy Bypass -File .\init.ps1
```

### Option 2: Manual Setup

```powershell
# 1. Clone anywhere
cd C:\Tools
git clone https://github.com/YOUR_USERNAME/claude-code-docker.git

# 2. Copy to your project
Copy-Item -Recurse C:\Tools\claude-code-docker C:\YourProject\claude-setup

# 3. Configure
cd C:\YourProject\claude-setup
copy .env.example .env
# Edit .env with your PROJECT_PATH

# 4. Start
powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1
```

### Option 3: Shared Installation

```powershell
# One installation, multiple projects
# Install once in C:\Tools\claude-code-docker
# Create different .env files for each project:
# - .env.project1
# - .env.project2
# Start with: .\scripts\start-claude.ps1 -EnvFile .env.project1
```

## ⚙️ Configuration

### Essential Settings (.env file)

```ini
# Your project name (used for container name)
PROJECT_NAME=my-project

# Path to your code (Windows paths auto-converted)
PROJECT_PATH=C:\Users\YourName\Projects\MyBigProject
# Or use relative paths:
# PROJECT_PATH=..                    # Parent directory
# PROJECT_PATH=..\..                 # Two levels up

# Git configuration
GIT_USER_NAME=Your Name
GIT_USER_EMAIL=you@example.com

# API Keys (get from respective websites)
GITHUB_TOKEN=ghp_xxxxxxxxxxxx      # https://github.com/settings/tokens
ANTHROPIC_API_KEY=sk-ant-xxx       # https://console.anthropic.com/
```

### Example Windows Paths

```powershell
# Typical Windows project locations
PROJECT_PATH=C:\Users\John\source\repos\MyProject
PROJECT_PATH=D:\Development\CompanyProject
PROJECT_PATH=C:\Work\ClientName\ProjectName

# Network drives also work
PROJECT_PATH=Z:\SharedCode\TeamProject
PROJECT_PATH=\\server\share\project    # UNC paths
```

## 🚀 Daily Usage

### Starting Claude Code

#### Option 1: Using Start Script (Recommended)
```powershell
# From your claude-setup directory
cd C:\YourProject\claude-setup

# Start Claude Code (no rebuild needed after first time)
powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1

# Claude Code launches automatically!

# Or start shell only (no Claude Code)
powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1 -Shell
```

#### Option 2: Using Docker Compose Directly
```powershell
# Start
docker-compose up -d
docker-compose exec claude-dev bash

# The container will automatically start Claude Code
```

### Using Claude Code

Once started, Claude Code runs with full access to your project:

```bash
# Your entire project is mounted at /workspace
# All file operations work seamlessly
# No Windows path issues or limitations

# Claude Code commands available:
claude --help      # See all options
claude chat       # Start a chat session
claude --version  # Check version
```

### Working with Your Code

```bash
# All development tools are available
git status                    # Version control
npm install                   # Node.js packages
python -m pip install -r requirements.txt  # Python packages
gradle build                  # Java projects

# Your changes persist on your Windows filesystem
# Edit files in Windows or in the container - both work!
```

### Stopping and Restarting

```powershell
# Exit Claude Code and container
exit  # or Ctrl+D

# Restart later (instant - no rebuild)
powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1

# Your work is exactly where you left it
```

### Additional Docker Compose Commands

```powershell
# View logs
docker-compose logs -f

# Stop container
docker-compose down

# Restart container
docker-compose restart

# Check status
docker-compose ps
```

## 📚 Documentation

- [Using Relative Paths](docs/RELATIVE_PATHS.md) - Portable path configuration
- [Remote Windows Shares](docs/REMOTE_SHARES.md) - Mount network drives
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📦 What's Included

<details>
<summary>Click to see full tool list</summary>

### Programming Languages & Runtimes
- **Python 3** with pip, virtualenv, poetry, pipenv
- **Node.js 20 LTS** with npm, yarn, pnpm
- **Java 8 SDK** (OpenJDK 8) with Maven & Gradle
- **Go 1.21** with gopls, delve, golangci-lint
- **Rust** (latest) with cargo, rustfmt, clippy
- **.NET 8 SDK** for C# development
- **Claude Code** pre-installed and ready

### Build Tools & Package Managers
- **Gradle 8.5** - Modern Java build tool
- **Maven** - Classic Java build tool
- **npm, yarn, pnpm** - JavaScript package managers
- **pip, poetry, pipenv** - Python package managers
- **cargo** - Rust package manager
- **go mod** - Go modules
- **dotnet** - .NET CLI
- Build essentials (gcc, make, etc.)

### Version Control
- **Git** - Distributed version control
- **GitHub CLI (gh)** - GitHub from the command line
- **Subversion (SVN)** - Legacy version control support

### Frontend Development
- **React** - create-react-app, react-scripts
- **Vue** - @vue/cli
- **Angular** - @angular/cli
- **Vite** - Lightning fast build tool
- **TypeScript** - Typed JavaScript
- **Webpack** - Module bundler
- **ESLint & Prettier** - Code quality
- **Jest** - Testing framework
- **Vercel & Netlify CLI** - Deployment tools
- **Firebase Tools** - Backend services

### Python Development
- **Web Frameworks** - Flask, Django, FastAPI
- **Data Science** - pandas, numpy, matplotlib, jupyter
- **Testing** - pytest
- **Code Quality** - black, flake8, mypy
- **Async** - uvicorn, celery
- **Database** - sqlalchemy, redis
- **Cloud SDKs** - boto3, google-cloud, azure-storage

### Database Clients
- **PostgreSQL** - psql client
- **MySQL** - mysql client  
- **Redis** - redis-cli
- **SQLite3** - sqlite3 CLI

### Development Tools
- **Docker CLI** - Container management
- **jq** - JSON processor
- **tree** - Directory visualization
- **tmux & screen** - Terminal multiplexers
- **htop & iotop** - System monitoring
- **ncdu** - Disk usage analyzer
- **curl & wget** - Download tools
- **nano & vim** - Text editors
- **zip/unzip** - Archive tools
- Network tools (ping, netstat)

### Pre-configured Environment
- Claude Code starts automatically
- Git credentials configured from .env
- npm global packages in user directory
- Python packages in user directory
- Persistent home directory
- Your project mounted at /workspace

</details>

## 🐛 Troubleshooting

### PowerShell Script Error
```powershell
# If you see "cannot be loaded because running scripts is disabled"
powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1

# Or permanently allow scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Docker Not Running
```powershell
# Error: "Docker is not running"
# Solution: Start Docker Desktop from Windows Start Menu
# Wait for Docker to fully start (system tray icon turns green)
```

### Path Issues
```powershell
# If PROJECT_PATH not found, check:
# 1. Path exists: Test-Path "C:\YourPath"
# 2. No typos in path
# 3. Use full absolute path, not relative
```

### Claude Code Not Starting
```powershell
# Force rebuild if Claude Code is missing
powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1 -Rebuild

# Check if installed
docker exec claude-dev which claude

# Or use shell mode to debug
powershell -ExecutionPolicy Bypass -File .\scripts\start-claude.ps1 -Shell
```

### Large Codebase Performance
```ini
# In .env file, increase resources:
CPU_LIMIT=8
MEMORY_LIMIT=16G
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built for use with [Claude Code](https://claude.ai/code)
- Inspired by modern development workflows
- Thanks to all contributors!

## 🔗 Links

- [Report Issues](https://github.com/TheClark/claude-dev-env/issues)
- [Discussions](https://github.com/TheClark/claude-dev-env/discussions)  
- [Wiki](https://github.com/TheClark/claude-dev-env/wiki)

---

<p align="center">
  Made with ❤️ for developers who love Claude
</p>