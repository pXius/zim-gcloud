# Purpose: Find Google Cloud SDK, set up the environment, and define functions.
# This runs BEFORE the completion system is initialized.

# --- Find the Google Cloud SDK ---
# Use a local variable to avoid polluting the global scope.
local gcloud_sdk_home_found=""

if [[ -z "${CLOUDSDK_HOME}" ]]; then
  setopt local_options null_glob
  local search_locations=(
    "$HOME/google-cloud-sdk"
    "/usr/local/share/google-cloud-sdk"
    "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    "/opt/homebrew/share/google-cloud-sdk"
    "/usr/share/google-cloud-sdk"
    "/snap/google-cloud-sdk/current"
    "/snap/google-cloud-cli/current"
    "/usr/lib/google-cloud-sdk"
    "/usr/lib64/google-cloud-sdk"
    "/opt/google-cloud-sdk"
    "/opt/google-cloud-cli"
    "/opt/local/libexec/google-cloud-sdk"
    "$HOME/.asdf/installs/gcloud"/*/
  )

  for gcloud_sdk_location in "${search_locations[@]}"; do
    if [[ -d "${gcloud_sdk_location}" ]]; then
      gcloud_sdk_home_found="${gcloud_sdk_location}"
      break
    fi
  done
  unset gcloud_sdk_location search_locations
fi

# If we found a location, set the global CLOUDSDK_HOME.
if [[ -n "$gcloud_sdk_home_found" ]]; then
  CLOUDSDK_HOME="$gcloud_sdk_home_found"
fi
unset gcloud_sdk_home_found

# --- Setup Environment and Define Functions if SDK was found ---
if [[ -n "${CLOUDSDK_HOME}" ]]; then
  export CLOUDSDK_HOME

  # Add gcloud binaries to PATH
  if [[ -f "${CLOUDSDK_HOME}/path.zsh.inc" ]]; then
    source "${CLOUDSDK_HOME}/path.zsh.inc"
  fi

  # Define completion functions only once per session to be safe.
  if [[ -z "${__GCLOUD_COMPLETION_FUNCS_DEFINED:-}" ]]; then
    __GCLOUD_COMPLETION_FUNCS_DEFINED=1

    _python_argcomplete() {
        local prefix=
        if [[ $COMP_LINE == 'gcloud '* ]]; then
            if [[ $3 == ssh && $2 == *@* ]]; then
                prefix=${2%@*}@
                COMP_LINE=${COMP_LINE%$2}"${2#*@}"
            elif [[ $2 == *'='* ]]; then
                prefix=${2%=*}'='
                COMP_LINE=${COMP_LINE%$2}${2/'='/' '}
            fi
        fi
        local IFS=$'\v'
        COMPREPLY=( $(IFS="$IFS" \
            COMP_LINE="$COMP_LINE" \
            COMP_POINT="$COMP_POINT" \
            _ARGCOMPLETE_COMP_WORDBREAKS="$COMP_WORDBREAKS" \
            _ARGCOMPLETE=1 \
            "$1" 8>&1 9>&2 1>/dev/null 2>/dev/null) )
        if [[ $? != 0 ]]; then
            unset COMPREPLY
            return
        fi
        if [[ ${#COMPREPLY[@]} == 1 && $COMPREPLY != *[=' '] ]]; then
            COMPREPLY+=' '
        fi
        if [[ -n "$prefix" ]]; then
            for i in {1..${#COMPREPLY[@]}}; do
                COMPREPLY[$i-1]=$prefix${COMPREPLY[$i-1]}
            done
        fi
    }

    _completer() {
        local command=$1 name=$2
        # Use a temporary variable to hold commands to avoid relying on eval's timing.
        local -a commands_list
        if (( ! ${+__GCLOUD_COMMANDS_CACHE[$name]} )); then
            __GCLOUD_COMMANDS_CACHE[$name]="$(${(z)command})"
        fi
        commands_list=("${(f)__GCLOUD_COMMANDS_CACHE[$name]}")

        # Basic completion logic
        local current_word=$words[CURRENT]
        COMPREPLY=(${(M)commands_list:#$current_word*})
    }

    _bq_completer() {
        _completer "CLOUDSDK_COMPONENT_MANAGER_DISABLE_UPDATE_CHECK=1 bq help | grep '^[^ ][^ ]*  ' | sed 's/ .*//'" bq
    }

  fi
fi

# Initialize a global associative array for caching if it doesn't exist
typeset -gA __GCLOUD_COMMANDS_CACHE &>/dev/null