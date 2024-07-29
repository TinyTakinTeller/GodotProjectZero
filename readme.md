# Godot Project Zero: A Dark Forest

If you wish to contribute, join us in Trello and Discord (add `tiny_takin_teller` for invites).

PLAY THE GAME : https://tinytakinteller.itch.io/the-best-game-ever

READ WEEKLY DEVLOG'S : https://tinytakinteller.itch.io/the-best-game-ever/devlog

Current Version - [ PROTOTYPE : WEEK 14 ]

*Gather Resources...*

![image](https://github.com/TinyTakinTeller/GodotProjectZero/assets/155020210/09a90a5c-b271-4623-ae7b-e0c439c6546a)

*Generate Passive Resources...*

![image](https://github.com/TinyTakinTeller/GodotProjectZero/assets/155020210/e9805710-b03b-4b6f-ade8-f7c85461d46c)

*Fight Ancient Colossals...*

![image](https://github.com/TinyTakinTeller/GodotProjectZero/assets/155020210/9b62ac2a-db9b-470e-9178-d85e1c033ca4)

*And More...*


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
