setwd("C:/Users/rocco.sorma/Desktop/R_PROGRAMMING/2016_PRES_ELECTION_CRIME")

COUNTY_2016_PRES_RESULTS_FINAL <- read.csv("COUNTY_RESULTS.csv")
COUNTY_CRIME_2015_FINAL <- read.csv("CRIMES_BY_COUNTY_2015.csv")


COMBINED_2016_ELEC_RESULTS_CRIME <- merge(COUNTY_2016_PRES_RESULTS_FINAL, COUNTY_CRIME_2015_FINAL,
                                     by.x = "county_state",
                                     by.y = "COUNTY_STATE_ABB")

write.csv(COMBINED_2016_ELEC_RESULTS_CRIME, "COMBINED_2016_ELEC_RESULTS_CRIME.csv")