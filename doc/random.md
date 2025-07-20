# random.fs

This module is here mostly for historic reasons, but it's perfectly fine to
use it.

While pforth has it's own RANDOM word, you can find a extra Gforth-compatible
random number generator that can generate numbers in a range.

Words:

- SEED-INIT ( -- )
    - Initializes a new random seed based on current system time
    - It is called automatically when the module is included

- SEED! ( n -- )
    - Sets a new value to the current seed

- RND ( -- n )
    - Generates a new random number

- RANDOM ( n -- 0..n-1 )
    - Generates a new random value within a certain range
