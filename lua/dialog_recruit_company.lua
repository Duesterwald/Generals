<<

	local company_info_header = T.row { T.column {
		T.toggle_panel
		{
			id = "company_info_header",
			T.grid { row {
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
			T.grid { row {
				column { T.image { linked_group = "img", id = "icon"   } },
				column { T.label { linked_group = "nam", id = "name"   } },
				column { T.label { linked_group = "cst", id = "cost"   } },
				column { T.label { linked_group = "lvl", id = "level"  } },
				column { T.label { linked_group = "hlt", id = "health" } },
				column { T.label { linked_group = "mov", id = "moves"  } }
			} }
		}
	} }

	local function populate_company_info(list, index, unit)
		wesnoth.set_dialog_value(unit.__cfg.image.."~TC("..unit.side..",magenta)",   list, index, "icon")
		wesnoth.set_dialog_value(unit.name,          list, index, "name")
		wesnoth.set_dialog_value(unit.cost,          list, index, "cost")
		wesnoth.set_dialog_value(unit.level,         list, index, "level")
		wesnoth.set_dialog_value(unit.max_hitpoints, list, index, "health")
		wesnoth.set_dialog_value(unit.max_moves,     list, index, "moves")
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
			row { T.column { T.label { definition = "title", label = G"Available Companies" } } },

			row { column { T.listbox
			{
				id = "companies",
				T.header { company_info_header },
				T.list_definition { company_info_descriptor }
			} } },

			row { column { T.grid { row
			{
				T.column { T.button { id = "profile", label = _"Profile" } },
				T.column { horizontal_grow = true, grow_factor = 1, T.spacer {} },
				T.column { T.button { id = "ok", label = _"OK", return_value = -1 } },
				T.column { horizontal_grow = true, grow_factor = 1, T.spacer {} },
				T.column { T.button { id = "cancel", label = _"Cancel", return_value = -2 } }
			} } } }
		}
	}

	local too_little_gold =
	{
		T.tooltip { id = "tooltip_large" },
		T.helptip { id = "tooltip_large" },

		T.grid { T.row { T.column { T.label {
			label = G"Not enough gold left for recruiting a company!"
		} } } }
	}

	local company_types = {}

	for type_name, type_def in pairs(wesnoth.unit_types) do
		if type_def.__cfg.race == "Company" then table.insert(company_types, type_def) end
	end

	local company_id = nil

	local function company_profile()
		wesnoth.wml_actions.open_help({topic = "unit_" .. company_types[company_id[wesnoth.get_dialog_value("companies")]].id})
	end

	function choose_company_type(gold_left, variable)
		company_id = {}
		for i, company_type in ipairs(company_types) do
			if gold_left >= company_type.cost then table.insert(company_id, i) end
		end

		local result = wesnoth.synchronize_choice( function()
			local li = 0
			if #company_id == 0 then
				wesnoth.show_dialog(too_little_gold)
			else
				local function preshow()
					for j, i in ipairs(company_id) do
						populate_company_info("companies", j, company_types[i])
					end
					wesnoth.set_dialog_callback(company_profile, "profile")
				end

				local function postshow()
					li = wesnoth.get_dialog_value("companies")
				end

				if wesnoth.show_dialog(company_type_chooser, preshow, postshow) == -2 then
					li = 0
				end
			end
			print(li, company_types[company_id[li]].id)
			if li ~= 0 then return { company = company_types[company_id[li]].id } else return nil end
		end)

		print(result.company)
		wesnoth.set_variable(variable, result.company)
	end

	print("dialog_recruit_company.lua loaded")
>>
