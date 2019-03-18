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


# Ingest data ------------------------------------------------------------------

data <- read_csv(here('..', 'geobeer-private-data', 'GeoBeer-Speakers.csv'))

# Do some minor data enrichment and restructuring ------------------------------

data %<>%
  filter(!is.na(gender)) %>%
  select(event, gender)

# Analyse gender by event and save to disk
gender_stats_data <- data %>%
  group_by(event, gender) %>%
  summarise (count = n()) %>%
  mutate(percentage = count / sum(count) * 100)

write_csv(gender_stats_data, here('Results', 'geobeer-speakers-gender-stats.csv'))
