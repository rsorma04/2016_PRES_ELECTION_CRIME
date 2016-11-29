library(XML)
library(RCurl)

setwd("C:/Users/rocco.sorma/Desktop/R_PROGRAMMING/2016_ELECTION_CRIME_ANALYSIS")

# Read in crime data by county.  Around 16% of counties are missing.
county_data <- read.csv("CRIMES_BY_COUNTY_2015.csv")

# List of unique states represented.  4 are missing.
state_abbr <- unique(county_data$STATE_LOWER)


county_election_url <- "http://www.politico.com/2016-election/results/map/president/ohio"
county_parse <- htmlTreeParse(county_election_url, useInternalNodes = T)

xpathSApply(county_parse, "//div[@id = 'globalWrapper']//div[@class = 'super-duper']//h4",xmlValue)
xpathSApply(county_parse, "//div[@id = 'globalWrapper']//div[@class = 'super-duper']//article[@class = 'results-group']//table[@class = 'results-table']//tr[@class = 'type-republican']//td[@class = 'results-percentage']//span[@class = 'percentage-combo']//span[@class = 'number']",xmlValue)
xpathSApply(county_parse, "//div[@id = 'globalWrapper']//div[@class = 'super-duper']//article[@class = 'results-group']//table[@class = 'results-table']//tr[@class = 'type-republican']//td[@class = 'results-name']//span[@class = 'name-combo']",xmlValue)

  