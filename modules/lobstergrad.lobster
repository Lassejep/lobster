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
            children[0].grad += (children[1].data *
                (children[0].data.pow(children[1].data - 1.)) * grad)
            children[1].grad += (pow(children[0].data, children[1].data) *
                log(children[0].data) * grad)
        elif op == "tanh":
            children[0].grad += grad * (1. - data * data)
        elif op == "relu":
            children[0].grad += grad * (if data > 0.: 1. else: 0.)
        else:
            return
        for(children) child:
            child.backward()

    def operator+(other:Value) -> Value:
        return Value{data + other.data, children: [this, other], op: "+"}
    def operator+(other:float) -> Value:
        return this + Value{other}
    def operator*(other:Value) -> Value:
        return Value{data * other.data, children: [this, other], op: "*"}
    def operator*(other:float) -> Value:
        return this * Value{other}
    def pow(self:Value, other:Value) -> Value:
        return Value{pow(self.data, other.data),
            children: [self, other], op: "pow"}
    def pow(self:Value, other:float) -> Value:
        return this.pow(self, Value{other})
    def operator-() -> Value:
        return this * -1.
    def operator-(other:Value) -> Value:
        return this + (-other)
    def operator-(other:float) -> Value:
        return this + (-other)
    def operator/(other:Value) -> Value:
        return this * other.pow(other, -1.)
    def exp() -> Value:
        return this.pow(Value{math_Constants{}.e}, this)
    def tanh() -> Value:
        return Value{math_tanh(data), children: [this], op: "tanh"}
    def relu() -> Value:
        return Value{math_relu(data), children: [this], op: "relu"}
    
    def repr() -> string:
        if label.length:
            return "{label}: {data}"
        else:
            return "{data}"

    def zero_grad() -> void:
        grad = 0.
        for(children) child:
            child.zero_grad()


class Neuron:
    number_of_inputs:int
    weights:[Value] = []
    bias:Value = Value{0.}
    
    def init() -> void:
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
    
    def params() -> [Value]:
        let params:[Value] = []
        params.append_into(weights)
        params.push(bias)
        return params


class Layer:
    number_of_inputs:int
    number_of_outputs:int
    neurons:[Neuron] = []
    outputs:[Value] = []
    
    def init() -> void:
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
        
    def params() -> [Value]:
        let params:[Value] = []
        for(neurons) neuron:
            params.append_into(neuron.params())
        return params

    def forward(inputs:[Value]) -> [Value]:
        return inputs


class Linear: Layer
    def forward(inputs:[Value]) -> [Value]:
        outputs = []
        for(neurons) neuron:
            outputs.push(neuron.forward(inputs))
        return outputs


class ReLU: Layer
    def forward(inputs:[Value]) -> [Value]:
        outputs = []
        for(neurons) neuron:
            outputs.push(neuron.forward(inputs).relu())
        return outputs


class Softmax: Layer
    def forward(inputs:[Value]) -> [Value]:
        outputs = []
        for(neurons) neuron:
            outputs.push(neuron.forward(inputs).exp())
        var sum = Value{0.}
        for(outputs) output:
            sum = sum + output
        for(outputs) output:
            output = output / sum
        return outputs


class tanh: Layer
    def forward(inputs:[Value]) -> [Value]:
        outputs = []
        for(neurons) neuron:
            outputs.push(neuron.forward(inputs).tanh())
        return outputs


class MLP:
    layers:[Layer]

    def init() -> void:
        for(layers) layer:
            layer.init()
  
    def forward(inputs:[Value]) -> [Value]:
        var outputs = inputs
        for(layers) layer:
            outputs = layer.forward(outputs)
        return outputs

    def mse(outs:[Value], targets:[Value]) -> Value:
        var loss = Value{0.}
        for(zip(outs, targets)) union:
            let out = union[0]
            let target = union[1]
            let diff = out - target
            loss = loss + diff.pow(diff, 2.)
        loss = loss / Value{outs.length}
        return loss

    def backward(outputs) -> void:
        for(outputs) output:
            output.grad = 1.
            output.backward()
    
    def params() -> [Value]:
        let params:[Value] = []
        for(layers) layer:
            params.append_into(layer.params())
        return params

    def train(inputs:[Value], targets:[Value], lr:float = 0.003) -> Value:
        let outputs = forward(inputs)
        let loss = mse(outputs, targets)
        loss.zero_grad()
        loss.grad = 1.
        loss.backward()
        let params = this.params()
        for(params) param:
            param.data -= (param.grad * lr)


def to_value(x:float) -> Value:
    return Value{x}

def to_value(x:[float]) -> [Value]:
    let output:[Value] = []
    for(x) element:
        output.push(to_value(element))
    return output

def to_value(x:[[float]]) -> [[Value]]:
    let output:[[Value]] = []
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

def print(x:Value) -> string:
    print(x.repr)
