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

* Cost inputs
    capCost_MWh    "Capital cost component of LCOE (USD/MWh)"
    omCost_MWh     "Operations and maintenance cost (USD/MWh)"
    fuelCost_MWh   "Fuel cost (USD/MWh)"

* Financing inputs
    kappa       "Risk-to-WACC multiplier (per year of schedule risk)"
    hrs         "Hours per year"

* Financing / cost structure for CRF formulation (units matter)
    occ     "Overnight capital cost ($/kW)"
    fom     "Fixed O&M ($/kW-yr)"
    vom     "Variable O&M ($/MWh)"
    fuel    "Fuel ($/MWh)";

PARAMETERS
    wacc(o)     "Base WACC by ownership"
    buildY(r)   "Construction time to COD (years)"
    sigY(r)     "Schedule risk (years, dispersion proxy)";

* Engineering and production
* Representative plant capacity based on EIA nuclear fleet data: 95.55 million kW total capacity / 93 reactors
capMW   = 1000;     * size of the plant
capFac  = 0.92;     * how often it runs
lifeY   = 60;       * how long it operates

* Cost inputs
* NOTE: Cost components are taken directly from OECD-NEA LCOE tables; capital costs are already annualized and expressed per MWh.
capCost_MWh  = 50.32;    * Total capital costs (USD/MWh)
omCost_MWh   = 11.6;     * O&M costs (USD/MWh)
fuelCost_MWh = 9.33;     * Fuel costs (USD/MWh)

hrs = 8760;

* Map $/MWh fuel from your existing input
fuel = fuelCost_MWh;

* TODO: replace with real values in correct units
occ = 0;               * $/kW
fom = 0;               * $/kW-yr
vom  = omCost_MWh;     * $/MWh

* Financing inputs
wacc("private") = 0.08;
wacc("public")  = 0.025;

* Permitting / construction assumptions
* Construction time = Construction Start Date → Commercial Operation Date
* Values reflect cohort means computed from PRIS reactor-level data

buildY("baseline") = 14.92;   * Mean construction duration, baseline cohort
buildY("reform")   = 6.44;    * Mean construction duration, reform cohort

* Schedule risk (sample sd of construction duration, years)
sigY("baseline") = 10.36;     * Fragmented regime
sigY("reform")   = 0.66;      * Standardized regime

* Risk pricing assumption
kappa = 0.0075;  * 0.75 percentage points per 1.0 year of schedule risk

* -------------------------
* 2) DERIVED TERMS (LCOE building blocks)
* -------------------------
SCALARS
    annMWh      annual generation (MWh/yr)
    capkW       capacity (kW);

PARAMETERS
    rEff(o,r)       effective WACC after risk adjustment
    crf(o,r)        capital recovery factor
    idcMult(o,r)    simple IDC multiplier for construction time
    capexAnn(o,r)   annualized capital cost ($/yr)
    fixedAnn(o,r)   annual fixed O&M ($/yr)
    lcoe(o,r)       LCOE by case ($/MWh);

capkW  = capMW * 1000;
annMWh = capMW * hrs * capFac;

* Effective WACC: base WACC + kappa * schedule risk
rEff(o,r) = wacc(o) + kappa * sigY(r);

* CRF = r*(1+r)^N / [(1+r)^N - 1]
crf(o,r) = rEff(o,r) * power(1 + rEff(o,r), lifeY)
           / ( power(1 + rEff(o,r), lifeY) - 1 );

* Simple IDC multiplier using midpoint compounding:
* roughly treats spending as spread over build time
idcMult(o,r) = power(1 + rEff(o,r), buildY(r)/2);

* Annualized capital cost ($/yr)
capexAnn(o,r) = (occ * capkW * idcMult(o,r)) * crf(o,r);

* Annual fixed O&M cost ($/yr)
fixedAnn(o,r) = fom * capkW;

* LCOE = (capexAnn + fixedAnn)/annMWh + VOM + Fuel
lcoe(o,r) = (capexAnn(o,r) + fixedAnn(o,r)) / annMWh + vom + fuel;

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
DISPLAY lcoe, x.l, Z.l, rEff, buildY, sigY, crf, idcMult;