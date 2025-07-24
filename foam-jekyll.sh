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
    
    # Handle different argument patterns
    if [[ $# -eq 0 ]]; then
        # If no argument, use current directory
        echo "Setting up Jekyll for current directory: $(pwd)"
        /bin/bash "$script_path" "$(pwd)"
    elif [[ "$1" == "--uninstall" ]]; then
        # Handle uninstall with optional directory
        if [[ $# -eq 1 ]]; then
            # Uninstall from current directory
            echo "Uninstalling Jekyll from current directory: $(pwd)"
            /bin/bash "$script_path" --uninstall "$(pwd)"
        else
            # Uninstall from specified directory
            /bin/bash "$script_path" --uninstall "$2"
        fi
    else
        # Use provided directory
        /bin/bash "$script_path" "$1"
    fi
}

# Alias for convenience
alias fj="foam-jekyll"
alias foam-jekyll-setup="foam-jekyll"