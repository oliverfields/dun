" Language: dun
" Maintainer: Oliver Fields
" If statuses are changed, this file must be updated too

if exists("b:current_syntax")
  finish
endif

syntax keyword dunTODO TODO
syntax keyword dunWAIT WAIT
syntax keyword dunWONT WONT
syntax keyword dunDONE DONE
syntax match dunTag "\v#\a{1,}"

highlight link dunTODO DiffDelete
highlight link dunWAIT WildMenu
highlight link dunWONT StatusLineTermN
highlight link dunDONE StatusLineTermNC
highlight link dunTag DiffAdd

let b:current_syntax = "dun"
