extends MarginContainer

const TAB_DATA_ID: String = "settings"

const WATERMARK_URL: String = "https://tinytakinteller.itch.io/the-best-game-ever"

@export var shake_shader_component_scene: PackedScene

@onready var settings_margin_container: MarginContainer = %SettingsMarginContainer
@onready var credits_margin_container: MarginContainer = %CreditsMarginContainer
@onready var license_margin_container: MarginContainer = %LicenseMarginContainer

@onready var credits_h_box_container: HBoxContainer = %CreditsHBoxContainer
@onready var license_h_box_container: HBoxContainer = %LicenseHBoxContainer

@onready var shortcuts_label: Label = %ShortcutsLabel

@onready var master_settings_slider: SettingsSlider = %MasterSettingsSlider
@onready var music_settings_slider: SettingsSlider = %MusicSettingsSlider
@onready var sfx_settings_slider: SettingsSlider = %SFXSettingsSlider
@onready var shake_settings_slider: SettingsSlider = %ShakeSettingsSlider
@onready var typing_settings_slider: SettingsSlider = %TypingSettingsSlider
@onready var display_mode_button: Button = %DisplayModeButton
@onready var display_resolution_button: Button = %DisplayResolutionButton
@onready var display_language_button: Button = %DisplayLanguageButton
@onready var watermark_button: Button = %WatermarkButton

@onready var audio_title_label: Label = %AudioTitleLabel
@onready var effects_title_label: Label = %EffectsTitleLabel
@onready var display_title_label: Label = %DisplayTitleLabel
@onready var watermark_label: Label = %WatermarkLabel

@onready var tabs_h_box_container: HBoxContainer = %TabsHBoxContainer
@onready var settings_tab_button: Button = %SettingsTabButton
@onready var credits_tab_button: Button = %CreditsTabButton
@onready var license_tab_button: Button = %LicenseTabButton

@onready var rich_text_label_1: RichTextLabel = %RichTextLabel1
@onready var rich_text_label_2: RichTextLabel = %RichTextLabel2
@onready var rich_text_label_3: RichTextLabel = %RichTextLabel3

###############
## overrides ##
###############


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("master_music_toggle"):
		pass  # TODO toggle master music setting and update UI


func _ready() -> void:
	_initialize()
	_connect_signals()
	_load_from_save_file()

	_on_tab_clicked_event(0)


#############
## helpers ##
#############


func _initialize() -> void:
	_apply_effects()
	_set_ui_labels()


func _reload() -> void:
	_set_ui_labels()
	_load_from_save_file()


func _set_ui_labels() -> void:
	settings_tab_button.text = Locale.get_ui_label("settings")
	credits_tab_button.text = Locale.get_ui_label("credits")
	license_tab_button.text = Locale.get_ui_label("license")

	shortcuts_label.text = Locale.get_ui_label("shortcuts_label")

	master_settings_slider.get_title_label().text = Locale.get_ui_label("master")
	music_settings_slider.get_title_label().text = Locale.get_ui_label("music")
	sfx_settings_slider.get_title_label().text = Locale.get_ui_label("sfx")

	shake_settings_slider.get_title_label().text = Locale.get_ui_label("shake")
	typing_settings_slider.get_title_label().text = Locale.get_ui_label("typing")

	display_mode_button.text = "?"
	display_resolution_button.text = "?"
	## TODO: replace resolution setting with a different one
	display_resolution_button.disabled = true

	display_language_button.text = Locale.LOCALE_NAME[SaveFile.locale]

	audio_title_label.text = Locale.get_ui_label("audio_title")
	effects_title_label.text = Locale.get_ui_label("effects_title")
	display_title_label.text = Locale.get_ui_label("display_title")
	watermark_label.text = "%s : %s" % [Locale.get_ui_label("watermark_title"), WATERMARK_URL]

	watermark_label.visible = OS.has_feature("web")
	shortcuts_label.visible = false

	rich_text_label_1.text = _get_credits_1()
	rich_text_label_2.text = _get_credits_2()
	rich_text_label_3.text = _get_license_1()

	if not OS.has_feature("web"):
		%TitleMarginContainerAudio.add_theme_constant_override("margin_top", 20)


func _apply_effects() -> void:
	var shake_shader_component: ShakeShaderComponent = (
		shake_shader_component_scene.instantiate() as ShakeShaderComponent
	)
	shake_settings_slider.get_title_label().add_child(shake_shader_component)

	typing_settings_slider.get_title_label().set_end_delay(0.5)
	typing_settings_slider.get_title_label().play_typing_animation(false)


