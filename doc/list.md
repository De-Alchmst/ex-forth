# list.fs

This module provides a simple implementation of a dynamic resizable list.
Each field in the list is exactly one cell long.

These words don't have any sanity checks and will crash the system
(or break other stuff) if you try to go under 0 elements or give it
index over the max.
I feel indifferent to what should happen, so I'm keeping them like this.
If you with them to handle it differently, you are encouraged to edit
them as much as you like.

Words:

- LIST% ( -- n )
    - A data structure of a list

- LIST-LEN ( c-addr -- n )
    - A length of a list

- LIST-PTR ( c-addr -- c-addr )
    - Returns an address of the list data
    - Data can the be further manipulated like normal

- NEW-LIST ( n -- c-addr )
    - Creates a new list of given length

- NEW-LIST-FILL ( n* -- c-addr )
    - Creates a new list from values given, last one is the number of elements
    - Example: 14 6 42 3 NEW-LIST-FILL

- LIST-RESIZE ( n c-addr -- )
    - Grows or shrinks a list by the given amount

- LIST-REMOVE ( n c-addr -- )
    - Removes an element at given index

- LIST-APPEND ( n c-addr -- )
    - Appends a value at the end of a list

- LIST-INSERT ( n n c-addr -- )
    - (value, index, list)
    - inserts a value at given index, shifting the rest

- LIST-POP ( c-addr -- n )
    - Removes the last item from list and puts it on the stack

- LIST-SHIFT ( c-addr -- n )
    - Removes the first item from list and puts it on the stack
