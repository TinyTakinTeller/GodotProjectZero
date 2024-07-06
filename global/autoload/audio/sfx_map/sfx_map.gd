extends Node

const SFX_ID: Dictionary = {
	"manager_button_allocated": COINS_2_1_CUT,
	"manager_button_zero": ARROW_HIT_1_1_CUT,
	"managment_screen_cycle": COINS_1_1,
	"unlock_controller_unlock": null,  #MAGIC_CHIMES_1_7,  #PIANO_1,
	"progress_button_down": UI_SIMPLE_5_1,
	"progress_button_success": UI_SIMPLE_2_1,
	"progress_button_fail": UI_SIMPLE_3_2,
	"generic_click": BOOK_1_1_CUT,
	"enemy_click_1": GENERIC_HIT_1_1,
	"enemy_click_2": GENERIC_HIT_2_1,
	"enemy_click_3": GENERIC_HIT_3_1,
	"enemy_click_4": GENERIC_HIT_4_1,
	"swordsmen_cycle_1": STAB_1_1,
	"swordsmen_cycle_2": STAB_2_1,
	"swordsmen_cycle_3": WHOOSH_METAL_3_1,
	"enemy_explode": FIRE_WHOOSH_1_1,
	"enemy_implode": FIRE_BURST_1_1,
	"diary_entry_1": WRITING_1_1,
	"diary_entry_2": WRITING_1_4,
	"cat_click": PIANO_1,
	"cat_talking": KEYBOARD_TYPING
}

const KEYBOARD_TYPING = preload(
	"res://assets/audio/freesound_org/keyboard_typing/keyboard_typing.mp3"
)

## res://assets/audio/indie_friendly_sounds_survival/_edited/
const ARROW_HIT_1_1_CUT = preload(
	"res://assets/audio/indie_friendly_sounds_survival/_edited/arrow_hit_1_1_cut.wav"
)
const BOOK_1_1_CUT = preload(
	"res://assets/audio/indie_friendly_sounds_survival/_edited/book_1_1_cut.wav"
)
const COINS_2_1_CUT = preload(
	"res://assets/audio/indie_friendly_sounds_survival/_edited/coins_2_1_cut.wav"
)
const WOOD_BUNDLE_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/_edited/wood_bundle_1.wav"
)
const WOOD_CHOP_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/_edited/wood_chop_1.wav"
)

## res://assets/audio/indie_friendly_sounds_survival/indie_friendly_survival_sounds/
const FIRE_BURST_1_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_survival_sounds/fire_burst_1_1.wav"
)

## res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/misc/
const COINS_1_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/misc/coins_1_1.wav"
)
const FIRE_WHOOSH_1_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/misc/fire_whoosh_1_1.wav"
)
const WRITING_1_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/misc/writing_1_1.wav"
)
const WRITING_1_4 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/misc/writing_1_4.wav"
)

## res://assets/audio/custom_sfx/
const PIANO_1 = preload("res://assets/audio/custom_sfx/piano_1.wav")

## res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/interface/
const UI_SIMPLE_1_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/interface/ui_simple_1_1.wav"
)
const UI_SIMPLE_2_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/interface/ui_simple_2_1.wav"
)
const UI_SIMPLE_3_2 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/interface/ui_simple_3_2.wav"
)
const UI_SIMPLE_5_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/interface/ui_simple_5_1.wav"
)
const UI_SIMPLE_6_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/interface/ui_simple_6_1.wav"
)
const MAGIC_CHIMES_1_7 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/interface/magic_chimes_1_7.wav"
)

## res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/combat/
const GENERIC_HIT_1_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/combat/generic_hit_1_1.wav"
)
const GENERIC_HIT_2_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/combat/generic_hit_2_1.wav"
)
const GENERIC_HIT_3_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/combat/generic_hit_3_1.wav"
)
const GENERIC_HIT_4_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/combat/generic_hit_4_1.wav"
)
const STAB_1_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/combat/stab_1_1.wav"
)
const STAB_2_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/combat/stab_2_1.wav"
)
const WHOOSH_METAL_3_1 = preload(
	"res://assets/audio/indie_friendly_sounds_survival/indie_friendly_rpg_sounds/combat/whoosh_metal_3_1.wav"
)
