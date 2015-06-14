<<
function check_retreat_options()
	local def_comp = wesnoth.get_variable("GN_DEFENDING_COMPANY")
	def_comp = wesnoth.get_units({ { "filter_wml", { {"variables", { company = def_comp } } } } })[1]
	local side = def_comp.side
	local v = HexVec.new(def_comp.x, def_comp.y)
	local dirs = { true, true, true, true, true, true }
	for i = 1,6 do
		local va = v + adjacent_offset[i]
		local unit = wesnoth.get_unit(va.x, va.y)
		if unit ~= nil then
			dirs[i] = false
		else
			local possible = 0
			for vaa in adjacent_tiles(va) do
				local aunit = wesnoth.get_unit(vaa.x, vaa.y)
				if aunit ~= nil then
					if aunit.side == side then
						possible = possible + 1
					else
						possible = possible - 1
					end
				end
			end
			if possible <= 0 then
				dirs[i] = false
			end
		end
	end

	for i = 1, 6 do
		if dirs[i] then
			wesnoth.set_variable("GN_RETREAT["..i.."].possible", true)
			local va = v + adjacent_offset[i]
			wesnoth.set_variable("GN_RETREAT["..i.."].x", va.x)
			wesnoth.set_variable("GN_RETREAT["..i.."].y", va.y)
		else
			wesnoth.set_variable("GN_RETREAT["..i.."].possible", false)
		end
	end
end

function find_sign_post_positions()
	local def_comp = wesnoth.get_variable("GN_DEFENDING_COMPANY")
	local captain = wesnoth.get_units({ {"filter_wml", { { "variables", { company = def_comp } } } }, canrecruit = true })[1]
	local md = HexVec.new(wesnoth.get_map_size())
	local function map_contains(u) return u.x > 0 and u.x <= md.x and u.y > 0 and u.y <= md.y end
	local u = HexVec.new(captain.x, captain.y)
	for i = 1, 6 do
		if wesnoth.get_variable("GN_RETREAT["..i.."].possible") == true then
			local ua = u
			while map_contains(ua + adjacent_offset[i]) do ua = ua + adjacent_offset[i] end
			--print("place_sign_posts: ua ", ua)
			wesnoth.set_variable("GN_RETREAT["..i.."].xl", ua.x)
			wesnoth.set_variable("GN_RETREAT["..i.."].yl", ua.y)
		end
	end
end

print("retreat_functions.lua loaded.")
>>
