# Enhanced Claude Code with Development Tools
FROM ghcr.io/anthropics/claude-code:latest

USER root

# Install system dependencies and development tools
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    cmake \
    pkg-config \
    # Version control
    git \
    git-lfs \
    subversion \
    mercurial \
    # Cloud CLIs dependencies
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    # Database clients
    postgresql-client \
    mysql-client \
    redis-tools \
    sqlite3 \
    mongodb-clients \
    # Network tools
    curl \
    wget \
    httpie \
    netcat \
    telnet \
    dnsutils \
    iputils-ping \
    traceroute \
    # Text processing
    jq \
    yq \
    xmlstarlet \
    # Terminal tools
    tmux \
    screen \
    htop \
    tree \
    fzf \
    ripgrep \
    fd-find \
    bat \
    # Archive tools
    zip \
    unzip \
    tar \
    gzip \
    bzip2 \
    xz-utils \
    # Development libraries
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    libjpeg-dev \
    zlib1g-dev \
    # Other useful tools
    rsync \
    openssh-client \
    vim \
    nano \
    less \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI (for Docker-in-Docker operations)
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update && \
    apt-get install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin && \
    rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js 20 LTS and package managers
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g \
        yarn \
        pnpm \
        npm@latest \
        # React and frontend tools
        create-react-app \
        create-next-app \
        @vue/cli \
        @angular/cli \
        vite \
        parcel \
        webpack-cli \
        # Development tools
        nodemon \
        pm2 \
        concurrently \
        cross-env \
        dotenv-cli \
        # Testing tools
        jest \
        mocha \
        cypress \
        playwright \
        # Linting and formatting
        eslint \
        prettier \
        stylelint \
        # TypeScript
        typescript \
        ts-node \
        tsx \
        # API development
        @nestjs/cli \
        express-generator \
        fastify-cli \
        # Documentation
        jsdoc \
        typedoc \
        # Package management
        npm-check-updates \
        npkill \
        # Build tools
        turbo \
        nx \
    && rm -rf /var/lib/apt/lists/*

# Install Python development tools
RUN pip3 install --no-cache-dir \
    # Package managers
    poetry \
    pipenv \
    pip-tools \
    # Development tools
    black \
    isort \
    flake8 \
    pylint \
    mypy \
    bandit \
    safety \
    # Testing
    pytest \
    pytest-cov \
    pytest-asyncio \
    pytest-mock \
    tox \
    # Web frameworks
    django \
    fastapi \
    flask \
    tornado \
    aiohttp \
    # Data science
    numpy \
    pandas \
    matplotlib \
    seaborn \
    scikit-learn \
    jupyter \
    notebook \
    ipython \
    # Database
    sqlalchemy \
    alembic \
    psycopg2-binary \
    pymongo \
    redis \
    # API tools
    requests \
    httpx \
    beautifulsoup4 \
    scrapy \
    # Documentation
    sphinx \
    mkdocs \
    mkdocs-material \
    # CLI tools
    click \
    typer \
    rich \
    # Async
    asyncio \
    aiofiles \
    # DevOps
    ansible \
    fabric \
    # Cloud SDKs
    boto3 \
    google-cloud-storage \
    azure-storage-blob \
    # Other useful packages
    python-dotenv \
    pyyaml \
    watchdog \
    schedule \
    celery

# Install Go
RUN wget -q https://go.dev/dl/go1.21.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz && \
    rm go1.21.5.linux-amd64.tar.gz && \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    echo 'source $HOME/.cargo/env' >> /etc/profile

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws/

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    apt-get install -y terraform && \
    rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install Helm
RUN curl https://get.helm.sh/helm-v3.13.3-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf linux-amd64

# Install k9s (Kubernetes CLI)
RUN wget https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz && \
    tar xzf k9s_Linux_amd64.tar.gz && \
    mv k9s /usr/local/bin/ && \
    rm k9s_Linux_amd64.tar.gz

# Install useful development tools
RUN pip3 install --no-cache-dir \
    cookiecutter \
    pre-commit \
    commitizen \
    bump2version

# Install database migration tools
RUN npm install -g \
    prisma \
    typeorm \
    sequelize-cli \
    knex

# Install API testing tools
RUN npm install -g \
    @stoplight/prism-cli \
    newman \
    insomnia-inso

# Install code quality tools
RUN npm install -g \
    sonarqube-scanner \
    snyk \
    retire

# Switch back to claude user
USER claude

# Set up development environment
RUN mkdir -p ~/.config ~/.cache ~/.local/share

# Configure git globals (will be overridden by mounted config)
RUN git config --global init.defaultBranch main && \
    git config --global pull.rebase false && \
    git config --global core.editor vim

# Install VS Code extensions for better code understanding
RUN code --install-extension dbaeumer.vscode-eslint && \
    code --install-extension esbenp.prettier-vscode && \
    code --install-extension ms-python.python && \
    code --install-extension golang.go && \
    code --install-extension rust-lang.rust-analyzer && \
    code --install-extension bradlc.vscode-tailwindcss && \
    code --install-extension prisma.prisma && \
    code --install-extension redhat.vscode-yaml && \
    code --install-extension ms-azuretools.vscode-docker

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    NODE_ENV=development \
    PATH="/home/claude/.local/bin:/home/claude/.cargo/bin:/usr/local/go/bin:${PATH}" \
    EDITOR=vim

# Create workspace directory
WORKDIR /workspace

# Set entrypoint
ENTRYPOINT ["/bin/bash"]