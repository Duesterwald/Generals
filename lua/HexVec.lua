<<
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
		return HexVec.new({-a[1], -a[2]})
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

	function HexVec._mt.__eq(u, v)
		return u.x == v.x and u.y == v.y
	end

	function HexVec._mt.__tostring(u)
		return "(" .. u[1] .. ", " .. u[2] .. ")"
	end

	function HexVec._mt.__index(vec, index)
		if index == "distance" or index == "length" then
			if vec[1] * vec[2] > 0 then return math.abs(vec[1] + vec[2])
			else return math.max(math.abs(vec[1]), math.abs(vec[2]))
			end

		elseif index == "x" then return vec[1]
		elseif index == "y" then return vec[2] + math.ceil(vec[1]/2)
		end
	end

	HexVecSet = {}
	HexVecSet._mt = {}

	function HexVecSet.new()
		local s = {}
		setmetatable(s, HexVecSet._mt)
		return s
	end

	function HexVecSet._vec2ind(u)
		return 100000 * u[1] + u[2]
	end

	function HexVecSet._mt.__index(s, u)
		if HexVecSet._functions[u] ~= nil then return HexVecSet._functions[u] end
		if type(u) ~= "table" or getmetatable(u) ~= HexVec._mt then
			error("Error: tried to obtain value of non-HexVec key" .. u)
			return nil
		end
		local entry = rawget(s, HexVecSet._vec2ind(u))
		if entry == nil then return nil else return entry[2] end
	end

	HexVecSet._functions =
	{
		contains = function (self, pos)
			return self[pos] ~= nil
		end,

		overlaps_with = function (self, other)
			for u in self() do
				for v in other() do
					if u == v then return true end
				end
			end
		end,

		touches = function (self, other)
			for u in self() do
				for v in other() do
					if (u - v).length == 1 then return true end
				end
			end
		end,

		border = function (self, value, include_self)
			local res = HexVecSet.new()
			for u,d in self() do
				for i = 1, 6 do
					local b = u + adjacent_offset[i]
					if self[b] == nil and res[b] == nil then res[b] = value end
				end
				if include_self then res[u] = d end
			end
			return res
		end
	}

	function HexVecSet._mt.__newindex(s, u, v)
		if type(u) ~= "table" or getmetatable(u) ~= HexVec._mt then
			error("Error: tried to set value with non-HexVec key" .. u)
			return nil
		end
		rawset(s, HexVecSet._vec2ind(u), {u, v})
	end

	function HexVecSet._mt.__call(s)
		local val, current_index = nil
		return function()
			current_index, val = next(s, current_index)
			if val == nil then return nil else return val[1], val[2] end
		end
	end

	function HexVecSet._mt.__len(s)
		local l = 0
		for i in s() do l = l + 1 end
		return l
	end

	adjacent_offset =
	{
		HexVec.new({ 0,-1}),
		HexVec.new({ 1,-1}),
		HexVec.new({ 1, 0}),
		HexVec.new({ 0, 1}),
		HexVec.new({-1, 1}),
		HexVec.new({-1, 0})
	}

	function left_to(i)
		if i == 1 then return 6 end
		return i - 1
	end

	function right_to(i)
		if i == 6 then return 1 end
		return i + 1
	end

	keep_conn = {}
	for i = 1,6 do keep_conn[i] = adjacent_offset[i]*(map_size*2) end

	function dir(u)
		local l = u.length
		for d = 1, 6 do
			if adjacent_offset[d]*l == u then return d end
		end
		return nil
	end

	--! Returns an iterator over adjacent locations that can be used in a for-in loop.
	function adjacent_tiles(v)
		local i = 1
		return function()
			while i <= 6 do
				local u = v + adjacent_offset[i]
				i = i + 1
				return u
			end
			return nil
		end
	end

	function random_position(random_number, max_radius)
		local sextant = nil
		local number_tiles, i = (max_radius * max_radius + max_radius) / 2, nil

		sextant, random_number = ran_int(random_number, 6)
		i, random_number = ran_int(random_number, number_tiles)

		while number_tiles > i and max_radius > 0 do
			number_tiles = number_tiles - max_radius
			max_radius = max_radius - 1
		end

		local radial = adjacent_offset[sextant] * (max_radius + 1)
		local tangential = adjacent_offset[ 1 + ((sextant + 1) % 6)] * (i - number_tiles)
		return radial + tangential, random_number
	end

	print("HexVec.lua loaded")
>>
