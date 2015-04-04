habitat = {}

local habitat_data = {}
function habitat:generate(...)
	table.insert(habitat_data, {...})
end

local c = {air = minetest.get_content_id("air")}
local function get_content(name)
	local id = c[name]
	if id then
		return id
	end
	id = minetest.get_content_id(name)
	c[name] = id
	return id
end

minetest.register_on_generated(function(minp, maxp, seed)
	local t1 = os.clock()
	print("[habitat] generating...")

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	local count = 0
	for _,data in pairs(habitat_data) do
		local node, surface, _, _, height_min, height_max, spread, habitat_size, habitat_nodes, antitat_size, antitat_nodes
			= unpack(data)
		if height_min <= maxp.y
		and height_max >= minp.y then

			local node_id = get_content(node)
			local surface_id = get_content(surface)

			local height_min_max = math.max(height_min,minp.y)
			local height_max_min = math.min(height_max,maxp.y)
			local width = maxp.x-minp.x
			local length = maxp.z-minp.z
			for z_current = spread/2, length, spread do
				for x_current = spread/2, width, spread do
					local x_deviation = math.floor(math.random(spread))-spread/2
					local z_deviation = math.floor(math.random(spread))-spread/2
					local n
					for y_current = height_max_min, height_min_max, -1 do 
						local n_top = n
						local p = {x=minp.x+x_current+x_deviation, y=y_current, z=minp.z+z_current+z_deviation}
						n = data[area:indexp(p)]
						if surface_id == n
						and n_top == c.air then
							local p_top = {x=p.x, y=p.y+1, z=p.z}
							if minetest.find_node_near(p_top, habitat_size, habitat_nodes) ~= nil
							and minetest.find_node_near(p_top, antitat_size, antitat_nodes) == nil	then
								count = count + 1
								data[area:indexp(p_top)] = node_id
							end
						end
					end
				end
			end
		end
	end
	local info = "[habitat] "
	if count == 0 then
		info = info.."done "
	else
		vm:set_data(data)
		vm:write_to_map()
		info = info.."generated "..count.." nodes "
	end
	info = info..string.format("after ca. %.2fs", os.clock() - t1)
	print(info)
end)

print("[Habitat] Loaded!")
