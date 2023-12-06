# Dun

Free form note taking and follow up tasks using task statuses and tagging.

- A task is a single line in a text file containing a status string (e.g. TODO or DONE)
- Tag lines by adding #string
- Notes are plain text files that contain both notes and zero or more tasks
- Interactive task listing with fuzzy search
- Sync Notes to a remote git repository

![Dun commercial video](https://github.com/oliverfields/dun/blob/main/commercial/dun-commercial.gif)


## Installation

Clone the repo.

```
git clone https://github.com/oliverfields/dun.git
```

Ensure `dun` command is executable.

```
chmod u+x <path to cloned repo>/dun
```

Ensure `dun` command is in the PATH, for example make a symlink to `~/.local/bin`.

```
ln -s <path to cloned repo>/dun ~/.local/bin/dun
```

> **Warning**
> Dun requires that [fzf](https://github.com/junegunn/fzf) is installed


## Getting started

Create a new note.

```
dun new-note <note name, optional>
```

Configured editor opens note, add some text and some tasks then and close.

```
Hello world:)

TODO Call boss
TODO Review X
```

View all open tasks from all note files.

```
dun tasks
```


## Configuration

To change the default configuration copy the example config file and edit it.

```
cp <path to cloned repo>/dun.conf_example ~/.config/dun.conf
```


## Editor

Dun uses vim as default editor, but changing that can be configured by adding a bash function to `~/.config/dun.conf`.

```
_dun_open_editor() {
  filename=$1

  # If line_number (second argument) is present, use it to open editor on
  # the correct line, this is dependent on you editor
  [ $# -eq 2 ] && line_option="+$2"

  # Open the file
  #emacs $line_option "$filename"
  nano $line_option "$filename"
}
```

Support for syntax highlighting in other editors is not implemented.


## Vim support

Vim supports provides:

- vim highlighting of statuses and tags
- Key binding ds (type in quick succession) to set status of current line from popup list
- Dictionary completion(Ctrl+p) of both statuses and tags

1. Set `VIM_SUPPORT=enabled` in `~/.config/dun.conf`.
2. Add the following to `~/.vimrc`, essentially it says source .dun_vimrc if it exists in the same directory as the file vim has opend.
  ```
  " Load dun vimrc
  let g:dun_notes_dir = $HOME.'/dun'
  let g:dun_vimrc = g:dun_notes_dir.'/.dun_vimrc'
  let g:current_file_path = expand('%:p:h')
  " If current file path starts with dun_notes_dir, then load dun vimrc
  if g:current_file_path[0:len(g:dun_notes_dir)-1] ==# g:dun_notes_dir
    if filereadable(g:dun_vimrc)
      exec printf('source %s', g:dun_vimrc)
    endif
  endif
  ```
3. If the notes directory is also a git repository, add the following to `.gitignore`
  ```
  .dun_vim_dictionary
  .dun_vimrc
  ```


## Bash completion

To enable bash completion of arguments, statuses and tags use the suppied `_dun_bash_completion`.

How this is done is distro dependent, but on Ubuntu it could be enabled by creating a symlink in the `bash-completion.d` directory.

```
$ ln -s <path to dun>/_dun_bash_completion /etc/bash-completion.d/dun_completion
```

Reboot, source or restart to enable.


## Task statuses

Dun uses three status categories. Each category must have at least one, or more, statuses configured. The first status defined for each category is considered the default status.

1. TODO statuses are considered in progress/need work
2. BLOCK statuses indicate the task cannot proceed
3. DONE statuses mean this task needs no more work or attention

Default statuses are:

- TODO statuses: TODO
- BLOCK statuses: WAIT
- DONE statuses: DONE and WONT

