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
        if [[ $words[1] == gcloud ]]; then
            if [[ $words[2] == ssh && $words[3] == *@* ]]; then
                prefix=${words[3]%@*}@
                COMP_LINE=${COMP_LINE%$words[3]}"${words[3]#*@}"
            elif [[ $words[2] == *'='* ]]; then
                prefix=${words[2]%=*}'='
                COMP_LINE=${COMP_LINE%$words[2]}${words[2]/'='/' '}
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
        reply=("${COMPREPLY[@]}")
    }

    _bq_completer() {
        local cmds
        cmds=$(CLOUDSDK_COMPONENT_MANAGER_DISABLE_UPDATE_CHECK=1 bq help | grep '^[^ ][^ ]*  ' | sed 's/ .*//')
        reply=(${(f)cmds})
    }

    compdef _python_argcomplete gcloud
    compdef _python_argcomplete gsutil
    compdef _bq_completer bq
  fi
fi
