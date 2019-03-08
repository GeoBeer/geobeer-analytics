# Gender balance of our audience

## Background and rationale
Based on event registration data from [Eventbrite](http://www.eventbrite.com) (old) and the [Ti.to](http://ti.to) (current) platform, we analysed the gender of audience members by looking at the first names they gave for registering to GeoBeer events. Specifically, we analysed (in sequential order, if the previous approaches haven't yielded a result): 

- first names 
- a small fraction of &laquo;last names&raquo; when people may have entered their first name in the wrong form field 
- a small fraction of parts of e-mail addresses

Lastly, we manually classified a few names that wouldn't yield results otherwise.

Several disclaimers are in order as there are simplifications, inherent shortcomings, and potential pitfalls with this type of analysis:

- The analysis relies on functionality provided by the R package `gender` (and its supplementary package `genderdata`) ([link to documentation](https://cran.r-project.org/web/packages/gender)). 
- Gender classification in `gender`is based on historical data from the U.S. Social Security Administration birth record data. As such, the classification will have certain biases, e.g. when classifying first names which may have different typically associated genders in different cultures.
- Of course, besides people who identify as gender-binary there are non-binary (or genderqueer) persons. Further, some cultures know more than two genders. Unfortunately, data-driven analyses cannot adequately capture all gender categories.
- For classifying gender based on first name using `gender`, a range of birth years has to be supplied. As we do not capture any such information from our audience members, we used the timeframe between 1950 and 2000. This may be representative of our audience, or not.

## Results

[![GeoBeer audience gender balance](https://raw.githubusercontent.com/GeoBeer/geobeer-analytics/master/Results/GeoBeer-gender-balance--relative--per-event.png)](https://raw.githubusercontent.com/GeoBeer/geobeer-analytics/master/Results/GeoBeer-gender-balance--relative--per-event.png)

[![Gender balance of various GIS-related entities](https://raw.githubusercontent.com/GeoBeer/geobeer-analytics/master/Results/Gender-balances--relative.png)](https://raw.githubusercontent.com/GeoBeer/geobeer-analytics/master/Results/Gender-balances--relative.png)

[![Size of GeoBeer events and audience gender balance](https://raw.githubusercontent.com/GeoBeer/geobeer-analytics/master/Results/GeoBeer-gender-balance--absolute--per-event.png)](https://raw.githubusercontent.com/GeoBeer/geobeer-analytics/master/Results/GeoBeer-gender-balance--absolute--per-event.png)

[![Size of GeoBeer events and audience gender balance](https://raw.githubusercontent.com/GeoBeer/geobeer-analytics/master/Results/GeoBeer-gender-balance-vs-size--per-event.png)](https://raw.githubusercontent.com/GeoBeer/geobeer-analytics/master/Results/GeoBeer-gender-balance-vs-size--per-event.png)

[![Geobeer audience gender balance](https://raw.githubusercontent.com/GeoBeer/geobeer-analytics/master/Results/GeoBeer-gender-balance--relative--left-right--per-event.png)](https://raw.githubusercontent.com/GeoBeer/geobeer-analytics/master/Results/GeoBeer-gender-balance--relative--left-right--per-event.png)

[![Treemap of GeoBeer audience gender balance](https://raw.githubusercontent.com/GeoBeer/geobeer-analytics/master/Results/GeoBeer-gender-balance--per-event--treemap.png)](https://raw.githubusercontent.com/GeoBeer/geobeer-analytics/master/Results/GeoBeer-gender-balance--per-event--treemap.png)

## Analysis
The data processing for these visualisations was done using the following R-scripts:
[0-process-eventbrite-data.R](https://github.com/GeoBeer/geobeer-analytics/blob/master/0-process-eventbrite-data.R)
[0-process-tito-data.R](https://github.com/GeoBeer/geobeer-analytics/blob/master/0-process-tito-data.R)
[0-process-swissgis-data.R](https://github.com/GeoBeer/geobeer-analytics/blob/master/0-process-swissgis-data.R)
[0-process-geowebforum-data.R](https://github.com/GeoBeer/geobeer-analytics/blob/master/0-process-geowebforum-data.R)

geowebforum.ch data was obtained using the [geowebforum-scraper](https://github.com/rastrau/geowebforum-scraper) by [Ralph](https://www.twitter.com/rastrau).

The visualisations themselves were made using the following R-scripts:

- [1-visualize-geobeer-gender-distribution.R](https://github.com/GeoBeer/geobeer-analytics/blob/master/1-visualize-geobeer-gender-distribution.R)
- [1-visualize-gender-distributions.R](https://github.com/GeoBeer/geobeer-analytics/blob/master/1-visualize-gender-distributions.R)
- [1-visualize-swissgis-gender-distribution.R](https://github.com/GeoBeer/geobeer-analytics/blob/master/1-visualize-swissgis-gender-distribution.R)

&larr; [Back to the main page](index.md)

&rarr; Look at [our analysis of the event locations](locations.md)

&rarr; Look at [our analysis of the ticketing process](ticketing.md)

&rarr; Look at [our analysis of the speaker gender balance](gender-balance-speakers.md)

