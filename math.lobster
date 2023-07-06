namespace math

struct Constants:
    pi = 3.1415926535897932384626433832795
    e = 2.7182818284590452353602874713527

let constants = Constants{}

def exp(x: float) -> float:
    return pow(constants.e, x)

def tanh(x: float) -> float:
    return (exp(x) - exp(-x)) / (exp(x) + exp(-x))

def relu(x: float) -> float:
    return max(0., x)
