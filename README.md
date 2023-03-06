# Dun

Free form note taking and easily identify tasks in the text to follow up on using statuses and tags.

- A task is a single line in a text file that contains a status string (e.g. TODO or DONE)
- Tag tasks or other lines by adding #string
- Notes(plain text files) contain both notes and zero or more tasks
- CLI for listing tasks found in notes and filtering them by statuses and tags
- Vim for editing notes

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


## Getting started

Create a new note.

```
$ dun new
```

Vim opens, add some text and two tasks to the note and close Vim.

```
Hello world:)

- Call boss TODO
- TODO Review X
```

View all open tasks from all note files.

```
$ dun list
```


## Configuration

To change the default configuration copy the example config file and edit it.

```
cp <path to cloned repo>/dun.conf_example .config/dun.conf
```


## Vim support

Vim support visually highlights statuses and tags and also makes them available for dictionary complete(Ctr+n).

1. Set `VIM_SUPPORT=enabled` in `~/.config/dun.conf`.
2. Add the following to `~/.vimrc`, essentially it says source .dun_vimrc if it exists in the same directory as the file vim has opend.
  ```
  let g:dun_vimrc = expand('%:p:h') . '/.dun_vimrc'
  if filereadable(dun_vimrc)
    exec printf('source %s', g:dun_vimrc)
  endif
  ```

## Bash completion

Add the following to `.bashrc` to enable bash tab complete of arguments, statuses and tags.

```
complete -W "$(dun 2>/dev/null bash-complete-options)" dun
```

Then `source .bashrc` or reboot to enable.


## Task statuses

Dun uses three status categories. Each category may have one or more user configurable statuses.

1. TODO statuses are considered in progress/need work
2. BLOCK statuses indicate the task cannot proceed
3. DONE statuses mean this task needs no more work or attention

Default statuses are:

- TODO statuses: TODO
- BLOCK statuses: WAIT
- DONE statuses: WONT and DONE

