\ Licensed under 0-clause BSD

\ This is some older code that I just remember existed and decided to add it as
\ a module.
\ The code might not be the most readable and it might not be the most optimal
\ implementation, but I do remember it working.
\ TODO: rewrite list.fs from scratch

\ These words don't have any sanity checks and will crash the system
\ (or break other stuff) if you try to go under 0 elements or give it
\ index over the max.
\ I feel indifferent to what should happen, so I'm keeping them like this.
\ If you with them to handle it differently, you are encouraged to edit
\ them as much as you like

\ Words can be easily modified to use items of different size.
\ The base list% is usable for any type of data.


begin-structure LIST%
  field: LIST-LEN
  field: LIST-PTR
end-structure


: NEW-LIST ( n -- c-addr ) \ len
  \ list
  list% allocate throw
 
  \ contents
  2dup list-len !
  swap cells allocate throw
  over list-ptr !
;


: NEW-LIST-FILL ( n* -- c-addr ) \ list of values ended by length
  dup new-list                   \ example: 14 6 42 3 new-list-fill

  swap
  dup 0<> if
    0 swap 1- do \ start from the end, so that the order is preserved
      \ n* list-ptr
      swap
      over list-ptr @ i cells + !
    -1 +loop
  else
    drop
  then
;


: LIST-RESIZE { n c-addr -- } \ delta list
  c-addr list-ptr dup @
  c-addr list-len dup @ n + 
  \ ptr-adr ptr len-adr new-len

  dup rot !
  cells resize throw
   
  swap !
;


: LIST-REMOVE { n c-addr -- } \ index (starting at 0!) list
  \ if remove the last, use normal resize
  n c-addr list-len 1- = if
    -1 c-addr list-resize
    exit
  then

  c-addr list-ptr @ n cells + \ position of remove
  c-addr list-len @ n 1- - \ number of items left

  \ shift all values comming after
  0 do
    dup i 1+ cells + @
    over i cells + !
  loop
  drop
  \ resize anyways
  \ probably could be all written better,
  \ but I want it to be single and readable word
  -1 c-addr list-resize
;


: LIST-APPEND ( n c-addr -- )
  1 over list-resize
  dup list-len @ 1- cells
  swap list-ptr @ + ! 
;


: LIST-INSERT { v n c-addr -- } \ value index (still 0 based) list

  \ give to regular append if inserting at the end
  n c-addr list-len @ = if
    v c-addr list-append
    exit
  then

  1 c-addr list-resize
  c-addr list-ptr @ n cells + \ position of append
  c-addr list-len @ n - 1- \ number of items after insertion

  \ shift everything one further
  1 swap do
    dup i 1- cells + @
    over i cells + !
  -1 +loop

  v swap !
;


\ remove last and return it's value
: LIST-POP ( c-addr -- n )
  dup list-ptr @
  over list-len @ 1- cells + @
  -1 rot list-resize
;


\ remove first and return it's value
: LIST-SHIFT ( c-addr -- n )
  dup list-ptr @ @
  0 rot list-remove
;
