$title Q1 - Benny's Bakery (single model; counterfactual via --CF)

$if not set CF $set CF 0   * 0=reference, 1=counterfactual (2 rolls per croissant)

set i / roll, croissant, bread /;

parameters
    r(i)  'revenue [$ per item]'
    c(i)  'cost    [$ per item]'
    t(i)  'time    [hours per item]';

r('roll')       = 2.25;   c('roll')       = 1.50;   t('roll')       = 1.50;
r('croissant')  = 5.50;   c('croissant')  = 2.00;   t('croissant')  = 2.25;
r('bread')      = 10.50;  c('bread')      = 5.00;   t('bread')      = 5.00;

scalar Hbar 'total available hours [hours]' /40/;

variables
    x(i)    'production [items]'
    profit  'total profit [$]';
positive variable x;

equations
    eq_obj        'objective: maximize profit'
    eq_time       'weekly time budget'
    eq_pairing    'counterfactual: 2 rolls per croissant (enabled when CF=1)';

eq_obj..  profit =e= sum(i, (r(i)-c(i)) * x(i));
eq_time.. sum(i, t(i)*x(i)) =l= Hbar;

$ifthen "%CF%"=="1"
eq_pairing.. x('roll') =g= 2 * x('croissant');
$else
* harmless dummy so the model compiles when CF=0
eq_pairing.. 0 =e= 0;
$endif

model bakery / eq_obj, eq_time, eq_pairing /;

solve bakery using lp maximizing profit;

* === Report ===
parameter report(*,i) 'production and margins', summary(*);
report('qty [items]',i)     = x.l(i);
report('unit margin [$]',i) = r(i)-c(i);
report('hours/item',i)      = t(i);
summary('total profit [$]') = profit.l;
summary('hours used [h]')   = sum(i, t(i)*x.l(i));
display report, summary;