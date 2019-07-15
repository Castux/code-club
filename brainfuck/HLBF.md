# Higher level Brainfuck

Three tier improvements:

## 1. Named blocks

Basically macros/text insertion. Can't be recursive!

## 2. Name variables inside blocks.

Basically give names to the N memory cells under the cursor and to the right at the time the macro is invoked.

Then have commands that use these addresses:

- move cursor to `a`
- set `a` to constant
- (in/de)crease `a` by constant

Each macro can announce what cells it will modify, to what, and if touches anything else, like temporary use cells ("registers").

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
