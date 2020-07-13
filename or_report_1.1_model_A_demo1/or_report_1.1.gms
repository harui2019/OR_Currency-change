$title or_report_1.1

$offListing

Sets i "nodes" /1*5/
     k "index of num of currency" /1*10/
     
;
scalars zz ;
        

Alias (i,j);
    
Table m(i,j) "max change quantities of currency"
        1   2   3   4   5  
    1   0 100 100 100 100
    2 100   0 100 100 100
    3 100 100   0 100 100
    4 100 100 100   0 100
    5 100 100 100 100   0
;

Table c(i,j) 
          1      2      3      4     5
    1     1  1.041  1.034  1.028 1.046
    2 1.020      1  1.018  1.041 1.064
    3 1.027  1.036      1  1.063 1.071
    4 1.050  1.060  1.052      1 1.067
    5 1.061  1.058  1.057  1.082     1
;

Table c_on(i,j)
        1   2   3   4   5  
    1   0   1   1   1   1
    2   1   0   1   1   1
    3   1   1   0   1   1
    4   1   1   1   0   1
    5   1   1   1   1   0
;

parameter cc(i,j);

cc(i,j)$(c_on(i,j) eqv 1) = 0;
cc(i,j)$(c_on(i,j) xor 0) = div(1, c(i,j));

* Bold font(column) to i, 

Parameters  d(i) "maxload of node a, e" /1 100, 5 -100, 2*4 0/
           w1(i)                        /1 1, 2*5 0/
           f5(i)                        /5 -1, 1*4 0/
               w                        /100/,
              ww "kth state of model"   /1/,
           ff(k) "kth sol of model"  ;

Variables x(i,j)  "tube from i to j"
          z       "total"
          f       "maxflow";
     
Positive variable x;
    
Free variable z, f;

Equations
    cost_z "cost of change of currency",
    mode_io_1(i) "demand of I/O",
    mode_io_2(i) "",
    mode_io_2_fullfunc(i) "",
    tube_io(i,j) "max flow of tube";
    
    cost_z .. z =e= sum((i, j), x(i,j));    
    mode_io_1(i) .. sum(j, x(i,j)) - sum(j, x(j, i)) =e= d(i);    
    mode_io_2(i) .. sum(j, x(i,j)) - sum(j, div(c_on(j,i), c(j,i))*x(j, i)) =e= f5(i)*f + w1(i)*w;
    
    mode_io_2_fullfunc(i) ..
        sum(j,x(i,j))-sum(j, div(c_on(j,i), c(j,i))*x(j,i)) =e= f5(i)*f + w1(i)*ww;
    
    tube_io(i,j) .. x(i,j) =l= m(i,j);

$onListing

Model
    model_1_test /cost_z, mode_io_1, tube_io/,
    model_2_test /mode_io_2, tube_io/,
    model_2_demo_1 /mode_io_2_fullfunc, tube_io/;

Solve model_1_test using LP min z;
Solve model_2_test using LP max f;

zz = model_1_test.ObjVal;
*(model_name)..ObjVal for output of objective
$onText
    2. set by gams after each solve execution
       DomUsd, ETAlg, ETSolve, ETSolver, Handle, IterUsd, Line, LinkUsed
       Marginals, ModelStat, NodUsd, Number, NumDepnd, NumDVar, NumEqu
       NumInfes, NumNLIns, NumNLNZ, NumNOpt, NumNZ, NumRedef, NumVar
       NumVarProj, ObjEst, ObjVal, ProcUsed, ResCalc, ResDeriv, ResGen
       ResIn, ResOut, ResUsd, RObj, SolveStat, SumInfes, MaxInfes
       MeanInfes, SysIdent, SysVer
$offText

*zz = cc('1','1');
$double
display zz;

loop (k,
     display k;
     Solve model_2_demo_1 using LP max f;
     ww = ww + 1;
     ff(k) = model_2_demo_1.ObjVal;
     
     
);

display ff