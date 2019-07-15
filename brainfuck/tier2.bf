# This is a lot of fun!

# res and 0 reset a cell to 0

*res a	# [a] --> [0]

	[-]

*0	!res

# All other numerals expect an empty cell to begin with [a] --> [a + n]

*1	+
*2	++
*3	+++
*4	++++
*5	+++++
*6	++++++
*7	+++++++
*8	++++++++
*9	!5 !4
*10 !5 !5

*add a b	# [a] b --> [a+b]
>[-<+>]


*main foo bar

@foo ++
@bar +++
@foo !res