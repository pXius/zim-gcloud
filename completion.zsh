# Purpose: Register the completion functions for gcloud, bq, and gsutil.
# This runs AFTER the completion system is initialized by Zimfw.

# Check that the main init script successfully found the SDK and defined the functions
# before attempting to register completions.
if [[ -n "${CLOUDSDK_HOME:-}" && -n "${__GCLOUD_COMPLETION_FUNCS_DEFINED:-}" ]]; then
  # The compdef command is now guaranteed to exist.
  compdef _python_argcomplete gcloud
  compdef _python_argcomplete gsutil
  compdef _bq_completer bq
fi