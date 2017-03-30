# SSBL (Shitty/Succinct Stack Based Language)

## The Language

Comments are denoted with `#`. All characters after a `#` on any given line are ignored by the parser.

Non-comments that have no indentation are treated as proc headers. Non-comments that have indentation are treated as part of a proc body. A proc body continues until a non-comment with no indentation is reached or the end of the file is reached.

Proc headers contain two parts: a name for the proc, and a stack descriptor for the proc. Right now, the stack descriptor is not actually used by the language. If there are no stack effects, the stack descriptor can be omitted. Proc names can contain alpha numeric characters, as well as `-` and `_`. The first character of the proc name must be an alphabetical character.

## Stack Descriptors

Stack descriptors are not parsed right now, so the syntax of the stack descriptor doesn't really matter too much right now. However, this is a description of what stack descriptors should look like when they are written into the parser. Following these guidelines will ensure you won't need to convert your code later.

Stack descriptors are layed out exactly the same as the stack descriptors in Factor. Stack descriptors are a space separated list of strings contained within a set of parenthesis. Every stack descriptor must contain the symbol `--` somewhere in the stack description. This symbol separates the two sides of the stack descriptor. Symbols on the left hand side are descriptions of items expected to be on the stack when the proc is called. The right hand side contains symbols describing the items left on the stack after the proc is called. Here are some examples of stack descriptors:

    # no change
    (--)
    
    # pulling a variable off the stack
    (var --)
    
    # pushing a variable on the stack
    (-- var)
    
    # pulling two variables and adding one
    (var1 var2 -- var3)
    
    # No stack actual effect, but variable is read from stack
    (var1 -- var1)

## Proc Bodies

Proc bodies are essentially lists of constant expressions and proc names. Constant expressions push values onto the stack and proc names call the proc.

Currently, the valid contant expressions are string expressions, number expressions, and atom expressions. String expressions are any pair of `"` located on a single line. Number expressions are any numeric strings. Atom expressons are strings starting with `:`.

## Byte Code

The bytecode for this is currently very simple. As time goes on, this will most likely be reduced in an attempt to increase effeciency. Right now, bytecode is read by tracking an index within the bytecode for reading, reading a op byte, performing that operation (which will read any data it requires and move the read index accordingly), and reading another op byte.

### Op Bytes

0x00 - NOOP
  Nothing to read.
0x01 - PUSH
  Reads 1 byte for type of variable (to determine how to read it), then reads variable, pushing to stack. Repeats until null type byte is read.
0x02 - FRAME JUMP
  Reads next 4 bytes as offset for next frame.
0x03 - FRAME COMPLETE
  Nothing to read. Used to signify the end of a frame.
0x04 - CRASH
  Reads null terminated error string and crashes the program, displaying the message.
0x05 - ARRAY CONCAT
  Concatenates two arrays off the stack and pushes the new array onto the stack.

Any other op byte value will cause a crash.

### Variable Types

Variable type bytes contain two nibbles. The first nibble is used to identify the type, and the second nibble contains any metadata for the type.

0x0 - Number
  NOTE: Only integers are supported right now. First version will only use 32 bit signed integers in order to simplify things.
  First two bits in metadata represents pack size of integer. Seconds two bits are currently reserved.

0x1 - Char
  Metadata is reserved. Stored as unsigned integer byte.

0x2 - Array
  Metadata is reserved. First byte represents type stored in array. Second byte contains length of array.

0x3 - String
  Metadata is reserved. Helper for arrays of characters to reduce required array fields.

## The Stack


### NIXED
The stack in ssbl contains two stacks: a pointer stack and a data stack. The advantage of this tactic is that we do not need to worry about garbage collection for variable amounts of data. The pointer stack contains 32 bit unsigned data stack offsets that tell the machine where data is stored in the data stack. The data stack is just a heap of memory where any arbitrary data can be stored. In order to read a value on the top of the stack, the machine first reads the top two values from the pointer stack and then the data can be found between those offsets in the data stack.

    The issue here is managing swapping the stack around, which is kind of required for stack based programming...


