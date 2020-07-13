$title or_report_1.3

$offlisting
Sets
    i "nodes" /i1*i5, iover/
    k "index of num of currency" /1*1000/
    l "demulti opt sol test" /1*10/
;

Alias (i,j);

Table m(i,j) "max change quantities of currency"
$Ondelim
$Include or_report_1.3_m_ij.csv
$Offdelim
;

Table c_down(i,j)
$Ondelim
$Include or_report_1.3_c_down_ij.csv
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

Table c_up(i,j)
$Ondelim
$Include or_report_1.3_c_up_ij.csv
$Offdelim
;
$ontext
        i1  i2  i3  i4  i5 iover 
    i1   0   1   1   1   1     0
    i2   1   0   1   1   1     0
    i3   1   1   0   1   1     0
    i4   1   1   1   0   1     0
    i5   1   1   1   1   0     0
 iover   1   1   1   1   1     0
$offtext

Parameters
    c(i,j) ,
    d(i) "maxload of node a, e" /iover 0,i1 100, i5 -100, i2*i4 0/,
    w1(i) "" /i1 1, i2*i5 0, iover 0/,
    f5(i) "" /i5 -1, i1*i4 0, iover 0/,
    
    w "once" /300/,
    w_k "loop, kth state of model" /1/,
    
    f_k(k) "kth sol of model" ,
    f_l(l) "the kth of loop l times",
    rate_1(k) "remain rate after currency change",
    rate_2(l) "remain rate after currency change",
    state_k(k) "isfeasible",
    
    f_diff "",
    last_f "last try of opt maxflow" /0/;
    
    c(i,j)$(c_up(i,j) eqv 0) = 0;
    c(i,j)$(c_up(i,j) eqv 1) = div(1, c_down(i,j));

Variables
    x(i,j) "tube from i to j",
    z "total cost",
    f "maxflow",
    f_bar "total";
     
Positive variable x;
    
Free variable z, f;

Equations
    cost_z "cost of change of currency",
    mode_io_1(i) "demand of I/O",
    mode_io_2(i) "",
    mode_io_2_fullfunc(i) "",
    
    tube_io(i,j) "max flow of tube",
    total_f "max flow & the trash can",
    demulti "prevent multi opt sol";
    
    cost_z ..
        z =e= sum((i,j), x(i,j));
        
    mode_io_1(i) ..
        sum(j, x(i,j)) - sum(j, x(j,i)) =e= d(i);
        
    mode_io_2(i) ..
        sum(j,c_up(i,j)*x(i,j)) - sum(j,c(j,i)*x(j,i)) =e= f5(i)*f + w1(i)*w;
    
    mode_io_2_fullfunc(i) ..
        sum(j,c_up(i,j)*x(i,j)) - sum(j,c(j,i)*x(j,i)) =e= f5(i)*f + w1(i)*w_k;
        
    tube_io(i,j) ..
        x(i,j) =l= m(i,j);
    
    total_f ..
        f + 0.00001*sum(i, x(i, 'iover')) =e= f_bar;
        
    demulti ..
        (last_f - f)*(last_f - f) =g= 0.000001


Model
    model_1_test  ""
        /cost_z, mode_io_1, tube_io/,
    
    model_2_test "once_ver"
        /mode_io_2, tube_io/,
    model_3_test "overflowing things check"
        /mode_io_2, tube_io, total_f/ ,
    
    model_2_demo_1 "loop_index 1 to 500"
        /mode_io_2_fullfunc, tube_io/,
    
    model_2_demo_2 "loop_100 times"
        /mode_io_2, tube_io, demulti/;

*Solve model_1_test using LP min z;
*Solve model_2_test using LP max f;

$title loop_index 1 to 500

loop (k,
    display k;
    display w_k , 'total currency';
    Solve model_2_demo_1 using MIP max f;
    f_k(k) = model_2_demo_1.ObjVal;
    rate_1(k) = div(f_k(k), w_k);
    state_k(k) = model_2_demo_1.ModelStat;
    w_k = w_k + 1;
);


$title overflowing things check
$onText
Solve model_3_test using MIP max f_bar;
f_k(k) = model_2_test.ObjVal;
rate_1(k) = div(f_k(k), w);
$offText

$double
*display f_bar.l;

*f_diff = (f_bar.l - f.l)*1000000;
$double
*display f_diff;


$title loop_100 times
*$onText
loop (l,
    display l ,'th';
    display w , 'total currency';
    Solve model_2_demo_2 using NLP max f;
    f_l(l) = model_2_demo_2.ObjVal;
    rate_2(l) = div(f_l(l), w);

    last_f = f_l(l);
);
*$offText
$onlisting

* general display
$double
display 'loop_index 1 to 500', 'overflowing things check'
display f_k
display w_k
display rate_1

$double
display 'loop_500 times'
display f_l
display w
display rate_2

*SolveStat <> 1 to stop

execute_unload 'or_report_1.3.gdx', f_k, w_k, rate_1, state_k, f_l, w, rate_2;

*gdx2csv
$gdxin 'or_report_1.3.gdx'
*$call gdxdump or_report.1.3.gdx output=or_report.1.3_output.csv format=csv
$call gdxdump or_report_1.3.gdx symb=f_k CSVSetText format=csv header = "f_k(k)">> or_report.1.3_output.f_k.csv
$call gdxdump or_report_1.3.gdx symb=rate_1 CSVSetText format=csv header = "rate_1(k)">> or_report.1.3_output.rate_1.csv
$call gdxdump or_report_1.3.gdx symb=f_l CSVSetText format=csv header = "f_l(l)">> or_report.1.3_output.f_l.csv
$call gdxdump or_report_1.3.gdx symb=rate_2 CSVSetText format=csv header = "rate_2(l)">> or_report.1.3_output.rate_2.csv