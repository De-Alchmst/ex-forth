# Modules

Ex:forth has (mostly for historic reasons) a module system. 
Modules are stored in one of the following directories:

- `/usr/local/share/exforth/`
- `/usr/share/exforth/`
- `~/.local/share/exforth/`

(See [path resolution](index.md#path-resolution) for more details.)

This way, you can easily share code between your personal projects.
(but it is recommended to package all the files together before sharing)

Ex:forth comes with the following modules pre-made:

- [random.fs](random.md) - a Gforth compatible random number generator
- [list.fs](list.fs) - dynamic list data structure
