# Foam Jekyll Setup

A shell script to quickly set up Jekyll with Just the Docs theme for Foam knowledge bases, including automatic wikilink conversion support.

## Features

- 🚀 **Quick Setup**: One command to set up Jekyll for your Foam repository
- 🔗 **Wikilink Support**: Automatically includes [jekyll-foam-links](https://github.com/time4Wiley/jekyll-foam-links) plugin
- 📚 **Just the Docs Theme**: Beautiful documentation theme with search
- 🎨 **Mermaid Diagrams**: Built-in support for Mermaid diagrams
- 💎 **Ruby 3.4 Compatible**: Includes necessary gems for Ruby 3.4+
- 🌐 **LAN Access**: Configured for local network access

## Installation

### Option 1: Homebrew (Recommended for macOS)

```bash
brew tap time4wiley/foam
brew install foam-jekyll-setup
```

After installation, you can immediately use:
```bash
foam-jekyll [directory]
# or
fj [directory]
```

### Option 2: Shell Function

1. Clone this repository:
```bash
git clone https://github.com/time4Wiley/foam-jekyll-setup.git
cd foam-jekyll-setup
```

2. Add to your shell configuration:
```bash
# For zsh (add to ~/.zshrc)
source /path/to/foam-jekyll-setup/foam-jekyll.sh

# For bash (add to ~/.bashrc)
source /path/to/foam-jekyll-setup/foam-jekyll.sh
```

3. Reload your shell:
```bash
source ~/.zshrc  # or ~/.bashrc
```

### Option 3: Direct Script Usage

```bash
# Download the script
curl -O https://raw.githubusercontent.com/time4Wiley/foam-jekyll-setup/main/setup-jekyll-foam.sh
chmod +x setup-jekyll-foam.sh

# Run in your Foam repository
./setup-jekyll-foam.sh /path/to/your/foam-repo

# Or uninstall existing setup
./setup-jekyll-foam.sh --uninstall /path/to/your/foam-repo
```

## Usage

Navigate to your Foam repository and run:

```bash
foam-jekyll
# or use the alias
fj
```

The script will:
1. Create a `Gemfile` with all necessary dependencies
2. Set up `_config.yml` with Just the Docs theme and plugins
3. Configure Jekyll to convert `[[wikilinks]]` automatically
4. Create a `run-jekyll.sh` helper script
5. Install all dependencies
6. Optionally start the Jekyll server

### Uninstalling Jekyll Setup

To completely remove the Jekyll setup (useful for reinstalling or updating plugins):

```bash
foam-jekyll --uninstall
# or
fj --uninstall
# or specify a directory
foam-jekyll --uninstall /path/to/your/foam-repo
```

This will:
- Remove all Jekyll-related files (Gemfile, _config.yml, etc.)
- Clean up build directories (public/, _site/, .jekyll-cache/)
- Clear the bundle cache for foam-related gems
- Allow you to run a fresh installation afterward

## What It Sets Up

### Gemfile
- Jekyll 4.3.2
- Just the Docs theme
- Jekyll Foam Links plugin (for wikilink conversion)
- Ruby 3.4 compatibility gems
- Various Jekyll plugins for enhanced functionality

### Configuration
- Builds to `public/` directory
- Enables search functionality
- Configures Mermaid diagram support
- Sets up proper exclusions for Foam/VSCode files
- Enables all useful Jekyll plugins

### Wikilink Support
The included [jekyll-foam-links](https://github.com/time4Wiley/jekyll-foam-links) plugin automatically converts:
- `[[page-name]]` → `[page-name]` with reference definitions
- `![[image-name]]` → `![image-name]` with reference definitions

This happens during build time without modifying your source files!

## Running the Site

After setup, you can start Jekyll with:

```bash
./run-jekyll.sh
# or
bundle exec jekyll serve --host 0.0.0.0 --port 4000
```

Then access:
- Locally: http://localhost:4000
- From LAN: http://YOUR_IP:4000

## Requirements

- Ruby (with bundler gem installed)
- Git (optional, for version control)

To install Ruby and bundler on macOS:
```bash
brew install ruby
gem install bundler
```

## Troubleshooting

### YAML Syntax Error
If you see YAML parsing errors, check that your `_config.yml` doesn't have shell script content mixed in. The file should end with proper YAML syntax.

### Missing CSV Error (Ruby 3.4+)
The script includes the necessary gems for Ruby 3.4 compatibility. If you still see errors, run:
```bash
bundle add csv base64 bigdecimal
bundle install
```

### Port Already in Use
If port 4000 is already in use:
```bash
lsof -ti:4000 | xargs kill -9
```

## Contributing

Pull requests are welcome! Please feel free to submit improvements.

## License

MIT License - feel free to use this in your own projects!

## Related Projects

- [Foam](https://foambubble.github.io/foam/) - Personal knowledge management for VSCode
- [jekyll-foam-links](https://github.com/time4Wiley/jekyll-foam-links) - Jekyll plugin for wikilink conversion
- [Just the Docs](https://just-the-docs.github.io/just-the-docs/) - Documentation theme for Jekyll