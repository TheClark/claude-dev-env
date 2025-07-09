# Using Relative Paths in Claude Dev Setup

## Overview

The Claude Dev setup supports relative paths in the `PROJECT_PATH` environment variable, making it easy to place the claude-setup folder inside your project and use it from anywhere.

## How It Works

When you specify a relative path in your `.env` file, the scripts automatically resolve it relative to the `claude-setup` directory location.

## Common Use Cases

### 1. Claude Setup Inside Project

```
my-project/
├── src/
├── tests/
├── claude-setup/        # Claude setup here
│   ├── .env            # PROJECT_PATH=../
│   └── scripts/
└── package.json
```

**.env configuration:**
```bash
PROJECT_PATH=../
```

### 2. Claude Setup in Tools Directory

```
my-project/
├── backend/
├── frontend/
├── tools/
│   └── claude-setup/   # Claude setup here
│       └── .env       # PROJECT_PATH=../../
└── README.md
```

**.env configuration:**
```bash
PROJECT_PATH=../../
```

### 3. Separate Backend/Frontend Projects

```
my-workspace/
├── backend/
├── frontend/
└── claude-setup/       # Shared setup
    ├── backend.env    # PROJECT_PATH=../backend
    └── frontend.env   # PROJECT_PATH=../frontend
```

**backend.env:**
```bash
PROJECT_NAME=my-backend
PROJECT_PATH=../backend
```

**frontend.env:**
```bash
PROJECT_NAME=my-frontend
PROJECT_PATH=../frontend
```

**Usage:**
```bash
# For backend
./scripts/start-claude.sh --env backend.env

# For frontend
./scripts/start-claude.sh --env frontend.env
```

### 4. Monorepo Structure

```
monorepo/
├── apps/
│   ├── web/
│   └── api/
├── packages/
│   ├── ui/
│   └── utils/
└── tools/
    └── claude-setup/   # PROJECT_PATH=../../
        └── .env
```

**.env configuration:**
```bash
PROJECT_PATH=../../
```

## Path Resolution Examples

| Relative Path | Resolves From | Example Result |
|--------------|---------------|----------------|
| `../` | `/project/claude-setup/` | `/project/` |
| `../../` | `/project/tools/claude-setup/` | `/project/` |
| `../backend` | `/workspace/claude-setup/` | `/workspace/backend/` |
| `../../../shared` | `/a/b/c/claude-setup/` | `/a/shared/` |

## Benefits

1. **Portability**: Move the entire project anywhere, relative paths still work
2. **Version Control**: Commit claude-setup with your project
3. **Team Sharing**: Everyone uses the same relative structure
4. **No Hardcoded Paths**: No need to update paths for different machines

## Best Practices

### 1. Project Template

Create a project template with claude-setup included:

```bash
# Create template
mkdir -p my-template/claude-setup
cp -r /path/to/claude-setup/* my-template/claude-setup/

# Set relative path
echo "PROJECT_PATH=../" > my-template/claude-setup/.env

# Use template
cp -r my-template my-new-project
cd my-new-project/claude-setup
./scripts/start-claude.sh
```

### 2. Git Repository Setup

Add to your `.gitignore`:

```gitignore
# Claude setup - keep structure but not secrets
claude-setup/.env
claude-setup/credentials-summary.txt
```

Commit the example:
```bash
git add claude-setup/.env.example
git commit -m "Add Claude dev setup"
```

### 3. Multiple Configurations

For different environments:

```
claude-setup/
├── .env.dev      # PROJECT_PATH=../
├── .env.test     # PROJECT_PATH=../test-data
├── .env.prod     # PROJECT_PATH=/mnt/prod-share
└── scripts/
```

Use with:
```bash
./scripts/start-claude.sh --env .env.dev
./scripts/start-claude.sh --env .env.test
```

### 4. Symlink Alternative

Instead of relative paths, you can use symlinks:

```bash
# Create a symlink to your project
ln -s /absolute/path/to/project ../project-link

# Use in .env
PROJECT_PATH=../project-link
```

## Troubleshooting

### Path Not Found

If you get "Cannot resolve relative path" error:

1. **Check current directory:**
   ```bash
   pwd  # Should be in claude-setup directory
   ```

2. **Verify relative path:**
   ```bash
   # Test the path
   cd /path/to/claude-setup
   cd ../your-relative-path  # Should succeed
   ```

3. **Use absolute path temporarily:**
   ```bash
   # Find absolute path
   cd /your/project && pwd
   # Update .env with absolute path for testing
   ```

### Windows Path Issues

On Windows, relative paths work but consider:

1. **Use forward slashes:**
   ```bash
   # Good
   PROJECT_PATH=../backend
   
   # Avoid
   PROJECT_PATH=..\backend
   ```

2. **WSL path resolution:**
   ```bash
   # The script handles conversion
   PROJECT_PATH=../  # Works in both Windows and WSL
   ```

## Advanced: Dynamic Path Resolution

For complex scenarios, create a wrapper script:

```bash
#!/bin/bash
# find-project.sh

# Search for project markers
PROJECT_ROOT=$(find .. -name "package.json" -o -name "requirements.txt" | head -1 | xargs dirname)

if [[ -n "$PROJECT_ROOT" ]]; then
    echo "PROJECT_PATH=$PROJECT_ROOT" > .env.dynamic
    ./scripts/start-claude.sh --env .env.dynamic
else
    echo "Could not find project root"
    exit 1
fi
```

## Security Considerations

1. **Don't use relative paths for sensitive data:**
   ```bash
   # Avoid
   SSH_PATH=../../../.ssh  # Too many parent directories
   
   # Better
   SSH_PATH=~/.ssh  # Use home directory
   ```

2. **Validate resolved paths:**
   The scripts automatically validate that resolved paths exist and are accessible.

3. **Container isolation:**
   Even with relative paths, the container only has access to the mounted directories.

## Summary

Relative paths make the Claude Dev setup more flexible and portable. Place the setup wherever makes sense for your project structure, and use simple relative paths to point to your code. The scripts handle all the path resolution automatically!