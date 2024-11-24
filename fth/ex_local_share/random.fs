\ Gforth compatible random number implementation
\ 0BSD

variable seed

: SEED! ( n -- ) seed ! ;
: SEED-INIT ( -- ) ntime drop seed ! ;

\ https://en.wikipedia.org/wiki/Linear_congruential_generator
: RND ( -- n )
  \ Musl values
  #6364136223846793005 seed @ * 1+ \ natural overflow as modulus
  dup seed ! ;
: RANDOM ( n -- 0..n-1 ) rnd swap mod abs ;

seed-init