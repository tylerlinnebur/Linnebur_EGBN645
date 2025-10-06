$title Q2 - June's Jellybeans (one model; parts c and d via switches)

$if not set DO_EQ    $set DO_EQ 0     * 0=off, 1=on (Part c: 6% nearly-equal)
$if not set DO_SPLIT $set DO_SPLIT 0  * 0=off, 1=on (Part d: machine-color limits)

set m / X1, X2 /;
set b / yellow, blue, green, orange, purple /;
alias (b,bb);

parameters
    nr(b) 'net revenue [$ per bean]';
nr('yellow') = 1.10;
nr('blue')   = 1.05;
nr('green')  = 1.07;
nr('orange') = 0.95;
nr('purple') = 0.99;

scalar rate 'beans per hour' /100/
       H    'hours per week' /40/
       cap  'machine weekly capacity [beans]';
cap = rate*H;  * = 4000

* Part d mapping: valid (m,b) pairs
set m_b(m,b) 'allowed combos when DO_SPLIT=1';
m_b('X1','yellow') = yes; m_b('X1','blue')   = yes; m_b('X1','green')  = yes;
m_b('X2','yellow') = yes; m_b('X2','orange') = yes; m_b('X2','purple') = yes;

variables
    Q(m,b)  'production [beans]'
    profit  'total profit [$]';
positive variable Q;

* Totals by color for Part c constraints
parameter X(b) 'total production by color [beans]';

equations
    eq_obj          'objective'
    eq_cap(m)       'capacity per machine'
$ifi %DO_EQ%==1 eq_up(b,bb), eq_lo(b,bb);

eq_obj.. profit =e= sum((m,b) $ ( %DO_SPLIT% = 0 or m_b(m,b) ), nr(b)*Q(m,b));

eq_cap(m).. sum(b $ ( %DO_SPLIT% = 0 or m_b(m,b) ), Q(m,b)) =l= cap;

* Nearly-equal (6%) across colors based on totals X(b)
$if %DO_EQ%==1
X(b) =e= sum(m, Q(m,b));
eq_up(b,bb) $ (not sameas(b,bb)) .. X(b) =l= 1.06 * X(bb);
eq_lo(b,bb) $ (not sameas(b,bb)) .. X(b) =g= 0.94 * X(bb);

* If Part d is active, zero-out disallowed variables explicitly
$ifthen %DO_SPLIT%==1
Q.fx(m,b) $ (not m_b(m,b)) = 0;
$endif

$ifthen %DO_EQ%==1
model jelly / eq_obj, eq_cap, eq_up, eq_lo /;
$else
model jelly / eq_obj, eq_cap /;
$endif

solve jelly using lp maximizing profit;

* === Report ===
parameter byMachine(m,*), byColor(b,*), summary(*);

byMachine(m,'qty [beans]')  = sum(b, Q.l(m,b));
byMachine(m,'util [%]')     = 100*byMachine(m,'qty [beans]')/cap;

byColor(b,'qty [beans]')    = sum(m, Q.l(m,b));
byColor(b,'share [%]')      = 100*byColor(b,'qty [beans]') / sum((m,bb), Q.l(m,bb));

summary('profit [$]')       = profit.l;
summary('total beans')      = sum((m,b), Q.l(m,b));

display byMachine, byColor, summary;
