" Language: dun
" Maintainer: Oliver Fields

if exists("b:current_syntax")
  finish
endif

syntax keyword dunTODO TODO
syntax keyword dunWAIT WAIT
syntax keyword dunWONT WONT
syntax keyword dunDONE DONE
syntax match dunTag "\v#\a{1,}"

highlight link dunTODO DiffDelete
highlight link dunWAIT SpellBad
highlight link dunWONT CursorColumn
highlight link dunDONE StatusLineTermNC
highlight link dunTag DiffAdd

let b:current_syntax = "dun"
