import std
import from "../modules"
import transformer

def load_data(file_name) -> string:
    let file = read_file(file_name)
    var data = ""

    // change data type from string? to string
    if file:
        data = file

    data = data.replace_string("\n", ".")
    data = "..." + data + "..."
    return data

def get_name(data_set) -> string:
    if data_set.length <= 0:
        return ""
    else:
        var name = ""
        var i = 0
        while i < data_set.length:
            let c = unicode_to_string([data_set[i]])
            if c == ".":
                break
            name += c
            i++
        data_set = data_set.substring(i+1, -1)
        if name == "":
            name = get_name()
        return name

def count_letters(data_set) -> int:
    let counts = []
    for(27):
        counts.push(0)

    for(data_set.length) i:
        let letter = data_set[i] - 96
        if letter < 0:
            counts[0] += 1
        else:
            counts[letter] += 1

def create_data_sets(data) -> string, string, string:
    var data = data.eleme
    let slices = []
    let length = data.length
    slices.push(int(length * 0.8))
    slices.push(int(length * 0.9))
    let training_data = data.substring(0, slices[0])
    let validation_data = data.substring(slices[0], slices[0] - slices[1])
    let test_data = data.substring(slices[1], -1)
    return training_data, validation_data, test_data

let data = load_data("../src/names.txt")
let training_data, validation_data, test_data = create_data_sets(data)

