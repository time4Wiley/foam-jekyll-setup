# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the Foam Jekyll Setup project - a shell script tool to quickly set up Jekyll with the Just the Docs theme for Foam knowledge bases. It automatically configures wikilink conversion support via the jekyll-foam-links plugin.

## Key Components

- **foam-jekyll.sh**: Wrapper function that sources the main setup script
- **setup-jekyll-foam.sh**: Main installation script that sets up Jekyll in a target Foam repository

## Common Commands

### Installation via Homebrew
```bash
brew tap time4wiley/foam
brew install foam-jekyll-setup
```

### Direct Script Usage
```bash
# Run the setup in a Foam repository
./setup-jekyll-foam.sh /path/to/foam-repo

# Uninstall Jekyll setup
./setup-jekyll-foam.sh --uninstall /path/to/foam-repo

# Or use the wrapper function after sourcing
foam-jekyll [directory]
fj [directory]  # alias

# Uninstall using wrapper
foam-jekyll --uninstall [directory]
fj --uninstall  # uninstalls from current directory
```

### Jekyll Commands (after setup in target repo)
```bash
# Install dependencies
bundle install

# Run Jekyll server
./run-jekyll.sh
# or
bundle exec jekyll serve --host 0.0.0.0 --port 4000

# Build site
bundle exec jekyll build
```

## Architecture & Functionality

The setup script performs these key operations:

1. **Validation**: Checks target directory exists and optionally warns if not a git repo
2. **Configuration Creation**: 
   - Generates `Gemfile` with Jekyll 4.3.2, Just the Docs theme, and Ruby 3.4 compatibility gems
   - Creates `_config.yml` with smart exclusions for Foam/VSCode files
   - Detects and excludes Hugo/Gatsby content if present
3. **Plugin Setup**: Integrates jekyll-foam-links for automatic wikilink conversion
4. **Helper Files**: Creates `run-jekyll.sh` script and Mermaid diagram support
5. **Git Integration**: Optionally commits the setup with a detailed commit message
6. **Dependency Installation**: Runs `bundle install` automatically
7. **Uninstall Support**: Can cleanly remove all Jekyll-related files and clear bundle cache with `--uninstall` flag

## Important Notes

- The script uses bash (not zsh) for broader compatibility
- Includes Ruby 3.4 compatibility gems (csv, base64, bigdecimal)
- Automatically excludes common development files from Jekyll builds
- Configures Jekyll to serve on 0.0.0.0 for LAN access
- The jekyll-foam-links plugin converts `[[wikilinks]]` to standard markdown links at build time without modifying source files