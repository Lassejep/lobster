def check_mouse_click(body):
    if gl_button("mouse1") == 1 and
        gl_local_mouse_pos(0).x > 0. and
        gl_local_mouse_pos(0).x < 1. and
        gl_local_mouse_pos(0).y > 0. and
        gl_local_mouse_pos(0).y < 1.:
            body()