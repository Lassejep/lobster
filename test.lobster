import lobstergrad

let input = [1., 2., 3., 4., 5., 6., 7., 8., 9., 10.].lg_to_value
let desired_output = [5., 13.].lg_to_value
let lr = 0.000003

let nn = lg_NeuralNet{[lg_Linear{10, 20}, lg_Linear{20, 2}]}
nn.init()

lg_print(nn.predict(input))

for(1000):
    nn.train(input, desired_output, lr)

lg_print(nn.params)
lg_print(nn.predict(input))
lg_print(desired_output)