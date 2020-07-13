Sets
    node "node" /a, b, c, d, e, f/
    iter "loop from 1 to infeasible" /1*1000/
;
alias (node, i, j)
;

$ontext
Table maxflow(i,j) "maxflow of tube"
$Ondelim
$Include or_report.1.5_maxflow_mB_6f.csv
$Offdelim
;

Table c_down(i,j)
$Ondelim
$Include or_report.1.5_maxflow_mB_6f.csv
$Offdelim
;
$ontext
          i1     i2     i3     i4    i5 iover
    i1     1  1.041  1.034  1.028 1.046     1
    i2 1.020      1  1.018  1.041 1.064     1
    i3 1.027  1.036      1  1.063 1.071     1
    i4 1.050  1.060  1.052      1 1.067     1
    i5 1.061  1.058  1.057  1.082     1     1
 iover     1      1      1      1     1     1
$offtext
parameter
    maxflow "" /100/,
    c_down "" /1.05/;

;
Table c_on(i,j) "prevent i to i"
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
    w_on(node) "" /a 1, b 0, c 0, d 0, e 0, f 0/,
    f_on(node) "" /a 0, b 0, c 0, d 0, e -1, f 0/,
    c(i,j) "" ,
    
    w_max "max I/O" /400/,
    w_miter "max I/O iter to " /1/
    
    cost_m1 "from 1 to infeasible",
    isfeasible_m1 "record feasible state",
    remain_m1 "as title",
    remainrate_m1 "as title",

    cost(iter) "from 1 to infeasible",
    isfeasible(iter) "record feasible state",
    remain(iter) "as title",
    remainrate(iter) "as title"
;
    
    c(i,j)$(c_on(i,j) eqv 0) = 0;
    c(i,j)$(c_on(i,j) eqv 1) = div(1, c_down);
;
Variable
    x(i,j) "tube",
    f "sum to solve"
;
Positive Variable x
;
Free Variable f
;
Equations
    node_io(i) "I/O of each tube",
    node_io_iter(i) "I/O of each tube",
    tube_max(i,j) "maxflow of each tube";
    
    node_io(i) ..
        sum(j,c_on(i,j)*x(i,j)) - sum(j,c(j,i)*x(j,i)) =e= f_on(i)*f + w_on(i)*w_max;
    
    node_io_iter(i) ..
        sum(j,c_on(i,j)*x(i,j)) - sum(j,c(j,i)*x(j,i)) =e= f_on(i)*f + w_on(i)*w_miter;

    tube_max(i,j) ..
        x(i,j) =l= maxflow;
        
Model
    demo_1 "once" /node_io, tube_max/
    demo_2 "loop" /node_io_iter, tube_max/
;

$title once_ver
Solve demo_1 using LP max f;

display w_max;

isfeasible_m1 = demo_1.ModelStat;
remain_m1 = demo_1.ObjVal;
cost_m1 = w_max - remain_m1;
remainrate_m1 = div(remain_m1, w_max)

display cost_m1, isfeasible_m1, remain_m1, remainrate_m1;

$ontext
$title loop_ver
loop (iter,
    display w_miter, 'total currency';
    Solve demo_2 using LP max f;
    
    isfeasible(iter) = demo_2.ModelStat;
    remain(iter) = demo_2.ObjVal;
    cost(iter) = w_miter - remain(iter);
    remainrate(iter) = div(remain(iter), w_miter);
    
    remain(iter)$(remain(iter) = NA) = 0;

    display demo_2.ObjVal, demo_2.ModelStat;
    w_miter = w_miter + 1;
)

display cost;
display isfeasible;
display remain;
display remainrate;

$title output to gdx
execute_unload 'or_report.1.5_mB_6f.gdx', cost, isfeasible, remain, remainrate;
$offtext

*$ontext
*gdx2csv
$call gdxdump or_report.1.5_mB_6f.gdx symb=cost CSVSetText format=csv header = "cost(iter)">> or_report.1.5_mB_6f_out_cost.csv
$call gdxdump or_report.1.5_mB_6f.gdx symb=isfeasible CSVSetText format=csv header = "isfeasible(iter)">> or_report.1.5_mB_6f_out_isfeasible.csv
$call gdxdump or_report.1.5_mB_6f.gdx symb=remain CSVSetText format=csv header ="remain(iter)">> or_report.1.5_mB_6f_out_remain.csv
$call gdxdump or_report.1.5_mB_6f.gdx symb=remainrate CSVSetText format=csv header = "remainrate(iter)">> or_report.1.5_mB_6f_out_remainrate.csv
*$offtext