$TITLE Nuclear LCOE Model — Indices, Parameters, Variables, Objective, Constraints (draft)

*--------------------------------------------------
* Indices / Sets
set
    s   "scenarios"            / s1*sN /     * e.g., s1*s1000 later
    t   "operating years"      / t1*tT / ;   * e.g., t1*t60 later

alias (t,tt) ;

*--------------------------------------------------
* Parameters (placeholders; data filled later)
scalar
    Cbase    "baseline EPC capital ($)"
    r        "risk-adjusted discount rate (WACC + premium, decimal)"
    Tlife    "financial lifetime (years)" ;

parameter
    pi(s)    "scenario probability (sum_s pi(s)=1)"
    phi(s)   "cost overrun multiplier in scenario s (decimal, e.g., 0.25)"
    dlt(s)   "construction delay from FID to COD in scenario s (years)"
    p(t)     "expected real price in year t ($/MWh)"
    Q(t)     "expected energy in year t (MWh)"
    PVden(s) "PV of expected revenues denominator for scenario s (to be computed later)" ;

*--------------------------------------------------
* Variables
binary variable
    x        "build decision (1=build, 0=do not build)" ;

variable
    Z        "objective value: expected LCOE" ;

*--------------------------------------------------
* Objective Function (expected LCOE)
equation
    eq_objfn "minimize expected LCOE across scenarios" ;

eq_objfn..
    Z =e= sum(s, pi(s) * ( Cbase * (1 + phi(s)) * power(1 + r, dlt(s)) / PVden(s) ) );

*--------------------------------------------------
* Constraints
equation
    prob_norm      "scenario probabilities sum to one"
    prob_nonneg(s) "scenario probabilities nonnegative"
    delay_lower(s) "delay lower bound"
    delay_upper(s) "delay upper bound"
    overrun_lower(s) "cost overrun lower bound"
    overrun_upper(s) "cost overrun upper bound"
    feas_num_pos(s) "capitalized cost (numerator) positive"
    feas_den_pos(s) "discounted revenue (denominator) positive" ;
