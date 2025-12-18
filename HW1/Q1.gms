* Q1a.gms

Sets
    i   "products" / roll, croissant, bread /;

Parameters
    r(i)    "revenue ($/item)"
    c(i)    "cost ($/item)"
    t(i)    "labor time (hours/item)"
    H       "labor available (hours/week)"
    pi(i)   "unit profit ($/item)";

* Data
r("roll")      = 2.25;
r("croissant") = 5.50;
r("bread")     = 10.00;

c("roll")      = 1.50;
c("croissant") = 2.00;
c("bread")     = 5.00;

t("roll")      = 1.50;
t("croissant") = 2.25;
t("bread")     = 5.00;

H = 40;

pi(i) = r(i) - c(i);

Variables
    x(i)   "production (items/week)"
    z      "total profit ($/week)";

Positive Variables x;

Equations
    obj     "maximize weekly profit"
    labor   "labor-hours constraint";

obj..
    z =e= sum(i, pi(i) * x(i));

labor..
    sum(i, t(i) * x(i)) =l= H;

Model bakery / obj, labor /;

Solve bakery using LP maximizing z;

Display x.l, z.l;
