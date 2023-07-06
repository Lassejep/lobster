import gl
import std
import vec
import color
import jtensor

def trace(root):
    let nodes, edges = [], []
    def build(v) -> void:
        let comp= []
        for(nodes) node:
            if node == v:
                comp.push(1)
            else:
                comp.push(0)
        if not any(comp):
            nodes.push(v)
            for(v.children) child:
                edges.push([v.label, child.label])
                build(child)
    build(root)
    return nodes, edges

def tree_length(root) -> int:
    var max_children = 0
    for(root.children) child:
        let count = tree_length(child)
        if count > max_children:
            max_children = count
    return max_children + 1

def tree_width(root) -> int:
    var number_of_children = 0
    let childrens_children = []
    for(root.children) child:
        number_of_children = child.children.length
        childrens_children.push(number_of_children)
        childrens_children.push(tree_width(child))
    return max(childrens_children)

def draw_tree(root):
    fatal(gl_window("tree", 800, 600))
    let nodes, edges = trace(root)
    var fullscreen = false
    
    // TODO: make this draw a line between two boxes
    // perhaps make the boxes a class to help with this.
    def draw_line(a, b):
        gl_color(color_black):
            gl_line(a, b, 3.)

    // TODO: make the box the same size as the text ish.
    def draw_box(margin_thickness, outline_thickness,
        value):
        let outer_size = xy_1 - (margin_thickness * 2.)
        let inner_size = xy_1 - (outline_thickness * 2.)
        gl_translate(margin_thickness):
            gl_scale(outer_size)
            gl_color(color_black)
            gl_rounded_rectangle(xy_1, 60, 0.2)
            gl_translate(outline_thickness)
            gl_scale(inner_size)
            gl_color(color_white)
            gl_rounded_rectangle(xy_1, 60, 0.2)
            gl_translate(xy_h)
            gl_set_font_name("lobster/data/fonts/US101/US101.ttf")
            gl_set_font_size(32)
            gl_color(color_black)
            set_print_decimals(2)
            let msg = "{value.label} | data {value.data} | grad {value.grad}"
            gl_scale(xy_1.x / float(gl_text_size(msg).x)):
                gl_translate(float(gl_text_size(msg)) / -2.):
                    gl_text(msg)


    while gl_frame() and gl_button("escape") != 1:

        if gl_button("f") == 1:
            if fullscreen:
                gl_window_min_max(0)
            else:
                gl_window_min_max(1)
            fullscreen = not fullscreen
            

        let world_size = xy{tree_length(root), tree_width(root)}
        let scale = float(gl_window_size() / world_size)
        gl_clear(color_white)
        gl_scale(scale)
        let margin = xy{0.1, 0.1}
        let outline = xy{0.05, 0.05}

        // TODO: make this draw the correct boxes and line between them.
        for(world_size.x):
            for(world_size.y):
                gl_translate(float(xy{i, j})):
                    draw_box(margin, outline, root)

    for(nodes) node, i:
        print("node{i}: {node.label}")
    for(edges) edge, i:
        print("edge{i}: {edge}")

draw_tree(o)