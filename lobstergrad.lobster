import std
import math
namespace lg


class Value:
    data:float
    children:[Value] = []
    op:string = ""
    label:string = ""
    grad:float = 0.
    
    def backward() -> void:
        if op == "+":
            children[0].grad += grad
            children[1].grad += grad
        elif op == "+=":
            children[0].grad += grad
        elif op == "*":
            children[0].grad += grad * children[1].data
            children[1].grad += grad * children[0].data
        elif op == "pow":
            children[0].grad += children[1].data * (children[0].data.pow(children[1].data - 1.)) * grad
            children[1].grad += pow(children[0].data, children[1].data) * log(children[0].data) * grad
        elif op == "tanh":
            children[0].grad += grad * (1. - data * data)
        elif op == "relu":
            children[0].grad += grad * (if data > 0.: 1. else: 0.)
        else:
            return
        for(children) child:
            child.backward()

    def operator+(other:Value):
        return Value{data + other.data, children: [this, other], op: "+"}
    def operator+(other:float):
        return this + Value{other}
    def operator*(other:Value):
        return Value{data * other.data, children: [this, other], op: "*"}
    def operator*(other:float):
        return this * Value{other}
    def pow(self:Value, other:Value):
        return Value{pow(self.data, other.data),
            children: [self, other], op: "pow"}
    def pow(self:Value, other:float):
        return this.pow(self, Value{other})
    def operator-():
        return this * -1.
    def operator-(other:Value):
        return this + (-other)
    def operator-(other:float):
        return this + (-other)
    def operator/(other:Value):
        return this * other.pow(other, -1.)
    def exp():
        return this.pow(Value{math_Constants{}.e}, this)
    def tanh():
        return Value{math_tanh(data), children: [this], op: "tanh"}
    def relu():
        return Value{math_relu(data), children: [this], op: "relu"}
    
    def repr() -> string:
        if label.length:
            return "{label}: {data}"
        else:
            return "{data}"


class Neuron:
    number_of_inputs:int
    weights:[Value] = []
    bias:Value = Value{0.}
    
    def init():
        if not weights.length:
            for(number_of_inputs):
                weights.push(Value{rnd_float()})
    
    def forward(inputs:[Value]) -> Value:
        var output:Value = bias
        for(zip(weights, inputs)) combined:
            output = output + (combined[0] * combined[1])
        return output
    
    def repr() -> string:
        var weights_str = ""
        for(weights) weight, i:
            weights_str += weight.repr()
            if i < weights.length - 1:
                weights_str += ", "
        return "weights: [{weights_str}], bias: {bias.repr()}"
    
    def params():
        let params:[Value] = []
        for(weights) weight:
            params.push(weight)
        params.push(bias)
        return params


class Layer:
    number_of_inputs:int
    number_of_outputs:int
    neurons:[Neuron] = []
    outputs:[Value] = []
    
    def init():
        if not neurons.length:
            for(number_of_outputs):
                neurons.push(Neuron{number_of_inputs})
            for(neurons) neuron:
                neuron.init()
    
    def repr() -> string:
        var neurons_str = ""
        for(neurons) neuron, i:
            neurons_str += neuron.repr()
            if i < neurons.length - 1:
                neurons_str += "\n "
        return "[{neurons_str}]"
    
    def backward() -> void:
        for(outputs) output:
            output.grad = 1.
            output.backward()
        
    def params():
        let params:[Value] = []
        for(neurons) neuron:
            for(neuron.params()) param:
                params.push(param)
        return params


class Linear: Layer
    def forward(inputs:[Value]):
        outputs = []
        for(neurons) neuron:
            outputs.push(neuron.forward(inputs))
        return outputs


class ReLU: Layer
    def forward(inputs:[Value]):
        let output:[Value] = []
        for(neurons) neuron:
            output.push(neuron.forward(inputs).relu())
        return output


class NeuralNet:
    layers:[Layer]
    outputs:[Value] = []
    loss:Value = Value{0.}

    def init():
        for(layers) layer:
            layer.init()
    
    def predict(inputs:[Value]):
        outputs = []
        for(layers) layer:
            inputs = layer.forward(inputs)
        outputs = inputs
        return outputs
    
    def get_loss(targets:[Value]) -> Value:
        if not outputs.length:
            print("run predict() first")
            return
        loss = Value{0.}
        for(zip(outputs, targets)) union:
            let output = union[0]
            let target = union[1]
            loss = loss + (output - target).pow(2.)
        loss = loss * (1. / outputs.length)
        return loss

    def backward() -> void:
        if not outputs.length:
            print("run predict() first")
            return
        else:
            for(outputs) output:
                output.grad = 1.
                output.backward()
    
    def train(inputs:[Value], targets:[Value], lr:float = 0.003):
        outputs = predict(inputs)
        for(zip(outputs, targets)) union:
            let output = union[0]
            let target = union[1]
            output.grad = 2. * (output.data - target.data)
            output.backward()
        for(layers) layer:
            for(layer.params()) param:
                param.data -= lr * param.grad
        outputs = []
    
    def params():
        let params:[Value] = []
        for(layers) layer:
            for(layer.params()) param:
                params.push(param)
        return params

def to_value(x:float) -> Value:
    return Value{x}

def to_value(x:[float]):
    let output:[Value] = []
    for(x) element:
        output.push(to_value(element))
    return output

def print(x:[Value]) -> string:
    var output = "["
    for(x) element, i:
        output += element.repr
        if i < x.length - 1:
            output += ", "
    output += "]"
    print(output)