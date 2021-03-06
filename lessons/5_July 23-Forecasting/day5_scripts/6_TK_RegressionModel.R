#' Author: Ted Kwartler
#' Data: 6-6-2018
#' Purpose: Simple regression forecasting example

# WD
setwd("~/HarvardSummerStudent2018/lessons/5_July 23-Forecasting/day5_data")

# Libraries
library(forecast)

# Data Input
cvsRev <- read.csv('CVSrevenue.csv')

# Time formatting
cvsRev$date <- as.POSIXct(cvsRev$unixTime, origin = '1970-1-1')

# Change to a time series
stYr <- year(cvsRev$date[1])
stQtr <- quarter(cvsRev$date[1])
st<- c(stYr, stQtr)
qtrTS <- ts(cvsRev$revMill, start = st, frequency = 4)

# Add quarterly dummies, takes care of dropping a season
quarts <- seasonaldummy(qtrTS)
head(quarts,10)

# Trend can be captured just by an index
trendIdx <- seq_along(cvsRev$revMill)

# Add an event; CVS bought Caremark
acquisition <- c(rep(0,76),rep(1,120-76))

# Organize
modelDF <- as.data.frame(cbind(y = log(cvsRev$revMill),
                                trend =trendIdx,
                                quarts, 
                                acquisitionFlag = acquisition))
fit <-lm(y ~., modelDF)
summary(fit)

# Viz
pred <- exp(predict(fit))
plot(pred, col='blue')
lines(pred, col='blue')
lines(cvsRev$revMill, col='red')

# Make a prediction
newQtr <- data.frame(trend =(max(trendIdx)+1),
                     Q1 = 0 ,
                     Q2 = 1, 
                     Q3 = 0,
                     acquisitionFlag = 1)

logPred <- predict(fit, newQtr)
exp(logPred)

# plot it
points(max(trendIdx)+1, exp(logPred), pch =15)

# End
