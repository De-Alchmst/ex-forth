# ex:forth manual
This manual describes changes from
[pforth](https://www.softsynth.com/pforth/).
Extra words can be found [here](words.md).
Included modules can be found [here](modules.md)

Full list of changes can be found
[here](changes.md).

## C interpolation

Ex:forth's C interpolation (like some other parts) is inspired by
[Gforth](https://gforth.org/).
While it works completely differently, it's interface is very similar.

### generating bindings

All binding generation happens in a block.
The block starts either with C-LIBRARY followed by a name, or with
C-LIBRARY-NAME, which takes a string instead.
The block is ended by END-C-LIBRARY, which then compiles and loads the C code.

At first, you must get the library you want to include into the C bindings.

You add a library to the compiler via ADD-LIB word, which takes a string with
the name of the library as you would pass it to the compiler '-l' flag
(which it also does with it).

Then you want to load it into the bindings.
Think of this block as a C file (to which it also gets turned into).
You can write a line of C via the \C word. Everything after \C is put
into the file as is.
For example, to load stdio, you would write `\C #include <stdio.h>`.

You can also use \C to write wrapper functions and stuff.

Then you want to generate binding for a function.
It has the following syntax:
`c-function <forth-name> <c-name> <arg-types> -- <return-type>`

Forth name can be any valid forth word, but I like to prefix it with
library identifier separated by double colon, such as 'M:SIN' for 'sin' function
from math library or 'RL:INIT-WINDOW' for the 'InitWindow' function from the
[raylib](https://www.raylib.com/)
library.
It helps to distinguish what is what.

This is also where the ex:forth name comes from.
It is all inspired by
[RetroForth](https://retroforth.org/)
prefixes, but I use it only for libraries.

Arg types are a sequence of 0-15 of the following types:

- n - number
- a - address
- r - real (taken from the floating point stack)
- s - string (using this one provides automatic string format conversion)
- void - nothing

Return type is just a single value, but if the function returns nothing, you
must provide the void type.

Maximum number of arguments supported is 15.
Please, don't make C functions that take 15 arguments.
It's not cool.

Arguments can also be further casted. For example, if your C function requires
the `Foo` struct, you cannot give it just 'a' (void*).
After a type (without any white space) you can write curly-braces-enclosed
C typecast that will be applied on the argument in the function call.
The previous example would look like this: `a{*(Foo*)}`.

Ex:forth also allows you to bind a variable using C-VARIABLE.
It only takes \<forth-name\> and \<c-name\>.
Resulting word returns pointer to that variable.

You cannot create bindings for structs in this way.
C structs are just a bunch of data in a row, so it's easy to replicate them
in forth via forth
[facility structures](https://forth-standard.org/standard/facility/BEGIN-STRUCTURE).

Ex:forth even provides you with special Gforth-like words for 16-bit,
32-bit and 64-bit fields. (viz.
[words.md](words.md))
(CFIELD: is used for 8-bit fields)

The final C file only gets recompiled when it is deleted, or when the FORTH file
with bindings changes.
Changes in included C libraries are not watched.

Example taken from
[example/bindings.fth](../example/bindings.fth):

```
c-library testlib
  s" m" add-lib

  \c #include <math.h>
  \c #include <stdio.h>

  \c typedef struct TestStruct {
  \c   int64_t n1;
  \c   int64_t n2;
  \c } TestStruct;

  \c void printStruct(TestStruct ts) { 
  \c   printf("I will give you my struct now:\n");
  \c   printf("  %d-%d\n", ts.n1, ts.n2);
  \c } 

  \c int customFunc(int x, int y, float z, int p) {
  \c   printf("> %d %d %f %d\n", x, y, z, p);
  \c   return (x+y - (int)z + p);
  \c }

  \c char* handshake(char* in) {
  \c   printf("%s\n", in);
  \c   return "Hi from C!";
  \c } 

  \c static int var = 5;

  c-function m:sin sin r -- r
  c-variable tst:var var
  c-function c:func customFunc n n r n -- n
  c-function handshake handshake s -- s
  c-function c:print-structure printStruct a{*(TestStruct*)} -- void
end-c-library
```

### handwriting bindings

Second approach is to write the C binding directly.
This approach might be preferred if you wish not only to use existing C library,
but to write entire part of your application in C.

Example binding can be found in
[examles/testlib.c](../example/testlib.c).

The following is required to connect your C to ex:forth.

At first, you will need some definitions:

```
#include <stdint.h>

#define C_RETURNS_VOID  (0)
#define C_RETURNS_VALUE (1)

typedef void (*addFunction_t)(void* fn, char* name, int argsNum, int returns);
typedef intptr_t cell_t;
```

You could technically do without those, but they do help.

All your functions that will be exposed to ex:forth should take only
arguments of `cell_t` type and should return either `void` or `cell_t`.
In case you need to use floats, ex:forth uses `double`s, which should be the
same size as `cell_t`, so do some fancy pointer casting.
You know, the fun part of C.

Once you have your functions defined, write the following function:

```
void addWords(void* fn) {
   addFunction_t addFunction = (addFunction_t) fn;

   ...
    your bindings
   ...
}
```

It MUST be named `addWords`.

This function will be loaded and called from withing ex:forth.

You will use the `addFunction` function to create bindings for your functions
in accordance to the following:

```
addFunction(<function-pointer>, <forth-name>, <arg-num>, <return-type>);
```

Example of a sum function that takes two numbers and returns one will look
like this:

```
addFunction(&sum, "M:SUM", 2, C_RETURNS_VALUE);
```

The forth name should be in all-caps and max number of args is 15.

Then compile the C code with the `-fPIC -shared` flags (or whatever is your
compilers alternative) and link the outcome file with the INCLUDE-CLIB
word.

Congratulations, you are now fully qualified to embed lua into FORTH!

## path resolution

Ex:forth gets a fancy (and a bit clunky) file name resolution.

INCLUDE and REQUIRE look at files relative to included file and in
extra prefixes.
Those are:

- `/usr/local/share/exforth/`
- `/usr/share/exforth/`
- `~/.local/share/exforth/`

This can be used for sharing code between projects.

Any other file operation is controlled by ALTER-PATH! and ALTER-PATH@.
These operate on boolean values:

- 0 (default) : relative to user
- -1 : relative to executed file


## pforth features of note

Note that pforth does not support dictionaries.
It instead uses PRIVATE{, }PRIVATE and PRIVATIZE words for keeping
words in one file.
When PRIVATIZE is called, all words defined between PRIVATE{ and }PRIVATE
gets removed from the wordlist.

I know that this does technically not solve anything, but it looks nicer
than without it.
Dictionaries might get added in the future, but I don't really need them that
much and its not a priority.

## compatibility breaking changes

Due to the addition of FVALUE, I needed to change the structure of VALUE
as well, so that TO can work on both.
VALUE now holds both the value and a type identifier.
This means that you can no longer uses TO words made via VARIABLE and CREATE.
This might get fixed if I come up with a better solution.

By default, paths are resolved relative to currently executed file.
This can be changed via the ALTER-PATH! word.
