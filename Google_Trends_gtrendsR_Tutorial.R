#Filename: Google_Trends_gtrendsR_Tutorial.R
#Author: Charlotte Woolley
#'Using Google Trends to explore temporal and geographical patterns in 
#search query data'

#Install and load the gtrendsR package
        install.packages('gtrendsR')
        library(gtrendsR)

#load any other useful packages
        library(ggplot2)
        library(ggmap)
        library(lubridate)
        library(dplyr)

#check out the help file
        ?gtrends
        
#Have a look at the different location codes and categories        
        data("countries")
        head(countries)
        head(subset(countries, countries$country_code =='GB'), 15)
        data("categories")
        head(categories)
        
#Example 1 - Investigate UK searches for 'hangover cure' over the past week

        hangover_cure <- gtrends(keyword = 'hangover cure', geo = 'GB', time = 'now 7-d')
        summary(hangover_cure)
        plot(hangover_cure)
        
        #Extract the 'interest over time' dataframe from the gtrends object
        hangover_cure_iot <- as.data.frame(hangover_cure$interest_over_time)
        
        #group the date into days of the week and sort the levels so that ggplot
        # will understand how to represent it
        hangover_cure_iot <- hangover_cure_iot %>%
                mutate(date = as.Date(date),
                       day = factor(lubridate::wday(ymd(date), label = TRUE),
                                    levels = c('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')))
        
        #boxplot of the number of hits for 'hangover cure' per day
        searches_by_day_boxplot <- ggplot(hangover_cure_iot, aes(x = day, 
                                                               y = hits, group = day)) +
                geom_boxplot() +
                stat_summary(fun.y=mean, colour="red", geom="point", 
                             shape=18, size=3.5) +
                labs(title = "Google searches in Great Britain for 'hangover cure' over the past week", 
                     x = "Day",
                     y = "Search ratio") +
                theme_bw()
        print(searches_by_day_boxplot)
        
        #Extract the 'interest by region' dataframe from the gtrends object
        hangover_cure_ibr <- as.data.frame(hangover_cure$interest_by_region)
        
        #Order the levels in order of decreasing 'hits' so it looks good in the bar chart
        hangover_cure_ibr$location <- factor(hangover_cure_ibr$location, 
                                        levels = hangover_cure_ibr$location[order(
                                                hangover_cure_ibr$hits, decreasing = TRUE)])
        
        #bar chart of the number of hits for 'hangover cure' per region
        hangover_cure_over_region <- ggplot(hangover_cure_ibr, aes(x=location, 
                                                   y = hits)) +
                geom_bar(stat='identity', fill = c('blue','red', 'gold', 'green')) +
                labs(title = "Google searches in Great Britain for 'hangover cure' over the last week", 
                     x = "Region",
                     y = "Search index") +
                scale_y_continuous(breaks=c(seq(from=0, to=100, by=10))) +
                theme_bw()
        print(hangover_cure_over_region)
        
        
