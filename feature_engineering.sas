libname test "/home/tdasarat0";

filename train "/home/tdasarat0/train_cleaned.csv";
filename train2 "/home/tdasarat0/train_nw.csv";
filename report "/home/tdasarat0/varclus.csv";

/* Importing the cleaned CSV file */
proc import datafile = train dbms = csv out = work.train_cleaned;
run;

proc import datafile = train2 dbms = csv out = work.train_nw;
run;

data train_cleaned; set train_cleaned;
drop var1;
run;

proc contents data = train_cleaned;run;

proc means data = train_cleaned n nmiss mean median stddev min p1 p5 p25 p50 p75 p99 max;
var _numeric_;
run;

%let varlist = 
VehYear
VehOdo
MMRAcquisitionAuctionAveragePri
MMRAcquisitionAuctionCleanPrice
MMRAcquisitionRetailAveragePric
MMRAcquisitonRetailCleanPrice
MMRCurrentAuctionAveragePrice
MMRCurrentAuctionCleanPrice
MMRCurrentRetailAveragePrice
MMRCurrentRetailCleanPrice
VehBCost
IsOnlineSale
WarrantyCost
Nationality_American
Nationality_Other
Nationality_Other_Asian
Nationality_Topline_Asian
tob3brand_other
tob3brand_GM
tob3brand_Ford
tob3brand_Chrysler
auction_ADESA
auction_MANHEIM
auction_OTHER
size_COMPACT
size_CROSSOVER
size_LARGE
size_LARGE_SUV
size_LARGE_TRUCK
size_MEDIUM
size_MEDIUM_SUV
size_SMALL_SUV
size_SMALL_TRUCK
size_SPECIALTY
size_SPORTS
size_VAN
color_BEIGE
color_BLACK
color_BLUE
color_BROWN
color_GOLD
color_GREEN
color_GREY
color_MAROON
color_NOT_AVAIL
color_ORANGE
color_OTHER
color_PURPLE
color_RED
color_SILVER
color_WHITE
color_YELLOW
Transmission_AUTO
Transmission_MANUAL
WheelType_Alloy
WheelType_Covers
WheelType_Special
PRIMEUNIT_Flg
AUCGUART_flg
AUCGUART_miss_flg
;

/* Generating the Statistics like CHISQ, RSquare, Correlation Scatter Plots to deep dive into the variables */

%MAX_CHI2_P(work, train_cleaned, IsBadBuy, &varlist., pivot, 10, start_n=0, runrank=Y, details=NOPRINT);

proc export data=pivotdetail outfile="/home/tdasarat0/pivotdetail3.csv" dbms=csv;
run;

ods csv file= report;

/* Clustering variables */

proc varclus data = train_cleaned;
var &varlist.;
run;

ods csv close;

proc rank data = train_cleaned groups = 10 out= temp;
var MMRAcquisitionAuctionAveragePri;
ranks ranked;
run;

proc means data = temp noprint;
class ranked;
var MMRAcquisitionAuctionAveragePri
MMRCurrentAuctionAveragePrice
MMRAcquisitionAuctionCleanPrice
MMRCurrentAuctionCleanPrice
MMRCurrentRetailAveragePrice
MMRCurrentRetailCleanPrice
MMRAcquisitionRetailAveragePric
MMRAcquisitonRetailCleanPrice
VehBCost
VehYear;
output out= report mean = ;
run;

proc export data = report outfile = "/home/tdasarat0/temp.csv" dbms=csv; run;



/************ PCA ***************/
proc princomp data=_model plots=scree;
   var MMRAcquisitionAuctionAveragePri
MMRAcquisitionAuctionCleanPrice
MMRCurrentAuctionCleanPrice
MMRCurrentAuctionAveragePrice
MMRCurrentRetailAveragePrice
MMRCurrentRetailCleanPrice
MMRAcquisitonRetailCleanPrice
MMRAcquisitionRetailAveragePric;
   ods output Eigenvalues=Evals;
run;

