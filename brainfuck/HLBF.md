# Higher level Brainfuck

Three tier improvements:

## 1. Named blocks

Basically macros/text insertion. Can't be recursive!

## 2. Name variables inside blocks.

Basically give names to the N memory cells under the cursor and to the right at the time the macro is invoked.

Then have a "move to `a`" commands that moves the cursor to that cell. This gives:

- `a++			@a +`
- `a--			@a -`
- `while(a>0)	@a [ ... @a ]`
- `a = 0        @a !res`
- `a += 5       @a !5`
- `a = a + b    @a !add`
- ...

All moves/copies still require knowing the relative positions of the cells.

## 3. Loops using variables

- while `a`
- if then else?

## 4. Stacked macro call convention

Since we know how many cells each macro needs, we can have a convention for passing arguments and returning values on a stack. To call a macro:

- Move cursor above all locals of current macro
- Copy arguments
- Call macro
- Clean all cells except return values
- Move return value to wanted destination
