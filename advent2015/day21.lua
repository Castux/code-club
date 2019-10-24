local boss =
{	
	hp = 103,
	damage = 9,
	armor = 2
}

local weapons =
{
	{ name = "Dagger", cost = 8, damage = 4},
	{ name = "Warhammer", cost = 25, damage = 6},
	{ name = "Longsword", cost = 40, damage = 7},
	{ name = "Greataxe", cost = 74, damage = 8},
}

local armors =
{
	{ name = "Leather", cost = 13, armor = 1},
	{ name = "Chainmail", cost = 31, armor = 2},
	{ name = "Splintmail", cost = 53, armor = 3},
	{ name = "Bandedmail", cost = 75, armor = 4},
	{ name = "Platemail", cost = 102, armor = 5},
	{ name = "NoArmor", }
}

local rings =
{
	{ name = "Defense1", cost = 20, armor = 1},
	{ name = "Defense2", cost = 40, armor = 2},
	{ name = "Defense3", cost = 80, armor = 3},
	{ name = "Damage1", cost = 25, damage = 1},
	{ name = "Damage2", cost = 50, damage = 2},
	{ name = "Damage3", cost = 100, damage = 3},
	{ name = "NoRing1" },
	{ name = "NoRing2" },
}

local function iterate_setups()

	for _,weapon in ipairs(weapons) do
		for _,armor in ipairs(armors) do

			for i,ring1 in ipairs(rings) do
				for j = i+1,#rings do
					local ring2 = rings[j]

					coroutine.yield({weapon, armor, ring1, ring2})

				end
			end
		end
	end
end

local function player_wins(player, boss)

	player.tmp_hp = player.hp
	boss.tmp_hp = boss.hp

	local attacker,defender = player,boss

	while player.tmp_hp > 0 and boss.tmp_hp > 0 do
		defender.tmp_hp = defender.tmp_hp - math.max(attacker.damage - defender.armor, 1)
		attacker,defender = defender,attacker
	end

	local player_won = player.tmp_hp > boss.tmp_hp
	player.tmp_hp, boss.tmp_hp = nil,nil

	return player_won
end

local function test()

	assert(player_wins(
			{ hp = 8, damage = 5, armor = 5 },
			{ hp = 12, damage = 7, armor = 2 }) == true)

end

test()

local function combine(setup)

	local res = {}

	for _,item in ipairs(setup) do
		for k,v in pairs(item) do
			if k ~= "name" then

				res[k] = (res[k] or 0) + v

			end
		end
	end

	return res
end

local function run(part_2)

	local winner
	local cost = part_2 and math.mininteger or math.maxinteger

	for setup in coroutine.wrap(iterate_setups) do
		local combined = combine(setup)
		combined.hp = 100
		combined.armor = combined.armor or 0

		local win = player_wins(combined, boss)

		if not part_2 then
			if win then
				if combined.cost < cost then
					cost = combined.cost
					winner = setup
				end
			end

		else -- part2
			if not win then
				if combined.cost > cost then
					cost = combined.cost
					winner = setup
				end
			end
		end
	end

	for i,v in ipairs(winner) do
		io.write(v.name, " ")
	end
	print ""
	print(cost)
end

run()
run(true)