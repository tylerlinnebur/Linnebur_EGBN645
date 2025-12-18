* Q1a.gms

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
    x(i)   "production (items/week)"
    z      "total profit ($/week)";

Positive Variables x;

Equations
    obj     "maximize weekly profit"
    labor   "labor-hours constraint"
    bundle    "roll required with every croissant";

obj..
    z =e= sum(i, pi(i) * x(i));

labor..
    sum(i, t(i) * x(i)) =l= H;

* Bundling constraint: rolls >= croissants
bundle..
    x("roll") =g= x("croissant");

Model bakery / obj, labor /;

Solve bakery using LP maximizing z;

Display x.l, z.l;