func _load_from_save_file() -> void:
	master_settings_slider.set_data(
		SaveFile.audio_settings["master"]["toggle"], SaveFile.audio_settings["master"]["value"]
	)
	music_settings_slider.set_data(
		SaveFile.audio_settings["music"]["toggle"], SaveFile.audio_settings["music"]["value"]
	)
	sfx_settings_slider.set_data(
		SaveFile.audio_settings["sfx"]["toggle"], SaveFile.audio_settings["sfx"]["value"]
	)

	shake_settings_slider.set_data(
		SaveFile.effect_settings["shake"]["toggle"], SaveFile.effect_settings["shake"]["value"]
	)
	typing_settings_slider.set_data(
		SaveFile.effect_settings["typing"]["toggle"], SaveFile.effect_settings["typing"]["value"]
	)

	display_mode_button.text = Locale.get_ui_label(SaveFile.settings["display_mode"])
	var width: int = SaveFile.settings["display_resolution"][0]
	var height: int = SaveFile.settings["display_resolution"][1]
	display_resolution_button.text = "{a} x {b}".format({"a": width, "b": height})


#############
## signals ##
#############


func _connect_signals() -> void:
	SignalBus.audio_settings_updated.connect(_on_audio_settings_updated)

	SignalBus.tab_changed.connect(_on_tab_changed)

	master_settings_slider.data_changed.connect(_on_audio_data_changed.bind("master"))
	music_settings_slider.data_changed.connect(_on_audio_data_changed.bind("music"))
	sfx_settings_slider.data_changed.connect(_on_audio_data_changed.bind("sfx"))

	shake_settings_slider.data_changed.connect(_on_effect_data_changed.bind("shake"))
	typing_settings_slider.data_changed.connect(_on_effect_data_changed.bind("typing"))

	display_mode_button.button_up.connect(_on_display_mode_button_up)
	display_resolution_button.button_up.connect(_on_display_resolution_button_up)
	display_language_button.button_up.connect(_on_display_language_button_up)

	SignalBus.display_mode_settings_updated.connect(_on_display_mode_settings_updated)
	SignalBus.display_resolution_settings_updated.connect(_on_display_resolution_settings_updated)

	watermark_button.mouse_entered.connect(_on_watermark_mouse_entered)
	watermark_button.button_down.connect(_on_watermark_button_down)

	SignalBus.display_language_updated.connect(_on_display_language_updated)

	var tabs: Array = tabs_h_box_container.get_children()
	for index: int in tabs.size():
		var tab: Button = tabs[index]
		tab.button_up.connect(_on_tab_clicked_event.bind(index))

	var credits_texts: Array = credits_h_box_container.get_children()
	for text: RichTextLabel in credits_texts:
		text.meta_clicked.connect(_on_url_meta_clicked)
		text.meta_hover_started.connect(_on_credits_meta_hover)

	var license_texts: Array = license_h_box_container.get_children()
	for text: RichTextLabel in license_texts:
		text.meta_clicked.connect(_on_url_meta_clicked)
		text.meta_hover_started.connect(_on_license_meta_hover)


# react to "master_music_toggle" shortcut keybind (M)
func _on_audio_settings_updated(toggle: bool, value: float, id: String) -> void:
	if id == "master":
		if master_settings_slider.get_toggle() != toggle:
			master_settings_slider.set_data(toggle, value)


func _on_tab_changed(tab_data: TabData) -> void:
	if tab_data.id == TAB_DATA_ID:
		visible = true
	else:
		visible = false


func _on_audio_data_changed(toggle: bool, value: float, id: String) -> void:
	SignalBus.audio_settings_update.emit(toggle, value, id)


func _on_effect_data_changed(toggle: bool, value: float, id: String) -> void:
	SignalBus.effect_settings_update.emit(toggle, value, id)


func _on_display_mode_button_up() -> void:
	SignalBus.display_mode_settings_toggle.emit()
	display_mode_button.release_focus()


func _on_display_resolution_button_up() -> void:
	SignalBus.display_resolution_settings_toggle.emit()
	display_resolution_button.release_focus()


func _on_display_language_button_up() -> void:
	display_language_button.release_focus()
	Scene.change_language()


func _on_display_mode_settings_updated(display_mode: String) -> void:
	display_mode_button.text = Locale.get_ui_label(display_mode)


func _on_display_resolution_settings_updated(width: int, height: int) -> void:
	## TODO: replace resolution setting with a different one
	display_resolution_button.text = "{a} x {b}".format({"a": width, "b": height})


func _on_watermark_mouse_entered() -> void:
	SignalBus.info_hover.emit(
		Locale.get_ui_label("watermark_title"), Locale.get_ui_label("watermark_info")
	)


func _on_watermark_button_down() -> void:
	OS.shell_open("https://tinytakinteller.itch.io/the-best-game-ever")


