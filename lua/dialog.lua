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
			T.row { T.column { T.label { definition = "title", id = "cpt_title", label = _"Captain" } } },
			T.row { T.column { horizontal_grow = true, T.listbox
			{
				id = "captain",
				T.header { unit_descriptor_header },
				T.list_definition { unit_descriptor }
			} } },

			T.row { T.column { T.spacer { id = "mid_spacer", height = 20 } } },

			T.row { T.column { T.label { definition = "title", id = "units_title", label = _"Units" } } },
			T.row { T.column { horizontal_grow = true, T.listbox
			{
				id = "units",
				T.header { unit_descriptor_header},
				T.list_definition { unit_descriptor }
			} } },

			T.row { T.column { T.spacer { id = "fin_spacer", height = 10 } } },

			T.row { T.column { T.grid { T.row
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

	local company_info_header = T.row { T.column {
		T.toggle_panel
		{
			id = "company_info_header",
			T.grid { T.row {
				column { T.spacer { linked_group = "img", id = "header_icon" } },
				column { T.label  { linked_group = "nam", id = "header_name",   label = _"Name"} },
				column { T.label  { linked_group = "cst", id = "header_cost",   label = _"Cost"} },
				column { T.label  { linked_group = "lvl", id = "header_level",  label = _"Level"} },
				column { T.label  { linked_group = "hlt", id = "header_health", label = _"Health"} },
				column { T.label  { linked_group = "mov", id = "header_moves",  label = _"Moves"} }
			} }
		}
	} }

	local company_info_descriptor = T.row { T.column {
		T.toggle_panel
		{
			id = "company_info_descriptor",
			T.grid { T.row {
				column { T.image { linked_group = "img", id = "icon"   } },
				column { T.label { linked_group = "nam", id = "name"   } },
				column { T.label { linked_group = "cst", id = "cost"   } },
				column { T.label { linked_group = "lvl", id = "level"  } },
				column { T.label { linked_group = "hlt", id = "health" } },
				column { T.label { linked_group = "mov", id = "moves"  } }
			} }
		}
	} }

	local function populate_company_info(list, index, wesnoth_variable)
		wesnoth.set_dialog_value(wesnoth_variable.__cfg.image,   list, index, "icon")
		wesnoth.set_dialog_value(wesnoth_variable.name,          list, index, "name")
		wesnoth.set_dialog_value(wesnoth_variable.cost,          list, index, "cost")
		wesnoth.set_dialog_value(wesnoth_variable.level,         list, index, "level")
		wesnoth.set_dialog_value(wesnoth_variable.max_hitpoints, list, index, "health")
		wesnoth.set_dialog_value(wesnoth_variable.max_moves,     list, index, "moves")
	end

	local company_type_chooser =
	{
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },

		T.linked_group { id = "img", fixed_width = true },
		T.linked_group { id = "nam", fixed_width = true },
		T.linked_group { id = "cst", fixed_width = true },
		T.linked_group { id = "lvl", fixed_width = true },
		T.linked_group { id = "hlt", fixed_width = true },
		T.linked_group { id = "mov", fixed_width = true },

		T.grid
		{
			T.row { T.column { T.label { definition = "title", id = "cmp_title", label = _"Available Companies" } } },

			T.row { T.column { horizontal_grow = true, T.listbox
			{
				id = "companies",
				T.header { company_info_header },
				T.list_definition { company_info_descriptor }
			} } },

			T.row { T.column { T.grid { T.row
			{
				T.column { T.button { id = "profile", label = _"Profile" } },
				T.column { horizontal_grow = true, grow_factor = 1, T.spacer { id = "left_button_spacer" } },
				T.column { T.button { id = "ok", label = _"OK", return_value = -1 } },
				T.column { horizontal_grow = true, grow_factor = 1, T.spacer { id = "right_button_spacer" } },
				T.column { T.button { id = "cancel", label = _"Cancel", return_value = -2 } }
			} } } }
		}
	}

	local too_little_gold =
	{
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },

		T.grid { T.row { T.column { T.label { id = "tlg",
			label = _"Not enough gold left for recruiting a company!"
		} } } }
	}

	local company_types = {}

	for type_name, type_def in pairs(wesnoth.unit_types) do
		if type_def.__cfg.race == "Company" then table.insert(company_types, type_def) end
	end

	local company_id = nil

	local function company_profile()
		wesnoth.wml_actions.open_help({topic = "unit_" .. company_id[wesnoth.get_dialog_value("companies")]})
	end

	function choose_company_type(gold_left)
		company_id = {}
		for i, company_type in ipairs(company_types) do
			if gold_left >= company_type.cost then table.insert(company_id, i) end
		end

		local li = 0
		if #company_id == 0 then
			wesnoth.show_dialog(too_little_gold)
		else
			local function preshow()
				for j, i in ipairs(company_id) do
					populate_company_info("companies", j, company_types[i])
				end
				wesnoth.set_dialog_callback(profile, "profile")
			end

			local function postshow()
				li = wesnoth.get_dialog_value("companies")
			end

			if wesnoth.show_dialog(company_type_chooser, preshow, postshow) == -2 then
				li = 0
			end
		end

		local result = ""
		if li ~= 0 then result = company_types[company_id[li]].id end
		wesnoth.set_variable("gn_chosen_company", result)
	end

	print("dialog.lua loaded")
>>
