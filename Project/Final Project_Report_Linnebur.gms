$TITLE Nuclear LCOE Model

*Sets
set s scenarios /s1*s10/;
set t years /1*60/;

*Parameters

*LCOE calculation inside GAMS
parameter IDC(s) ;
IDC(s) = (1+r)**Delta(s) ;
LCOE(s) =e= (Cbase*(1+phi(s))*IDC(s)) / sum(t, p(t)*Q(t)/(1+r)**t.val );

*Expected LCOE target
Z =e= sum(s, pi(s)*LCOE(s));

*Build rule with big-M
eq_build.. Z =l= Lstar + M*(1-x) ;

*Policy switch
if(sw_reform=1,
    Delta(s) = reform_factor * Delta(s);
    phi(s)   = reform_phi * phi(s);
    r        = r - reform_riskreduction ;
);

*Solve
model nuclear /all/ ;
solve nuclear using nlp minimizing Z ;

