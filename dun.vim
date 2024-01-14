" Dun vimrc
" 1. Add to .vim/plug/plugins/start/dun/plugins/dun.vim
" 2. Update notes dir

let g:dun_notes_dir = $HOME.'/Documents/notes'
let g:dun_vimrc = g:dun_notes_dir.'/.dun_vimrc'
let g:current_file_path = expand('%:p:h')
" If current file path starts with dun_notes_dir, then load dun vimrc
if g:current_file_path[0:len(g:dun_notes_dir)-1] ==# g:dun_notes_dir
  if filereadable(g:dun_vimrc)
    exec printf('source %s', g:dun_vimrc)
  endif
endif

