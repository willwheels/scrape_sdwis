library(rvest)
library(dplyr)


options("scipen"=999) # turn off scientific notation

table_names <- c("TREATMENT")

get_table_lengths <- function(table_name) {
  
  treatment_count_url <- paste0("https://data.epa.gov/efservice/", table_name, "/COUNT")
  
  table_length <- read_html(treatment_count_url) %>%
    html_text() %>%
    as.integer()
  
  return_df <- tibble(table_name = table_name, table_length = table_length)
  
}

get_one_table <- function(table_name, table_length) {
  
  start_seq <- seq(1, plyr::round_any(table_length, 10000), by = 10000)
  
  url_seq <- paste0("https://data.epa.gov/efservice/",
                    table_name, 
                    "/rows/", 
                    as.character(start_seq), 
                    ":",
                    as.character(start_seq+9999),
                    "/CSV"
  )
  
  
  entire_table <- purrr::map_dfr(url_seq, readr::read_csv, show_col_types = FALSE) 
  
  
}


## function to read in a table and then write it to an R data file
## using assign the way I am using it is often frowned upon but I thought it
## was important to keep the variable name in the name of the data frame

read_and_write_table <- function(table_name, table_length) {
  
  one_table <- get_one_table(table_name, table_length)
  
  name_of_table <- paste0(table_name, "_df")
  
  saveRDS(one_table, file = paste0(name_of_table, ".RDS"))
  
}

table_names_and_lengths <- purrr::map_dfr(table_names, .f = get_table_lengths)


## read one table into memory

my_table <- get_one_table(table_name <- table_names_and_lengths$table_name[1], 
                          table_length <- table_names_and_lengths$table_length[1])


# this should go down the entire list of tables and save them all with appropriate filenames
## will have to be read in w/ appropriate names using readRDS

purrr::pwalk(table_names_and_lengths, read_and_write_table)







