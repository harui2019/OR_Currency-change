$title or_report_1.2
$offListing
Sets
    i "nodes" /1*5/
    k "index of num of currency" /650/
;

Alias (i,j);

Table m(i,j) "max change quantities of currency"
        1   2   3   4   5  
    1   0 140 170 136 234
    2 124   0 100 187 172
    3 142 180   0 100  86
    4 173 126  60   0  95
    5  50  60  30  80   0
;

Table c_down(i,j) 
          1      2      3      4     5
    1     1  1.041  1.034  1.028 1.046
    2 1.020      1  1.018  1.041 1.064
    3 1.027  1.036      1  1.063 1.071
    4 1.050  1.060  1.052      1 1.067
    5 1.061  1.058  1.057  1.082     1
;

Table c_up(i,j)
        1   2   3   4   5  
    1   0   1   1   1   1
    2   1   0   1   1   1
    3   1   1   0   1   1
    4   1   1   1   0   1
    5   1   1   1   1   0
;

Parameters
    c(i,j) ,
    d(i) "maxload of node a, e" /1 100, 5 -100, 2*4 0/,
    w1(i) "" /1 1, 2*5 0/,
    f5(i) "" /5 -1, 1*4 0/,
    w "" /602/,
    w_k "kth state of model" /1/,
    f_k(k) "kth sol of model" ,
    rate_1(k) "remain rate after currency change" ;
    
    c(i,j)$(c_up(i,j) eqv 1) = 0;
    c(i,j)$(c_up(i,j) xor 0) = div(1, c_down(i,j));

Variables
    x(i,j) "tube from i to j",
    z "total cost",
    f "maxflow";
     
Positive variable x;
    
Free variable z, f;

Equations
    cost_z "cost of change of currency",
    mode_io_1(i) "demand of I/O",
    mode_io_2(i) "",
    mode_io_2_fullfunc(i) "",
    tube_io(i,j) "max flow of tube";
    
    cost_z ..
        z =e= sum((i,j), x(i,j));    
    mode_io_1(i) ..
        sum(j, x(i,j)) - sum(j, x(j,i)) =e= d(i);    
    mode_io_2(i) ..
        sum(j, x(i,j)) - sum(j, c(j,i)*x(j, i)) =e= f5(i)*f + w1(i)*w;
    
    mode_io_2_fullfunc(i) ..
        sum(j,x(i,j)) - sum(j, c(j,i)*x(j,i)) =e= f5(i)*f + w1(i)*w_k;
    
    tube_io(i,j) .. x(i,j) =l= m(i,j);

$onListing

Model
    model_1_test /cost_z, mode_io_1, tube_io/,
    
    model_2_test /mode_io_2, tube_io/,
    model_2_demo_1 /mode_io_2_fullfunc, tube_io/;

*Solve model_1_test using LP min z;
*Solve model_2_test using LP max f;

$onText
loop (k,
    display k;
    Solve model_2_demo_1 using MIP max f;
    f_k(k) = model_2_demo_1.ObjVal;
    rate_1(k) = div(f_k(k), w_k);

    w_k = w_k + 1;
);
$offtext

Solve model_2_test using MIP max f;
f_k(k) = model_2_test.ObjVal;
rate_1(k) = div(f_k(k), w);

$double
display f_k

$double
display rate_1

*SolveStat <> 1 to stop