<<
	local _ = wesnoth.textdomain("wesnoth")
	local T = {}
	setmetatable(T, { __index = function (self, key) return function(val) return { key, val } end end })

	local function GUI_FORCE_WIDGET_MINIMUM_SIZE(w,h, content)
		return T.stacked_widget {
			definition = "default",
			T.stack { T.layer { T.row { T.column { T.spacer {
								definition = "default",
								width = w,
								height = h
				} } } },
				T.layer { T.row { grow_factor = 1, T.column {
							grow_factor = 1,
							horizontal_grow = "true",
							vertical_grow = "true",
							content
				} } }
			}
		}
	end

	local function column(data)
		data.border = "all"
		data.border_size = 5
		data.horizontal_alignment = "left"
		return T.column(data)
	end

	local unit_descriptor_header = T.row {
		column { T.spacer { linked_group = "img", id = "unit_descriptor_icon" } },
		column { T.label  { linked_group = "typ", id = "unit_descriptor_type",  label = _"Type"} },
		column { T.label  { linked_group = "nam", id = "unit_descriptor_name",  label = _"Name" } },
		column { T.label  { linked_group = "lvl", id = "unit_descriptor_level", label = _"Level" } },
		column { T.label  { linked_group = "exp", id = "unit_descriptor_exp",   label = _"XP" } }
	}

	local unit_descriptor = T.row { T.column {
		T.toggle_panel
		{
			id = "unit_descriptor",
			T.grid { T.row {
				column { T.image { linked_group = "img", id = "unit_descriptor_icon" } },
				column { T.label { linked_group = "typ", id = "unit_descriptor_type" } },
				column { T.label { linked_group = "nam", id = "unit_descriptor_name" } },
				column { T.label { linked_group = "lvl", id = "unit_descriptor_level" } },
				column { T.label { linked_group = "exp", id = "unit_descriptor_exp" } }
			} }
		}
	} }

	local company_info_dialog = {
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },

		T.linked_group { id = "img", fixed_width = true },
		T.linked_group { id = "typ", fixed_width = true },
		T.linked_group { id = "nam", fixed_width = true },
		T.linked_group { id = "lvl", fixed_width = true },
		T.linked_group { id = "exp", fixed_width = true },

		T.grid
		{
			T.row { T.column { T.label { definition = "title", id = "cpt_title", label = _"Captain" } } },
			T.row { T.column { horizontal_grow = true,
				T.listbox
				{
					id = "captain",
					T.header { unit_descriptor_header},
					T.list_definition { unit_descriptor } }
			} },

			T.row { T.column { T.spacer { id = "mid_spacer", height = 20 } } },

			T.row { T.column { T.label { definition = "title", id = "units_title", label = _"Units" } } },
			T.row { T.column { horizontal_grow = true,
				T.listbox
				{
					id = "units",
					T.header { unit_descriptor_header},
					T.list_definition { unit_descriptor } }
			} },

			T.row { T.column { T.spacer { id = "fin_spacer", height = 10 } } },

			T.row { T.column { T.grid { T.row {
				T.column { T.button { id = "profile", label = _"Profile" } },
				T.column { horizontal_grow = true, grow_factor = 1, T.spacer { id = "left_button_spacer" } },
				T.column { T.button { id = "ok", label = _"OK", return_value = -1 } },
				T.column { horizontal_grow = true, grow_factor = 1, T.spacer { id = "right_button_spacer" } },
				T.column { T.button { id = "dismiss", label = _"Dismiss Unit", return_value = 1 } }
			} } } }
		}
	}

	local function populate_unit_descriptor(list, index, wesnoth_variable)
		wesnoth.set_dialog_value(wesnoth_variable.image, list, index, "unit_descriptor_icon")
		wesnoth.set_dialog_value(wesnoth_variable.type,  list, index, "unit_descriptor_type")
		wesnoth.set_dialog_value(wesnoth_variable.name,  list, index, "unit_descriptor_name")
		wesnoth.set_dialog_value(wesnoth_variable.level, list, index, "unit_descriptor_level")
		wesnoth.set_dialog_value(wesnoth_variable.experience .. "/" .. wesnoth_variable.max_experience,
			list, index, "unit_descriptor_exp")
	end

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
		print("Captain selected")
		selected_unit = 0
	end

	local function select_unit()
		selected_unit = wesnoth.get_dialog_value("units")
		print("Unit "..selected_unit.." selected.")
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
		local function preshow()
			gn_company = "GN_COMPANY["..index.."]"
			captain = wesnoth.get_variable(gn_company .. ".captain")
			populate_unit_descriptor("captain", 1, captain)
			wesnoth.set_dialog_callback(select_captain, "captain")

			units = {}
			local num_units = wesnoth.get_variable(gn_company .. ".unit.length")
			if num_units > 0 then
				for i = 1, num_units do
					local unit = wesnoth.get_variable(string.format("%s[%d]", gn_company .. ".unit", i - 1))
					units[#units+1] = unit
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

		local r = wesnoth.show_dialog(company_info_dialog, preshow, postshow)
		while r == 1 and #units > 0 do
			if side == captain.side then
				wesnoth.set_variable(gn_company .. ".unit["..(li-1).."]", nil)
			end
			r = wesnoth.show_dialog(company_info_dialog, preshow, postshow)
		end

		wesnoth.message(string.format("Button %d pressed. Item %d selected.", r, li))
	end

	print("dialog.lua loaded")
>>