func _on_display_language_updated() -> void:
	_reload()


func _on_tab_clicked_event(tab_index: int) -> void:
	var tabs: Array = tabs_h_box_container.get_children()
	for index: int in tabs.size():
		var tab: Button = tabs[index]
		if index == tab_index:
			tab.disabled = true
		else:
			tab.disabled = false

	Audio.play_sfx_id("generic_click")

	if tab_index == 0:
		_handle_settings_tab()
	elif tab_index == 1:
		_handle_credits_tab()
	elif tab_index == 2:
		_handle_license_tab()


func _handle_settings_tab() -> void:
	settings_margin_container.visible = true
	credits_margin_container.visible = false
	license_margin_container.visible = false


func _handle_credits_tab() -> void:
	settings_margin_container.visible = false
	credits_margin_container.visible = true
	license_margin_container.visible = false


func _handle_license_tab() -> void:
	settings_margin_container.visible = false
	credits_margin_container.visible = false
	license_margin_container.visible = true


func _on_url_meta_clicked(meta: String) -> void:
	if meta.begins_with("https://"):
		var err: Error = OS.shell_open(meta)
		if err != Error.OK:
			push_warning("Failed to open URL %s due to error code %s" % [meta, str(err)])


func _on_credits_meta_hover(meta: String) -> void:
	if meta.begins_with("NA:"):
		SignalBus.info_hover.emit(credits_tab_button.text, meta.split("NA:")[1])
	if meta.begins_with("https://"):
		SignalBus.info_hover.emit(credits_tab_button.text, meta)


func _on_license_meta_hover(meta: String) -> void:
	if meta.begins_with("NA:"):
		SignalBus.info_hover.emit(license_tab_button.text, meta.split("NA:")[1])
	if meta.begins_with("https://"):
		SignalBus.info_hover.emit(license_tab_button.text, meta)


# gdlint:disable = max-line-length


static func _get_credits_1() -> String:
	var template: String = """[color=#e0e064][b]{Programming}[/b][/color]
[url=https://github.com/TinyTakinTeller]TinyTakinTeller[/url] - {Lead}
[url=https://github.com/alexmunoz502]Alex Munoz[/url] - {Help}
[url=https://github.com/mielifica]Mellifica[/url] - {Help}
[url=https://github.com/debris]Marek Kotewicz[/url] - {Bugfix}
[url=https://github.com/mhvejs]Mhvejs[/url] - {Bugfix}

[color=#e0e064][b]{Art}[/b][/color]
[url=https://instagram.com/navy.raccoon]Navy_Raccoon[/url] - {Lead}

[color=#e0e064][b]{Writing & Narrative}[/b][/color]
[url=https://abyssalnovelist.carrd.co/]Abyssal Novelist[/url] - {Lead}
[url=https://github.com/Reed-lzy]Reed[/url] - {Help}
[url=https://github.com/TinyTakinTeller]TinyTakinTeller[/url] - {Review}"""
	return _localize_credits(template)


static func _get_credits_2() -> String:
	var template: String = """[color=#e0e064][b]{Music}[/b][/color]
[url=https://www.youtube.com/@JoeBurkeZerk]Joe Burke[/url] - 4 {Tracks}
[url=https://circlesinthesky.com/]Skyler Newsome[/url] - 4 {Tracks}

[color=#e0e064][b]{Localization}[/b][/color]
[url=https://abyssalnovelist.carrd.co/]Abyssal Novelist[/url] - {Polish}
[url=NA:Maria Oliveira]Maria Oliveira[/url] - {Portuguese}
[url=https://www.linkedin.com/in/marion-veber-838279342/]Marion Veber[/url] - {French}
[url=https://www.linkedin.com/in/xiaofei-shen/]Xiaofei Shen[/url] & [url=https://www.middlebury.edu/institute/]Gloria[/url] - {Chinese}


[color=#e0e064][b]{Publishing & Management}[/b][/color]
[url=https://abyssalnovelist.carrd.co/]Abyssal Novelist[/url] - {Steam}
[url=https://github.com/TinyTakinTeller]TinyTakinTeller[/url] - {Itch}"""
	return _localize_credits(template)


