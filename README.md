# dun
Lightweight meeting notes and todo tasks CLI

Add the following to .profile or .bashrc to enable bash tab complete.

> _dun() {
    COMPREPLY=()
    COMPREPLY=( $(compgen -W "$(dun bash-complete-options)" -- $2) )
  }
  complete -F _dun dun

