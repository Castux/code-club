# With variables, we have nicer(?) syntaxes:
# a++			@a +
# a--			@a -
# while(a>0)	@a [ ... @a ]
#
#

# res and 0 reset a cell to 0

*res a	# [a] --> [0]

@a [
	@a -
@a ]

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

@b[
	@b -
	@a +
@b]
@a

*sub a b	# [a] b --> [a-b]

@b[
	@b -
	@a -
@b]
@a

*up a b		# [a] b --> [0] a

@b !res
@a[
	@a -
	@b +
@a]
@a

*up2 a b c	# [a] b c --> [0] b a

@c !res
@a[
	@a -
	@c +
@a]
@a

*down2 a b c

	@a !res
	@c [
		@c -
		@a +
	@c ]
	@a

*mul a b t1 t2

@a[
	@a -
	@b[
		@b -
		@t1 +
		@t2 +
	@b]
	
	@b !down2
@a]
@b !res
@a !down2


*main a b

@a !5
@b !9
@a !mul2