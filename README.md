# Dun

Free form note taking and easily identify tasks in the text to follow up on using statuses and tags.

- A task is a single line in a text file that contains a status string (e.g. TODO or DONE)
- Tag tasks or other lines by adding #string
- Notes(plain text files) contain both notes and zero or more tasks
- CLI for listing tasks found in notes and filtering them by statuses and tags

GIF


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


### Configuration

To change the default configuration copy the example config file and edit it.

```
cp <path to cloned repo>/dun.conf_example .config/dun.conf
```


### Vim syntax

Copy syntax file to enable vim syntax highlighting of statuses and tags.

```
cp <path to cloned repo>/dun_syntax.vim ~/.vimrc/syntax/dun.vim
```


### Bash completion

Add the following to `.profile` or `.bashrc` to enable bash tab complete of arguments, statuses and tags.

```
_dun() {
  COMPREPLY=()
  COMPREPLY=( $(compgen -W "$(dun bash-complete-options)" -- $2) )
}
complete -F _dun dun
```

Then either reboot or source the relevant file (e.g. `source .bashrc`).


## Task statuses

Dun uses three status categories. Each category may have one or more user configurable statuses.

1. TODO statuses are considered in progress/need work
2. BLOCK statuses indicate the task cannot proceed
3. DONE statuses mean this task needs no more work or attention

Default statuses are:

- TODO - category: TODO
- WAIT - category: BLOCK
- WONT - category: DONE
- DONE - category: DONE

