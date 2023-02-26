" Language: dun
" Maintainer: Oliver Fields
" If statuses are changed, this file must be updated too

if exists("b:current_syntax")
  finish
endif

syntax keyword dunTODO TODO
syntax keyword dunBLOCK WAIT
syntax keyword dunDONE WONT DONE
syntax match dunTag "\v#[^ #]+"

highlight link dunTODO DiffAdd
highlight link dunBLOCK WildMenu
highlight link dunDONE StatusLineTermNC
highlight link dunTag DiffDelete

let b:current_syntax = "dun"
