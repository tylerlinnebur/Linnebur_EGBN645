* Q1.gms - Benny's Bakery (Reference + Counterfactual via switch)

Sets
    i   "products"   / roll, croissant, bread /
    s   "scenarios"  / ref, cf /;

Parameters
    rev(i)     "revenue ($/item)"
    cost(i)    "cost ($/item)"
    time(i)    "labor time (hours/item)"
    profit(i)  "unit profit ($/item)"
    H          "available labor (hours/week)"
    sw_s(s)    "switch for bundling constraint (0=off, 1=on)";

* Data
rev("roll")      = 2.25;
rev("croissant") = 5.50;
rev("bread")     = 10.00;

cost("roll")      = 1.50;
cost("croissant") = 2.00;
cost("bread")     = 5.00;

time("roll")      = 1.50;
time("croissant") = 2.25;
time("bread")     = 5.00;

H = 40;

profit(i) = rev(i) - cost(i);

* Switch values by scenario
sw_s("ref") = 0;
sw_s("cf")  = 1;

Variables
    x(i)  "production (items/week)"
    z     "total profit ($/week)";

Positive Variables x;

Equations
    obj      "objective definition"
    labor    "labor-hours constraint"
    bundle   "roll required with every croissant (switch-controlled)";

obj..
    z =e= sum(i, profit(i) * x(i));

labor..
    sum(i, time(i) * x(i)) =l= H;

Scalar sw "bundling switch used in the solve";

* If sw=0 => x(roll) >= 0 (redundant)
* If sw=1 => x(roll) >= x(croissant)
bundle..
    x("roll") =g= sw * x("croissant");

Model bakery / obj, labor, bundle /;

* Storage for results
Parameters
    xsol(i,s)    "optimal production (items/week)"
    profsol(s)   "optimal total profit ($/week)"
    timeUsed(s)  "labor hours used (hours/week)";

Loop(s,
    sw = sw_s(s);

    Solve bakery using LP maximizing z;

    xsol(i,s)   = x.l(i);
    profsol(s)  = z.l;
    timeUsed(s) = sum(i, time(i) * x.l(i));
);

Display xsol, profsol, timeUsed;