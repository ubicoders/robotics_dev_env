#!/bin/bash
BASHRC="$HOME/.bashrc"
# Identify the file used in the conda init block
CONDA_BLOCK_FILE="/miniconda/etc/profile.d/conda.sh"

echo "Switching to Conda..."

# 1. Remove forced system path
sed -i '/^export PATH="\/usr\/bin:\$PATH"/d' "$BASHRC"

# 2. Re-enable or Initialize Conda
if grep -q "__conda_setup" "$BASHRC" || grep -q "CONDA_HOOK_DISABLED" "$BASHRC"; then
    echo "Re-enabling Conda in .bashrc..."
    # Restore the hook if it was disabled by use_system_python.bash
    sed -i "s|: # CONDA_HOOK_DISABLED|__conda_setup=\"\$('/miniconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)\"|g" "$BASHRC"
    
    # Clean up legacy disabled lines (if any remain from previous versions)
    sed -i "s|: # CONDA_DISABLED|. \"/miniconda/etc/profile.d/conda.sh\"|g" "$BASHRC"
else
    echo "Initializing Conda in .bashrc..."
    # If the block is missing entirely, let conda generate it
    /miniconda/bin/conda init bash
fi

# 3. Clean up manual exports (legacy)
sed -i '/^export PATH="\/miniconda\/bin:\$PATH"/d' "$BASHRC"

# 4. Activate base environment explicitly
echo "Activating conda base..."
export PATH="/miniconda/bin:$PATH"
eval "$(/miniconda/bin/conda shell.bash hook)"
conda activate base

source ~/.bashrc

echo "Done. Please run: source ~/.bashrc"