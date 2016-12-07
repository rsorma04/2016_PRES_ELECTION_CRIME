setwd("C:/Users/rocco.sorma/Desktop/R_PROGRAMMING/2016_PRES_ELECTION_CRIME")

library(httr)
library(stringi)
library(purrr)
library(dplyr)

# Bring in file containing state abbreviations.
state_df_file <- data.frame(read.csv("STATE_ABBREVIATIONS.csv"), stringsAsFactors=FALSE)
# Turn state abbreviation from a factor to a character.
state_df_file$ABBREVIATION <- as.character(state_df_file$ABBREVIATION)

county_results <- data.frame()
for (i in 1:nrow(state_df_file)) {
  
  # Iterate through the current state abbreviation.
  state_abb <- subset(state_df_file$ABBREVIATION, state_df_file$ID == i)
  # Get the first part of the url.
  beg_url <- "http://s3.amazonaws.com/origin-east-elections.politico.com/mapdata/2016/"
  # Get the last part of the url.
  end_url <- "_20161108.xml"
  
  # Bring url together.
  url <- paste(beg_url, state_abb, end_url, sep = "")
  
  res <- GET(url)
  dat <- readLines(textConnection(content(res, as="text")))
  
  # Format list of Get list of candidates.
  stri_split_fixed(dat[2], "|")[[1]] %>%
    stri_replace_last_fixed(";", "") %>% 
    stri_split_fixed(";", 3) %>% 
    map_df(~setNames(as.list(.), c("rep_id", "last", "first"))) -> candidates

  str_one <- paste("^", state_abb, ";P;G", sep = "")
  str_two <- paste("^", state_abb, ";P;G;", sep = "")
  
  # Format list of Get list of candidates.
  stri_split_fixed(dat[2], "|")[[1]] %>%
    stri_replace_last_fixed(";", "") %>% 
    stri_split_fixed(";", 3) %>% 
    map_df(~setNames(as.list(.), c("rep_id", "last", "first"))) -> candidates
  
  dat[stri_detect_regex(dat, str_one)] %>% 
    stri_replace_first_regex(str_two, "") %>% 
    map_df(function(x) {
      
      county_results <- stri_split_fixed(x, "||", 2)[[1]]
      
      stri_replace_last_fixed(county_results[1], ";;", "") %>% 
        stri_split_fixed(";") %>% 
        map_df(~setNames(as.list(.), c("fips", "name", "x1", "reporting", "x2", "x3", "x4"))) -> county_prefix
      
      stri_split_fixed(county_results[2], "|")[[1]] %>% 
        stri_split_fixed(";") %>% 
        map_df(~setNames(as.list(.), c("rep_id", "party", "count", "pct", "x5", "x6", "x7", "x8", "candidate_idx"))) %>% 
        left_join(candidates, by="rep_id") -> df
      
      df$fips <- county_prefix$fips
      df$name <- county_prefix$name
      df$reporting <- county_prefix$reporting
      
      select(df, -starts_with("x"))
      
    }) -> results_county
  # Filter to only include county results and 4 main candidates.
  results_county <- subset(results_county, results_county$fips != 0 & 
                             (results_county$last == "Trump" |
                             results_county$last == "Clinton" |
                             results_county$last == "Johnson" |
                             results_county$last == "Stein"))
  
  # Create a new field that contains the state abbreviation.
  results_county$state <- substr(results_county$rep_id, 1, 2)
  
  # Create a new field that concatenates the county and state abbreviation.
  results_county$county_state <- paste(results_county$name, results_county$state, sep = " ")
  
  # Append the data frame with data from each iteration of the loop.
  county_results <- rbind(county_results, results_county)
}


write.csv(county_results, "COUNTY_RESULTS.csv")