if (!require(lubridate)) {
  install.packages('lubridate')
  require(lubridate)
}
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

data <- read_csv(here('..', 'geobeer-private-data', 'Tito', 'tito-aggregated-data.csv'))

# Do some minor data enrichment and restructuring ------------------------------

data %<>%
  select(timestamp, event)

table(data$event)

# Compute overall registration times
data$datetime = ymd_hms(data$timestamp)
data %>%
  group_by(event) %>%
  summarise(first=min(datetime), last=max(datetime), duration=last-first) %>%
  arrange(duration) -> overall_times

# The overall registration times are not representative of the time it takes to 
# fully book a GeoBeer event, as the overall times also encompass reallocated 
# tickets (i.e., cancelled and re-issued tickets). Thus, next we compute the 
# time until a certain share of the tickets has been booked.
data %<>%
  group_by(event) %>%
  summarise(first_registration = min(datetime), 
            median_registration = quantile(datetime, 0.5), 
            last_registration = max(datetime), 
            duration_median_hours = difftime(median_registration, 
                                             first_registration, 
                                             units='hours')) %>%
  arrange(duration_median_hours) %>%
  mutate(event_short = str_replace(event, 'GeoBeer ', ''),
         event_numeric = as.numeric(str_replace(event, 'GeoBeer #', ''))) %>%
  select(event, event_short, event_numeric, duration_median_hours, 
         first_registration, median_registration, last_registration)


ggplot(data, aes(x=event, y=duration_median_hours)) +
  geom_bar(stat='identity', fill='#4CA3C3') + 
  theme_geobeer_verbar() +
  theme(legend.position='none') +
  theme(axis.text = element_text(size = rel(1.1)),
        axis.title = element_text(size = rel(1.2))) +
  labs(title="Time until half of a GeoBeer’s tickets are gone", 
       subtitle='\nHow many hours does it take until 50% of the tickets are registered? We look at the time until half\nof the tickets are gone, since the complete data contains cancelled and re-issued tickes – something\nwe do right up to the event\n\n', 
       caption='\n\n@geobeerch, geobeer.github.io/geobeer-analytics',
       x='\nEvent',
       y='Hours\n')
ggsave(here('Results', 'GeoBeer-ticket-registration-times--per-event.png'), 
       width=25, height=18, units='cm')

