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

	HexVecSet._index_meta = {}

	function HexVecSet.new()
		local s = { _length = 0, _index_table = {} }
		setmetatable(s._index_table, HexVecSet._index_meta)
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

		add = function (self, other)
			for u, val in other() do
				self[u] = val
			end
		end,

		subtract = function (self, other)
			local tmp = self()()
			for u in other() do
				self[u] = nil
			end
			if tmp ~= nil and self()() == nil and #self > 0 then error("subtract broke sth") end
		end,

		insert = function (self, other, func)
			for u, data in other() do
				if self[u] ~= nil then
					if func == nil then
						self[u] = data
					else
						self[u] = func(self[u], data)
					end
				end
			end
		end,

		xor_with = function (self, other)
			for u in (self * other)() do
				self[u] = nil
				other[u] = nil
			end
		end,

		get_by_index = function (self, index)
			local vecind = rawget(self, "_index_table")[index]
			local data = rawget(self, vecind)
			if data == nil then return nil end
			return data[1], data[2]
		end,

		random_hex = function(self, random_number)
			local i, r = ran_int(random_number, #self)
			local u, t = self:get_by_index(i)
			return u, r
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
		end,

		thin = function(self, rand_gen, fraction)
			local size = #self
			for void = 1, fraction * size do
				self[self:random_hex(rand_gen())] = nil
			end
		end
	}

	function HexVecSet._mt.__newindex(s, u, v)
		if type(u) ~= "table" or getmetatable(u) ~= HexVec._mt then
			error("Error: tried to set value with non-HexVec key", u)
			return nil
		end
		local prev = s[u]
		local ind = HexVecSet._vec2ind(u)
		if v == nil and prev ~= nil then
			local it = rawget(s,"_index_table")
			rawset(s, ind, nil)
			rawset(s, "_length", #s - 1)
			rawget(s, "_index_table"):delete(ind)
			it = rawget(s,"_index_table")
		elseif v ~= nil then
			if prev == nil then
				rawset(s, "_length", #s + 1)
				rawget(s, "_index_table"):add(ind)
			end
			rawset(s, ind, {u, v})
		end
	end

	function HexVecSet._mt.__call(s)
		local i = 0
		return function()
			i = i + 1
			return s:get_by_index(i)
		end
	end

	-- Addition is union
	function HexVecSet._mt.__add(l, r)
		local res = HexVecSet.new()
		for u in l() do res[u] = true end
		for u in r() do res[u] = true end
		return res
	end

	-- Multiplication is intersection
	function HexVecSet._mt.__mul(l, r)
		local res = HexVecSet.new()
		for u in l() do
			if r[u] ~= nil then res[u] = true end
		end
		return res
	end

	function HexVecSet._mt.__len(s)
		return rawget(s, "_length")
	end

	function HexVecSet._index_meta.__index(it, func)
		return HexVecSet._index_table_functions[func]
	end

	HexVecSet._index_table_functions =
	{
		find = function(self, number)
			if #self == 0 or number < self[1] then return 1 end
			if number > self[#self] then return #self + 1 end
			local upper, middle, lower = #self, 1, 1
			while upper ~= lower and upper ~= lower + 1 do
				middle = math.floor((upper + lower) / 2)
				if number > self[middle] then lower = middle
				elseif number < self[middle] then upper = middle
				else return middle
				end
			end
			if number == self[lower] then return lower end
			return upper
		end,

		add = function(self, number)
			table.insert(self, self:find(number), number)
		end,

		delete = function(self, number)
			table.remove(self, self:find(number))
		end
	}

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

	HexVecSet._super_hex_storage = { r = 0, n = HexVecSet.new(), [0] = HexVecSet.new() }
	HexVecSet._super_hex_storage[0][HexVec.new({0,0})] = true
	for i = 1, 6 do
		HexVecSet._super_hex_storage.n[adjacent_offset[i]] = {i}
	end

	function HexVecSet._grow_super_hex_storage()
		local function ad(set, pos, dir)
			pos = pos + adjacent_offset[dir]
			if set[pos] == nil then set[pos] = {} end
			set[pos][#set[pos] + 1] = dir
		end
		local function are_close(dirs)
			return left_to(dirs[1]) == dirs[2] or right_to(dirs[1]) == dirs[2]
		end

		local r = HexVecSet._super_hex_storage.r
		local n = HexVecSet._super_hex_storage.n
		local m = HexVecSet.new()
		local h = HexVecSet.new()
		for npos, ndir in n() do
			n[npos] = true
			if #ndir == 1 then
				ad(m, npos, left_to(ndir[1]))
				ad(m, npos, ndir[1])
				ad(m, npos, right_to(ndir[1]))
			elseif #ndir == 2 and are_close(ndir) then
				for void, dir in pairs(ndir) do
					ad(m, npos, dir)
					local hp = npos + adjacent_offset[dir]
					if h[hp] ~= nil then
						m[hp] = nil
						local left, right = h[hp], dir
						if dir == left_to(h[hp]) then left, right = dir, h[hp] end
						ad(m, hp, left_to(left))
						ad(m, hp, left)
						ad(m, hp, right)
						ad(m, hp, right_to(right))
						h[hp] = true
					else
						h[hp] = dir
					end
				end
			end
		end
		for hpos, hbool in h() do if hbool == true then n[hpos] = true end end
		HexVecSet._super_hex_storage.r, r = r + 1, r + 1
		HexVecSet._super_hex_storage[r] = n
		HexVecSet._super_hex_storage.n = m
	end

	function HexVecSet.super_hex(center, radius, value)
		while HexVecSet._super_hex_storage.r < radius do
			HexVecSet._grow_super_hex_storage()
		end

		local s = HexVecSet.new()
		for i = 0, radius do
			for pos in HexVecSet._super_hex_storage[i]() do
				s[center + pos] = value
			end
		end
		return s
	end

	keep_conn = {}
	for i = 1,6 do keep_conn[i] = adjacent_offset[i]*(map_size*2) end

	function dir(u)
		if u[1] * u[2] < 0 then
			local ret = 1 - u[1]/u[2]
			if math.abs(u[1]) > math.abs(-u[2]) then ret = 3 + u[2]/u[1] end
			if u[1] < 0 then ret = ret + 3 end
			return ret
		end
		local ret = u[2] / (u[1] + u[2])
		if u[1] > 0 or u[2] > 0 then ret = ret + 3
		elseif u[1] < u[2] then ret = ret + 6
		end
		return ret
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
