<<
function check_retreat_options()
	local def_comp = wesnoth.get_variable("GN_DEFENDING_COMPANY")
	print("check_retreat_options: ", def_comp)
	def_comp = wesnoth.get_units({ { "filter_wml", { {"variables", { company = def_comp } } } } })[1]
	print("check_retreat_options: ", def_comp.side)
	local side = def_comp.side
	local v = HexVec.new(def_comp.x, def_comp.y)
	local dirs = { 1, 1, 1, 1, 1, 1}
	for i = 1,6 do
		local va = v + adjacent_offset[i]
		local unit = wesnoth.get_unit(va.x, va.y)
		if unit ~= nil then
			if unit.side ~= side then
				dirs[i] = -4
				dirs[left_to(i)] = dirs[left_to(i)] - 1
				dirs[right_to(i)] = dirs[right_to(i)] - 1
			else
				dirs[i] = -4
				dirs[left_to(i)] = dirs[left_to(i)] + 1
				dirs[right_to(i)] = dirs[right_to(i)] + 1
			end
		end
	end

	for i = 1, 6 do
		if dirs[i] > 0 then
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
