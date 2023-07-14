import gl
import color

def event_func() -> void
let event_type: event_func = fn: nil 

class Button:
    pos:float2
    size:float2
    event:event_func
    text:[string] = ["Click", "Me!"]
    button_color:color = color_white
    text_color:color = color_white
    font_name:string = "../lobster/data/fonts/US101/US101.ttf"
    font_size:int = 32
    font_outline:float = 2.

    def trigger(e:event_func) -> void:
        call_function_value(event)

    def render() -> void:
        gl_translate pos:
            gl_scale(size)
            gl_color(button_color)
            gl_polygon([float2_0, float2_x, float2_1, float2_y])
            if gl_button("mouse1") == 1 and
                gl_local_mouse_pos(0).x > 0. and
                gl_local_mouse_pos(0).x < 1. and
                gl_local_mouse_pos(0).y > 0. and
                gl_local_mouse_pos(0).y < 1.:
                    trigger(event)

            gl_set_font_name(font_name)
            gl_set_font_size(font_size, font_outline)
            gl_color(text_color)
            if text.length == 1:
                gl_translate(float2_h)
                gl_scale(0.32 / float(font_size))
                gl_translate(float(gl_text_size(text[0])) / -2.)
                gl_text(text[0])
            elif text.length > 1:
                gl_translate(float2{0.5, 0.})
                gl_scale(0.32 / float(font_size))
                for(text) line, i:
                    gl_translate float2{gl_text_size(line).x / -2.,
                        gl_text_size(line).y * i
                    }:
                        gl_text(line)
            else:
                pass()


class MenuBox:
    pos:float2
    size:float2
    menu_color:color
    button_margin:float2
    buttons: [Button] = []

    def render() -> void:
        gl_translate pos:
            gl_scale(size)
            gl_color(menu_color)
            gl_polygon([float2_0, float2_x, float2_1, float2_y])

    def render_buttons() -> void:
        gl_translate pos + button_margin:
            gl_scale(min(size - button_margin * 2.))
            for(buttons) button:
                button.render()
                gl_translate(float2_y)
                gl_translate(button_margin * 0.5 * float2_y)

    def add_button(button:Button) -> void:
        buttons.push(button)
