$TITLE HW1 - Q2 Junes Jellybeans

* Sets
Set m "machines" / X1, X2 /;
Set b "bean colors" / yellow, blue, green, orange, purple /;
Alias(b,bb);

* Parameters
Parameter revenue(b) "net revenue ($/bean)"
/
    yellow 1.00
    blue   1.05
    green  1.07
    orange 0.95
    purple 0.90
/;

Scalar rate  "beans per hour per machine (beans/hour)" / 100 /;
Scalar hours "hours per week per machine (hours/week)" / 40 /;
Scalar cap   "capacity per machine (beans/week)";
cap = rate * hours;   
* 4000

Scalar dev "max deviation fraction for near-equal constraint" / 0.05 /;
Scalar big "big-M for switching constraints" / 1e6 /;

* Machine-color valid combinations for part (d)
Set m_b(m,b) "valid machine-color combinations";
m_b(m,b) = no;
m_b("X1","yellow") = yes;
m_b("X1","blue")   = yes;
m_b("X1","green")  = yes;
m_b("X2","yellow") = yes;
m_b("X2","orange") = yes;
m_b("X2","purple") = yes;

Parameter mb(m,b) "1 if (m,b) allowed under part (d), else 0";
mb(m,b) = 0;
mb(m,b)$m_b(m,b) = 1;

* Scenario switches
Set s "scenarios" / b_base, c_equal, d_restrict, cd_both /;

Parameter
    sw_equal_s(s)    "1 activates near-equal constraints"
    sw_restrict_s(s) "1 activates machine-color restriction";

sw_equal_s(s)    = 0;
sw_restrict_s(s) = 0;

sw_equal_s("c_equal")        = 1;
sw_restrict_s("d_restrict")  = 1;

sw_equal_s("cd_both")        = 1;
sw_restrict_s("cd_both")     = 1;

Scalar sw_equal, sw_restrict;

* Decision variables
Variables
    Q(m,b)     "production on machine m of color b (beans/week)"
    Qcolor(b)  "total production of color b across machines (beans/week)"
    z          "profit ($/week)";

Positive Variable Q, Qcolor;

* Equations
Equations
    obj                     "maximize total net revenue"
    def_color(b)            "define totals by color"
    cap_machine(m)          "machine weekly capacity"
    eq_prodlimit_upper(b,bb) "near-equal upper bound (switchable)"
    eq_prodlimit_lower(b,bb) "near-equal lower bound (switchable)"
    restrict_mb(m,b)        "machine-color restriction (switchable)";

obj.. z =e= sum((m,b), revenue(b) * Q(m,b));

def_color(b).. Qcolor(b) =e= sum(m, Q(m,b));

cap_machine(m).. sum(b, Q(m,b)) =l= cap;

* Part (c): near-equal across colors, switched with big-M
eq_prodlimit_upper(b,bb)..
    Qcolor(b) =l= (1 + dev) * Qcolor(bb) + big * (1 - sw_equal);

eq_prodlimit_lower(b,bb)..
    Qcolor(b) =g= (1 - dev) * Qcolor(bb) - big * (1 - sw_equal);

* Part (d): switched machine-color restriction
restrict_mb(m,b)..
    Q(m,b) =l= cap * ( mb(m,b) + (1 - mb(m,b)) * (1 - sw_restrict) );

Model Jelly / obj, def_color, cap_machine, eq_prodlimit_upper, eq_prodlimit_lower, restrict_mb /;

* Storage for results
Parameter
    Q_sol(s,m,b)      "solution Q by scenario (beans/week)"
    Qcolor_sol(s,b)   "solution totals by color (beans/week)"
    z_sol(s)          "profit by scenario ($/week)";

loop(s,
    sw_equal    = sw_equal_s(s);
    sw_restrict = sw_restrict_s(s);

    solve Jelly using lp maximizing z;

    Q_sol(s,m,b)    = Q.l(m,b);
    Qcolor_sol(s,b) = Qcolor.l(b);
    z_sol(s)        = z.l;
);

display cap, revenue, Q_sol, Qcolor_sol, z_sol;