# Example 2 - Investigate UK searches for the term 'emigrate' over the last 5 years

        emigrate <- gtrends(keyword = 'emigrate', geo = 'GB', time = 'today+5-y')
        summary(emigrate)
        plot(emigrate)
        
        #extract the dataframes from the gtrends object
        emigrate_iot <- as.data.frame(emigrate$interest_over_time)
        emigrate_ibr <- as.data.frame(emigrate$interest_by_region)
        emigrate_ibc <- as.data.frame(emigrate$interest_by_city)
        emigrate_rt <- as.data.frame(emigrate$related_topics)
        emigrate_rq <- as.data.frame(emigrate$related_queries)
        
        #visualise interest over time
        emigrate_iot$date <- as.Date(emigrate_iot$date)
        emigrate_over_time <- ggplot(emigrate_iot, aes(x=date, y = hits)) +
                geom_line() +
                labs(title = "Google searches in Great Britain for 'emigrate' over the last 5 years", 
                     x = "Year",
                     y = "Search index") +
                scale_y_continuous(breaks=c(seq(from=0, to=100, by=10))) +
                scale_x_date(date_breaks="1 year", date_labels = "%Y") +
                theme_bw()
        print(emigrate_over_time)
        
        #Is there any real difference in searches for emigrate before and after
        #brexit?
        #Brexit was 23rd of June 2016 week starting 2016-06-2018. Assign the data
        #a 'before' or 'after'Brexit status using ifelse. 
        emigrate_iot$time_period <- factor(ifelse(emigrate_iot$date < "2016-06-18", 'Before Brexit', 'After Brexit'), 
                                           levels = c('Before Brexit', 'After Brexit'))
        
        #Visualise the difference in search index before and after Brexit
        brexit_boxplot <- ggplot(emigrate_iot, aes(x = time_period, y = hits, group = time_period)) +
                geom_boxplot() +
                stat_summary(fun.y=mean, colour="red", geom="point", 
                             shape=18, size=3.5) +
                labs(title = "Google searches in the UK in the last 5 years for 'emigrate' before and after Brexit", 
                     x = "Time Period",
                     y = "Search ratio") +
                theme_bw()
        print(brexit_boxplot)
        
        #visualise interest over region (Scotland, Wales, NI, England)
        emigrate_ibr$location <- factor(emigrate_ibr$location, 
                                levels = emigrate_ibr$location[order(
                                        emigrate_ibr$hits, decreasing = TRUE)])
        emigrate_over_region <- ggplot(emigrate_ibr, aes(x=location, y = hits)) +
                geom_bar(stat='identity') +
                labs(title = "Google searches in Great Britain for 'emigrate' over the last 5 years", 
                     x = "Region",
                     y = "Search index") +
                scale_y_continuous(breaks=c(seq(from=0, to=100, by=10))) +
                theme_bw()
        print(emigrate_over_region)
        
        #visualise interest over city (top 20 cities/towns with highest interest)
        emigrate_ibc$location <- factor(emigrate_ibc$location, 
                                        levels = emigrate_ibc$location[order(
                                                emigrate_ibc$hits, decreasing = TRUE)])
        emigrate_over_city <- ggplot(emigrate_ibc, aes(x=location, y = hits)) +
                geom_bar(stat='identity') +
                labs(title = "Google searches in Great Britain for 'emigrate' over the last 5 years", 
                     x = "City",
                     y = "Search index") +
                scale_y_continuous(breaks=c(seq(from=0, to=100, by=10))) +
                theme_bw() +
                theme(axis.text.x=element_text(angle=90,hjust=1))
        print(emigrate_over_city)
        
        #Separate 'top' queries from 'rising' queries and order for ggplot
        top_queries <- subset(emigrate_rq, emigrate_rq$related_queries == 'top')
        top_queries$subject <- as.numeric(top_queries$subject)
        top_queries$value <- factor(top_queries$value, 
                                        levels = top_queries$value[order(
                                                top_queries$subject, decreasing = TRUE)])
        
        #visualise related queries (top 25 related queries)
        emigrate_related_queries <- ggplot(top_queries, aes(x=value, y = subject)) +
                geom_bar(stat='identity') +
                labs(title = "Top related Google queries to 'emigrate' in the UK over the last 5 years", 
                     x = "Related queries",
                     y = "Search index") +
                scale_y_continuous(breaks=c(seq(from=0, to=100, by=10))) +
                theme_bw() +
                theme(axis.text.x=element_text(angle=90,hjust=1))
        print(emigrate_related_queries)
        
        #Separate 'top' topics from 'rising' topics and order for ggplot
        top_topics <- subset(emigrate_rt, emigrate_rt$related_topics == 'top' &
                                     subject > 0)
        top_topics$subject <- as.numeric(top_topics$subject)
        top_topics$value <- factor(top_topics$value, 
                                    levels = top_topics$value[order(
                                            top_topics$subject, decreasing = TRUE)])
        
        #visualise related topics (top 25 related topics)
        emigrate_related_topics <- ggplot(top_topics, aes(x=value, y = subject)) +
                geom_bar(stat='identity') +
                labs(title = "Top related Google topics to 'emigrate' in the UK over the last 5 years", 
                     x = "Related topics",
                     y = "Search index") +
                scale_y_continuous(breaks=c(seq(from=0, to=100, by=10))) +
                theme_bw() +
                theme(axis.text.x=element_text(angle=90,hjust=1))
        print(emigrate_related_topics)
        
