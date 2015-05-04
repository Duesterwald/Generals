<<
	_ = wesnoth.textdomain("wesnoth")
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
		data.border = "all"
		data.border_size = 5
		data.horizontal_alignment = "left"
		data.horizontal_grow = true
		return T.column(data)
	end

	function row(data)
		data.horizontal_grow = true
		return T.row(data)
	end

	print("dialog_common.lua loaded.")
>>

