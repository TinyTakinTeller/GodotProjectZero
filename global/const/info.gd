class_name Info

const npc_hover: Dictionary = {
	"cat": "Suspicious looking creature, somehow able to produce human speech."
}
const npc_hover_title: Dictionary = {}

const npc_click: Dictionary = {
	"cat": "I do not want to do that... all my senses, are screaming... Do. Not. Click. Her."
}

const npc_click_title: Dictionary = {"cat": "Click The Cat ??"}

const scale_settings: Dictionary = {
	-1: "How did we get here?",
	1: "One by one.",
	10: "Huh, that's quite the crowd. I have never seen these men in my life.",
	100: "Three clicks for three hundred men. Children, gather round!",
	1000: "Thousand, Kilo, K, ... Okay. But, don't forget to drink plenty of water.",
	10000: "It's over 9000! There is no way...",
	100000: "Hundred thousand years of war... wait, wrong game.",
	1000000: "Who wants to be a million?",
	10000000: "A small loan of a couple million...",
	100000000: "Are you sure this is enough people?  ¯\\_( ツ )_/¯",
	1000000000: "They Are Billions! Can the humanity survive?",
	10000000000: "Okay stop overplaying this game, please. YES YOU.",
	100000000000: "How did we get here?"
}


static func get_npc_hover_info(npc_id: String) -> String:
	return Info.npc_hover.get(npc_id, "")


static func get_npc_hover_title(npc_id: String) -> String:
	return Info.npc_hover_title.get(npc_id, StringUtils.humanify_string(npc_id))


static func get_npc_click_info(npc_id: String) -> String:
	return Info.npc_click.get(npc_id, "")


static func get_npc_click_title(npc_id: String) -> String:
	return Info.npc_click_title.get(npc_id, StringUtils.humanify_string(npc_id))


static func get_scale_settings_info(scale_: int) -> String:
	return Info.scale_settings.get(scale_, Info.scale_settings[-1])
