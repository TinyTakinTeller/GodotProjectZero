# Godot Project Zero: A Dark Forest

Inspired by A Dark Room, the Dark Forest is an incremental experimental minimalistic idle game project.

Started as my first game project to learn Godot, now a community project with 10+ contributors!

THE GAME:
- PLAY ON Steam: https://store.steampowered.com/app/3314970/A_Dark_Forest/
- PLAY ON Itch: https://tinytakinteller.itch.io/the-best-game-ever

CONTRIBUTE:
- A) **Enhancements** by checking out "Issues" section on Github
- B) **Content, Mechanics, Design** by joining Discord (add `tiny_takin_teller` for invites)
- C) **???** by forking the project *(code is MIT licensed, **assets are licensed by respective contributors**)*

**Milestones**
- 29/04/2024 [`prototype.week.01`] **First version shared on Itch** 👀
- 24/06/2024 [`prototype.week.09`] **Created Discord & Trello for the community** ❤️
- 26/08/2024 [`prototype.week.18`] **Project featured on front page of Itch "New & Popular"** 🚀
- 09/09/2024 [`prototype.week.20`] **Discontinuing weekly updates going forward.** ⚰️
- 07/10/2024 [`prototype.release.1.0`] **Added final boss fight, a short minigame ending.** ⭐
- 05/01/2025 [`prototype.release.1.1`] **Localization Update for French and Chinese (SC).** 🌎
- 08/01/2025 [`prototype.release.1.2`] **Localization Update for Portuguese (Brazilian).** 🌎
- 11/01/2025 [`prototype.release.1.3`] **Soulstone Patch: Added 15th Charm to fix endgame grind.** ⚡
- 11/02/2025 [`prototype.release.1.4`] **🎨The Art Update & 🔮The Future & 🌍Polish Localization**
- 06/06/2025 [`prototype.release.1.4.4`] **Steam Demo Release & Next Fest 2025**



## Overview

*Gather Resources...*

![](https://github.com/TinyTakinTeller/GodotProjectZero/blob/master/.github/docs/sc14_1.png)

*Generate Passive Resources...*

![](https://github.com/TinyTakinTeller/GodotProjectZero/blob/master/.github/docs/sc14_2.png)

*Fight Ancient Colossals...*

![](https://github.com/TinyTakinTeller/GodotProjectZero/blob/master/.github/docs/sc14_3.png)

*And More...*

![](https://github.com/TinyTakinTeller/GodotProjectZero/blob/master/.github/docs/sc14_4.png)



## Development setup

### Setup the GDScript Toolkit
This project uses the [Format on Save](https://github.com/ryan-haskell/gdformat-on-save) and [gdLinter](https://github.com/el-falso/gdlinter) plugins.
Both of these depend on the [GDScript Toolkit](https://github.com/Scony/godot-gdscript-toolkit) python package being installed.
You can install this dependency globally or in a virtual environment.

#### To install globally
This is the standard way described in the documentation of the package
```
pip3 install "gdtoolkit==4.*"
```

#### To install in a virtual environment
If you're on Windows, this project has some custom code in the "Format on Save" and "gdLinter" plugins to make it work with a `venv/` directory in the root of the project.
```
cd <path/to/this/project>
python -m venv venv
.\venv\Scripts\activate

pip3 install "gdtoolkit==4.*"
```
Remarks 
1. The `venv/` directory is in the `.gitignore`, so won't be committed to git
2. Because of the custom code, the `venv` integration will break when we update the plugins
