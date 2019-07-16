# Higher level Brainfuck

An experiment around the [Brainfuck programming language](https://en.wikipedia.org/wiki/Brainfuck).

Files in the repository:

- `bf.lua`: a barebones BF interpreter as a Lua module. Uses an infinity memory storage in both directions. Generates an error on integer underflows (trying to decrement 0). Additional command `?` prints the current state of the tape (positive indices only).
- `hlbl.lua`: a "higher level" BF interpreter that supports named blocks of code and named variables (see tiers 1 and 2 below)
-    `interpreter`: a shell script to run either BF or HLBF:
    > `Usage: ./interpreter source [-hl]`
- `tier1.bf` and `tier2.bf`: examples files to run respectively with the BF or HLBF modules

As a distinct subproject:

- `t4.lua`: a Lua module that interprets an even higher level language "T4" and compiles it to basic BF.
- `t4parser.lua`: a Lua module that parses said language
- `t4`: a shell script to run the T4 interpreter
- `langkit.lua`: a Lua module providing basic facilities for lexing and parsing text
- `prelude.t4`: a library of basic functions written for T4
- `examples.t4`: more demonstrations of what T4 looks like and what it can do

This is essentially a kind of assembly language for BF, mapping directly to the

# Motivation

Writing the basic BF interpreter is almost trivial. Writing BF code however, turned out to be a lot more difficult. After verifying that the interpreter executed correctly with samples from the web, I tried writing my own programs and hit a wall pretty quickly.

It became clear that we could rely on some patterns such as:

- `[-]`: zero out the current cell
- `[->+<]`: add current cell to cell to its right, bringing it down to 0 in the process
- `move to cell [ do thing, move back to cell]`: a loop equivalent to `while(cell) ... end`

However it required keeping track of the state of the tape, assigning meaning to certain cells, manually jumping between cells by knowing the relative position, etc. Very error prone and difficult.

# Improvements

I wondered about improvements that would make programming in BF an actual possibility beyond trivial programs, and came up with four tiers of extensions to the basic language:

1. Named blocks
2. Name variables inside blocks
3. Arbitrary moves and copies between variables
4. Stack based function call convention

## Tier 1: named blocks

The first improvement was the ability to name blocks of code by starting them with `*name`, and to invoke them with `!name`:

```
*add	# [a] b --> [a+b] 0

	>[-<+>]<

*sub	# [a] b --> [a-b] 0

	>[-<->]<

*up		# [a] b --> [0] a

	> !res <
	[->+<]
```

(`#` start comments and are here only to describe the stack manipulation. The element in brackets is the one pointed to by the memory pointer).

The interpreter performs trivial inlining of the macros, starting with the one named `main`.

This simple feature turned out to be surprisingly potent.

- Numerals: `*0 [-]`, `*1 +`, `*2 ++`, `*3 +++`, etc.
- Lots of code reuse (even if it is of course expanded and inlined by the interpreter)
- Even keyword like combinations for control structures

    ```
    *mul	# [a] b 0 0 --> [a*b] 0 0 0

    	!times
    		!add_up
    	!times_end		# now at [0] b a*b 0

    	!down2
    	> !res <
    ```

However, most of the effort was still to wrap my head around stack manipulation, and had to write many helpers to move up, copy, move down, move over, swap elements on the tape. Some of these can be executed in place, while others require temporary space which needs to be minded, often leading to errors when state is overwritten by less careful macros.

## Tier 2: named variables

Seeing how most of the difficulty was to assign meaning to certain cells, and keeping track of the tape state, it seemed like the next improvement would be to use variables to represent these cells.

Basically, when invoking a macro, we give names to the N memory cells under the cursor and to the right at the time the macro is invoked.

Variables as listed after the macro's name, and we add the `@name` command which signified: move the pointer to `a`.
at moves the cursor to that cell.

This has many practical uses:

- `a++			@a +`
- `a--			@a -`
- `while(a>0)	@a [ ... @a ]`
- `a = 0        @a !res`
- `a += 5       @a !5`
- ...

For instance setting a cell to 0:

```
*res a	# [a] --> [0]

@a [
	@a -
@a ]
```

or subtracting a cell from its left neighbor:

```
*sub a b	# [a] b --> [a-b]

@b[
	@b -
	@a -
@b]
@a
```

It helps with some clarity, however all moves and copies still require knowing the relative positions of the cells. Additionally, there is still a lot of confusion regarding which macros act in place, which need temporary storage, which are "safe" to call, etc.

## Tier 3: arbitrary move/copy

Now that we have named variables, we'd really want to be able to express "move a to b" or "copy b to c", which would make all stack manipulations trivial.

At the same time, expressing constants could be quite useful: directly setting a cell to a number instead of reseting it and incrementing it manually.

At this point, the syntax of my "improvements" was starting to be cumbersome and I figured it would be a good time to write a proper parser for a neater little language, and I moved on directly to tier 4.

## Tier 4: stacked macro call convention

The biggest problem so far has been stack shuffling: what code modifies what memory and in what way.

We started considering macros as proper functions, and got inspired by the calling conventions on real processor architecture: how to setup the stack/registers, and what to leave behind, to ensure that functions only access their own local variables.

We know how many arguments a function has, and we can also reserve some space for locals. Therefore we know exactly how many cells the function will need.

This "frame" is the only memory that the function is allowed to access, and this is enforced by only allowing access via the named variables declared by the function. When calling a new function, we add a new frame to the stack, of the exact size needed.

For instance the following code:

```
function f2(m,n | t1,t2,t3,t4)
    # ...
end

function f1(a,b | tmp1)
    # ...
    f2(arg1, arg2)
end
```

might generate the following stack:

| 1     | 2 | 3    | 4     | 5 | 6  | 7  | 8  | 9  |
|:------|:--|:-----|:------|:--|:---|:---|:---|:---|
| f1: a | b | tmp1 | f2: m | n | t1 | t2 | t3 | t4 |

Since we know how many cells each function needs, we can have a convention for passing arguments and returning values on a stack.

- Copy arguments in the first cells above the current frame (4 and 5)
- Move pointer in the first cell above the current frame (5)
- Call function `f2`. It is not allowed to write anything below its own frame (which starts at 4).
- Compute stuff
- Place return value in cell 4
- Caller function `f1` may copy that return value into its own frame and continue from there

By using exclusively named variables, and enforcing the call convention in the compiler, we got a rather "safe" language, quite expressive, but still close to the underlying reality of the BF instruction set.

Occasionally, the compiler will use memory above the current frame (denoted "registers" in the code) to hold temporary data. It can only be used for local operations, since that data might be overwritten by the next function call. This is not accessible from the language.

# The T4 language

## Grammar

The lexical elements are the usual:

- identifiers: alphanumerical plus underscore, not starting with a number
- reserved keywords: see grammar
- number literals: sequence of digits (integers only)
- symbols: see grammar
- all whitespace between tokens is ignored

```
Program :=  { Function }

Function := 'function' identifier '(' [ ArgumentList ] [ LocalsList ] ')'
    { Operation }
    [ Return ]
    'end'

ArgumentList := IdentifierList
LocalsList := '|' [ IdentifierList ]

Operation := Io | Increment | Decrement | Set | Move | Copy | Call | While | Debug

Io := ('in' | 'out' ) identifier
Increment := identifier '+' { '+' }
Decrement := identifier '-' { '-' }
Set := number '->' IdentifierList
Move := identifier '~>' IdentifierList
Copy := identifier '->' IdentifierList
Call := identifier '(' [ IdentifierList ] ')' [ '->' IdentifierList ]
While := 'while' identifier { Operation } 'end'
Debug := '?'

Return := 'return' identifier

IdentifierList := identifier { ',' identifier }
```

## Semantics

### Entry

The compiler expects to find a function named `main`, and proceeds to convert it into BF, inlining all the calls to other functions recursively according to the call convention outlined earlier.

No name conflicts checks are performed. A later function will replace a previous function with the same name.

### Increment and decrement

These operations map directly to BF `+` and `-`

- `a+` and `a-` increment and decrement variable `a`
- Any number of increments or decrements (but not both) can be specified: `a++++`, `a--`

### Input and output

- `in a` reads one byte from the standard input and places its value in `a`
- `out a` write the character contained in `a` to the standard output

### Constant setting `->`

- `number -> a` sets variable `a` to `number`, regardless of the previous value
- `number -> a,b,c`: several variables can be specified as destination. They do not need to be different, in which case the value will accumulate.

### Move operator `~>`

- `a ~> b` add `a` to `b`, leaving the cells respectively at `0` and `a+b`. If `b` was zero, this is equivalent to moving the value in memory.
- `a ~> b,c,d` several variables can be specified as destination. They do not need to be different, in which case the value will accumulate.
- `a ~> a` does nothing
- `a ~> a,b,c` is equivalent to `a ~> b,c`

### Copy operator `->`

- `a -> b` copies `a` to `b`, leaving both cells to contain `a`.
- `a -> b,c,d`: several variables can be specified as destination. They do not need to be different, in which case the value will accumulate.
- `a -> a` does nothing
- `a -> a,b,c` is equivalent to `a -> b,c`

### Function call

- `func(arg1, arg2, ...)` performs the proper stack shuffling according to the call convention, passes the given arguments, and executes the body of the function
- Arguments can be variable names or number literals
- `func(a,b,c) -> d,e`: The return value of the call can optionally be stored into one or more variables using the same syntax as copy. Here as well the variables do not have to be different, in which case the return value will accumulate in them.
- The number of arguments passed is not checked. Behavior is undefined when the wrong number of arguments is passed (depending on whatever is on the stack at invocation).

### Function definition

```
function name(arg1, arg2, arg3 | local1, local2)
    # ...
end
```

- Both arguments and locals can be omitted, but they must be separated by `|` if they are both present.
- These variables are the only ones accessible in the body of the function, and they are accessible only from there.
- No name collision checking is performed. A later name will shadow an earlier one.

### Return value

- `return var` will setup the stack so that the value of `var` is returned to the caller
- `return` can only be the last operation in a function
- `return` is optional. The caller is responsible for using the return value or not. Taking a return value from a function that does not return one is undefined (although by the call convention, it will be equal to the last value of the first variable of the function).

### While loop

```
while var
    # ...
end
```

- Upon entry, the `while` loop checks the value of variable `var`. If it is non-zero, the body of the loop is executed. If it is zero, the body is skipped.
- Reaching the end of the body, the loop checks again the value of `var`. If it is still non-zero, the body is executed again. Otherwise, control continues after the loop.
- This maps directly to BF `move to var [ body, move to var ]`

The while loop can emulate many higher level constructs:

The usual while loop: `while(f()) do ... end`:

```
f() -> cond
while cond
    # ...
    f() -> cond
end
```

A do-while which executes the body once before performing the check:

```
1 -> cond
while cond
    # ...
    f() -> cond
end
```

A numerical for loop `for(i = 0; i < 100 ;i++) {}`

```
0 -> n
lt(n,100) -> cond
while cond
    # ...
    n+
    lt(n,100) -> cond
end
```

An if statement:

```
while bool
    0 -> bool

    # body
end
```

And if-then-else statement:

```
1 -> not_bool
while bool
    0 -> bool
    0 -> not_bool

    # then body
end

while not_bool
    0 -> not_bool

    # else body
end
```

### Debug `?`

- The `?` command is translated directly as `?` in BF. When using the provided `bf.lua` module, this prints out the current state of the memory.

## Prelude

The file `prelude.t4` provides various arithmetics, logic, and text functions built on top of the basic constructs of the language.

For logic functions, it uses the convention that 0 is false and non-zero is true.
