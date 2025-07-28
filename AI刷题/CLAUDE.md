# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal study notes repository focused on AI certification preparation, specifically for HCIA-AI (Huawei Certified ICT Associate - Artificial Intelligence). The repository is structured as a comprehensive collection of technical documentation covering various topics in AI, machine learning, cloud computing, and software development.

## Repository Structure

The repository is organized into topic-based directories:

- **AI刷题/**: Current working directory containing HCIA-AI certification study materials
- **DeepSeek/**: Research papers and analysis on DeepSeek AI models
- **Dify/**: Documentation for Dify platform deployment and management
- **LLM/**: Large Language Model development scripts and guides
- **Docker/**: Container technology guides and best practices
- **Linux/**: System administration and shell scripting
- **JAVA/**: Java programming fundamentals and JVM concepts
- **Git/**: Version control workflows and GitHub Actions
- **Kubernetes/**: Container orchestration and KubeSphere guides
- **Database systems/**: MySQL, Redis, NebulaGraph documentation
- **Monitoring/**: Prometheus, Grafana, Zipkin configurations

## Key File Types and Patterns

### Documentation Format
- Primary format: Markdown (.md files)
- Image references: Stored in `imgs/` subdirectories using relative paths
- Naming convention: `【Category】Topic.md` format for Chinese documentation
- English documentation: Located in `en/` subdirectories for internationalization

### Study Materials Structure
- **Day01.md**: Daily study progress and question analysis
- **HCIA-AI重点.md**: Key exam points with detailed explanations
- **HCIA-AI重点整理.md**: Organized summary of important concepts

Each study document includes:
- Question analysis with answer explanations
- Technical concept breakdowns
- Memory aids and mnemonics (记忆口诀)
- Comparison tables for similar concepts

### Scripts and Automation
- **chatgpt.py**: Local ChatGPT API integration script
- **process_markdown.py**: Markdown file processing utilities
- **Docker/shell scripts**: Deployment automation
- **YAML configurations**: Docker Compose and Kubernetes manifests

## Working with Study Materials

### When Analyzing HCIA-AI Content
1. **Question Format**: Most questions include multiple choice answers with detailed explanations
2. **Visual Elements**: Screenshots and diagrams are referenced as `![description](./imgs/filename.png)`
3. **Answer Structure**: Each question provides:
   - Correct answer identification
   - Option-by-option analysis
   - Extended knowledge points
   - Memory techniques (口诀)

### When Modifying Documentation
1. **Maintain Format Consistency**: Follow existing patterns for headings, tables, and code blocks
2. **Image Handling**: Place new images in appropriate `imgs/` directories
3. **Cross-References**: Update related documents when making conceptual changes
4. **Language Consistency**: Keep Chinese technical terms in original language with English explanations where helpful

## Development Environment

### No Build System
This repository does not contain traditional software projects with build scripts. It's primarily documentation-based with:
- No package.json, Makefile, or build configurations
- No dependency management requirements
- No test suites to run

### File Operations
- **Reading**: All files are plain text (Markdown, YAML, Python scripts)
- **Editing**: Direct file modification without compilation steps
- **Validation**: Manual review of Markdown rendering and link integrity

## Common Tasks

### Adding New Study Content
1. Create appropriately named Markdown files in relevant directories
2. Add supporting images to corresponding `imgs/` subdirectories
3. Update any index or summary documents as needed
4. Maintain consistent formatting with existing materials

### Updating Technical Documentation
1. Review related files for cross-references that may need updates
2. Verify technical accuracy, especially for rapidly evolving topics like AI/ML
3. Update both Chinese and English versions if applicable

### Managing Scripts and Configurations
1. **Python scripts**: Located in topic-specific directories, usually standalone
2. **Docker configurations**: Include both Dockerfiles and docker-compose.yaml files
3. **Shell scripts**: Often for deployment automation, maintain executable permissions

## Repository Context

This appears to be a personal knowledge management system for a technical professional studying for AI certifications while maintaining documentation across multiple technology domains. The content suggests expertise in cloud-native technologies, AI/ML concepts, and enterprise software development.

When working with this repository, prioritize maintaining the educational value and organizational structure that supports learning and reference purposes.