data = [tonumber line\match ": (%d+)" for line in io.lines "day21.txt"]
mod = (x, n) -> (x - 1) % n + 1
other = (player) -> 3 - player

class Die
	new: () =>
		@rolled = 0
	roll: () =>
		@rolled += 1
		mod @rolled, 100
	roll3: () =>
		self\roll! + self\roll! + self\roll!

part1 = () ->
	positions = {data[1], data[2]}
	scores = {0, 0}
	player = 1
	die = Die!
	while true
		positions[player] = mod (positions[player] + die\roll3!), 10
		scores[player] += positions[player]
		if scores[player] >= 1000
			print "Part 1", scores[other player] * die.rolled
			break
		player = other player

dirac_rolls = [i + j + k for i = 1,3 for j = 1,3 for k = 1,3]

state_to_int = (s1, s2, p1, p2) ->
	s1 << 24 | s2 << 16 | p1 << 8 | p2

int_to_state = (i) ->
	s1 = (i >> 24) & 0xFF
	s2 = (i >> 16) & 0xFF
	p1 = (i >> 8) & 0xFF
	p2 = (i >> 0) & 0xFF
	{s1, s2}, {p1, p2}

apply_roll = (i, player, roll) ->
	scores, positions = int_to_state i
	positions[player] = mod (positions[player] + roll), 10
	scores[player] += positions[player]
	if scores[player] >= 21
		"win"
	else
		state_to_int scores[1], scores[2], positions[1], positions[2]

part2 = () ->
	start_state = state_to_int 0, 0, data[1], data[2]
	states = { [start_state]: 1 }
	wins = {0, 0}
	player = 1

	while next states
		new_states = {}
		for state,count in pairs states
			for roll in *dirac_rolls
				result = apply_roll state, player, roll
				if result == "win"
					wins[player] += count
				else
					new_states[result] = (new_states[result] or 0) + count
		player = other player
		states = new_states

	print "Part 2", math.max(wins[1], wins[2])

part1!
part2!
