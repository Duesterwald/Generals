<<
	_ = wesnoth.textdomain("wesnoth")
	G = wesnoth.textdomain("generals")
	T = {}
	setmetatable(T, { __index = function (self, key) return function(val) return { key, val } end end })

	function GUI_FORCE_WIDGET_MINIMUM_SIZE(w,h, content)
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

	function column(data)
		if data.border == nil then data.border = "all" end
		if data.border_size == nil then data.border_size = 5 end
		if data.horizontal_alignment == nil then data.horizontal_alignment = "left" end
		return T.column(data)
	end

	function row(data)
		if data.horizontal_grow == nil then data.horizontal_grow = true end
		return T.row(data)
	end

	print("dialog_common.lua loaded.")
>>

