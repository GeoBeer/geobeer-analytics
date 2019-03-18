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
source(here('functions.R'))


# Ingest data ------------------------------------------------------------------

# Read and combine the (preprocessed) data on the #SwissGIS Twitter list
data <- read_csv(here('Results', 'swissgis-gender-stats.csv'))


# Do some minor data enrichment and restructuring ------------------------------

# Make <data$gender> a factor. The order of factor levels determines the  
# drawing order in ggplot bar plots (later factor levels are drawn first). 
data$gender <- factor(data$gender, levels=c('unknown or unapplicable', 'male', 
                                            'female'))

# Create a dataframe without the 'unknown or unapplicable' category
data_clean <- data %>%
  filter(gender == 'female' | gender == 'male') %>%
  mutate(percentage = count / sum(count) * 100)

# Start plotting data ----------------------------------------------------------

# GeoBeer colors: yellow: #F8C904, light-blue: #86D8FC, dark-blue: #4CA3C3

# Stacked bar charts of absolute counts of gender (all categories)
ggplot(data, aes(x='', y=count, fill=gender)) +
  geom_bar(stat='identity') + 
  scale_fill_manual(values=c('#4CA3C3', '#86D8FC', '#F9D84F')) + 
  theme_geobeer_horbar() +
  coord_flip() +
  theme(legend.position='top') +
  labs(title='Gender balance of the #SwissGIS Twitter list', 
       subtitle='\nHow many Twitter accounts of each gender are on #SwissGIS?\n', 
       caption=str_c('\n\n@geobeerch, geobeer.github.io/geobeer-analytics\n\n',
                     'Based on www.twitter.com/rastrau/lists/swissgis.'),
       x='\n',
       y='\nNumber of accounts\n')
ggsave(here('Results', 'SwissGIS-gender-balance--absolute--all-categs.png'), 
       width=25, height=12, units='cm')

# Stacked bar charts of relative counts of gender (only male/female categories)
ggplot(data, aes(x='', y=percentage, fill=gender)) +
  geom_bar(stat='identity') + 
  scale_fill_manual(values=c('#4CA3C3', '#86D8FC', '#F9D84F')) + 
  #geom_hline(yintercept=overall$percentage[overall$gender=='female']) +
  theme_geobeer_horbar() +
  coord_flip() +
  theme(legend.position='top') +
  labs(title='Gender balance of the #SwissGIS Twitter list', 
       subtitle='\nWhat are the proportions of female and male Twitter accounts?\n', 
       caption=str_c('\n\n@geobeerch, geobeer.github.io/geobeer-analytics\n\n',
                     'Based on www.twitter.com/rastrau/lists/swissgis.'),
       x='\n',
       y='\nProportion of accounts [%]')
ggsave(here('Results', 'SwissGIS-gender-balance--relative--all-categs.png'), 
       width=25, height=12, units='cm')

# Stacked bar charts of absolute counts of gender (all categories)
ggplot(data_clean, aes(x='', y=count, fill=gender)) +
  geom_bar(stat='identity') + 
  scale_fill_manual(values=c('#86D8FC', '#F9D84F')) + 
  theme_geobeer_horbar() +
  coord_flip() +
  theme(legend.position='top') +
  labs(title='Gender balance of the #SwissGIS Twitter list', 
       subtitle='\nHow many Twitter accounts of each gender are on #SwissGIS?\n', 
       caption=str_c('\n\n@geobeerch, geobeer.github.io/geobeer-analytics\n\n',
                     'Based on www.twitter.com/rastrau/lists/swissgis.'),
       x='\n',
       y='\nNumber of accounts')
ggsave(here('Results', 'SwissGIS-gender-balance--absolute.png'), width=25, 
       height=12, units='cm')

# Stacked bar charts of relative counts of gender (only male/female categories)
ggplot(data_clean, aes(x='', y=percentage, fill=gender)) +
  geom_bar(stat='identity') + 
  scale_fill_manual(values=c('#86D8FC', '#F9D84F')) + 
  theme_geobeer_horbar() +
  coord_flip() +
  theme(legend.position='top') +
  labs(title='Gender balance of the #SwissGIS Twitter list', 
       subtitle='\nWhat are the proportions of female and male Twitter accounts?\n', 
       caption=str_c('\n\n@geobeerch, geobeer.github.io/geobeer-analytics\n\n',
                     'Based on www.twitter.com/rastrau/lists/swissgis.'),
       x='\n',
       y='\nProportion of accounts [%]')
ggsave(here('Results', 'SwissGIS-gender-balance--relative.png'), width=25, 
       height=12, units='cm')

