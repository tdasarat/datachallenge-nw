setwd("url\\data")

source("url\\inventory.R")

##############################
#Import and Process JSON file#
##############################

sourcejson <- "car_maker.json"
car_maker_df <- data.frame(do.call(rbind, (RJSONIO::fromJSON(sourcejson))))
car_maker_df <- transform(car_maker_df, Make = as.character(Make))
car_maker_df <- transform(car_maker_df, Nationality = as.character(Nationality))
car_maker_df <- transform(car_maker_df, TopThreeAmericanName = as.character(TopThreeAmericanName))
car_maker_df2 <- sqldf::sqldf("select Make,
                                      max(case when Make in ('GMC','OLDSMOBILE','JEEP','BUICK','PONTIAC','CADILLAC',
                                                         'HUMMER','CHEVROLET','MERCURY','CHRYSLER','PLYMOUTH',
                                                         'DODGE','SATURN','FORD','LINCOLN') then 1 else 0 end) as Nationality_American,
                                      max(case when Make in ('VOLKSWAGEN','MINI','VOLVO') then 1 else 0 end) as Nationality_Other,
                                      max(case when Make in ('MITSUBISHI','TOYOTA','SUBARU','HYUNDAI','MAZDA','INFINITI','SCION','ISUZU',
                                                         'SUZUKI','KIA','TOYOTA SCION','ACURA','LEXUS') then 1 else 0 end) as Nationality_Other_Asian,
                                      max(case when Make in ('NISSAN','TOYOTA','HONDA') then 1 else 0 end) as Nationality_Topline_Asian,
                                      max(case when Make in ('TOYOTA','NISSAN','MINI','HONDA','SUBARU','HYUNDAI','VOLKSWAGEN','INFINITI',
                                                             'MITSUBISHI','ISUZU','SCION','KIA','SUZUKI','VOLVO','TOYOTA SCION',
                                                             'ACURA','MAZDA','LEXUS') then 1 else 0 end) as tob3brand_other,
                                      max(case when Make in ('OLDSMOBILE','HUMMER','GMC','BUICK','SATURN','CADILLAC',
                                                             'CHEVROLET','PONTIAC') then 1 else 0 end) as tob3brand_GM,
                                      max(case when Make in ('FORD','MERCURY','LINCOLN') then 1 else 0 end) as tob3brand_Ford,
                                      max(case when Make in ('PLYMOUTH','DODGE','CHRYSLER','JEEP') then 1 else 0 end) as tob3brand_Chrysler
                          from car_maker_df group by 1")
						  
						  
##############################
#   Import Train data file   #
##############################

train_df <- read.csv("train_nw.csv")

# Call inventory function to understand the contents of the data along with some univariate stats

inventory(train_df,"Inventory-Train.csv")



##############################
#  Train Data Processing     #
##############################

train_df <- transform(train_df, Make = as.character(Make))
sapply(car_maker_df, class)

#clean the SQl code to not include the Make from Car_maker_df2#
train_df2 <-sqldf::sqldf("select *
                         from train_df as a left join 
                              car_maker_df2 as b on a.make = b.make")

train_df3 <- sqldf::sqldf("select *,
                                  case when auction = 'ADESA' then 1 else 0 end as auction_ADESA,
                                  case when auction = 'MANHEIM' then 1 else 0 end as auction_MANHEIM,
                                  case when auction = 'OTHER' then 1 else 0 end as auction_OTHER,
                                  case when size = 'COMPACT' then 1 else 0 end as size_COMPACT,
                                  case when size = 'CROSSOVER' then 1 else 0 end as size_CROSSOVER,
                                  case when size = 'LARGE' then 1 else 0 end as size_LARGE,
                                  case when size = 'LARGE SUV' then 1 else 0 end as size_LARGE_SUV,
                                  case when size = 'LARGE TRUCK' then 1 else 0 end as size_LARGE_TRUCK,
                                  case when size = 'MEDIUM' then 1 else 0 end as size_MEDIUM,
                                  case when size = 'MEDIUM SUV' then 1 else 0 end as size_MEDIUM_SUV,
                                  case when size = 'SMALL SUV' then 1 else 0 end as size_SMALL_SUV,
                                  case when size = 'SMALL TRUCK' then 1 else 0 end as size_SMALL_TRUCK,
                                  case when size = 'SPECIALTY' then 1 else 0 end as size_SPECIALTY,
                                  case when size = 'SPORTS' then 1 else 0 end as size_SPORTS,
                                  case when size = 'VAN' then 1 else 0 end as size_VAN,
                                  case when color = 'BEIGE' then 1 else 0 end as color_BEIGE,
                                  case when color = 'BLACK' then 1 else 0 end as color_BLACK,
                                  case when color = 'BLUE' then 1 else 0 end as color_BLUE,
                                  case when color = 'BROWN' then 1 else 0 end as color_BROWN,
                                  case when color = 'GOLD' then 1 else 0 end as color_GOLD,
                                  case when color = 'GREEN' then 1 else 0 end as color_GREEN,
                                  case when color = 'GREY' then 1 else 0 end as color_GREY,
                                  case when color = 'MAROON' then 1 else 0 end as color_MAROON,
                                  case when color = 'NOT AVAIL' then 1 else 0 end as color_NOT_AVAIL,
                                  case when color = 'ORANGE' then 1 else 0 end as color_ORANGE,
                                  case when color = 'OTHER' then 1 else 0 end as color_OTHER,
                                  case when color = 'PURPLE' then 1 else 0 end as color_PURPLE,
                                  case when color = 'RED' then 1 else 0 end as color_RED,
                                  case when color = 'SILVER' then 1 else 0 end as color_SILVER,
                                  case when color = 'WHITE' then 1 else 0 end as color_WHITE,
                                  case when color = 'YELLOW' then 1 else 0 end as color_YELLOW,
                                  case when Transmission = 'AUTO' then 1 else 0 end as Transmission_AUTO,
                                  case when Transmission = 'MANUAL' then 1 else 0 end as Transmission_MANUAL,
                                  case when WheelType = 'Alloy' then 1 else 0 end as WheelType_Alloy,
                                  case when WheelType = 'Covers' then 1 else 0 end as WheelType_Covers,
                                  case when WheelType = 'Special' then 1 else 0 end as WheelType_Special,
                                  case when PRIMEUNIT = 'YES' then 1 else 0 end as PRIMEUNIT_Flg,
                                  case when AUCGUART = 'GREEN' then 1 else 0 end as AUCGUART_flg,
                                  case when AUCGUART not in ('GREEN','RED') then 1 else 0 end as AUCGUART_miss_flg
                    from train_df2")

train_df4 <- unique(train_df3)
write.csv(train_df4,file="train_cleaned.csv")


