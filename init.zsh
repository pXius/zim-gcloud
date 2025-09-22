# This module provides completions for gcloud.

# Zimfw sets the `$zmodule` variable to the path of the current module.
# We add this path to the Zsh function path (`fpath`).
#
# Zsh's completion system will automatically find the `_gcloud` file
# inside the `functions` subdirectory of any directory in the fpath.

fpath=("$zmodule" $fpath)