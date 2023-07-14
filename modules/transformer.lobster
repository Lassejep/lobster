import lobstergrad 
namespace tf

let net = lg_MLP{[
    lg_Linear{15, 100},
    lg_Linear{100, 10},
    lg_Softmax{10, 10}
]}

net.init()
