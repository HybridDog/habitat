habitat = {}

function habitat:generate(node, surface, minp, maxp, height_min, height_max, spread, habitat_size, habitat_nodes, antitat_size, antitat_nodes)
	minetest.register_on_generated(function(minp, maxp, seed)
		if height_min > maxp.y
		or height_max < minp.y then
			return
		end

		local height_min_max = math.max(height_min,minp.y)
		local height_max_min = math.min(height_max,maxp.y)
		local width = maxp.x-minp.x
		local length = maxp.z-minp.z
		print("[habitat] "..node)
		local count = 0
		for x_current = spread/2, width, spread do
			for z_current = spread/2, length, spread do
				local x_deviation = math.floor(math.random(spread))-spread/2
				local z_deviation = math.floor(math.random(spread))-spread/2
				local n
				for y_current = height_max_min, height_min_max, -1 do 
					local n_top = n
					count = count + 1
					local p = {x=minp.x+x_current+x_deviation, y=y_current, z=minp.z+z_current+z_deviation}
					n = minetest.get_node(p).name
					if surface == n
					and n_top == "air" then
						local p_top = {x=p.x, y=p.y+1, z=p.z}
						if minetest.find_node_near(p_top, habitat_size, habitat_nodes) ~= nil
						and minetest.find_node_near(p_top, antitat_size, antitat_nodes) == nil	then
							minetest.add_node(p_top, {name=node})
						end
					end
				end
			end
		end
		print("[habitat] "..count)
	end)
end

print("[Habitat] Loaded!")
