anew task-ex_clib.fth

\ TODO: add some checks!

private{

\ \ \ \ \ \ \ \
\ VARS/BUFFERS \
\ \ \ \ \ \ \ \ \
0 value current-fun-index

0 value lib-fileid
create lib-name 64 allot
create lib-name-len 0 ,
: LIB-NAME@ ( -- c-addr u )
  lib-name lib-name-len @ ;

unix? [if]
  s" echo $HOME/.local/share/exforth/.clibs/" sh-get
    1 - \ newline
    dup constant lib-name-base-len
    lib-name swap move
[else]
  \ TODO: HERE WILL BE WINDOWS STUFF
[then]
lib-name-base-len lib-name-len !

create c-name-str 32 allot
create c-name-len 0 ,
: C-NAME@ ( -- c-addr u )
  c-name-str c-name-len @ ;

create forth-name-str 32 allot
create forth-name-len 0 ,
: FORTH-NAME@ ( -- c-addr u )
  forth-name-str forth-name-len @ ;

create compile-command 256 allot
create compile-command-len 0 ,
: COMPILE-COMMAND@ ( -- c-addr u )
  compile-command compile-command-len @ ;

0 value addWords-body \ allocate at runtime
create addWords-body-len 0 ,
: ADDWORDS-BODY@ ( -- c-addr u ) 
  addWords-body addWords-body-len @ ;

0 value wrap-words \ allocate at runtime
create wrap-words-len 0 ,
: WRAP-WORDS@ ( -- c-addr u ) 
  wrap-words wrap-words-len @ ;

create wrap-args 512 allot \ I support up to 15 args, so it can get quite long
create wrap-args-len 0 ,
: WRAP-ARGS@ ( -- c-addr u ) 
  wrap-args wrap-args-len @ ;

\ return types
0 constant n
2 constant a
3 constant r
5 constant void
6 constant s

\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \
\ BUFFER SPECIFIC MANIPULATION \
\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \

: BUFF-WRITE ( c-addr u buff-addr buff-len-addr -- )
  rot dup rot +!
  move ;

: ADDWORDS-WRITE ( c-addr u -- )
  addWords-body@ + addWords-body-len buff-write ;

: ADDWORDS-WRITE-LINE ( c-addr u -- )
  addWords-write
  s\" \n" addWords-write ;

: WRAP-WORDS-WRITE ( c-addr u -- )
  wrap-words@ + wrap-words-len buff-write ;

: WRAP-ARGS-WRITE ( c-addr u -- )
  wrap-args@ + wrap-args-len buff-write ;

: WRAP-ARGS-WRITE-LINE ( c-addr u -- )
  wrap-args-write
  s\" \n" wrap-args-write ;

\ \ \ \ \ \
\ FILE OPS \
\ \ \ \ \ \ \

: LIB-WRITE ( c-addr u -- )
  lib-fileid write-file throw ;

: LIB-WRITE-LINE ( c-addr u -- )
  lib-fileid write-line throw ;

\ \ \ \ \
\ SETUP \
\ \ \ \ \

: INIT-ALL ( -- )
  \ average bind +- 120 chars?
  \ -> 100 funcs = 12_000 chars
  12000 allocate throw to addWords-body
  12000 allocate throw to wrap-words
;

: DEINIT-ALL ( -- )
  addWords-body free throw
  wrap-words free throw

  0 c-name-len !
  0 to lib-fileid
  0 to wrap-words
  0 wrap-args-len !
  0 to addWords-body
  0 forth-name-len !
  0 wrap-words-len !
  0 addWords-body-len !
  0 to current-fun-index
  0 compile-command-len !
  lib-name-base-len lib-name-len !

;

: LIB-NAME! ( c-addr1 u1 -- )
  dup -rot
  \ add the name
  lib-name@ + swap move
  \ add extension
  lib-name-len +!
  s" .c" lib-name@ + swap move
  \ return
  2 lib-name-len +!
;


: LIB-BEGIN ( -- )
  s" #include <stdint.h>"
  lib-write-line
  s" #define VOID  (0)"
  lib-write-line
  s" #define VALUE (1)"
  lib-write-line
  s" #define N(b) return (c_t)b"
  lib-write-line
  s" #define R(b) double d = b; return *(c_t*)&d"
  lib-write-line
  s" typedef void (*af_t)(void* fn, char* name, int argsNum, int returns);"
  lib-write-line
  s" typedef intptr_t c_t;"
  lib-write-line

  s" void addWords(void* fn) {"
  addWords-write-line
  s" af_t af = (af_t) fn;"
  addWords-write-line
;

: LIB-END ( -- )
  s" } " addWords-write
  addWords-body@ lib-write-line ;

\ \ \ \ \ \ \ \ \
\ COMPILE STUFF \
\ \ \ \ \ \ \ \ \

: COMMAND-WRITE ( c-addr u -- )
  dup -rot
  compile-command@ + swap move
  compile-command-len +!
;

: COMMAND-BEGIN ( -- )
  s" gcc -fPIC -shared " command-write
  lib-name@ command-write
  s"  -o " command-write
  lib-name@ 2 - command-write
  s" .so" command-write
;

\ \ \ \ \ \ \ \ \
\ LIB FILE STUFF \
\ \ \ \ \ \ \ \ \ \

: FORTH-NAME! ( c-addr u -- )
  dup forth-name-len !
  forth-name-str swap move ;

: C-NAME! ( c-addr u -- )
  dup c-name-len !
  c-name-str swap move ;

: SET-FORTH&C-NAMES ( "forth-name" "c-name" -- )
  parse-name forth-name!
  parse-name c-name! ;

: WRITE-LIB-WRAP-NAME ( -- )
  s" f" lib-write current-fun-index 0 <# #s #> lib-write ;

: WRITE-ADDWORDS-WRAP-NAME ( -- )
  s" f" addWords-write current-fun-index 0 <# #s #> addWords-write ;

: WRITE-VARIABLE-FUNC ( -- )
  s" static c_t " lib-write
  write-lib-wrap-name s" () { return (c_t)&" lib-write
  c-name@ lib-write s" ; }" lib-write-line
;

: WRITE-BIND-FUNC ( f n -- ) \ returns? arg-num
  s" af(&" addWords-write write-addWords-wrap-name
  s\" , \"" addWords-write forth-name@ addWords-write
  s\" \", " addWords-write s>d <# #s #> addWords-write
  s" , " addWords-write
  if s" VALUE" else s" VOID" then
  addWords-write
  s" );" addWords-write-line
;

: TRANSFORM-TO-R ( c-addr1 u1 -- c-addr2 u2 )
  [char] { scan dup 0= if
    2drop
    s" r{*(double*)&}"
  else
    swap 1+ swap \ also skip the '{'
    s" r{" pad swap move
    dup -rot \ save len
    pad 2+ swap move
    s" *(double*)&}"
    rot 2dup + \ get total len
    \ c-addr u u-pad u-final
    swap 2swap
    \ u-final u-pad c-addr u
    rot pad + swap move
    pad swap
  then
;

: TRANSFORM-TO-S ( c-addr1 u1 -- c-addr2 u2 )
  [char] { scan dup 0= if
    2drop
    s" n{(char*)}"
  else
    swap 1+ swap \ also skip the '{'
    s" n{" pad swap move
    dup -rot \ save len
    pad 2+ swap move
    s" (char*)}"
    rot 2dup + \ get total len
    \ c-addr u u-pad u-final
    swap 2swap
    \ u-final u-pad c-addr u
    rot pad + swap move
    pad swap
  then
;

: TRANSFORM-TO-A ( c-addr1 u1 - c-addr2 u2 )
  [char] { scan dup 0= if
    2drop
    s" n{(void*)}"
  else
    swap 1+ swap \ also skip the '{'
    s" n{" pad swap move
    dup -rot \ save len
    pad 2+ swap move
    s" (void*)}"
    rot 2dup + \ get total len
    \ c-addr u u-pad u-final
    swap 2swap
    \ u-final u-pad c-addr u
    rot pad + swap move
    pad swap
  then
;

: WRITE-ARG-C ( c-addr u arg-num -- )
  dup 1 <> if s" , " wrap-args-write then

  -rot
  [char] { scan dup 0<> if
    2- swap 1+ swap wrap-args-write
  else 2drop then
  s>d <# #s [char] v hold #> wrap-args-write
;

: WRITE-ARG-FORTH ( n -- ) \ type
  dup s = if
    drop
    s" fth>c "
    wrap-words-write
  else
    r = if
      s" here f! here @ " \ I don't want to destroy pad, arg strings might
      wrap-words-write
  then then
  s" >r " wrap-words-write
;

: STR>TYPE ( c-addr u -- n )
  drop
  case
    dup s" n" text= ?of n endof
    dup s" a" text= ?of a endof
    dup s" r" text= ?of r endof
    dup s" void" text= ?of void endof
    dup s" s" text= ?of s endof
    37 throw
  endcase
;

: END-WRAPPER-WORD ( "type" -- n ) \ return-type
  forth-name@ wrap-words-write

  parse-name dup 0= -rot
  str>type dup -rot dup void =
  rot or not if
    dup s = if
      drop
      s"  c>fth" wrap-words-write
    else r = if
      s"  here ! here f@" wrap-words-write
    then then
  else drop then

  s"  ;" wrap-words-write
;

: FILL-ARG-POP ( n -- )
  0 ?do s" r> " wrap-words-write loop ;

: CONSTRUCT-WRAPPER-WORD ( "{type}" "--" "type" -- n n ) \ arg-num return-type
  \ begin writing wrapper word
  s"  : " wrap-words-write forth-name@ wrap-words-write
  s"  " wrap-words-write
  
  \ read until return type
  \ also accumulates types
  0 { args }
  begin
    parse-name
    2dup
    dup 0= -rot \ empty?
    drop
    s" --" text= or not
  while
    1 +to args

    2dup str>type
    dup void <> if
      dup case
        r of -rot transform-to-r endof
        s of -rot transform-to-s endof
        a of -rot transform-to-a endof
        drop -rot dup
      endcase
      args write-arg-c
    else 2drop then

  repeat
  2drop

  \ here I use the accumulated types
  args 0 ?do
    write-arg-forth
  loop

  args fill-arg-pop

  args
  end-wrapper-word
;

: GET-RETURN-MACRO ( n -- c-addr u )
  dup void = if drop s" ("
  else r = if s" R("
  else s" N("
  then then
;

: WRITE-WRAPPER-ARGS ( n -- )
  0 ?do
    i 0<> if s" , " lib-write then
    s" c_t v" lib-write
    i 1+ s>d <# #s #> lib-write
  loop
;

: CONSTRUCT-WRAPPER-FUNC ( n n -- ) \ arg-num return-type
  s" static " lib-write
  dup void = if s" void " else s" c_t " then lib-write
  write-lib-wrap-name
  s" (" lib-write

  swap write-wrapper-args

  s" ) {" lib-write-line

  get-return-macro lib-write

  c-name@ lib-write
  s" (" lib-write
  wrap-args@ lib-write
  s\" ));\n}" lib-write-line
;

: WRITE-WRAPER-FUNCTION ( "{type}" "--" "type" -- f n )
  0 wrap-args-len !
  construct-wrapper-word 2dup
  construct-wrapper-func
  void <> swap
;

unix? [IF] \ *nix
: RECOMPILE? ( -- f )
  0 { len }
  s" [ "
    dup +to len
    pad swap move
  sourcefilename
    pad len + swap
    dup +to len
    move
  s"  -ot "
    pad len + swap
    dup +to len
    move
  lib-name@
    pad len + swap
    dup +to len
    move
  s"  ]"
    pad len + swap
    dup +to len
    move

  pad len system
  $?
;

[ELSE] \ Windows
: RECOMPILE? ( -- f )
  \ TODO: windows recompile?
  true
;
[THEN]

}private

\ HERE WILL BE WORDSET...

\ \ \ \ \ \ \ \ \
\ USER CALLABLE \
\ \ \ \ \ \ \ \ \

: ADD-LIB ( c-addr u -- )
  s"  -l" command-write command-write ;

: \C ( "..." -- )
  parse-line lib-write-line ;

: C-FUNCTION ( "forth-name" "c-name" "{type}" "--" "type" -- )
  1 +to current-fun-index
  set-forth&c-names
  write-wraper-function
  write-bind-func
;

: C-VARIABLE ( "forth-name" "c-name" -- )
  1 +to current-fun-index
  set-forth&c-names
  write-variable-func
  true 0 write-bind-func
;

\ \ \ \ \ \ \ \ \
\ USER INTERFACE \
\ \ \ \ \ \ \ \ \ \

\ HERE WILL BE FORTH...

: C-LIBRARY-NAME ( c-addr u -- )
  \ TODO: check if already compiled (or most likely not not?)
  \ While it would be nice to not have to generate/recompile the whole thing
  \ every time, There is a lot of egde cases to think of due to the nature of
  \ forth. Some might include:
  \   - bindings spanning across multiple files
  \   - bindings generated at runtime
  \   - bindings being pulled over the net (that sound fun...)
  \ Due to all this, I'm not sure it's ideal to try achieving something like
  \ this. But we'll see.
  init-all
  unix? if
    s" mkdir -p ~/.local/share/exforth/.clibs 2> /dev/null" system
  else
    ." win not supported"
    \ TODO: HERE WILL BE WINDOWS STUFF
  then

  lib-name!

  recompile? if
    command-begin
  else
    \ TODO: Windows might require different comments
    \ depends if powershell is used
    s" # " command-write
  then

  lib-name@ R/W create-file throw to lib-fileid
  lib-begin
;

: C-LIBRARY ( "name" -- )
  parse-name c-library-name ;

: END-C-LIBRARY ( -- )
  lib-end
  lib-fileid close-file throw

  compile-command@ system
  \ I don't know if I like or hate this hack
  s" so" lib-name@ 1- + swap move

  lib-name@ 1+ include-clib
  wrap-words@ evaluate
  deinit-all
;

privatize
