# 1. execute any script.gd

1. execute extracted methods from `userscripts/*snippets.gd`
2. execute any gdscript file by evaluating res://path::method_name

When calling `method_name`, the following will be passed in:

`editor:EditorInterface`  `plugin:EditorPlugin`  `data:={}`

Therefore, the method in the script must have 0 to 3 parameters, and they must be defined in the correct order.

# 2 eval

Enter simple code in the edit box. When press the Run button, this plugin concatenates the text and executes the method. 

It is called `eval`.  Three parameters are passed in to `eval` :

```
func eval(e:EdiorInterface,x:EditorPlugin, d:{}):
  your code
```
To prevent confusion, these three parameters are saved as field : `_et_`, `_ex_`, `_dat_`：
```
var _et_:EdiorInterface
var _ex_:EditorPlugin
var _dat_ := {}
func eval(e,x,d):
	_et_ = e
	_ex_ = x
	_dat_ = d
```


## Update Apr 9  2026
- add ability run script methods from `eval`:  
```gdscript
res://path/to/script.gd::method_name
```

- add ability to be invoked by 3rd party addons: 

```gdscript
var ret = FU.run("=1+1")
```

Actually I'm using this in ( modified version of ) [GDTerminal](https://github.com/ProgrammerOnCoffee/GDTerminal), which turns it into a sub-module of my plugin!

<img width="438" height="232" alt="image" src="https://github.com/user-attachments/assets/135699dd-9d2f-46d4-97d7-f21296676d01" />

<img width="441" height="375" alt="image" src="https://github.com/user-attachments/assets/89bf44c9-2d94-4553-880c-ca8fa65e7a4a" />



### Update Apr 7  2026
  
https://forum.godotengine.org/t/editor-console-plugin/136751  
  
1. add customizable dynamic menu by parsing  `res://addons/console_input/userscripts/*snippets.gd`
1. add some useful tools in the popupmenu: 

<img width="452" height="312" alt="image (2)" src="https://github.com/user-attachments/assets/866775c1-e45a-432c-ab5e-8abe5d410892" />

1. Scroll scene tree to top or bottom
1. Scroll inspector panel to top or bottom
1. Toggle node disabled or enabled
1. Batch move selected nodes gui ( a xyz dialog )
1. You can open snippet source file, and enjoy **full syntax highligh and code completion!**



### Update 2025年9月7日
  
1. include FPS monitor
1. learning from Debug Menu, make DDD auto reload by itself
1. new configurable short-cut F12 to run code in clipboard
2. new method `sn()` to get selected node 
1. "edit" button will open a temp script



### Todo
- [ ] a pie menu to run tool scripts (will steal from terrabrush :)  (Planned for 1000 years later.)



# Console Input


<img width="1306" height="290" alt="image" src="https://github.com/user-attachments/assets/e399ddb8-9324-4efc-a58d-caa242ed6377" />

<img width="316" height="282" alt="image" src="https://github.com/user-attachments/assets/ed2ca663-9eaa-4202-afad-3cfb7d20e2fb" />

Examples : 
```
=1+1
```

```
func test_math(a,b):
    return a+b
=test_math(1,1)
```

disable certain node : 
```
gn("%node_name_unique").process_mode = 4
```

- `gn(n:String)`:  get node in current scene
- `gr()`:  get root node of current scene


- simple functions supported
- auto convert 4 space to tab (naive approach)

- Internally, [`eval()`](https://www.reddit.com/r/godot/comments/vo40ya/how_can_i_run_strings_as_code_during_runtime/) is called : 
```
func eval(e:EdiorInterface,x:EditorPlugin,d:={}):
  your code
```
- `= some value` on the last line, and that value will be return by eval(), subsequently printed to OUTPUT window.


# Debug Print Screen

stolen from [Godot_debug_draw: Debug drawing utility for Godot Engine](https://github.com/Zylann/godot_debug_draw)

how to use : no configuration required. it's genuine AUTO RELOAD SCRIPT now :

then : 

```
DDD.set_text(....)
```

- remove ttf , use system font
- add @tool to allow run in editor mode ——

<img width="345" height="253" alt="image" src="https://github.com/user-attachments/assets/1d16141a-7c96-4d64-b1d7-79b89ba19381" />

- new method DDD.vvv to place an Arrow



# FPS monitor


stolen from [Godot-debug-menu: Display in-game FPS/performance/hardware metrics in a Godot 4.x project](https://github.com/godot-extended-libraries/godot-debug-menu)  

how to use :   

```
FPS.style = 1
```


