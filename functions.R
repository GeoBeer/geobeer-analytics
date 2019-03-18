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


# https://ggplot2.tidyverse.org/reference/theme.html
theme_geobeer <- function() {
  theme_minimal() +
    theme(
      text = element_text(color = "#22211d"),
      plot.title = element_text(lineheight=1, size = rel(2.1), face='bold'),
      plot.subtitle = element_text(size = rel(1.2), lineheight=1),
      plot.caption = element_text(size = rel(0.7)),
      plot.background = element_rect(fill = '#FAFAFA', colour=NA),
      legend.position = 'top',
      plot.margin = margin(10, 5, 5, 5, 'mm'))
}

theme_geobeer_horbar <- function() {
  theme_geobeer() +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      axis.text.y = element_text(size = rel(1.3), colour='black'),
      axis.title.x = element_text(size = rel(1.1)))
}

theme_geobeer_verbar <- function() {
  theme_geobeer() +
    theme(
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank())
      #,
      #axis.text.y = element_text(size = rel(1.3), colour='black'),
      #axis.title.x = element_text(size = rel(1.1)))
}

legend_theme <- guide_legend(
  nrow = 1,
  reverse = T,
  direction = "horizontal",
  keyheight = unit(5, units = "mm"),
  keywidth = unit(12, units = "mm"),
  title.position = "left",
  title.hjust = 0.5,
  title.vjust = 0.85,
  label.hjust = 0.5,
  byrow = T,
  label.position = "bottom"
)


classify_additional_names <- function(df) {
  # Load csv file with additional (unknown and manually added) names. For
  # convenience (since this list will be occasionally manually updated), we 
  # sort the list alphabetically and write it back to the file. This way, names
  # will always be in alphabetical order, no matter what, thus facilitating
  # updating the list in the future.
  additional_names <- read_csv(file = here('..', 'geobeer-private-data', 'Auxiliary-Data',
                                           'Additional-names.csv')) %>%
    arrange(firstname)
  write_csv(additional_names, here('..', 'geobeer-private-data', 'Auxiliary-Data', 
                                   'Additional-names.csv'))
  
  # Next, create a lower case version of the firstname and remove the firstname
  # variable
  additional_names %<>%
    mutate(lower_firstname=str_to_lower(firstname)) %>%
    select(-firstname)
  
  df_classified <- df %>%
    filter(!is.na(gender))
  
  # Filter out yet-unclassified records and add gender information from 
  # Additional-Names.csv to these
  df_unclassified <- df %>%
    filter(is.na(gender)) %>%
    select(-gender) %>%
    mutate(lower_firstname=str_to_lower(firstname)) %>% 
    left_join(additional_names, by='lower_firstname') %>%
    select(-lower_firstname)
  
  # Combine all data back into one dataframe
  df <- rbind(df_classified, df_unclassified)
  rm(df_classified)
  rm(df_unclassified)

  # Return the dataframe
  df
}
  
  
  