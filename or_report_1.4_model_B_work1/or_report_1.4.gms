Sets
    node "node" /a, b, c, d, e/
;
alias (node, i, j)
;
Table c_z(i,j) "coeff with z"
$Ondelim
$Include or_report_1.4_c(with_z).csv
$Offdelim
;
Table maxflow(i,j) "maxflow of tube"
$Ondelim
$Include or_report_1.4_maxflow.csv
$Offdelim
;
Table tube_on(i,j) "prevent i to i"
        a   b   c   d   e
    a   0   1   1   1   1
    b   1   0   1   1   1
    c   1   1   0   1   1
    d   1   1   1   0   1
    e   1   1   1   1   0
*using on node_io
;
Parameters
    w_on(node) "1 to a, -1 to e" /a 1, b 0, c 0, d 0, e -1/,
    w_max "max I/O" /500/
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
    w_set "range of w";
    
    cost_z ..
        z =e= 0.001*sum((i,j), c_z(i,j)*x(i,j));
    node_io(i) ..
        sum(j, tube_on(i,j)*x(i,j)) - sum(j, tube_on(j,i)*x(j,i)) =e= w_on(i)*w;
    tube_max(i,j) ..
        x(i,j) =l= maxflow(i,j);
    w_set ..
        w =e= w_max;
        
Model
    demo_1 "all" /all/
;
Solve demo_1 using LP min z;
   