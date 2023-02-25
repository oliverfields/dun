#!/bin/bash

# Source this file in .profile or .bashrc to enable bash tab complete
# e.g.
# source <path>/dun-bash-tab-complete.sh

_dun() {
  COMPREPLY=()
  COMPREPLY=( $(compgen -W "$(dun bash-complete-options)" -- $2) )
}
complete -F _dun dun

