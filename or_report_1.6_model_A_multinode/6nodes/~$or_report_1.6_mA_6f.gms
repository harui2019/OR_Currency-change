Sets
    node "node" /a, b, c, d, e, f/
    iter "loop from 1 to infeasible" /1*1000/
;
alias (node, i, j)
;
Table c_z(i,j) "coeff with z"
$Ondelim
$Include or_report.1.6_cost_mA_6f.csv
$Offdelim
;
Table maxflow(i,j) "maxflow of tube"
$Ondelim
$Include or_report.1.6_maxflow_mA_6f.csv
$Offdelim
;
Table tube_on(i,j) "prevent i to i"
        a   b   c   d   e   f
    a   0   1   1   1   1   1
    b   1   0   1   1   1   1
    c   1   1   0   1   1   1
    d   1   1   1   0   1   1
    e   1   1   1   1   0   1
    f   1   1   1   1   1   0
*using on node_io
;

Parameters
    w_on(node) "1 to a, -1 to e" /a 1, b 0, c 0, d 0, e -1/,
    
    w_max "max I/O" /800/,
    w_miter "max I/O iter to " /1/,
    
    cost_m1 "from 1 to infeasible",
    isfeasible_m1 "record feasible state",
    remain_m1 "as title",
    remainrate_m1 "as title",

    cost(iter) "from 1 to infeasible",
    isfeasible(iter) "record feasible state",
    remain(iter) "as title",
    remainrate(iter) "as title"
    
;

Variable
    x(i,j) "tube",
    w "I/O",
    z "sum to solve"
;
Positive Variable x
;
Free Variables z
;
Equations
    cost_z "total fee of exchange",
    node_io(i) "I/O of each tube",
    tube_max(i,j) "maxflow of each tube",
    
    w_set "range of w",
    w_set_iter "range of w";
    
    cost_z ..
        z =e= 0.001*sum((i,j), c_z(i,j)*x(i,j));
    node_io(i) ..
        sum(j, tube_on(i,j)*x(i,j)) - sum(j, tube_on(j,i)*x(j,i)) =e= w_on(i)*w;
    tube_max(i,j) ..
        x(i,j) =l= maxflow(i,j);
        
    w_set ..
        w =e= w_max;
    w_set_iter ..
        w =e= w_miter;
        
Model
    demo_1 "once" /cost_z, node_io, tube_max, w_set/
    demo_2 "loop" /cost_z, node_io, tube_max, w_set_iter/
*    demo_3 "loop include dismulti opt"
;


$title once_ver
Solve demo_1 using LP min z;

display w_max;

cost_m1 = demo_1.ObjVal;
isfeasible_m1 = demo_1.ModelStat;
remain_m1 = w_max;
remainrate_m1 = div(remain_m1, (remain_m1 + cost_m1))

display cost_m1, isfeasible_m1, remain_m1, remainrate_m1;

$ontext
$title loop_ver
loop (iter,
    display w_miter, 'total currency';
    Solve demo_2 using LP min z;
    
    cost(iter) = demo_2.ObjVal;
    isfeasible(iter) = demo_2.ModelStat;
    remain(iter) = w_miter;
    remainrate(iter) = div(remain(iter), (remain(iter) + cost(iter)));
    
    remain(iter)$(remain(iter) = NA) = 0;

    display demo_2.ObjVal, demo_2.ModelStat;
    w_miter = w_miter + 1;
)

display cost;
display isfeasible;
display remain;
display remainrate;

execute_unload 'or_report.1.6_mA_6f.gdx', cost, isfeasible, remain, remainrate;
$offtext

*$ontext
*gdx2csv
$call gdxdump or_report.1.6_mA_6f.gdx symb=cost CSVSetText format=csv header = "cost(iter)">> or_report.1.6_mA_6f_out_cost.csv
$call gdxdump or_report.1.6_mA_6f.gdx symb=isfeasible CSVSetText format=csv header = "isfeasible(iter)">> or_report.1.6_mA_6f_out_isfeasible.csv
$call gdxdump or_report.1.6_mA_6f.gdx symb=remain CSVSetText format=csv header ="remain(iter)">> or_report.1.6_mA_6f_out_remain.csv
$call gdxdump or_report.1.6_mA_6f.gdx symb=remainrate CSVSetText format=csv header = "remainrate(iter)">> or_report.1.6_mA_6f_out_remainrate.csv
*$offtext