static func _get_license_1() -> String:
	var template: String = """[color=#0064e0][b]{Credits}[/b][/color]
[color=#ffffff]{Programming}[/color] : [url=https://github.com/TinyTakinTeller/GodotProjectZero]Github[/url], [url=https://godotengine.org/license/]Godot Engine[/url] - [color=#e00064][url=https://opensource.org/license/mit]MIT[/url][/color]
[color=#ffffff]{Art}, {Music}, {Writing}, {Localization}[/color] - [color=#e00064][url=https://creativecommons.org/licenses/by-nc-sa/4.0/]CC-BY-NC-SA 4.0[/url][/color]

[color=#0064e0][b]{External}[/b][/color]
{Music} : [url=https://freemusicarchive.org/music/universfield/dark-music/corpse-rot/]Corpse Rot[/url], [url=https://freemusicarchive.org/music/universfield/dark-music/criminal-district/]Criminal District[/url] - [color=#e00064][url=https://creativecommons.org/licenses/by-sa/4.0/]CC-BY-SA 4.0[/url][/color]
{Music} : [url=https://pixabay.com/music/video-games-to-the-death-159171/]To The Death[/url] - [color=#e00064][url=https://pixabay.com/service/license-summary/]Pixabay License[/url][/color]
{SFX} : Sound Packs (by PlaceHolderAssets) - [color=#e00064][url=https://en.wikipedia.org/wiki/Licence_to_use]LTU[/url][/color]
{SFX} : [url=https://freesound.org/s/331656/]Keyboard Typing[/url], [url=https://freesound.org/s/249583/]Fart[/url], [url=https://freesound.org/s/332820/]Heartbeat[/url] - [color=#e00064][url=https://creativecommons.org/public-domain/cc0/]CC0[/url][/color]
{Theme} : Minimalistic UI Theme (by @AzagayaVj) - [color=#e00064][url=https://creativecommons.org/licenses/by/4.0/]CC-BY 4.0[/url][/color]
{Shader} : [url=https://godotshaders.com/shader/chromatic-aberration-vignette/]Vignette[/url], [url=https://godotshaders.com/shader/wiggle-2d/]Wiggle[/url], [url=https://godotshaders.com/shader/chromatic-abberation/]Aberration[/url], [url=https://godotshaders.com/shader/2d-radial-distortion-fisheye-barrel/]Fisheye[/url] - [color=#e00064][url=https://creativecommons.org/publicdomain/zero/1.0/]CC0[/url][/color]
{Shader} : [url=https://godotshaders.com/shader/starry-sky/]Starry Sky[/url] - [color=#e00064][url=https://opensource.org/license/mit/]MIT[/url][/color]
{Shader} : [url=https://gamedev.stackexchange.com/a/207351]Pixel Explosion Shader[/url] - [color=#e00064][url=https://creativecommons.org/licenses/by-sa/4.0/]CC-BY-SA 4.0[/url][/color]
{Shader} : [url=https://godotshaders.com/shader/cracked-glass/]Cracked Glass[/url] - [color=#e00064][url=https://creativecommons.org/licenses/by-nc-sa/3.0/]CC-BY-NC-SA 3.0[/url][/color] """
	return _localize_license(template)


static func _localize_credits(template: String) -> String:
	return (
		template
		. replace("{Lead}", Locale.get_credit_label("lead"))
		. replace("{Help}", Locale.get_credit_label("help"))
		. replace("{Bugfix}", Locale.get_credit_label("bugfix"))
		. replace("{Tracks}", Locale.get_credit_label("tracks"))
		. replace("{Polish}", Locale.get_credit_label("polish"))
		. replace("{Portuguese}", Locale.get_credit_label("portuguese"))
		. replace("{French}", Locale.get_credit_label("french"))
		. replace("{Chinese}", Locale.get_credit_label("chinese"))
		. replace("{Review}", Locale.get_credit_label("review"))
		. replace("{Steam}", Locale.get_credit_label("steam"))
		. replace("{Itch}", Locale.get_credit_label("itch"))
		. replace("{Programming}", Locale.get_role_label("programming"))
		. replace("{Art}", Locale.get_role_label("art"))
		. replace("{Music}", Locale.get_role_label("music"))
		. replace("{Localization}", Locale.get_role_label("localization"))
		. replace("{Writing & Narrative}", Locale.get_role_label("writing_narrative"))
		. replace("{Publishing & Management}", Locale.get_role_label("publishing_management"))
	)


static func _localize_license(template: String) -> String:
	return (
		template
		. replace("{Credits}", Locale.get_ui_label("credits"))
		. replace("{External}", Locale.get_credit_label("external"))
		. replace("{SFX}", Locale.get_ui_label("sfx"))
		. replace("{Theme}", Locale.get_credit_label("theme"))
		. replace("{Shader}", Locale.get_credit_label("shader"))
		. replace("{Programming}", Locale.get_role_label("programming"))
		. replace("{Art}", Locale.get_role_label("art"))
		. replace("{Music}", Locale.get_role_label("music"))
		. replace("{Localization}", Locale.get_role_label("localization"))
		. replace("{Writing}", Locale.get_credit_label("writing"))
	)
