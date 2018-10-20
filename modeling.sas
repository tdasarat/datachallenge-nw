libname test "/home/tdasarat0";

filename train "/home/tdasarat0/train_cleaned.csv";
filename report "/home/tdasarat0/model_results.xls";

/* Importing the cleaned CSV file */
proc import datafile = train dbms = csv out = work.train_cleaned;
run;

/* Impute variables based on the analysis performed */
data train_cleaned;
set train_cleaned;

if missing(MMRCurrentAuctionAveragePrice) then MMRCurrentAuctionAveragePrice= 10678;
if missing(MMRCurrentAuctionCleanPrice) then MMRCurrentAuctionCleanPrice= 12520;
if missing(MMRCurrentRetailAveragePrice) then MMRCurrentRetailAveragePrice= 14280;
if missing(MMRCurrentRetailCleanPrice) then MMRCurrentRetailCleanPrice= 16111;

if missing(MMRAcquisitionAuctionAveragePri) then MMRAcquisitionAuctionAveragePri= 7757;
if missing(MMRAcquisitionAuctionCleanPrice) then MMRAcquisitionAuctionCleanPrice= 9023;
if missing(MMRAcquisitionRetailAveragePric) then MMRAcquisitionRetailAveragePric= 11724;
if missing(MMRAcquisitonRetailCleanPrice) then MMRAcquisitonRetailCleanPrice= 13237;



run;

/* Creating Train and validation sample */
proc surveyselect data = train_cleaned samprate= .7 seed= 793 out= _model outall;
run;

/* variable transformations were created */
data _model;
set _model;
log_AcqAuctionAveragePri = log(MMRAcquisitionAuctionAveragePri + 1);
pca1 = (0.356219 * MMRAcquisitionAuctionAveragePri) +
(0.354980 * MMRAcquisitionAuctionCleanPrice) +
(0.354435 * MMRCurrentAuctionCleanPrice) +
(0.353821 * MMRCurrentAuctionAveragePrice) +
(0.353204 * MMRCurrentRetailAveragePrice) +
(0.353929 * MMRCurrentRetailCleanPrice) +
(0.351036 * MMRAcquisitonRetailCleanPrice) +
(0.350770 * MMRAcquisitionRetailAveragePric);

log_CurrentRtlAveragePrice = log(MMRCurrentRetailAveragePrice + 1);	
log_AcquisitonRtilCleanPrice = log(MMRAcquisitonRetailCleanPrice + 1)	;
log_AcquisitionRtilAveragePric = log(MMRAcquisitionRetailAveragePric + 1);

rtio = VehBCost/MMRCurrentRetailAveragePrice;

if selected = 1 then target = isbadbuy;else target = .;
rename selected = train;
run;

%let indepvars = VehYear VehOdo WheelType_Covers AUCGUART_flg 
VehBCost
tob3brand_GM
size_COMPACT
auction_ADESA;

ODS HMTL FILE=report; 
/* Model is trained to predict isbadbuy */
PROC LOGISTIC DATA = _model namelen = 50;
model target(event='1')= &indepvars/ details rsquare lackfit stb;
output out = _scored p = pred ;
RUN;

/* Below set of code provides collinearity index to understand and avoid multicollinearity */
proc reg data=_model;
model target = &indepvars/ vif collin;
run;

/* Below set of code helps to validate the model */
proc rank data = _scored(where=(train=1)) groups = 10 descending out = _ranked_train;
var pred;
ranks r_pred;
run;

proc means data= _ranked_train noprint;
class r_pred;
var target isbadbuy pred &indepvars.;
output out= meanout
mean = ;
run;

proc print data=meanout;
title3 "Train Dataset";
run;

proc rank data = _scored(where=(train=0)) groups = 10 descending out = _ranked_validate;
var pred;
ranks r_pred;
run;

proc means data= _ranked_validate noprint;
class r_pred;
var target isbadbuy pred &indepvars.;
output out= meanout
mean = ;
run;

proc print data=meanout;
title3 "Train Dataset";
run;

ods html close;