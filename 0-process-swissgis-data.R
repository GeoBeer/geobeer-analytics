if (!require(here)) {
  install.packages('here')
  require(here)
}
if (!require(tidyverse)) {
  install.packages('tidyverse')
  require(tidyverse)
}
if (!require(magrittr)) {
  install.packages('magrittr')
  require(magrittr)
}
if (!require(readr)) {
  install.packages('readr')
  require(readr)
}
if (!require(gender)) {
  install.packages('gender')
  require(gender)
}
if (!require(genderdata)) {
  install.packages('genderdata')
  require(genderdata)
}
source(here('functions.R'))


setwd(here('..', 'geobeer-private-data', 'SwissGIS'))

# Read all data files
data <- read_delim('SwissGIS-user-table.csv', delim=';')

# Restructure data
names(data) <- c('name','account','profile_img','language','account_age',
                 'followers','following','fo_fr_ratio','group_followers',
                 'group_following','group_fo_fr_ratio','tweets',
                 'tweets_per_month')
data <- data %>% 
  # Add timespan information for using gender_df() later on
  mutate(min_year=1950, max_year=2000)

fn_name_from_fullname <- function(x) {
  unlist(strsplit(x, " "))[1]
}
data$firstname <- as.character(lapply(data$name, fn_name_from_fullname))


# Classify the gender based on first name
gender_data <- gender_df(data, name_col="firstname", 
                         year_col=c("min_year", "max_year")) %>%
  select(c(name, gender))


# Join gender information to main data set. 
data %<>%
  left_join(gender_data, by = c("firstname"="name")) 

not_automatically_classifiable <- data %>%
  filter(is.na(gender))

# Drop unnecessary columns from data
data$min_year <- NULL
data$max_year <- NULL

# Classify the additional names using a manually curated firstname > gender list
aggregated_data <- classify_additional_names(data)

# Set unclassified records to 'unknown or unapplicable' (most of them are 
# companies and other institutions)
aggregated_data$gender[is.na(aggregated_data$gender)] <- 
  'unknown or unapplicable'

# Remove temporary data
rm(gender_data)

# Save resulting data to disks
write_csv(aggregated_data, here('..', 'geobeer-private-data', 'SwissGIS', 
                                'swissgis-aggregated-data.csv'))

# Analyse gender by event and save to disk
gender_stats_data <- aggregated_data %>%
  group_by(gender) %>%
  summarise (count = n()) %>%
  mutate(percentage = count / sum(count) * 100)

write_csv(gender_stats_data, here('Results', 'swissgis-gender-stats.csv'))
