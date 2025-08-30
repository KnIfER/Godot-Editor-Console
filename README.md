
# Console Input

<img width="295" height="231" alt="image" src="https://github.com/user-attachments/assets/fdf2f91d-69a4-4a31-90cf-d6b45bb10b53" />

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


- functions supported
- auto convert 4 space to tab (naive approach)

- Internally, [`eval()`](https://www.reddit.com/r/godot/comments/vo40ya/how_can_i_run_strings_as_code_during_runtime/) is called : 
```
func eval(e:EdiorInterface,x:EditorPlugin):
  your code
```
- `= some value` on the last line, and that value will be return by eval(), subsequently printed to OUTPUT window.


# Debug Print Screen

stolen from [Godot_debug_draw: Debug drawing utility for Godot Engine](https://github.com/Zylann/godot_debug_draw)

how to use : project settings -> autoreload tab -> add name=`DDD`, path=`res://addons/console_input/debug_draw.gd`  

then : 

```
DDD.set_text(....)
```

- single file
- remove ttf , use system font
- add @tool to allow run in editor mode ——

<img width="345" height="253" alt="image" src="https://github.com/user-attachments/assets/1d16141a-7c96-4d64-b1d7-79b89ba19381" />

