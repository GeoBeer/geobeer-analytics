# Ticketing process

## Background and rationale
GeoBeer events are free of charge to participants. Each event sponsor defines their own ticket quota. The ticket quota is often depleted within a relatively short timeframe. Based on event registration data from the [Ti.to](http://ti.to)-platform, we analysed the time it takes until 50% of the allocated tickets are gone. We analyse this timeframe rather than the time it takes until all tickets are gone for two reasons: 1) Local organisers sometimes re-up the ticket quota during the registration process. We can't systematically track this. 2) A certain proportion of all ticket holders cancel. When this happens we offer the ticket to the next person on the waiting list. When this person registers for the ticket (sometimes only days or even hours ahead of the event), this timestamp goes into our ticketing data. Both these issues would affect the complete analysis in a way that would strongly overestimate the time until tickets are gone.

## Results
![Ticket registration times per event](https://github.com/GeoBeer/geobeer-analytics/blob/master/Results/GeoBeer-ticket-registration-times--per-event.png)

## Analysis
This analysis was done using the R-script [1-visualize-ticket-registrations.R](https://github.com/GeoBeer/geobeer-analytics/blob/master/1-visualize-ticket-registrations.R). It is compatible with data exported from [Ti.to](http://ti.to). If you want to analyse several events simply aggregate the Ti.to data by concatenating records from your CSV files into a single file.

&larr; [Back to the main page](index.md)