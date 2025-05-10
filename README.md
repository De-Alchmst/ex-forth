# Ex:forth

![](logo.png)

Ex:forth is a
[FORTH](https://forth-standard.org/)
implementation based on
[pforth](https://github.com/philburk/pforth)
with the added ability to have C bindings.

It also has other stuff, but this is the reason you would want to use it over
[Gforth](https://gforth.org/)

# Build with ex:forth

[ex:forth tetris](https://github.com/De-Alchmst/ex-forth-tetris)

# Reasoning

I think that FORTH is an interesting language and I like to use it from time
to time.
When I do so, I like to use some graphics library
([raylib](https://www.raylib.com/))
and make little games with it.
The problem is, that no FORTH implementation I know of supports C bindings.

Yes,
[Gforth](https://gforth.org/)
_claims_ to support C bindings, but they are broken on every
platform I try it on.
This is most likely caused by Gforth devs forgetting that it's nice to make a
release once in a while, so they ship a 10 years old version.
You _can_ compile the current version, but I don't like that.

It only works seamlessly on some platforms, requires a lot of additional bloat
(latex, emacs...) and I prefer my projects to not require users to compile their
own compiler.

This led me to making my own FORTH that supports Gforth-like runtime bindings.

I chose pforth as the base, as it is written in portable C
(most implementations seem to be written in assembly for reasons)
and has built-in feature to compile in new words, so it was easy to add
runtime bindings.

# Features

Outside of all pforth's features and C bindings, ex:forth also adds few
[words](doc/words.md).
These include words for OS interaction, string manipulation, struct creation
and more.

Pforth does not fully supply all
[standard wordsets](https://forth-standard.org/standard/words).

Ex:forth does add a few missing words, but many are still missing.
However, you should still be able to do all the things you might want to.

# Warnings

This is a hobby project by one guy who knows nothing about FORTH, C, or even
language implementations in general.
It is mainly intended to fulfill my needs and probably has few a bugs/flaws.

I do not try to sway you from using it.
If you want to use C libraries with FORTH, I still believe ex:forth to be a
solid choice.
Just take it for what it is and don't expect perfection.

# Credits

All the core parts were made by
[Phill Burk](https://github.com/philburk).

All I did was added some words and the ability to load C libraries at runtime.

# Other FORTHs with runtime FFI

* [r3](https://github.com/phreda4/r3)
* [e4](https://github.com/shwnchpl/e4)

Tell me if you know of any other.

# Instructions

## Supported platforms

Ex:forth should support all POSIX platforms, tho tests are done only on Linux.
If you face any problems, feel free to report them.
Windows is currently supported only via [Cygwin](https://cygwin.com/) or a
similar solution.

Ex:forth uses OS specific features while loading libraries and some parts of
FORTH code are implemented only for POSIX environment.
All of these places (at least I hope) are marked with a `TODO:` comment.
((\*ehm\* \*ehm\*
[lstodo](https://github.com/De-Alchmst/lstodo.git)
\*ehm\* \*ehm\*))
Windows port should be possible and I might do it at some point.
It is just not my priority right now.

## Dependencies

- cmake (building only)
- make (also building only)
- gcc (used for bindings)

## Building

```
cmake .

# to install globaly
sudo make install

# or to install locally
make install/local
```

This installs the standalone version as `exforth`.
In case you want the non-standalone version and dict, they are in `fth/`

## Documentation

[here](doc/index.md)

This is not a FORTH tutorial, nor does it document the pforth core.
There are many great FORTH tutorials online and
[pforth's website](https://www.softsynth.com/pforth/)
documents it well enough (while also containing a FORTH tutorial).

I only document the non-standard stuff I added.

### TODO:

- fix the underflow problems
- missing standard extensions
    - search
    - double (m+ m*/ 2rot 2value)
    - facility (also has parts implemented)
    - tools (some missing)
    - xchar (maybe....)
- better debugging facility
- Native Windows support (maybe, we'll see)