#Example 3 - Investigate searches for 'hay fever' in the UK since Google Trends began
        
        hay_fever <- gtrends(keyword = 'hay fever', geo = 'GB', time = 'all')
        summary(hay_fever)
        
        #extract 'interest over time' dataframe from the gtrends object
        hay_fever_iot <- as.data.frame(hay_fever$interest_over_time)

        #visualise interest over time
        hay_fever_over_time <- ggplot(hay_fever_iot, aes(x=date, y = hits)) +
                geom_line() +
                labs(title = "Google searches in Great Britain for 'hay_fever' since 2004", 
                     x = "Year",
                     y = "Search index") +
                scale_y_continuous(breaks=c(seq(from=0, to=100, by=10))) +
                scale_x_date(date_breaks="1 year", date_labels = "%Y") +
                theme_bw() +
                theme(axis.text.x=element_text(angle=90,hjust=1))
        print(hay_fever_over_time)

        #group the data into months
        hay_fever_iot <- hay_fever_iot %>%
                mutate(month = lubridate::month(ymd(date), label = TRUE, abbr = FALSE))
        
        #visualise interest by month
        searches_by_month_boxplot <- ggplot(hay_fever_iot, aes(x = month, 
                                                          y = hits, group = month)) +
                geom_boxplot() +
                stat_summary(fun.y=mean, colour="red", geom="point", 
                             shape=18, size=3.5) +
                labs(title = "Google searches in Great Britain for 'hay fever' by month", 
                     x = "Month",
                     y = "Hits") +
                theme_bw() +
                theme(axis.text.x=element_text(angle=90,hjust=1))
        print(searches_by_month_boxplot)
        
# Example 4 - Investigate interest in 'fake news' in different countries

        fake_news <- gtrends(keyword = 'fake news', time = 'all')
        summary(fake_news)
        
        #extract the 'interest over time' dataframe from the gtrends object and plot
        fake_news_iot <- as.data.frame(fake_news$interest_over_time)
        fake_news_over_time <- ggplot(fake_news_iot, aes(x=date, y = hits)) +
                geom_line() +
                labs(title = "Worldwide Google searches for 'fake news' since 2004", 
                     x = "Year",
                     y = "Search index") +
                scale_y_continuous(breaks=c(seq(from=0, to=100, by=10))) +
                scale_x_date(date_breaks="1 year", date_labels = "%Y") +
                theme_bw() +
                theme(axis.text.x=element_text(angle=90,hjust=1))
        print(fake_news_over_time)
        
        #extract the 'interest by region' dataframe from the gtrends object and
        #order for ggplot
        fake_news_ibr <- as.data.frame(fake_news$interest_by_region)
        fake_news_ibr$location <- factor(fake_news_ibr$location, 
                                        levels = fake_news_ibr$location[order(
                                                fake_news_ibr$hits, decreasing = TRUE)])
        
        #visualise interest by region
        fake_news_over_region <- ggplot(fake_news_ibr, aes(x=location, y = hits)) +
                geom_bar(stat='identity') +
                labs(title = "Google searches for 'fake_news' worldwide", 
                     x = "Region",
                     y = "Search index") +
                scale_y_continuous(breaks=c(seq(from=0, to=100, by=10))) +
                theme_bw() +
                theme(axis.text.x=element_text(angle=90,hjust=1))
        print(fake_news_over_region)
        
        #reclassify some of the google trends 'regions' to match those in ggmap
        fake_news_ibr$region <- ifelse(fake_news_ibr$location == 'United States','USA', 
                                       ifelse(fake_news_ibr$location == 'United Kingdom', 'UK', 
                                              ifelse(fake_news_ibr$location == 'Czechia', 'Czech Republic', 
                                                     as.character(fake_news_ibr$location))))
        
        #Extract world map information and join it to the google trends data
        new_map <- full_join(map_data("world"), fake_news_ibr)
        
        #Create a new column that groups the 'hits' into categories of 20 and
        #assigns country with no information from google trends to a 'no data' group
        new_map$search_index <- factor(ifelse(is.na(new_map$hits), 'no data', ifelse(
                                new_map$hits < 20, '< 20', ifelse(
                                new_map$hits >= 20 & new_map$hits < 40, '20 - 39', ifelse(
                                new_map$hits >= 40 & new_map$hits < 60, '40 - 59', ifelse(
                                new_map$hits >= 60 & new_map$hits < 80, '60 - 79', ifelse(
                                new_map$hits >= 80, '> 80', new_map$hits)))))), 
                                levels = c('> 80', '60 - 79', '40 - 59', '20 - 39', '< 20', 'no data'))
        
        #Visualise interest by region on a map
        ggplot(new_map, aes(x=long, y=lat, group=group, fill=search_index)) + 
                geom_polygon(colour="black", show.legend = T) +
                scale_fill_manual(values= alpha(c("darkred", "orangered3", 
                                                  "orange2", "yellow1", "khaki1", "grey50"), 0.5)) +
                labs(title = "Google searches for 'fake news' worldwide since 2004", 
                     x = "Longitude",
                     y = "Latitude") +
                theme_bw()
       
        
