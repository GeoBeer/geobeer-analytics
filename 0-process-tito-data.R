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
in_files <- list.files(path=here('..', 'geobeer-private-data', 'Tito'), 
                       pattern='^tito-geobeer.*\\.csv$', ignore.case=TRUE)
in_files
raw_data <- do.call(rbind, lapply(paste(here('..', 'geobeer-private-data', 'Tito'),
                                        in_files, sep='/'), read_csv))


# Restructure data
names(raw_data) <- c('Number','TicketCreatedDate','TicketLastUpdatedDate',
                     'Ticket','fullname','firstname','lastname','email',
                     'TicketCompanyName','TicketPhoneNumber','event',
                     'VoidStatus','Price','DiscountStatus','TicketReference',
                     'Tags','UniqueTicketURL','UniqueOrderURL',
                     'OrderReference','OrderName','OrderEmail',
                     'OrderCompanyName','OrderPhoneNumber',
                     'OrderDiscountCode','ip','OrderCreatedDate','timestamp')
data <- raw_data %>% 
  subset(select=c('timestamp', 'fullname', 'firstname', 'lastname', 'email',
                  'event', 'ip')) %>%
  # Add timespan information for using gender_df() later on
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
rm(t)

# There are still records that haven't been assigned a gender. For these, 
# compute a proxy first name from the email addresses
fn_name_from_email <- function(x) {
  unlist(strsplit(x, "\\."))[1]
}
data$proxy_firstname <- as.character(lapply(data$email, fn_name_from_email))

# Estimate gender based on proxy first name
gender_data <- gender_df(data, name_col="proxy_firstname", 
                         year_col=c("min_year", "max_year")) %>%
  select(c(name, gender))

# Reassemble all result data
part2 <- data %>%
  filter(gender == '') %>%
  select(-contains("gender")) %>%
  left_join(gender_data, by=c("proxy_firstname"="name")) 
part1 <- data %>%
  filter(!(gender == ''))
aggregated_data <- rbind(part1, part2)

# Drop unnecessary columns from data
aggregated_data$min_year <- NULL
aggregated_data$max_year <- NULL
aggregated_data$proxy_firstname <- NULL

# Remove temporary data
rm(part1)
rm(part2)
rm(gender_data)

# Classify the additional names using a manually curated firstname > gender list
aggregated_data <- classify_additional_names(aggregated_data)


# Save resulting data to disks
write_csv(aggregated_data, here('..', 'geobeer-private-data', 'Tito', 
                                'tito-aggregated-data.csv'))

# Extract names for which a gender classification needs to be assigned manually, by 
# adding records to ..\geobeer-private-data\Auxiliary-Data\Additional-Names.csv
not_automatically_classifiable <- aggregated_data %>%
  filter(is.na(gender))


# Analyse gender by event and save to disk
gender_stats_data <- aggregated_data %>%
  group_by(event, gender) %>%
  summarise (count = n()) %>%
  mutate(percentage = count / sum(count) * 100)

write_csv(gender_stats_data, here('Results', 'tito-gender-stats.csv'))

# Read and combine the (preprocessed) data on Eventbrite events with Tito data
tito_data <- gender_stats_data
eventbrite_data <- read_csv(here('Results', 'eventbrite-gender-stats.csv'))
data <- rbind(as.data.frame(eventbrite_data), as.data.frame(tito_data))
write_csv(data, here('Results', 'geobeer-audience-gender-stats.csv'))

# Find records that have no associated gender yet
aggregated_data %>%
  filter(is.na(gender)) %>%
  select(event, fullname, firstname, lastname)
