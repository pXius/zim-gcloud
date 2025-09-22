# zim-gcloud

A [zimfw](https://zimfw.sh) module that automatically configures the  
[Google Cloud CLI (`gcloud`)](https://cloud.google.com/sdk/docs/install) environment:  

- Adds the `gcloud` binaries to your `PATH`.  
- Enables `zsh` completions for `gcloud`.  

## Prerequisites

You must have the **Google Cloud CLI** installed on your system.  
See the [official installation instructions](https://cloud.google.com/sdk/docs/install) for your platform.  

## Installation

Add the module to your `.zimrc`:

```zsh
zmodule pXius/zim-gcloud
