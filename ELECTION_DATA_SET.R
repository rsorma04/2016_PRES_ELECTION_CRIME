library(httr)
library(stringi)
library(purrr)
library(dplyr)

setwd("C:/Users/rocco.sorma/Desktop/R_PROGRAMMING/2016_ELECTION_CRIME_ANALYSIS")

# Bring in file containing state abbreviations.
state_df_file <- data.frame(read.csv("STATE_ABBREVIATIONS.csv"), stringsAsFactors=FALSE)
# Turn state abbreviation from a factor to a character.
state_df_file$ABBREVIATION <- as.character(state_df_file$ABBREVIATION)


data_two <- data.frame("raw_results" = as.character(0), stringsAsFactors=FALSE)
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
  data_two <- rbind(data_two, dat)
}

data_two


# Format list of Get list of candidates.
stri_split_fixed(dat[2], "|")[[1]] %>%
  stri_replace_last_fixed(";", "") %>% 
  stri_split_fixed(";", 3) %>% 
  map_df(~setNames(as.list(.), c("rep_id", "last", "first"))) -> candidates

res <- GET("http://s3.amazonaws.com/origin-east-elections.politico.com/mapdata/2016/DC_20161108.xml")

dat <- readLines(textConnection(content(res, as="text")))
dat

# Format list of Get list of candidates.
stri_split_fixed(dat[2], "|")[[1]] %>%
  stri_replace_last_fixed(";", "") %>% 
  stri_split_fixed(";", 3) %>% 
  map_df(~setNames(as.list(.), c("rep_id", "last", "first"))) -> candidates

dat[stri_detect_regex(dat, "^DC;P;G")] %>% 
  stri_replace_first_regex("^DC;P;G;", "") %>% 
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
    
  }) -> results

results_2 <- subset(results, results[[6]] %in% c("Clinton", "Trump") & results[[8]] != 0)
results_2
