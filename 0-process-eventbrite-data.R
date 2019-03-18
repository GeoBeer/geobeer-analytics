# ----------------------------------------------------------------------------------------
# Authors:      GeoBeer Team, @geobeer_ch
# Created:      2019-03
# License:      GNU General Public License v3.0
# Repository:   https://github.com/GeoBeer/geobeer-analytics
# More info:    https://geobeer.github.io/geobeer-analytics, http://www.geobeer.ch
# ----------------------------------------------------------------------------------------


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

# Read all data files
setwd(here('..', 'geobeer-private-data', 'Eventbrite'))
in_files <- list.files(path='.', pattern='^GeoBeer.*\\.csv$', ignore.case=TRUE)
in_files
raw_data <- do.call(rbind, lapply(in_files, read_csv))
raw_data$fullname <- str_c(raw_data$firstname, raw_data$lastname, sep=' ')
raw_data <- raw_data[,c(1,4,2,3)]

# Add timespan information for using gender_df() later on
data <- raw_data %>% 
  mutate(min_year=1950, max_year=2000)


# Classify the gender based on first name
gender_data <- gender_df(data, name_col="firstname", 
                         year_col=c("min_year", "max_year"))


# Also try analyzing "last names", as people seem to sometimes confuse 
# first and last name. Filter out names that are already contained in 
# gender_data$name, otherwise there will be duplicates after joining
gender_data_alt <- gender_df(data, name_col="lastname", 
                             year_col=c("min_year", "max_year")) %>%
  # Make sure we don't overwrite gender information that was derived from 
  # first names
  filter(!(name %in% gender_data$name))

# Combine the data from the two approaches
gender_data <- rbind(gender_data, gender_data_alt) %>%
  select(c(name, gender))
rm(gender_data_alt)


# Join gender information to main data set. First, retain records which got a 
# gender estimate based on first name 
r <- data %>% 
  inner_join(gender_data, by = c("firstname"="name")) 
# Records which got a gender estimate based on last name 
s  <- data %>% 
  inner_join(gender_data, by = c("lastname"="name")) %>%
  filter(!(fullname %in% r$fullname))
# Records which got no gender estimate, neither on first nor on last name. 
t <- data %>%
  filter(!(fullname %in% c(r$fullname, s$fullname))) %>%
  # Add 'gender' as new (empty) column to make the data structures compatible
  mutate(gender='')
# Combine all three data sets 
data <- rbind(r, s, t)  

# Remove temporary data
rm(r)
rm(s)
not_automatically_classifiable <- t
rm(t)

# Drop unnecessary columns from data and remove temporary data
data$min_year <- NULL
data$max_year <- NULL
rm(gender_data)

data$gender[data$gender == ""] <- NA

# Classify the additional names using a manually curated firstname > gender list
aggregated_data <- classify_additional_names(data)

# Save resulting data to disks
write_csv(aggregated_data, here('..', 'geobeer-private-data', 'Eventbrite', 
                                'eventbrite-aggregated-data.csv'))

# Analyse gender by event and save to disk
gender_stats_data <- aggregated_data %>%
  group_by(event, gender) %>%
  summarise (count = n()) %>%
  mutate(percentage = count / sum(count) * 100)

write_csv(gender_stats_data, here('Results', 'eventbrite-gender-stats.csv'))

