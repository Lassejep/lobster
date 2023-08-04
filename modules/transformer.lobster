import lobstergrad 
namespace tf

class transformer:
    net = lg_MLP{[
        lg_Linear{15, 100},
        lg_tanh{100, 10},
        lg_Softmax{10, 10}
    ]}

    def init():
        net.init()
