import from "../modules"
import lobstergrad

def test_to_value():
    let a = [1., 2., 3.]
    let b = a.lg_to_value
    
    assert(b[0].data == 1.)
    assert(b[1].data == 2.)
    assert(b[2].data == 3.)
    print("to_value test passed")

def test_Value():
    let a = lg_Value{1.}
    let b = lg_Value{2.}
    let c = lg_Value{3.}
    let d = a + b * c
    let neg_relu = (-d).relu()
    let relu = d.relu()
    
    relu.grad = 1.
    relu.backward()
    
    assert(d.data == 7.)
    assert(neg_relu.data == 0.)
    assert(relu.data == 7.)
    assert(a.grad == 1.)
    assert(b.grad == 3.)
    assert(c.grad == 2.)
    assert(d.grad == 1.)
    assert(relu.grad == 1.)
    print("Value test passed")

def test_Neuron():
    let weights = [1., 2., 3.].lg_to_value
    let inputs = [1., 2., 3.].lg_to_value
    let bias = lg_Value{10.}
    let neuron = lg_Neuron{3, weights: weights, bias: bias}
    neuron.init()
    let out = neuron.forward(inputs)
    
    assert(out.data == 24.)
    out.grad = 1.
    out.backward()
    
    assert(weights[0].grad == 1.)
    assert(weights[1].grad == 2.)
    assert(weights[2].grad == 3.)
    assert(bias.grad == 1.)
    assert(out.grad == 1.)

    let params = neuron.params()
    assert(params[0] == weights[0])
    assert(params[1] == weights[1])
    assert(params[2] == weights[2])
    assert(params[3] == bias)
    print("Neuron test passed")

def test_Layer():
    let lin_weights = [[1., 2., 3.], [-1., -2., -3.]].lg_to_value
    let lin_biases = [10., 10.].lg_to_value
    let lin_neurons = [
        lg_Neuron{3, weights: lin_weights[0], bias: lin_biases[0]},
        lg_Neuron{3, weights: lin_weights[1], bias: lin_biases[1]}
    ]
    let inputs = [1., 2., 3.].lg_to_value
    let lin_layer = lg_Linear{3, 2, neurons: lin_neurons}
    
    lin_layer.init()
    let lin_out = lin_layer.forward(inputs)
    lin_layer.backward()
    
    assert(lin_out[0].data == 24.)
    assert(lin_layer.neurons[0].weights[0].grad == 1.)
    assert(lin_layer.neurons[0].weights[1].grad == 2.)
    assert(lin_layer.neurons[0].weights[2].grad == 3.)
    assert(lin_layer.neurons[0].bias.grad == 1.)
    assert(lin_out[0].grad == 1.)
    
    assert(lin_out[1].data == -4.)
    assert(lin_layer.neurons[1].weights[0].grad == 1.)
    assert(lin_layer.neurons[1].weights[1].grad == 2.)
    assert(lin_layer.neurons[1].weights[2].grad == 3.)
    assert(lin_layer.neurons[1].bias.grad == 1.)
    assert(lin_out[1].grad == 1.)

    let params = lin_layer.params()
    assert(params[0] == lin_weights[0][0])
    assert(params[1] == lin_weights[0][1])
    assert(params[2] == lin_weights[0][2])
    assert(params[3] == lin_biases[0])
    assert(params[4] == lin_weights[1][0])
    assert(params[5] == lin_weights[1][1])
    assert(params[6] == lin_weights[1][2])
    assert(params[7] == lin_biases[1])
    print("Linear layer test passed")
    
    let relu_weights = [[1., 2., 3.], [-1., -2., -3.]].lg_to_value
    let relu_biases = [10., 10.].lg_to_value
    let relu_neurons = [
        lg_Neuron{3, weights: relu_weights[0], bias: relu_biases[0]},
        lg_Neuron{3, weights: relu_weights[1], bias: relu_biases[1]}
    ]
    let relu_layer = lg_ReLU{3, 2, neurons: relu_neurons}
    relu_layer.init()
    let relu_out = relu_layer.forward(inputs)
    relu_layer.backward()
    
    assert(relu_out[0].data == 24.)
    assert(relu_layer.neurons[0].weights[0].grad == 1.)
    assert(relu_layer.neurons[0].weights[1].grad == 2.)
    assert(relu_layer.neurons[0].weights[2].grad == 3.)
    assert(relu_layer.neurons[0].bias.grad == 1.)
    assert(relu_out[0].grad == 1.)
    
    assert(relu_out[1].data == 0.)
    assert(relu_out[1].grad == 1.)
    assert(relu_layer.neurons[1].bias.grad == 0.)
    assert(relu_layer.neurons[1].weights[0].grad == 0.)
    assert(relu_layer.neurons[1].weights[1].grad == 0.)
    assert(relu_layer.neurons[1].weights[2].grad == 0.)
    print("ReLU layer test passed")
    
    print("Layer tests passed")

