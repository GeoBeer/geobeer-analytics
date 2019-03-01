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

# Read and combine the (preprocessed) data on Eventbrite events and on Tito 
# events 
data <- read_csv(here('Results', 'geobeer-gender-stats.csv'))

# Do some minor data enrichment and restructuring ------------------------------

# Make <data$gender> a factor. The order of factor levels determines the  
# drawing order in ggplot bar plots (later factor levels are drawn first). 
data$gender <- factor(data$gender, levels=c('male', 'female'))

# Make some alternative (shorter) labelling attrbutes
data$event_short <- str_replace(data$event, 'GeoBeer ', '')
data$event_numeric <- as.numeric(str_replace(data$event, 'GeoBeer #', ''))

# Create a dataframe with the overall data. This is used to find the overall  
# average values.
overall <- data %>%
  group_by(gender) %>%
  summarise (count = sum(count)) %>%
  mutate(event="Overall") %>% 
  group_by(event) %>%
  mutate(percentage = count / sum(count) * 100)
overall <- overall[c('event', 'gender', 'count', 'percentage')]

# str(as.data.frame(data))
# str(as.data.frame(overall))
# data <- rbind(as.data.frame(data), as.data.frame(overall))
# rm(overall)

# Create a dataframe where each record is one event. Used for scatterplots.
female_data <- data %>% 
  filter(gender=='female') %>%
  mutate(female_percentage=percentage) %>%
  select(event, female_percentage)
male_data <- data %>% 
  filter(gender=='male') %>%
  mutate(male_percentage=percentage) %>%
  select(event, male_percentage)
data_per_event <- data %>%
  group_by(event) %>%
  summarise(count=sum(count)) %>%
  inner_join(female_data, by='event') %>%
  inner_join(male_data, by='event')
rm(female_data)
rm(male_data)


# Start plotting data ----------------------------------------------------------

# GeoBeer colors: yellow: #F8C904, light-blue: #86D8FC, dark-blue: #4CA3C3

# Stacked bar charts of absolute counts of gender, per event
ggplot(data, aes(x=event_numeric, y=count, fill=gender)) +
  geom_bar(stat='identity') + 
  scale_fill_manual(values=c('#86D8FC', '#F9D84F')) + 
  theme_geobeer_verbar() +
  theme(legend.position='top') +
  labs(title='Size of GeoBeer events and gender balance', 
       subtitle='\nHow many participants of each gender attended GeoBeer events?\n', 
       caption=str_c('\nbased on ', nrow(data_per_event), ' events'),
       x='\nEvent',
       y='Number of participants\n')
ggsave(here('Results', 'GeoBeer-gender-balance--absolute--per-event.png'), 
       width=25, height=16, units='cm')

# Stacked bar charts of relative counts of gender, per event
ggplot(data, aes(x=event_numeric, y=percentage, fill=gender)) +
  geom_bar(stat='identity') + 
  scale_fill_manual(values=c('#86D8FC', '#F9D84F')) + 
  geom_hline(yintercept=overall$percentage[overall$gender=='female']) +
  theme_geobeer_verbar() +
  theme(legend.position='right') +
  labs(title='Gender balance per GeoBeer event', 
       subtitle='\nWhat were the proportions of female and male participants per GeoBeer event?\n', 
       caption=str_c('\nbased on ', nrow(data_per_event), ' events; the line represents\nthe overall female participation rate'),
       x='\nEvent',
       y='Proportion of participants [%]\n')
ggsave(here('Results', 'GeoBeer-gender-balance--relative--per-event.png'), 
       width=25, height=16, units='cm')

# Make the percentages of female participants negative
# Source: https://stackoverflow.com/questions/14680075/simpler-population-pyramid-in-ggplot2
temp_data <- data
temp_data$percentage[temp_data$gender=='female'] = 
  -temp_data$percentage[temp_data$gender=='female'] 
ggplot(temp_data, aes(x=as.factor(event_numeric), y=percentage, fill=gender)) + 
  geom_bar(stat='identity', data=subset(temp_data, gender=='female')) + 
  geom_bar(stat='identity', data=subset(temp_data, gender=='male')) + 
  scale_y_continuous(breaks=seq(-40,80,20), labels=abs(seq(-40,80,20))) + 
  theme_geobeer_horbar() +
  scale_fill_manual(values=c('#F9D84F', '#86D8FC')) + 
  coord_flip() +
  labs(title='Gender balance per GeoBeer event', 
       subtitle='\nWhat were the proportions of female and male participants per GeoBeer event?\n', 
       caption=str_c('\nbased on ', nrow(data_per_event), ' events'),
       x='Event\n',
       y='\nProportion of participants [%]')
ggsave(here('Results', 'GeoBeer-gender-balance--relative--left-right--per-event.png'), 
       width=25, height=22, units='cm')


# Scatterplot of percentage of female participants versus absolute event size
ggplot(data_per_event, aes(x=count, y=female_percentage)) +
  geom_smooth(method=lm, color='#999999') +
  geom_point(color='#4CA3C3', size=3) + 
  theme_geobeer() +
  labs(title='Size of GeoBeer events and gender balance', 
       subtitle='\nDo bigger GeoBeer events lead to a more balanced gender representation?', 
       caption=str_c('\nbased on ', nrow(data_per_event), ' events'),
       x='\nSize of event (number of participants)',
       y='Proportion of female participants [%]\n')
ggsave(here('Results', 'GeoBeer-gender-balance-vs-size--per-event.png'), 
       width=25, height=18, units='cm')

# Treemap with gender balance per event
ggplot(data_per_event, aes(x=count, y=female_percentage)) +
  geom_smooth(method=lm, color='#999999') +
  geom_point(color='#4CA3C3', size=3) + 
  theme_geobeer() +
  scale_y_continuous(limits=c(0, 100)) +
  labs(title='Size of GeoBeer events and gender balance', 
       subtitle='\nDo bigger GeoBeer events lead to a more balanced gender representation?', 
       caption=str_c('\nbased on ', nrow(data_per_event), ' events'),
       x='\nSize of event (number of participants)',
       y='Proportion of female participants [%]\n')
ggsave(here('Results', 'GeoBeer-gender-balance-vs-size--per-event--complete-canvas.png'), 
       width=25, height=18, units='cm')

if (!require(treemapify)) {
  install.packages('treemapify')
  require(treemapify)
}

ggplot(data, aes(area=count, fill=gender, subgroup=event_short, label=event_short)) +
  geom_treemap() +
  scale_fill_manual(values=c('#86D8FC', '#F9D84F')) + 
  geom_treemap_subgroup_border(color='white', size=10) +
  geom_treemap_subgroup_text(place="centre", grow=T,alpha=0.1, colour="black") +
  theme_geobeer() +
  labs(title='Gender balance per GeoBeer event', 
       subtitle='\nWhat were the proportions of female and male participants per GeoBeer event?\n')
ggsave(here('Results', 'GeoBeer-gender-balance--per-event--treemap.png'), 
       width=25, height=22, units='cm')
