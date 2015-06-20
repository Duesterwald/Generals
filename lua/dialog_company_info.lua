<<

	local unit_descriptor_header = T.row {
		column { T.spacer { linked_group = "img", id = "header_icon" } },
		column { T.label  { linked_group = "typ", id = "header_type",  label = _"Type"} },
		column { T.label  { linked_group = "nam", id = "header_name",  label = _"Name" } },
		column { T.label  { linked_group = "lvl", id = "header_level", label = _"Level" } },
		column { T.label  { linked_group = "exp", id = "header_exp",   label = _"XP" } }
	}

	local unit_descriptor = T.row { T.column {
		T.toggle_panel
		{
			id = "unit_descriptor",
			T.grid { T.row {
				column { T.image { linked_group = "img", id = "icon" } },
				column { T.label { linked_group = "typ", id = "type" } },
				column { T.label { linked_group = "nam", id = "name" } },
				column { T.label { linked_group = "lvl", id = "level" } },
				column { T.label { linked_group = "exp", id = "exp" } }
			} }
		}
	} }

	local function populate_unit_descriptor(list, index, wesnoth_variable)
		wesnoth.set_dialog_value(wesnoth_variable.image, list, index, "icon")
		wesnoth.set_dialog_value(wesnoth_variable.type,  list, index, "type")
		wesnoth.set_dialog_value(wesnoth_variable.name,  list, index, "name")
		wesnoth.set_dialog_value(wesnoth_variable.level, list, index, "level")
		wesnoth.set_dialog_value(wesnoth_variable.experience .. "/" .. wesnoth_variable.max_experience,
			list, index, "exp")
	end

	local company_info_dialog =
	{
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },

		T.linked_group { id = "img", fixed_width = true },
		T.linked_group { id = "typ", fixed_width = true },
		T.linked_group { id = "nam", fixed_width = true },
		T.linked_group { id = "lvl", fixed_width = true },
		T.linked_group { id = "exp", fixed_width = true },

		T.grid
		{
			row { T.column { T.label { definition = "title", id = "cpt_title", label = _"Captain" } } },
			row { T.column { horizontal_grow = true, T.listbox
			{
				id = "captain",
				T.header { unit_descriptor_header },
				T.list_definition { unit_descriptor }
			} } },

			row { T.column { T.spacer { id = "mid_spacer", height = 20 } } },

			row { T.column { T.label { definition = "title", id = "units_title", label = _"Units" } } },
			row { column { T.listbox
			{
				id = "units",
				T.header { unit_descriptor_header },
				T.list_definition { unit_descriptor }
			} } },

			row { T.column { T.spacer { id = "fin_spacer", height = 30 } } },

			row { T.column { horizontal_grow = true, T.grid { row
			{
				T.column { T.button { id = "profile", label = _"Profile" } },
				T.column { horizontal_grow = true, grow_factor = 1, T.spacer { id = "left_button_spacer" } },
				T.column { T.button { id = "ok", label = _"OK", return_value = -1 } },
				T.column { horizontal_grow = true, grow_factor = 1, T.spacer { id = "right_button_spacer" } },
				T.column { T.button { id = "dismiss", label = _"Dismiss Unit", return_value = 1 } }
			} } } }
		}
	}

	local selected_unit = 0

	local gn_company = nil
	local captain = nil
	local units = nil

	local no_units_place_holder = 
	{
		image = "",
		type = "No units recruited yet",
		name = "", 
		level = "",
		experience = "",
		max_experience = ""
	}

	local function select_captain()
		selected_unit = 0
	end

	local function select_unit()
		selected_unit = wesnoth.get_dialog_value("units")
	end

	local function profile()
		local typ = captain.type
		if selected_unit > 0 then
			typ = units[selected_unit].type
		end
		wesnoth.wml_actions.open_help({topic = "unit_" .. typ})
	end

	local function dismiss_unit()
		local index = wesnoth.get_dialog_value("units")
		wesnoth.set_variable(gn_company .. ".unit["..index.."]")
		units[index] = nil
		for i = index, #units do
			populate_unit_descriptor("units", i, units[i])
		end
		populate_unit_descriptor("units", #units+1, {})
		if #units == 0 then
			populate_unit_descriptor("units", 1, no_units_place_holder)
			wesnoth.set_dialog_callback(nil, "dismiss")
		end
	end

	function show_company(index, side)
		gn_company = "GN_COMPANY["..index.."]"
		captain = wesnoth.get_variable(gn_company .. ".captain")
		units = {}
		local num_units = wesnoth.get_variable(gn_company .. ".unit.length")
		if num_units > 0 then
			for i = 1, num_units do
				local unit = wesnoth.get_variable(string.format("%s[%d]", gn_company .. ".unit", i - 1))
				units[#units+1] = unit
			end
		end

		local r = wesnoth.synchronize_choice(function()
			local function preshow()
				populate_unit_descriptor("captain", 1, captain)
				wesnoth.set_dialog_callback(select_captain, "captain")

				if num_units > 0 then
					for i = 1, num_units do
						populate_unit_descriptor("units", i, unit)
					end
					wesnoth.set_dialog_callback(select_unit, "units")
				else
					populate_unit_descriptor("units", 1, no_units_place_holder )
				end

				wesnoth.set_dialog_callback(profile, "profile")
			end

			local li = 0
			local function postshow()
				li = wesnoth.get_dialog_value "units"
			end

			return { val = wesnoth.show_dialog(company_info_dialog, preshow, postshow), li = li }
		end)

		if r.val == 1 and #units > 0 then
			if side == captain.side then
				wesnoth.set_variable(gn_company .. ".unit["..(r.li-1).."]", nil)
			end
			show_company(index, side)
		end
	end

	print("dialog_company_info.lua loaded")
>>
