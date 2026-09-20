#!/bin/bash

BASHRC="$HOME/.bashrc"
CONDA_PATH="/miniconda/etc/profile.d/conda.sh"

# 1. Use sed to delete lines containing the Conda path
if grep -q "$CONDA_PATH" "$BASHRC"; then
    echo "Removing Conda path from .bashrc..."
    sed -i "s|^__conda_setup=.*|: # CONDA_HOOK_DISABLED|g" "$BASHRC"
else
    echo "Conda path was not found in .bashrc"
fi

# 2. Optional: Remove manual PYTHONPATH if it exists (System python doesn't need it)
sed -i '/^export PYTHONPATH=/d' "$BASHRC"

# 3. Enforce system python priority
if ! grep -q 'export PATH="/usr/bin:$PATH"' "$BASHRC"; then
    echo "Ensuring /usr/bin priority in .bashrc..."
    echo 'export PATH="/usr/bin:$PATH"' >> "$BASHRC"
fi


# 4. Ensure python maps to python3
if [ ! -f /usr/bin/python ]; then
    echo "Creating symlink for /usr/bin/python..."
    ln -sf /usr/bin/python3 /usr/bin/python
fi
source ~/.bashrc
echo "Done. Please run: source ~/.bashrc"