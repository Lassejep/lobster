import std
import vec
import color
import gl
import utils
import gui
import ants


fatal(gl_window("Ant Simulator", 640, 480, gl_window_init_no_vsync))
let world_size = 40.

var running = true
var fullscreen = false
var quitting = false
var spawn_mode = false

let default_color = color_white
let default_font = "../lobster/data/fonts/US101/US101.ttf"
check(gl_set_font_name(default_font), "failed to load font {default_font}")

let spawn_event:event_func = fn: 
    running = false
    spawn_mode = true
    gl_frame()
let pause_event:event_func = fn:
    running = not running
let quit_event:event_func = fn:
    quitting = true

let ants = []::Ant


print("Ant Simulator running")
while gl_frame() and gl_button("escape") != 1 and quitting == false:
    if gl_button("space") == 1:
        running = not running
    if gl_button("f") == 1:
        if fullscreen:
            gl_window_min_max(0)
        else:
            gl_window_min_max(1)
        fullscreen = not fullscreen

    let center = float(gl_window_size()) / 2.
    let scale = gl_window_size().y / world_size
    let aspect = float(gl_window_size().x) / float(gl_window_size().y)
    gl_clear(color_black)
    gl_translate(center)
    gl_scale(scale)

    let mouse_pos = gl_local_mouse_pos(0)
    let y_edge = world_size / 2.
    let x_edge = world_size * aspect / 2.

    let main_menu = MenuBox{pos: float2{-x_edge, -y_edge},
        size: float2{5., world_size},
        menu_color: color_grey,
        button_margin: float2{.5, .5}
    }
    let spawn_ant_button = Button{pos: float2_0,
        size: float2{1., 1.},
        event: spawn_event,
        text: ["Spawn", "new", "Ant"]
    }
    let pause_button = Button{pos: float2_0,
        size: float2{1., 1.},
        event: pause_event,
        text: ["Pause"]
    }
    let quit_button = Button{pos: float2_0,
        size: float2{1., 1.},
        event: quit_event,
        text: ["Quit"]
    }

    main_menu.add_button(spawn_ant_button)
    main_menu.add_button(pause_button)
    main_menu.add_button(quit_button)

    for(ants) ant:
        ant.render()

    if running and gl_visible():
        for(ants) ant:
            ant.update(mouse_pos)

    else:
        let msg = "paused"
        gl_set_font_size(32, 2.)
        gl_scale .05:
            gl_translate float(gl_text_size(msg)) / -2.:
                gl_color default_color:
                    gl_text(msg)
        
        gl_translate float2 {-x_edge + main_menu.size.x + 1., -y_edge}:
            gl_scale .05:
                gl_text("Mouse - x{mouse_pos.x}, y{mouse_pos.y}")
        
        if spawn_mode:
            let ant = Ant{mouse_pos, -float2_y, 5}
            ant.render()
            if gl_button("mouse1") == 1:
                ants.push(ant)
                spawn_mode = false
                running = true
    
    main_menu.render()
    main_menu.render_buttons()

    set_print_decimals(1)
    let msg = "FPS: {1. / gl_delta_time()}"
    set_print_decimals(3)
    gl_scale .05:
        gl_translate float2{x_edge * 20. - float(gl_text_size(msg).x),
            -y_edge * 20.}:
                gl_color default_color:
                    gl_text(msg)

print("Ant Simulator stopped")
