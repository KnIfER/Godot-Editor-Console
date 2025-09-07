
- Update log 2025年9月7日
  
1. include FPS monitor
1. learning from Debug Menu, make DDD auto reload by itself
1. new configurable short-cut F12 to run code in clipboard
1. "edit" button will open a temp script



- Todo
- [ ] a pie menu to run tool scripts (will steal from terrabrush :)



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
func eval(e:EdiorInterface,x:EditorPlugin):
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

- new method DDD.vvv top place an Arrow



# FPS monitor


stolen from [Godot-debug-menu: Display in-game FPS/performance/hardware metrics in a Godot 4.x project](https://github.com/godot-extended-libraries/godot-debug-menu)  

how to use :   

```
FPS.style = 1
```


