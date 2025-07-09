# Contributing to Claude Dev Environment

First off, thank you for considering contributing to Claude Dev Environment! It's people like you that make this tool better for everyone.

## 🤝 Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct:
- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on what is best for the community
- Show empathy towards other community members

## 🚀 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **System information** (OS, Docker version, etc.)
- **Relevant logs** (docker logs, error messages)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Use case** - Why is this needed?
- **Proposed solution** - How should it work?
- **Alternatives considered** - What other solutions did you think about?
- **Additional context** - Screenshots, examples, etc.

### Adding New Tools

Want to add a new development tool? Great! Please:

1. **Check if it's already included** - Search the Dockerfile
2. **Consider the size impact** - We want to keep the image reasonably sized
3. **Test thoroughly** - Ensure it works with existing tools
4. **Document it** - Update the README tool list

### Pull Requests

1. Fork the repo and create your branch from `main`
2. Follow the existing code style
3. Test your changes thoroughly
4. Update documentation as needed
5. Submit a PR with a clear description

## 📝 Development Process

### Setting Up Development

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/claude-dev-env.git
cd claude-dev-env

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/claude-dev-env.git

# Create a branch
git checkout -b feature/my-new-feature
```

### Testing Changes

```bash
# Test Docker build
docker build -t claude-dev-test .

# Test with a sample project
cp .env.example .env
./scripts/start-claude.sh --build

# Run shell checks
shellcheck scripts/*.sh
```

### Commit Messages

Follow conventional commits:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance tasks

Examples:
```
feat: add Ruby development tools
fix: resolve path issue in Windows PowerShell script
docs: add troubleshooting guide for macOS
```

## 🧪 Testing Guidelines

### What to Test

- [ ] Docker image builds successfully
- [ ] Container starts without errors
- [ ] All documented tools are accessible
- [ ] Scripts work on Linux/WSL/macOS
- [ ] Relative paths resolve correctly
- [ ] Environment variables are passed through

### Testing Commands

```bash
# Basic functionality
docker run --rm claude-dev-test python --version
docker run --rm claude-dev-test node --version
docker run --rm claude-dev-test git --version

# Script functionality
./scripts/start-claude.sh --help
./scripts/setup-credentials.sh

# Path resolution
PROJECT_PATH=../ ./scripts/start-claude.sh
```

## 📚 Documentation

### Where to Document

- **README.md** - User-facing features and quick start
- **docs/** - Detailed guides and troubleshooting
- **Code comments** - Complex logic explanations
- **Commit messages** - Why changes were made

### Documentation Style

- Use clear, simple language
- Include code examples
- Add screenshots for UI elements
- Keep it up to date with code changes

## 🏗️ Project Structure

```
claude-dev-env/
├── Dockerfile              # Main container definition
├── docker-compose.yml      # Compose configuration
├── scripts/               # Shell scripts
│   ├── start-claude.sh    # Main startup script
│   └── ...
├── config/                # Configuration files
├── docs/                  # Documentation
└── .github/              # GitHub specific files
```

## 🎯 Priorities

When contributing, keep these priorities in mind:

1. **Compatibility** - Works across platforms
2. **Simplicity** - Easy to use and understand
3. **Performance** - Reasonable build/start times
4. **Size** - Keep image size manageable
5. **Security** - Don't expose credentials

## 💡 Tips for Contributors

- **Start small** - Fix a typo or improve documentation
- **Ask questions** - Use GitHub Discussions
- **Be patient** - Reviews may take time
- **Be receptive** - Feedback helps improve code
- **Have fun** - Enjoy contributing!

## 🙋 Getting Help

- **GitHub Discussions** - General questions
- **Issues** - Bug reports and features
- **Pull Requests** - Code contributions

Thank you for contributing! 🎉