# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive personal knowledge management system and study repository focused on technical documentation across multiple domains including AI/ML, cloud computing, software development, and system administration. The repository serves as both a learning resource and reference documentation for various technologies.

## Repository Structure & Architecture

### High-Level Organization
The repository follows a topic-based directory structure where each major technology or domain has its own folder:

- **AI刷题/**: AI certification study materials (HCIA-AI) with existing CLAUDE.md
- **LLM/**: Large Language Model scripts and ChatGPT integration (`chatgpt.py`)
- **DeepSeek/**: Research papers and model architecture analysis
- **Dify/**: Platform deployment documentation with Docker Compose configurations
- **Docker/**: Container guides and optimization documentation
- **Linux/**: System administration with shell scripting guides
- **JAVA/**: Programming fundamentals, JVM concepts, and design patterns
- **Git/**: Version control workflows and GitHub Actions automation
- **Infrastructure**: KubeSphere, Prometheus, Grafana, Zipkin configurations
- **Databases**: MySQL, Redis, NebulaGraph deployment and management
- **Specialized Tools**: Nacos, MinIO, Tomcat, Maven documentation

### Documentation Standards
- **Format**: Markdown (.md) files with consistent `【Category】Topic.md` naming
- **Images**: Stored in `imgs/` subdirectories with relative path references
- **Internationalization**: English versions in `en/` subdirectories
- **Cross-references**: Inter-document linking for related concepts

## Key Automation & Scripts

### Docker Infrastructure
```bash
# NebulaGraph cluster management
./NebulaGraph/nebula.sh
./NebulaGraph/docker-compose/docker-compose.yaml

# Nacos service registry
./Nacos/nacos.sh
./Nacos/docker-compose.yaml
```

### Development Scripts
```bash
# LLM integration
python LLM/chatgpt.py

# Markdown processing utilities
python Markdown/Scripts/process_markdown.py

# Git automation
./Git/【Git】优化Git提交脚本.md
```

## Working with This Repository

### No Build System Required
This repository is documentation-focused with no traditional build processes:
- No package.json, Makefile, or compilation steps
- Python scripts are standalone utilities
- Docker services use provided compose files
- Shell scripts handle deployment automation

### Common Development Patterns

#### Adding Documentation
1. Follow existing naming conventions: `【Category】Topic.md`
2. Place images in corresponding `imgs/` directories
3. Maintain cross-references between related documents
4. Update both Chinese and English versions when applicable

#### Working with Docker Services
```bash
# Start NebulaGraph cluster
cd NebulaGraph && ./nebula.sh

# Deploy Nacos
cd Nacos && ./nacos.sh

# Use provided docker-compose configurations
docker-compose -f <service>/docker-compose.yaml up -d
```

#### Script Management
- Python scripts are self-contained in their respective directories
- Shell scripts require executable permissions
- Configuration files (YAML, properties) are service-specific

### Repository Context & Architecture

This knowledge base reflects a cloud-native and AI-focused technical environment:

**Core Technologies**:
- Container orchestration (Docker, Kubernetes, KubeSphere)
- Distributed systems (NebulaGraph, Nacos, Redis)
- AI/ML platforms (Dify, DeepSeek, LLM integration)
- Monitoring stack (Prometheus, Grafana, Zipkin)

**Development Approach**:
- Infrastructure-as-Code with Docker Compose
- Documentation-driven development
- Automation through shell scripting
- Multi-language support (Chinese/English)

The repository serves as both a learning platform for AI certification (HCIA-AI) and a production reference for deploying and managing complex technical systems. When working with this codebase, prioritize maintaining the educational structure while ensuring technical accuracy across the diverse technology domains covered.