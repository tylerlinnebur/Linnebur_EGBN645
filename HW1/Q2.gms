* ==== Part (b): Base ====
Set m  "machines" /X1, X2/
    b  "beans"    /yellow, blue, green, orange, purple/;

Scalar rate  "beans/hour" /100/
       hours "hours/week" /40/;

Parameter cap(m) "capacity (beans/week)";
cap(m) = rate*hours * = 4000 (style like hbar etc.)

Parameter rev(b) "net revenue ($/bean)";
rev("yellow") = 1.00 ;
rev("blue")   = 1.05 ;
rev("green")  = 1.07 ;
rev("orange") = 0.95 ;
rev("purple") = 0.90 ;

Positive Variable Q(m,b) "production (beans/week)";
Variable Z "profit ($/week)";

Equation obj, capcon(m);

obj..    Z =e= sum((m,b), rev(b)*Q(m,b));
capcon(m).. sum(b, Q(m,b)) =l= cap(m);

Model base /all/;
Solve base using lp maximizing Z;

* ==== Part (c): add near-equal constraint (±5%) ====
Alias (b,bb);

Positive Variable T(b) "total by color (beans/week)";
Equation defTot(b), nearUp(b,bb), nearLo(b,bb);

defTot(b).. T(b) =e= sum(m, Q(m,b));

* enforce for all pairs b != bb using ord() as in your notes
nearUp(b,bb)$[ord(b)<>ord(bb)].. T(b) =l= 1.05*T(bb);
nearLo(b,bb)$[ord(b)<>ord(bb)].. T(b) =g= 0.95*T(bb);

Model equalMix /obj, capcon, defTot, nearUp, nearLo/;
Solve equalMix using lp maximizing Z;

* ==== Part (d): feasibility by machine-color ====
Set m_b(m,b) "feasible (m,b) pairs";
* X1 can: yellow, blue, green
m_b("X1","yellow") = yes ;
m_b("X1","blue")   = yes ;
m_b("X1","green")  = yes ;
* X2 can: yellow, orange, purple
m_b("X2","yellow") = yes ;
m_b("X2","orange") = yes ;
m_b("X2","purple") = yes ;

* Re-define obj and cap using only valid (m,b)
Equation obj_d, capcon_d(m);

obj_d..       Z =e= sum((m,b)$m_b(m,b), rev(b)*Q(m,b));
capcon_d(m).. sum(b$ m_b(m,b), Q(m,b)) =l= cap(m);

Model restricted /obj_d, capcon_d/;
Solve restricted using lp maximizing Z;
