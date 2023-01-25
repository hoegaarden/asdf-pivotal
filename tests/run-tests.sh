#!/bin/bash

# This set of tests must be run in a clean environment
# It can either be run in docker of github actions

. $HOME/.asdf/asdf.sh

[[ -z ${DEBUGX:-} ]] || set -x
set -euo pipefail

sep=" "
[[ -z ${ASDF_LEGACY:-} ]] || sep="-"

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"



function test_plugin() {
  local plugin_name=$1

  echo -e "\n#########################################"
  echo -e "####### Starting: ${plugin_name}\n"

  . "${script_dir}/../products.inc.sh" "${plugin_name}"

  echo "Adding plugin $plugin_name"
  asdf plugin${sep}add $plugin_name https://github.com/laidbackware/asdf-github-release-downloader

  echo "Listing $plugin_name"
  asdf list${sep}all $plugin_name

  if [[ -z ${ASDF_LEGACY:-} ]]; then
    echo "Installing $plugin_name"
    asdf install $plugin_name latest
  else
    plugin_version=$(asdf list${sep}all $plugin_name |tail -1)
    echo "Installing $plugin_name $plugin_version"
    asdf install $plugin_name $plugin_version
  fi

  installed_version=$(asdf list $plugin_name | xargs)
  asdf global $plugin_name $installed_version

  if [[ $VERSION_COMMAND != "test_not_possible" ]]; then
    echo -e "\nChecking $plugin_name is executable"
    echo "Running command '$plugin_name $VERSION_COMMAND'"
    "$plugin_name" "$VERSION_COMMAND"
  fi

  echo -e "\n####### Finished: $plugin_name"
  echo -e "#########################################\n"
}

function test_plugins() {
  plugin_name=${1:-}
  if [ -z "${plugin_name:-}" ]; then
    test_plugin bosh
    test_plugin credhub
    test_plugin fly
    test_plugin om
    test_plugin pivnet
    test_plugin bbr
    test_plugin bbr-s3-config-validator
  else
    test_plugin $plugin_name
  fi
}

test_plugins ${1:-}
