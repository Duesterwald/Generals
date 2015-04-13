<<
	local a = ...
	local helper = wesnoth.require("lua/helper.lua")
	local terrain = {wesnoth.get_terrain(a.x1, a.y2), wesnoth.get_terrain(a.x2, a.y2)}
	local map_size = wesnoth.get_variable("GN_LOCAL_MAP_SIZE")

	HexVec = {}
	HexVec._mt = {}

	function HexVec.new(x,y)
		local vec = {}
		if type(x) == "table" then
			if type(x[1]) == "number" and type(x[2]) == "number" then
				vec = { x[1], x[2] }
			elseif type(x.x) == "number" and type(x.y) == "number" then
				vec = { x.x, x.y - math.ceil(x.x/2) }
			end
		elseif type(x) == "number" and type(y) == "number" then
			vec = { x, y - math.ceil(x/2) }
		end
		if vec == {} then error("No valid arguments for HexVec constructor!") end
		setmetatable(vec, HexVec._mt)
		return vec
	end

	function HexVec._mt.__add(a,b)
		if getmetatable(b) ~= HexVec._mt then
			error("Trying to add a non-HexVec on the right hand side.")
		end
		local res = HexVec.new(a)
		res[1], res[2] = res[1] + b[1], res[2] + b[2]
		return res
	end

	function HexVec._mt.__unm(a)
		return HexVec.new(-a[1], -a[2])
	end

	function HexVec._mt.__sub(a,b)
		return a + (-b)
	end

	function HexVec._mt.__mul(a,s)
		if type(s) ~= "number" then error("Tried to multiply HexVec with non-scalar") end
		return HexVec.new({a[1]*s, a[2]*s})
	end

	function HexVec._mt.__div(a,s)
		if type(s) ~= "number" then error("Tried to divide HexVec by non-scalar") end
		return HexVec.new({a[1]/s, a[2]/s})
	end

	function HexVec._mt.__index(vec, index)
		if index == "distance" or index == "length" then
			if vec[1] * vec[2] > 0 then return vec[1] + vec[2]
			else return math.max(math.abs(vec[1]), math.abs(vec[2]))
			end

		elseif index == "x" then return vec[1]
		elseif index == "y" then return vec[2] + math.ceil(vec[1]/2)
		end
	end

	local adjacent_offset =
	{
		HexVec.new({ 0,-1}),
		HexVec.new({ 1,-1}),
		HexVec.new({ 1, 0}),
		HexVec.new({ 0, 1}),
		HexVec.new({-1, 1}),
		HexVec.new({-1, 0})
	}

	local keep_offset = {}
	for i,vec in ipairs(adjacent_offset) do
		keep_offset[i] = vec * map_size
	end

	local keep_pos = HexVec.new( 2 + math.ceil(map_size/4), 2 + math.ceil(map_size/6) )

	local keep = { keep_pos, keep_pos + keep_offset[3] }
	local map_dim = { x = keep[2].x + keep_pos.x - 1, y = keep[2].y + keep_pos.y - 1}

	--! Returns an iterator over adjacent locations that can be used in a for-in loop.
	local function adjacent_tiles(v)
		local i = 1
		return function()
			while i <= 6 do
				local u = v + adjacent_offset[i]
				i = i + 1
				if u.x >= 0 and u.y <= map_dim.x + 1 and u.y >= 0 and u.y <= map_dim.y + 1 then
					return u
				end
			end
			return nil
		end
	end

	local map = {}
	for x = 0, map_dim.x + 1 do
		map[x]={}
		for y = 0, map_dim.y + 1 do
			map[x][y] = "Gg"
		end
	end

	local rd = HexVec.new(keep_pos)
	for i = 1,map_size do
		rd = rd + adjacent_offset[3]
		map[rd.x][rd.y] = "Rd"
	end

	for i = 1,2 do
		map[keep[i].x][keep[i].y] = "Ke"
		for u in adjacent_tiles(keep[i]) do
			map[u.x][u.y] = "Ce"
		end
	end
	
	map_string = "border_size=1\nusage=map\n\n"
	for y = 0, map_dim.y + 1 do
		for x = 0, map_dim.x do
			map_string = map_string .. map[x][y] .. ','
		end
		map_string = map_string .. map[map_dim.x + 1][y] .. '\n'
	end

	wesnoth.set_variable("local_map", map_string)
	wesnoth.set_variable("GN_ATTACKER_X", keep[1].x)
	wesnoth.set_variable("GN_ATTACKER_Y", keep[1].y)
	wesnoth.set_variable("GN_DEFENDER_X", keep[2].x)
	wesnoth.set_variable("GN_DEFENDER_Y", keep[2].y)
>>

