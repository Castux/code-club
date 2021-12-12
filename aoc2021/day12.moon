adj = {}
small = {}
add_node = (node) ->
	if not adj[node]
		adj[node] = {}
		small[node] = node\lower! == node

for line in io.lines "day12.txt"
	a,b = line\match "(%w*)%-(%w*)"
	add_node a
	add_node b
	table.insert adj[a], b
	table.insert adj[b], a

count_paths = (part) ->
	visited = {node,0 for node,_ in pairs adj}
	double_cave = false
	count = 0

	helper = (node) ->
		if node == "end"
			count += 1
			return

		max_visits = if part == 2 and not double_cave and node != "start" then 2 else 1
		if small[node] and visited[node] >= max_visits
			return

		visited[node] += 1
		set_double = false
		if visited[node] == 2 and small[node]
			double_cave = true
			set_double = true

		for neighbour in *adj[node]
			helper neighbour

		if set_double then double_cave = false
		visited[node] -= 1

	helper "start"
	count

print "Part 1", count_paths(1)
print "Part 2", count_paths(2)
