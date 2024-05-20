class_name ScrollContainerUtils


static func disable_scrollbars(scroll_container: ScrollContainer) -> void:
	var invisible_scrollbar_theme: Theme = Theme.new()
	var empty_stylebox: StyleBoxEmpty = StyleBoxEmpty.new()
	invisible_scrollbar_theme.set_stylebox("scroll", "VScrollBar", empty_stylebox)
	invisible_scrollbar_theme.set_stylebox("scroll", "HScrollBar", empty_stylebox)
	scroll_container.get_h_scroll_bar().theme = invisible_scrollbar_theme
	scroll_container.get_v_scroll_bar().theme = invisible_scrollbar_theme
