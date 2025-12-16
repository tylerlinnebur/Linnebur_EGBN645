$TITLE Minimize LCOE, compare permitting reform under private vs public ownership
* NOTE: Reform affects construction duration and schedule risk only; all engineering and operating assumptions are held constant.


SETS
    o   ownership type          / private, public /
    r   permitting regime       / baseline, reform /;

* -------------------------
* 1) INPUT DATA
* -------------------------

SCALARS
* Engineering and production
    capMW       "Plant capacity (MW)"
    capFac      "Capacity factor (fraction)"
    lifeY       "Operating lifetime (years)"

* Cost inputs (all in $/MWh from OECD-NEA tables)
    capCost_MWh    "Capital cost component of LCOE (USD/MWh)"
    omCost_MWh     "Operations and maintenance cost (USD/MWh)"
    fuelCost_MWh   "Fuel cost (USD/MWh)"

* Financing inputs
    kappa       "Risk-to-WACC multiplier (per year of schedule risk)"
    hrs         "Hours per year";

PARAMETERS
    wacc(o)     "Base WACC by ownership"
    buildY(r)   "Construction time to COD (years)"
    sigY(r)     "Schedule risk (years, dispersion proxy)";

* Engineering and production
capMW   = 1000;
capFac  = 0.92;
lifeY   = 60;

* Cost inputs (OECD-NEA, already in $/MWh)
capCost_MWh  = 50.32;
omCost_MWh   = 11.6;
fuelCost_MWh = 9.33;

* Financing inputs
hrs = 8760;
wacc("private") = 0.08;
wacc("public")  = 0.025;

* Permitting / construction assumptions (PRIS cohort stats)
buildY("baseline") = 14.92;
buildY("reform")   = 6.44;

sigY("baseline") = 10.36;
sigY("reform")   = 0.66;

* Risk pricing assumption
kappa = 0.0075;

* -------------------------
* 2) DERIVED TERMS (LCOE building blocks)
* -------------------------
SCALARS
    annMWh  "annual generation (MWh/yr)";

PARAMETERS
    rEff(o,r)    "effective WACC after risk adjustment"
    idcMult(o,r) "IDC-style multiplier for construction time"
    lcoe(o,r)    "LCOE by case ($/MWh)";

annMWh = capMW * hrs * capFac;

* Effective WACC: base WACC + kappa * schedule risk
rEff(o,r) = wacc(o) + kappa * sigY(r);

* IDC multiplier using midpoint compounding over construction time
idcMult(o,r) = (1 + rEff(o,r)) ** (buildY(r)/2);

* LCOE: apply IDC multiplier to capital component only, keep O&M and fuel constant
lcoe(o,r) = capCost_MWh * idcMult(o,r) + omCost_MWh + fuelCost_MWh;

* -------------------------
* 3) LP: choose the minimum-LCOE case
* -------------------------
VARIABLES
    Z   "objective: chosen LCOE ($/MWh)";

POSITIVE VARIABLES
    x(o,r)  "weight on each case (LP will pick the min case)";

EQUATIONS
    objDef
    chooseOne;

objDef..     Z =E= SUM((o,r), lcoe(o,r) * x(o,r));
chooseOne..  SUM((o,r), x(o,r)) =E= 1;

MODEL chooseLCOE / objDef, chooseOne /;

SOLVE chooseLCOE USING LP MINIMIZING Z;

* -------------------------
* 4) OUTPUT
* -------------------------
DISPLAY lcoe, x.l, Z.l, rEff, buildY, sigY, idcMult;