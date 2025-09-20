# Set CLOUDSDK_HOME if it is not already set.
if [[ -z "${CLOUDSDK_HOME}" ]]; then
  # Common locations for the Google Cloud SDK.
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
    "$HOME/.asdf/installs/gcloud/*/"
  )

  # Set CLOUDSDK_HOME if a directory is found.
  for gcloud_sdk_location in "${search_locations[@]}"; do
    if [[ -d "${gcloud_sdk_location}" ]]; then
      CLOUDSDK_HOME="${gcloud_sdk_location}"
      break
    fi
  done
  unset gcloud_sdk_location search_locations
fi

# If CLOUDSDK_HOME is set, source the necessary files.
if [[ -n "${CLOUDSDK_HOME}" ]]; then
  # Source the path file to add gcloud to the PATH.
  if [[ -f "${CLOUDSDK_HOME}/path.zsh.inc" ]]; then
    source "${CLOUDSDK_HOME}/path.zsh.inc"
  fi

  # Possible locations
  comp_files=(
    "${CLOUDSDK_HOME}/completion.zsh.inc"             # Default location
    "/usr/share/google-cloud-sdk/completion.zsh.inc"  # apt-based location
  )

  # Loop through the possible locations and source the completion file if found.
  for comp_file in "${comp_files[@]}"; do
    if [[ -f "${comp_file}" ]]; then
      source "${comp_file}"
      break
    fi
  done
  unset comp_file comp_files

  export CLOUDSDK_HOME
fi