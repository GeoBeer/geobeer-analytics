# ----------------------------------------------------------------------------------------
# Authors:      GeoBeer Team, @geobeer_ch
# Created:      2019-03
# License:      GNU General Public License v3.0
# Repository:   https://github.com/GeoBeer/geobeer-analytics
# More info:    https://geobeer.github.io/geobeer-analytics, http://www.geobeer.ch
# ----------------------------------------------------------------------------------------


if (!require(here)) {
  install.packages("here")
  require(here)
}
if (!require(tidyverse)) {
  install.packages("tidyverse")
  require(tidyverse)
}
if (!require(magrittr)) {
  install.packages("magrittr")
  require(magrittr)
}
if (!require(readr)) {
  install.packages("readr")
  require(readr)
}
if (!require(stringr)) {
  install.packages("stringr")
  require(stringr)
}


# Ingest data ------------------------------------------------------------------

data <- read_csv(here("..", "geobeer-private-data", "GeoBeer-Speakers.csv"))

# Do some minor data enrichment and restructuring ------------------------------

data %<>%
  filter(!is.na(gender)) %>%
  select(event, gender)

# Analyse gender by event and save to disk
gender_stats_data <- data %>%
  group_by(event, gender) %>%
  summarise(count = n()) %>%
  mutate(percentage = count / sum(count) * 100)

write_csv(gender_stats_data, here("Results", "geobeer-speakers-gender-stats.csv"))


aggregated_data <- data %>%
  group_by(gender) %>%
  summarise(count = n()) %>%
  mutate(percentage = count / sum(count) * 100)


female_percentage <- aggregated_data %>%
  filter(gender == "female") %>%
  select(percentage)

male_percentage <- aggregated_data %>%
  filter(gender == "male") %>%
  select(percentage)

female_percentage <- round(female_percentage[[1]], 0)
male_percentage <- round(male_percentage[[1]], 0)

text <- "# Gender balance of our speakers

## Background and rationale
With GeoBeer, we want that everybody with an interest &laquo;geo&raquo; feels welcome at our events. Specifically, [our manifesto](http://geobeer.ch/manifesto.html) declares: 
- *&laquo;Networking is inclusive: Everybody adds value.&raquo;* and 
- *&laquo;We (...) welcome everybody: all genders, creeds and colours, citizen or expat, speaking French, Italian, German, Romansh, English, Python, C# or Javascript.&raquo;*. 

We want to make GeoBeer events better events by holding up these principles (and the remaining [principles of the manifesto](http://geobeer.ch/manifesto.html)). 

Against this background, we sometimes discuss questions of openness, representation, and diversity within our team and with some of our sponsors, organisers, and audience members. Questions of representation pertain to many characteristics of humans, of course. For example, age, nationality, gender, path of education, language, sexual orientation, race, and many more. Here, we derive some data on representation by looking at gender balance of the GeoBeer speakers to date. 

We used to not have any written restrictions or preferences regarding speakers at our events. As we have grown more and more aware (and concerned) about the afore-mentioned topics, we have included a clause in our dossier for local organisers that stipulates (but doesn't enforce) more representation of women. 

If you want to know more, please read about our reasoning about diversity and gender on our page about the [gender balance of our audience](gender-balance-audience.md).

## Results
In GeoBeers #1 (in 2013) through #"

footer <- "&larr; [Back to the main page](index.md)

&rarr; Look at [our analysis of the event locations](locations.md)

&rarr; Look at [our analysis of the ticketing process](ticketing.md)

&rarr; Look at [our analysis of the audience gender balance](gender-balance-audience.md)"

max_geobeer <- max(as.numeric(str_replace(data$event, "GeoBeer #", "")))

cat(text, file = here("docs", "gender-balance-speakers.md"))
cat(max_geobeer, file = here("docs", "gender-balance-speakers.md"), append = TRUE)
cat(", we have had a total of ", file = here("docs", "gender-balance-speakers.md"), append = TRUE)
cat(sum(aggregated_data$count), file = here("docs", "gender-balance-speakers.md"), append = TRUE)
cat(" talks (including technical contributions such as demos, but excluding welcome notes). Out of these talks, ", file = here("docs", "gender-balance-speakers.md"), append = TRUE)
cat(aggregated_data$count[aggregated_data$gender == "female"], file = here("docs", "gender-balance-speakers.md"), append = TRUE)
cat(" were held by women and ", file = here("docs", "gender-balance-speakers.md"), append = TRUE)
cat(aggregated_data$count[aggregated_data$gender == "male"], file = here("docs", "gender-balance-speakers.md"), append = TRUE)
cat(" were held by men. This puts the gender balance at ", file = here("docs", "gender-balance-speakers.md"), append = TRUE)
cat(female_percentage, file = here("docs", "gender-balance-speakers.md"), append = TRUE)
cat("% presentations by women and ", file = here("docs", "gender-balance-speakers.md"), append = TRUE)
cat(male_percentage, file = here("docs", "gender-balance-speakers.md"), append = TRUE)
cat("% by men.\n\n", file = here("docs", "gender-balance-speakers.md"), append = TRUE)
cat(footer, file = here("docs", "gender-balance-speakers.md"), append = TRUE)

