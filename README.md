# dun

Lightweight notes and todo tasks CLI.

GIF


## Why

To manage meeting notes and todo tasks from the command line using a very simple rule set and plain text files edited in vim.

There are plenty of both todo list managers and meeting notes tools already, but they often only offer one or the other, require more complex syntax to define tasks or don't use plain text files as a back end.

Dun allows free form note taking and easily identify tasks in the text to follow up on.


## Installation

1. Clone the repo, e.g. `https://github.com/oliverfields/dun.git`
2. Ensure command is executable `chmod u+x <path to cloned repo>/dun`
3. Put *dun* in the PATH, e.g. symlink to *~/.local/bin* `ln -s <path to cloned repo>/dun ~/.local/bin/dun`


### Configuration

To change configuration `cp <path to cloned repo>/dun.conf_example .config/dun.conf` and edit it.


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


## Central concepts

1. A task is a single line in a text file that contains a status string (e.g. TODO or DONE)
2. Tag tasks or other lines by adding #&lt;string&gt;
3. The notes directory contains notes(just plain text files) that contain zero or more tasks
4. CLI for listing tasks from all notes and filtering by statuses and tags


### Task statuses

Dun uses three status categories. Each category may have one or more user configurable statuses.

1. TODO statuses are considered in progress/need work
2. BLOCK statuses indicate the task cannot proceed
3. DONE statuses mean this task needs no more work or attention

Default statuses are:

1. TODO (category: TODO)
1. WAIT (category: BLOCK)
1. WONT (category: DONE)
1. DONE (category: DONE)


### Tagging

Tags are hash tags followed by non breaking space, e.g. `#veryimportant`. They can be added to any line.

