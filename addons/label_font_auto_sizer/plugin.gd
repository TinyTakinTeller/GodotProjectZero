@tool
extends EditorPlugin


#region Virtual functions
func _enter_tree():
	add_custom_type("AutoSizeLabel", "Label", preload("label_auto_sizer.gd"), preload("icon.svg"))
	add_custom_type("AutoSizeRichTextlabel", "RichTextLabel", preload("rich_label_auto_sizer.gd"), preload("icon.svg"))


func _exit_tree():
	remove_custom_type("AutoSizeLabel")
	remove_custom_type("AutoSizeRichTextlabel")
#endregion

