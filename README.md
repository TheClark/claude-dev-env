# Claude Development Environment

🚀 **A comprehensive Docker-based development environment with Claude Code and all modern development tools pre-installed.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Required-blue.svg)](https://www.docker.com/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS-green.svg)](https://github.com/)

## 🎯 Quick Start

```bash
# Clone into your project
git clone https://github.com/TheClark/claude-dev-env.git claude-setup
cd claude-setup

# Configure
cp .env.example .env
# Edit .env - set PROJECT_PATH=../ for parent directory

# Start Claude
./scripts/start-claude.sh --build
```

## ✨ Features

### 🛠️ Development Tools
- **Languages**: Python 3, Node.js 20 LTS, Go, Rust
- **Package Managers**: pip, npm, yarn, pnpm, poetry, pipenv
- **Cloud CLIs**: AWS, Google Cloud, Azure
- **Containers**: Docker, kubectl, Helm
- **Databases**: PostgreSQL, MySQL, MongoDB, Redis clients
- **Frontend**: React, Vue, Angular, Next.js, Vite
- **Testing**: Jest, Pytest, Cypress, Playwright
- **More**: Git, GitHub CLI, tmux, and 50+ tools

### 🔑 Key Benefits
- **📁 Relative Paths**: Use `PROJECT_PATH=../` to mount parent directory
- **🔄 Persistent Storage**: Your work persists between restarts
- **🔐 Credential Management**: Secure mounting of SSH keys and cloud credentials
- **🌐 Remote Shares**: Support for Windows network shares (SMB/CIFS)
- **💻 Cross-Platform**: Works on Windows (WSL2), Linux, and macOS
- **🚀 Multiple Projects**: Run isolated instances for different projects

## 📋 Prerequisites

- Docker Desktop installed and running
- WSL2 (Windows users)
- 8GB+ RAM
- 20GB free disk space

## 🔧 Installation

### Method 1: Clone into Your Project (Recommended)

```bash
# Navigate to your project
cd my-awesome-project

# Clone claude-dev-env
git clone https://github.com/TheClark/claude-dev-env.git claude-setup

# Configure for your project
cd claude-setup
cp .env.example .env
# Edit .env and set PROJECT_PATH=../

# Start developing!
./scripts/start-claude.sh
```

### Method 2: Global Installation

```bash
# Clone to a tools directory
mkdir -p ~/tools
cd ~/tools
git clone https://github.com/TheClark/claude-dev-env.git

# For each project, copy and configure
cp -r ~/tools/claude-dev-env ~/projects/my-project/claude-setup
cd ~/projects/my-project/claude-setup
cp .env.example .env
# Edit .env accordingly
```

### Method 3: Git Submodule

```bash
# Add as a submodule to your project
cd my-project
git submodule add https://github.com/YOUR_USERNAME/claude-dev-env.git claude-setup
git submodule update --init

# Configure
cd claude-setup
cp .env.example .env
# Edit .env with PROJECT_PATH=../
```

## ⚙️ Configuration

### Basic Setup (.env file)

```bash
# Project name (container/volume names)
PROJECT_NAME=my-project

# Project path (relative paths supported!)
PROJECT_PATH=../              # Parent directory
# PROJECT_PATH=../../          # Two levels up
# PROJECT_PATH=../backend     # Sibling directory

# Git config
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="you@example.com"

# Optional: GitHub token for gh CLI
GITHUB_TOKEN=ghp_xxxxxxxxxxxx
```

### Common Project Structures

```
# Claude inside project
my-project/
├── src/
├── claude-setup/         # PROJECT_PATH=../
└── package.json

# Shared setup
workspace/
├── backend/
├── frontend/
└── claude-setup/         # PROJECT_PATH=../backend or ../frontend

# Monorepo
monorepo/
├── apps/
├── packages/
└── tools/
    └── claude-setup/     # PROJECT_PATH=../../
```

## 🚀 Usage

### Starting Claude

```bash
# First time (builds image)
./scripts/start-claude.sh --build

# Normal start
./scripts/start-claude.sh

# Run in background
./scripts/start-claude.sh --detach

# Windows PowerShell
.\scripts\start-claude.ps1
```

### Inside the Container

```bash
# Python development
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Node.js development
npm install
npm run dev

# Use any installed tool
docker --version
kubectl get pods
gh pr create
aws s3 ls
```

### Managing Multiple Projects

```bash
# Different .env files
./scripts/start-claude.sh --env .env.backend
./scripts/start-claude.sh --env .env.frontend

# Or different PROJECT_NAME in each .env
PROJECT_NAME=my-backend
PROJECT_NAME=my-frontend
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

### Programming Languages
- Python 3.11+ with pip, poetry, pipenv
- Node.js 20 LTS with npm, yarn, pnpm
- Go 1.21+
- Rust with cargo
- Java (via apt)
- Ruby (via apt)

### Cloud & DevOps
- AWS CLI v2
- Google Cloud SDK
- Azure CLI
- Terraform
- Ansible
- Docker CLI & Compose
- Kubernetes (kubectl, helm, k9s)

### Databases
- PostgreSQL client
- MySQL client
- MongoDB client
- Redis tools
- SQLite3

### Development Tools
- Git & GitHub CLI
- VS Code (web)
- tmux
- jq, yq
- HTTPie
- Make, CMake
- Pre-commit

### Frontend Tools
- Create React App
- Next.js
- Vue CLI
- Angular CLI
- Vite
- Webpack
- Parcel

### Testing Tools
- Jest
- Mocha
- Cypress
- Playwright
- Pytest
- Coverage tools

### And much more...

</details>

## 🐛 Troubleshooting

### Container won't start
```bash
# Check Docker
docker version

# Check logs
docker logs claude-dev

# Remove old container
docker rm -f claude-dev
```

### Permission issues
```bash
# Fix SSH permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
```

### Path not found
```bash
# Verify relative path
cd claude-setup
ls ../  # Should show your project files
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