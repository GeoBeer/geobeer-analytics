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
if (!require(RSQLite)) {
  install.packages('RSQLite')
  require(RSQLite)
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


# Change the path to the location of your working directory
wd <- here()
db <- here('..', 'geowebforum-scraper', 'data.sqlite')


# Query the relevant data from the SQLite DB
library(DBI)
con <- dbConnect(RSQLite::SQLite(), db)

dbListTables(con)

results <- dbSendQuery(con, 'SELECT post_author, count(*) as posts FROM posts GROUP BY post_author ORDER BY posts DESC')
raw_data <- dbFetch(results)
dbClearResult(results)
dbDisconnect(con)

# Remove temporary objects
rm(con)
rm(results)

# Add timespan information for using gender_df() later on
# Isolate first names (https://stackoverflow.com/questions/33683862/first-entry-from-string-split)
data <- raw_data %>% 
  filter(!post_author %in% c('', 'Communication swisstopo', 'Der Administrator', 
                             'Der Newsmoderator', 'Geschäftsstelle IKGEO', 
                             'Geschäftsstelle KKGEO', 'HSR Geoinformation', 
                             'SOGI FG4')) %>%
  mutate(min_year=1950, max_year=2000)

data %<>%
  mutate(firstname=(str_split(data$post_author, boundary('word')) %>%
                      sapply(extract2, 1)))

# Classify the gender based on first name
gender_data <- gender_df(data, name_col="firstname", 
                         year_col=c("min_year", "max_year")) %>%
  select(name, gender)

# Join gender information to main data set
data %<>% 
  left_join(gender_data, by = c("firstname"="name")) %>%
  select(post_author, firstname, posts, gender)

# Extract the names that could not be classified automatically
data %>% 
  filter(is.na(gender)) %>%
  select(firstname) %>%
  unique() -> not_automatically_classifiable

# Remove temporary data
rm(gender_data)

# Classify the additional names using a manually curated firstname > gender list
data <- classify_additional_names(data)

data %<>%
  select(post_author, posts, gender)

# Save resulting data to disks
write_csv(data, here('Results', 'geowebforum-aggregated-data.csv'))

# Analyse gender of authors and save to disk
authors <- data %>%
  group_by(gender) %>%
  summarise (count = n()) %>%
  mutate(percentage = count / sum(count) * 100)
write_csv(authors, here('Results', 'geowebforum-author-gender-stats.csv'))

# Analyse "gender of posts" and save to disk
posts <- data %>%
  group_by(gender) %>%
  summarise(count = sum(posts)) %>%
  mutate(percentage = count / sum(count) * 100)
write_csv(posts, here('Results', 'geowebforum-post-gender-stats.csv'))

