import std
import vec
import color
import gl
import utils

fatal(gl_window("Ant Simulator", 640, 480, gl_window_init_no_vsync))

let world_size = 40.
var running = true
var fullscreen = false
var quitting = false
var spawn_mode = false

let default_color = color_white
let default_font = "lobster/data/fonts/US101/US101.ttf"
check(gl_set_font_name(default_font), "failed to load font {default_font}")

class MenuBox:
    pos:xy_f
    size:xy_f
    menu_color:color
    margin:xy_f
    buttons:int = 0

    def render():
        buttons = 0
        gl_translate pos:
            gl_scale size:
                gl_color menu_color:
                    gl_polygon([xy_0, xy_x, xy_1, xy_y])

    def render_button(messages, body, text_color = default_color,
        font_name = default_font, font_size = 32, font_outline = 2.,
        button_color = default_color):
        gl_translate pos + margin:
            gl_scale(min(size - margin * 2.))
            gl_translate(xy{0., 1. + margin.y / 2.} * buttons)
            gl_color button_color:
                gl_polygon([xy_0, xy_x, xy_1, xy_y])
            check_mouse_click():
                body()
            gl_set_font_name(font_name)
            gl_set_font_size(font_size, font_outline)
            gl_color(text_color)
            if messages is string:
                gl_translate(xy_h)
                gl_scale(0.32 / float(font_size))
                gl_translate(float(gl_text_size(messages)) / -2.)
                gl_text(messages)
            elif messages is [string]:
                gl_translate(xy {0.5, 0.})
                gl_scale(0.32 / float(font_size))
                for(messages) msg, i:
                    gl_translate xy {gl_text_size(msg).x / -2.,
                        gl_text_size(msg).y * i}:
                        gl_text(msg)
        buttons++

class Ant:
    pos:xy_f
    dir:xy_f
    speed:int

    def render():
        gl_translate pos:
            gl_rotate_z dir:
                gl_polygon([xy{-.5, .5}, xy_x, xy{-.5, -.5}])
    
let ants = []::Ant


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
    gl_set_font_name(default_font)
    gl_set_font_size(32, 2.)
    set_print_decimals(3)

    let mouse_pos = gl_local_mouse_pos(0)
    let y_edge = world_size / 2.
    let x_edge = world_size * aspect / 2.
    let menu = MenuBox{xy{-x_edge, -y_edge}, xy{5., world_size},
    color_grey, xy_h}

    for(ants) ant:
        ant.render()

    if running and gl_visible():
        for(ants) ant:
            if mouse_pos == ant.pos:
                ant.dir = -xy_y
            else:
                ant.dir = normalize(mouse_pos - ant.pos)
            ant.pos += ant.dir * ant.speed * gl_delta_time()

    else:
        let msg = "paused"
        gl_set_font_size(32, 2.)
        gl_scale .05:
            gl_translate float(gl_text_size(msg)) / -2.:
                gl_color default_color:
                    gl_text(msg)
        
        gl_translate xy {-x_edge + menu.size.x + 1., -y_edge}:
            gl_scale .05:
                gl_text("Mouse - x{mouse_pos.x}, y{mouse_pos.y}")
        
        if spawn_mode:
            let ant = Ant{mouse_pos, -xy_y, 5}
            ant.render()
            if gl_button("mouse1") == 1:
                ants.push(ant)
                spawn_mode = false
                running = true
    
    menu.render()
    menu.render_button(["Add", "white", "Ant"]):
        running = false
        spawn_mode = true
        gl_frame()
    menu.render_button("Pause"):
        running = not running
    menu.render_button("Quit"):
        quitting = true

    set_print_decimals(1)
    let msg = "FPS: {1. / gl_delta_time()}"
    set_print_decimals(3)
    gl_scale .05:
        gl_translate xy{x_edge * 20. - float(gl_text_size(msg).x),
            -y_edge * 20.}:
                gl_color default_color:
                    gl_text(msg)