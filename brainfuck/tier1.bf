# This is a lot of fun!

# res and 0 reset a cell to 0

*res	# [a] --> [0]
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


*add	# [a] b --> [a+b] 0

	>[-<+>]<

*sub	# [a] b --> [a-b] 0

	>[-<->]<

*up		# [a] b --> [0] a

	> !res <
	[->+<]

*up2	# [a] b c --> [0] b a
	>> !res <<
	[- >> + <<]

*down	# [a] b --> [b] 0
	
	!res !add

*down2	# [a] b c --> [c] b 0

	!res
	>>
	[- << + >> ]
	<<
	
*down3
	!res
	>>>
	[- <<< + >>> ]
	<<<

*times			# [a] b c d... --> [0] ? ? ?...
				# execute block a times on [b] c d...
				# block must return cursor to [b]
	[->

*times_end
	<]

*add_up		# [a] b 0 --> [a] a+b 0

	!times			# first get to [0] +a +a
		+>+<
	!times_end
	!down2			# then move 3->1

*dup		# [a] b 0 --> [a] a 0
	> !res <
	!add_up

*dup_over	# [a] b c 0 --> [a] b a
	>> !res <<
	!times
		> +>+< <
	!times_end
	!down3
	

*mul	# [a] b 0 0 --> [a*b] 0 0 0
	
	!times
		!add_up
	!times_end		# now at [0] b a*b 0
	
	!down2
	> !res <

*square		# [a] 0 0 0 --> [a * a] 0 0 0
	!dup !mul

*pow		# [b] a 0 0 0 0 --> [a^b]

	>> !res !1
	<<						# [b] a 1
	!times
		!dup_over			# [a] res	a
		> !mul <			# [a] res*a 0 
	!times_end
	
	!down2
	> !res <

*if			# a [cond] b c d... -> [a] ??
			# if cond !=, execute block on [b] c d
			# block must return cursor to b
			
	[>

*if_end
	
	< !res ]

*main

!0 
!if
	!10
!if_end