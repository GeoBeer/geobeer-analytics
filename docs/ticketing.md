# Ticketing process

## Background and rationale
GeoBeer events are free of charge to participants. Each event sponsor defines their own ticket quota. The ticket quota is often depleted within a relatively short timeframe.

Based on event registration data from the [Ti.to](http://ti.to)-platform, we analysed the time it takes until 50% of the allocated tickets are gone. We analyse this timeframe rather than the time it takes until all tickets are gone for two reasons: 

- Local organisers sometimes re-up the ticket quota when it's, nearly or completely, depleted. We can't systematically track when this occurs with reasonable effort. 

- A certain proportion of ticket holders cancel. When this happens, we offer the respective ticket to the next person on the waiting list. When this person registers for the ticket (sometimes only days or even hours ahead of the event), that timestamp goes into our ticketing data. 

Both these issues would affect the complete analysis in a way that would strongly overestimate the time until tickets are gone.

## Results
[![Ticket registration times per event](https://github.com/GeoBeer/geobeer-analytics/raw/master/Results/GeoBeer-ticket-registration-times--per-event.png)](https://github.com/GeoBeer/geobeer-analytics/raw/master/Results/GeoBeer-ticket-registration-times--per-event.png)

## Analysis
This analysis was done using the R-script [1-visualize-ticket-registrations.R](https://github.com/GeoBeer/geobeer-analytics/blob/master/1-visualize-ticket-registrations.R). It is compatible with data exported from [Ti.to](http://ti.to) (but shouldn't be too complicated to adapt for other ticketing platforms as long as they provide a timestamp when a ticket was issued). If, like us, you want to analyse several events at once, aggregate the Ti.to data by concatenating records from your per-event CSV files into just one aggregate file before running the analysis.

&larr; [Back to the main page](index.md)

&rarr; Look at [our analysis of the event locations](locations.md)

&rarr; Look at [our analysis of the audience gender balance](gender-balance-audience.md)

&rarr; Look at [our analysis of the speaker gender balance](gender-balance-speakers.md)