def test_MLP():
    let input = [1., 2., 3.].lg_to_value
    let lin_weights = [[1., 2., 3.], [1., 2., 3.], [1., 2., 3.]].lg_to_value
    let lin_biases = [10., 10., 10.].lg_to_value
    let relu_weights = [[1., 2., 3.], [-1., -2., -3.]].lg_to_value
    let relu_biases = [10., 10.].lg_to_value

    let lin_neurons = [
        lg_Neuron{3, weights: lin_weights[0], bias: lin_biases[0]},
        lg_Neuron{3, weights: lin_weights[1], bias: lin_biases[1]},
        lg_Neuron{3, weights: lin_weights[2], bias: lin_biases[2]}
    ]
    let relu_neurons = [
        lg_Neuron{3, weights: relu_weights[0], bias: relu_biases[0]},
        lg_Neuron{3, weights: relu_weights[1], bias: relu_biases[1]}
    ]

    let lin_layer = lg_Linear{3, 3, neurons: lin_neurons}
    let relu_layer = lg_ReLU{3, 2, neurons: relu_neurons}
    let mlp = lg_MLP{[lin_layer, relu_layer]}
    mlp.init()

    let out = mlp.forward(input)
    let desired_output = [1., 2.].lg_to_value
    let loss = mlp.mse(out, desired_output)
    let lr = 0.01
    loss.grad = 1.
    loss.backward()
    
    assert(out[0].data == 154.)
    assert(out[0].grad == 153.)
    assert(relu_biases[0].grad == 153.)
    assert(relu_weights[0][0].grad == 153.*24.)
    assert(relu_weights[0][1].grad == 153.*24.)
    assert(relu_weights[0][2].grad == 153.*24.)
    
    assert(out[1].data == 0.)
    assert(out[1].grad == -2.)
    assert(relu_biases[1].grad == 0.)
    assert(relu_weights[1][0].grad == 0.)
    print("MLP test passed")

def test_MLP_training():
    let input = [lg_Value{1.}]
    let lin_weights = [lg_Value{1.}]
    let lin_biases = lg_Value{1.}
    let relu_weights = [lg_Value{1.}]
    let relu_biases = lg_Value{1.}

    let lin_neurons = [
        lg_Neuron{1, weights: lin_weights, bias: lin_biases},
    ]
    let relu_neurons = [
        lg_Neuron{1, weights: relu_weights, bias: relu_biases}
    ]

    let lin_layer = lg_Linear{1, 1, neurons: lin_neurons}
    let relu_layer = lg_ReLU{1, 1, neurons: relu_neurons}
    let mlp = lg_MLP{[lin_layer, relu_layer]}
    mlp.init()

    let desired_output = [7.].lg_to_value
    let out = mlp.forward(input)
    let loss = mlp.mse(out, desired_output)
    let lr = 0.03

    for(10000):
        mlp.train(input, desired_output, lr)

    let new_out = mlp.forward(input)
    let new_loss = mlp.mse(new_out, desired_output)
    assert(new_loss.data < loss.data)
    print("MLP Training test passed")

test_to_value()
test_Value()
test_Neuron()
test_Layer()
test_MLP()
test_MLP_training()
