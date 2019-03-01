if (!require(here)) {
  install.packages('here')
  require(here)
}
if (!require(tidyverse)) {
  install.packages('tidyverse')
  require(tidyverse)
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
source(here('functions.R'))


# Ingest data ------------------------------------------------------------------

# Read and combine the (preprocessed) data on the #SwissGIS Twitter list
swissgis_data <- read_csv(here('Results', 'swissgis-gender-stats.csv'))
geobeer_data <- read_csv(here('Results', 'geobeer-gender-stats.csv'))
geowebforum_author_data <- 
  read_csv(here('Results', 'geowebforum-author-gender-stats.csv'))
geowebforum_post_data <- 
  read_csv(here('Results', 'geowebforum-post-gender-stats.csv'))


# Do some minor data enrichment and restructuring ------------------------------

# Change the swissgis_data dataframe to not contain the 'unknown or unapplicable' 
# category anymore
swissgis_data %<>%
  filter(gender == 'female' | gender == 'male') %>%
  mutate(percentage = count / sum(count) * 100, source='#SwissGIS Twitter list')

# Aggregate the per-event data in the geobeer_data dataframe
geobeer_data %<>%
  group_by(gender) %>%
  summarise (count = sum(count)) %>%
  mutate(percentage = count / sum(count) * 100, source='GeoBeer events')

# Annotate the source for Geowebforum data
geowebforum_author_data %<>%
  mutate(source='Geowebforum authors')
geowebforum_post_data %<>%
  mutate(source='Geowebforum authors, weighted by number of posts written')


data <- rbind(geobeer_data, swissgis_data, geowebforum_author_data, 
              geowebforum_post_data)
data <- data[c('source', 'gender', 'count', 'percentage')]
write_csv(data, here('Results', 'gender-stats.csv'))

data$source[data$source == 'Geowebforum authors, weighted by number of posts written'] <- 
  'Geowebforum authors,\nweighted by number\nof posts written'

# Make <data$gender> a factor. The order of factor levels determines the  
# drawing order in ggplot bar plots (later factor levels are drawn first). 
data$gender <- factor(data$gender, levels=c('male', 'female'))

# Make <data$source> a factor. The order of factor levels determines the  
# drawing order in ggplot bar plots (later factor levels are drawn first). 
data$source <- factor(data$source, 
                      levels=c('Geowebforum authors,\nweighted by number\nof posts written',
                               'Geowebforum authors', '#SwissGIS Twitter list', 
                               'GeoBeer events'))


# Start plotting data ----------------------------------------------------------

# GeoBeer colors: yellow: #F8C904, light-blue: #86D8FC, dark-blue: #4CA3C3

# Stacked bar charts of relative counts of gender (only male/female categories)
ggplot(data, aes(x=source, y=percentage, fill=gender)) +
  geom_bar(stat='identity') + 
  scale_fill_manual(values=c('#86D8FC', '#F9D84F'), guide = legend_theme) + 
  #geom_hline(yintercept=overall$percentage[overall$gender=='female']) +
  theme_geobeer_horbar() +
  coord_flip() +
  labs(title='Gender balances in GIS in Switzerland', 
       subtitle='\nWhat are the proportions of female and male representation in different channels?', 
       caption=str_c('\nbased on GeoBeer events, www.twitter.com/rastrau/lists/swissgis,\ngeowebforum.ch and github.com/rastrau/geowebforum-scraper'),
       x='',
       y='\nProportion of participants/accounts [%]')
ggsave(here('Results', 'Gender-balances--relative.png'), width=25, height=15, 
            units='cm')


