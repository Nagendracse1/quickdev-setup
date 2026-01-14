# Contributing to QuickDev Setup

Thank you for your interest in contributing! We're excited to have you help improve QuickDev Setup.

## Getting Started

### Prerequisites
- macOS 11+ (for macOS support)
- Git
- Bash 4+
- Basic shell scripting knowledge

### Local Development Setup

1. **Fork and clone** the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/quickdev-setup.git
   cd quickdev-setup
   ```

2. **Review the project structure**:
   ```
   quickdev-setup/
   ├── setup.sh                # Main setup entry point
   ├── install.sh              # Installer logic
   ├── scripts/
   │   ├── macos/             # macOS-specific scripts (planned)
   │   └── linux/             # Linux-specific scripts (planned)
   ├── create-demo.sh          # Demo creation
   ├── README.md               # Project documentation
   └── CONTRIBUTING.md         # This file
   ```

3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/issue-name
   ```

## How to Contribute

### Types of Contributions

#### 🐛 Bug Reports
- Open an issue describing the bug
- Include your macOS/Linux version, shell, and steps to reproduce
- Attach relevant error logs

#### ✨ New Features
- Check existing issues first to avoid duplicates
- Create an issue describing the feature and use case
- Wait for feedback before starting work

#### 📚 Documentation
- Improve README, add examples, or clarify setup steps
- Help with comments in shell scripts

#### 💻 Code Contributions

**Shell Script Guidelines**:
- Use ShellCheck (`shellcheck *.sh`) to validate scripts
- Follow existing code style (2-space indentation)
- Add comments for complex logic
- Test on both bash and zsh (macOS default)
- Use `set -e` for error handling where appropriate

**Testing Your Changes**:
```bash
# Run shellcheck
shellcheck setup.sh install.sh

# Test the setup script
./setup.sh --help
./setup.sh --dry-run

# Full test (only if you understand what it does)
# ./setup.sh
```

#### 🖥️ Platform Support (Linux/Windows)
We're actively seeking contributions for:
- Linux installation scripts (`scripts/linux/`)
- Windows support exploration
- Cross-platform testing and validation

### Development Workflow

1. **Make your changes** on your feature branch
2. **Write clear commit messages**:
   ```
   feat: add redis-cli installation support
   fix: correct homebrew permissions issue
   docs: clarify setup prerequisites
   ```
3. **Run tests and validation**:
   ```bash
   shellcheck *.sh
   ```
4. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
5. **Create a Pull Request** with:
   - Clear title and description
   - Reference any related issues (#123)
   - Explain what changed and why

## Pull Request Process

1. Update README.md if needed
2. Ensure shellcheck passes
3. Add tests or validation steps in PR description
4. Link to related issues
5. Maintainers will review and provide feedback

## Code Style

- **Indentation**: 2 spaces
- **Variable names**: use_snake_case
- **Constants**: ALL_CAPS
- **Comments**: Explain the "why", not the "what"
- **Error handling**: Check exit codes and provide helpful messages

Example:
```bash
# Install package using appropriate package manager
if command -v brew &> /dev/null; then
  brew install package-name
else
  echo "Error: Homebrew not found. Please install Homebrew first."
  exit 1
fi
```

## Roadmap & Good First Issues

Interested but not sure where to start? Check the **Roadmap** section in README or look for issues tagged:
- `good first issue` - Perfect for newcomers
- `help wanted` - We'd love your input
- `os:linux` - Linux platform work
- `os:windows` - Windows exploration

## Questions?

- 📖 Check existing issues and Discussions
- 💬 Start a Discussion for questions
- 📧 Reach out to maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for helping make QuickDev Setup better!** 🎉
