$TITLE Benny's Bakery (reference + counterfactual switch)

* =========================
* (a) Sets, params, vars
* =========================
set i "products" /roll, croissant, bread/ ;

* =========================
parameter rev(i)  "--$/item-- selling price"
/ roll 2.25, croissant 5.50, bread 10.00 /;

parameter cost(i) "--$/item-- variable cost"
/ roll 1.50, croissant 2.00, bread 5.00 /;

parameter time(i) "--hours/item-- hours of labor per item"
/ roll 1.50, croissant 2.25, bread 5.00 /;

scalar Hbar "--hours/week-- total available labor" /40/ ;

* =========================

* Decision variables
positive variable X(i) "--items-- production (units/week)" ;
variable profit "--$/week-- total profit" ;

* Objective: maximize profit = sum_i (rev(i)-cost(i)) * X(i)
equations
    eq_obj     "target: profit calculation"
    eq_hours   "time limit: cannot exceed weekly hours"
    eq_roll_cf "counterfactual: require a roll with every croissant (enabled by switch)"
;

eq_obj..
    profit =e= sum(i, (rev(i) - cost(i)) * X(i)) ;

eq_hours..
    Hbar =g= sum(i, time(i) * X(i)) ;

* =========================
* (b) Counterfactual constraint (math)
*     X(roll) >= X(croissant)
*     (rolls may also be sold individually)
* =========================

$if not set cf $setglobal cf 0
scalar sw_cf /%cf%/ ;
eq_roll_cf$sw_cf..
    X("roll") =g= X("croissant") ;

* =========================
* Model & solve
* =========================
model bakery /all/ ;
solve bakery using lp maximizing profit ;

* =========================
* Reporting
* =========================
parameter rep_x(i) "--items-- optimal production" ;
parameter rep_profit "--$/week-- optimal profit" ;

rep_x(i)     = X.l(i) ;
rep_profit   = profit.l ;

* Save a scenario-tagged GDX (0=reference, 1=counterfactual)
execute_unload 'bakery_%cf%.gdx', rep_x, rep_profit ;

* (Optional quick console echo)
display rep_x, rep_profit ;

* -----------------------------
set k "report fields" / qty, profit /;
set j "products plus total" / roll, croissant, bread, TOTAL /;

parameter rep(j,k) "solution report for export" ;

* quantities
rep(j,'qty') = 0 ;
rep('roll','qty')       = X.l('roll') ;
rep('croissant','qty')  = X.l('croissant') ;
rep('bread','qty')      = X.l('bread') ;

* profit (park on TOTAL row)
rep(j,'profit') = 0 ;
rep('TOTAL','profit') = profit.l ;

* write scenario-tagged GDX (0 = reference, 1 = counterfactual)
execute_unload 'bakery_%cf%.gdx', rep ;