#!/bin/zsh

# Jekyll setup for Foam repositories
# Wrapper function for setup-jekyll-foam.sh script

function foam-jekyll() {
    local script_path="$HOME/App.configs/zsh/scripts/functions/setup_jekyll_foam.script"
    
    # Check if script exists
    if [[ ! -f "$script_path" ]]; then
        echo "Error: Jekyll setup script not found at $script_path"
        return 1
    fi
    
    # Check if target directory is provided
    if [[ $# -eq 0 ]]; then
        # If no argument, use current directory
        echo "Setting up Jekyll for current directory: $(pwd)"
        /bin/bash "$script_path" "$(pwd)"
    else
        # Use provided directory
        /bin/bash "$script_path" "$1"
    fi
}

# Alias for convenience
alias fj="foam-jekyll"
alias foam-jekyll-setup="foam-jekyll"