if [[ -z "${CLOUDSDK_HOME}" ]]; then
  setopt local_options null_glob

  search_locations=(
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
      CLOUDSDK_HOME="${gcloud_sdk_location}"
      break
    fi
  done
fi

if [[ -n "${CLOUDSDK_HOME}" ]]; then
  export CLOUDSDK_HOME

  if [[ -f "${CLOUDSDK_HOME}/path.zsh.inc" ]]; then
    source "${CLOUDSDK_HOME}/path.zsh.inc"
  fi

  if [[ -z "${__GCLOUD_COMPLETION_LOADED:-}" ]]; then
    __GCLOUD_COMPLETION_LOADED=1

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
        command=$1
        name=$2
        eval '[[ -n "$'"${name}"'_COMMANDS" ]] || '"${name}"'_COMMANDS="$('"${command}"')"'
        set -- $COMP_LINE
        shift
        while [[ $1 == -* ]]; do
              shift
        done
        [[ -n "$2" ]] && return
        grep -q "${name}\s*$" <<< $COMP_LINE &&
            eval 'COMPREPLY=($'"${name}"'_COMMANDS)' &&
            return
        [[ "$COMP_LINE" == *" " ]] && return
        [[ -n "$1" ]] &&
            eval 'COMPREPLY=($(echo "$'"${name}"'_COMMANDS" | grep ^'"$1"'))'
    }

    unset bq_COMMANDS
    _bq_completer() {
        _completer "CLOUDSDK_COMPONENT_MANAGER_DISABLE_UPDATE_CHECK=1 bq help | grep '^[^ ][^ ]*  ' | sed 's/ .*//'" bq
    }

    complete -o nospace -o default -F _python_argcomplete gcloud
    complete -o default -F _bq_completer bq
    complete -o nospace -F _python_argcomplete gsutil
  fi
fi
