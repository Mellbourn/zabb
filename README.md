# zabb

[![License: MIT][license icon]][license]

zabb - a plugin for finding z abbreviations

## Command

I love the [z][zoxide] command. It lets me quickly jump to my favorite directories by typing very few keys.
But - sometimes I give in to my OCD and I wonder: _how_ few keys can I get a way with?

I can experiment, try different short versions. But this is hit-and-miss, and ironically, it can mess with the ranking and change what abbreviations can be used.

Presenting the solution: `zabb`

`zabb` is a command that tries to figure out the shortest memorable abbreviation of a directory that is usable by `z` to unambiguously jump to that directory.

Examples:

```zsh
~ > ls -d Do*
Documents Downloads
~ > zabb Downloads
d
~ > z d
~/Downloads > cd
~ > zabb Documents
doc
~ > z doc
~/Documents > cd
~ > zabb -s Documents
u
m
e
~ > z u
~ /Documents> cd
~ > zabb -a Documents
u
m
e
t
oc
cu
um
[...]
```

Currently zabb only supports the [zoxide][zoxide] implementation of `z`. I welcome PRs to expand it to other implementations.

## Installation

### [zinit][zinit]

This plugin is designed as a [zinit][zinit] module, but it's also
compatible with other plugin managers.

You can use [Turbo Mode][turbo mode] to load `zabb`:

```zsh
zinit ice wait'1' lucid
zinit light mellbourn/zabb
```

Or you can load `zabb` on demand:

```zsh
zinit ice lucid trigger-load'!zabb'
zinit light mellbourn/zabb
```

## License

The MIT License (MIT)

Copyright (c) 2021 Klas Mellbourn

[license icon]: https://img.shields.io/badge/License-MIT-green.svg
[license]: https://opensource.org/licenses/MIT
[zinit]: https://github.com/zdharma/zinit
[turbo mode]: https://github.com/zdharma/zinit#turbo-mode-zsh--53
[zoxide]: https://github.com/ajeetdsouza/zoxide
