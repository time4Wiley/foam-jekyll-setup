#!/bin/bash

# Setup Jekyll with Just the Docs for Foam repositories
# Based on learnings from foam-general Jekyll setup
# Usage: ./setup-jekyll-foam.sh [target-directory]
#        ./setup-jekyll-foam.sh --uninstall [target-directory]

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to uninstall Jekyll setup
uninstall_jekyll() {
    local target_dir="$1"
    
    echo -e "${YELLOW}Uninstalling Jekyll setup from: $target_dir${NC}"
    cd "$target_dir"
    
    # Files and directories to remove
    local items_to_remove=(
        "Gemfile"
        "Gemfile.lock"
        "_config.yml"
        "run-jekyll.sh"
        "_includes/footer_custom.html"
        "public"
        "_site"
        ".jekyll-cache"
        ".sass-cache"
        ".bundle"
        "vendor"
    )
    
    echo -e "${BLUE}The following items will be removed:${NC}"
    for item in "${items_to_remove[@]}"; do
        if [ -e "$item" ]; then
            echo "  - $item"
        fi
    done
    
    # Also check for empty _includes directory
    if [ -d "_includes" ] && [ -z "$(ls -A _includes 2>/dev/null)" ]; then
        echo "  - _includes (empty directory)"
    fi
    
    read -p "Continue with uninstall? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Uninstall cancelled${NC}"
        exit 0
    fi
    
    # Remove items
    for item in "${items_to_remove[@]}"; do
        if [ -e "$item" ]; then
            rm -rf "$item"
            echo -e "${GREEN}Removed: $item${NC}"
        fi
    done
    
    # Remove _includes if empty
    if [ -d "_includes" ] && [ -z "$(ls -A _includes 2>/dev/null)" ]; then
        rmdir "_includes"
        echo -e "${GREEN}Removed: _includes (empty directory)${NC}"
    fi
    
    # Clean bundle cache
    echo -e "${GREEN}Cleaning bundle cache...${NC}"
    rm -rf ~/.bundle/cache/compact_index/*github.com*foam*
    
    echo -e "${GREEN}✅ Jekyll setup uninstalled successfully!${NC}"
    echo -e "${YELLOW}You can now run the setup script again for a fresh installation.${NC}"
    exit 0
}

# Parse arguments
UNINSTALL=false
TARGET_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --uninstall)
            UNINSTALL=true
            shift
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Check if target directory is provided
if [ -z "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Please provide target directory${NC}"
    echo "Usage: $0 [--uninstall] /path/to/foam-repo"
    exit 1
fi

# Verify target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Directory $TARGET_DIR does not exist${NC}"
    exit 1
fi

# Handle uninstall if requested
if [ "$UNINSTALL" = true ]; then
    uninstall_jekyll "$TARGET_DIR"
fi

echo -e "${BLUE}Setting up Jekyll with Just the Docs for: $TARGET_DIR${NC}"

# Change to target directory
cd "$TARGET_DIR"

# Check if it's a git repository
if [ ! -d .git ]; then
    echo -e "${YELLOW}Warning: $TARGET_DIR is not a git repository${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for existing Jekyll setup
if [ -f "_config.yml" ] || [ -f "Gemfile" ]; then
    echo -e "${YELLOW}Warning: Existing Jekyll configuration detected${NC}"
    echo "Found files:"
    [ -f "_config.yml" ] && echo "  - _config.yml"
    [ -f "Gemfile" ] && echo "  - Gemfile"
    read -p "Continue and overwrite existing configuration? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Exiting without changes${NC}"
        exit 0
    fi
fi

# Step 1: Create Gemfile
echo -e "${GREEN}Creating Gemfile...${NC}"
cat > Gemfile << 'EOF'
source "https://rubygems.org"

gem "jekyll", "~> 4.3.2"
gem "just-the-docs", "~> 0.10.1"
gem "webrick", "~> 1.8"
gem "jekyll-foam-links", github: "time4Wiley/jekyll-foam-links", ref: "2a2d52a3b273449d6b7b4a47dcb655ea2a86eabc"

# Ruby 3.4 compatibility - these were previously default gems
gem "csv", "~> 3.0"
gem "base64", "~> 0.2.0"
gem "bigdecimal", "~> 3.1"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
  gem "jekyll-seo-tag", "~> 2.8"
  gem "jekyll-sitemap", "~> 1.4"
  gem "jekyll-relative-links", "~> 0.7.0"
  gem "jekyll-optional-front-matter", "~> 0.3.2"
  gem "jekyll-default-layout", "~> 0.1.5"
  gem "jekyll-titles-from-headings", "~> 0.5.3"
  gem "jemoji", "~> 0.13.0"
  gem "jekyll-github-metadata", "~> 2.16.1"
end
EOF

# Step 2: Create _config.yml with smart exclusions
echo -e "${GREEN}Creating _config.yml...${NC}"

# Detect potential conflicting directories and files
EXTRA_EXCLUDES=""

# Check for Hugo-specific content
if [ -d "domains/hugo" ] || [ -d "content/hugo" ] || [ -f "hugo.toml" ] || [ -f "hugo.yaml" ]; then
    echo -e "${YELLOW}Detected Hugo content - will exclude from Jekyll build${NC}"
    EXTRA_EXCLUDES="$EXTRA_EXCLUDES  - domains/hugo/\n  - content/hugo/\n"
fi

# Check for Gatsby content
if [ -d "gatsby" ] || [ -f "gatsby-config.js" ]; then
    echo -e "${YELLOW}Detected Gatsby content - will exclude from Jekyll build${NC}"
    EXTRA_EXCLUDES="$EXTRA_EXCLUDES  - gatsby/\n"
fi

# Check for other template syntax that might conflict
if grep -r "{{[^{].*[^}]}}" . --include="*.md" 2>/dev/null | grep -v ".git" | grep -v "public" | head -1 > /dev/null; then
    echo -e "${YELLOW}Detected potential template syntax conflicts in markdown files${NC}"
fi

cat > _config.yml << EOF
title: Foam Knowledge Base
description: A personal knowledge management and sharing system for VSCode
theme: just-the-docs

# Build settings
destination: public

# Plugins
plugins:
  - jekyll-foam-links
  - jekyll-feed
  - jekyll-seo-tag
  - jekyll-sitemap
  - jekyll-relative-links
  - jekyll-optional-front-matter
  - jekyll-default-layout
  - jekyll-titles-from-headings
  - jemoji
  - jekyll-github-metadata

# Just the Docs settings
search_enabled: true
mermaid:
  version: "9.4.3"

aux_links:
  "Foam on GitHub": "//github.com/foambubble/foam"

# Footer content
footer_content: "Built with Foam and Jekyll. Powered by Just the Docs theme."

# Include/Exclude
exclude:
  - Gemfile
  - Gemfile.lock
  - node_modules
  - vendor/
  - .taskmaster
  - .vscode
  - .git
  - .env.example
  - CLAUDE.md
  - scripts/
  - "*.sh"
$(echo -e "$EXTRA_EXCLUDES" | sed 's/^$//')
EOF

# Step 3: Create _includes directory and footer_custom.html for Mermaid
echo -e "${GREEN}Setting up Mermaid support...${NC}"
mkdir -p _includes
cat > _includes/footer_custom.html << 'EOF'
<script src="https://cdn.jsdelivr.net/npm/mermaid@9.4.3/dist/mermaid.min.js"></script>
<script>
  var config = {};
  mermaid.initialize(config);
  window.mermaid.init(undefined, document.querySelectorAll('.language-mermaid'));
</script>
EOF

# Step 4: Create or update index.md if it doesn't exist
if [ ! -f index.md ]; then
    echo -e "${GREEN}Creating index.md...${NC}"
    cat > index.md << 'EOF'
---
title: Home
layout: home
nav_order: 1
---

# Foam Knowledge Base

Welcome to your personal knowledge management system built with Foam, VSCode, and Jekyll.

## Quick Links

- [[getting-started]] - Get started with Foam
- [[inbox]] - Quick notes to organize later
- [[todo]] - Task tracking

## Features

This Jekyll site automatically converts Foam's wikilink syntax (`[[page-name]]`) to standard markdown links during build time, thanks to the jekyll-foam-links plugin.

## Mermaid Diagram Example

```mermaid
graph TD
    A[Foam] -->|Creates| B[Markdown Notes]
    B --> C{Linked Thoughts}
    C -->|Visualize| D[Graph]
    C -->|Publish| E[Website]
    E -->|Jekyll| F[GitHub Pages]
```
EOF
fi

# Step 5: Handle assets/css/style.scss if it exists
if [ -f assets/css/style.scss ]; then
    echo -e "${GREEN}Updating existing style.scss for Just the Docs compatibility...${NC}"
    # Check if it has the problematic import statement
    if grep -q '@import "{{ site.theme }}"' assets/css/style.scss; then
        # Create a backup
        cp assets/css/style.scss assets/css/style.scss.bak
        # Replace the problematic import
        sed -i '' 's/@import "{{ site.theme }}";/\/\/ Import Just the Docs theme\n\/\/ Note: When using Just the Docs as a gem theme, custom styles are automatically\n\/\/ loaded after the theme styles, so we don'"'"'t need to explicitly import the theme/' assets/css/style.scss
        echo -e "${YELLOW}Updated assets/css/style.scss (backup created as style.scss.bak)${NC}"
    fi
fi

# Step 6: Add public/ and .jekyll-cache to .gitignore
echo -e "${GREEN}Updating .gitignore...${NC}"
if [ -f .gitignore ]; then
    # Check if entries already exist
    grep -q "^public/$" .gitignore || echo "public/" >> .gitignore
    grep -q "^.jekyll-cache/$" .gitignore || echo ".jekyll-cache/" >> .gitignore
    grep -q "^_site/$" .gitignore || echo "_site/" >> .gitignore
    grep -q "^.sass-cache/$" .gitignore || echo ".sass-cache/" >> .gitignore
    grep -q "^.bundle/$" .gitignore || echo ".bundle/" >> .gitignore
    grep -q "^vendor/$" .gitignore || echo "vendor/" >> .gitignore
else
    cat > .gitignore << 'EOF'
# Jekyll
public/
_site/
.jekyll-cache/
.sass-cache/
.bundle/
vendor/

# MacOS
.DS_Store

# VS Code
.vscode/*
!.vscode/settings.json
!.vscode/extensions.json
!.vscode/foam.json
EOF
fi

# Step 7: Check for bundler early (moved from later)
if ! command -v bundle &> /dev/null; then
    echo -e "${RED}Error: bundler not found.${NC}"
    echo "Please install Ruby and bundler first:"
    echo "  gem install bundler"
    echo
    echo "On macOS with Homebrew:"
    echo "  brew install ruby"
    echo "  gem install bundler"
    exit 1
fi

# Step 8: Create run script
echo -e "${GREEN}Creating run-jekyll.sh script...${NC}"
cat > run-jekyll.sh << 'EOF'
#!/bin/bash
# Run Jekyll with LAN binding
bundle exec jekyll serve --host 0.0.0.0 --port 4000
EOF
chmod +x run-jekyll.sh

# Step 9: Clean up any existing Jekyll artifacts
echo -e "${GREEN}Cleaning up any existing Jekyll artifacts...${NC}"
rm -rf public _site .jekyll-cache .sass-cache

# Step 10: Commit changes if in git repo
if [ -d .git ]; then
    echo -e "${GREEN}Committing Jekyll setup...${NC}"
    git add -A
    git commit -m "feat: add Jekyll documentation site with Just the Docs

- Added Jekyll with Just the Docs theme v0.10.1  
- Included jekyll-foam-links plugin (v0.1.0) for wikilink support
- Pinned jekyll-foam-links to commit 2a2d52a for stability
- Configured for local development and LAN access
- Enabled Mermaid diagram support
- Set up automatic search functionality
- Created run-jekyll.sh helper script

Wikilinks like [[page-name]] are automatically converted to standard
markdown links during build time.

To start: ./run-jekyll.sh
To access: http://localhost:4000

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>" || echo -e "${YELLOW}Nothing to commit or commit failed${NC}"
fi

# Step 11: Install dependencies if bundler exists
if command -v bundle &> /dev/null; then
    echo -e "${GREEN}Installing dependencies...${NC}"
    bundle install
else
    echo -e "${RED}Error: bundler not found. Cannot install dependencies.${NC}"
    echo "Please install Ruby and bundler first:"
    echo "  gem install bundler"
    exit 1
fi

# Step 12: Ask if user wants to start the server
echo
read -p "Start Jekyll server now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Starting Jekyll server...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
    echo
    
    # Start Jekyll with error handling
    if ! bundle exec jekyll serve --host 0.0.0.0 --port 4000; then
        echo
        echo -e "${RED}❌ Jekyll failed to start!${NC}"
        echo
        echo -e "${YELLOW}Common issues and solutions:${NC}"
        echo "1. Liquid syntax errors: Check for template conflicts in markdown files"
        echo "   - Look for {{ }} syntax that might conflict with Jekyll's Liquid"
        echo "   - Consider excluding directories with conflicting syntax in _config.yml"
        echo
        echo "2. Missing dependencies: Run 'bundle install' again"
        echo
        echo "3. Port already in use: Kill existing processes on port 4000:"
        echo "   - lsof -ti:4000 | xargs kill -9"
        echo
        echo "4. For detailed error info, run with --trace:"
        echo "   - bundle exec jekyll serve --trace"
        echo
        echo -e "${GREEN}The Jekyll setup is complete. Fix the errors above and run:${NC}"
        echo "  ./run-jekyll.sh"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Jekyll setup complete!${NC}"
    echo
    echo "To start the server later:"
    echo "  ./run-jekyll.sh"
    echo "  OR"
    echo "  bundle exec jekyll serve --host 0.0.0.0 --port 4000"
    echo
    echo "Access locally: http://localhost:4000"
    echo "Access from LAN: http://YOUR_IP:4000"
fi