import gl

class Ant:
    pos:float2
    dir:float2
    speed:int

    def render() -> void:
        gl_translate pos:
            gl_rotate_z dir:
                gl_polygon([float2{-.5, .5}, float2_x, float2{-.5, -.5}])

    def update(mouse_pos:float2) -> void:
        if mouse_pos == pos:
            dir = -float2_y
        else:
            dir = normalize(mouse_pos - pos)
        pos += dir * speed * gl_delta_time()
