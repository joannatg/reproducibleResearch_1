getwd()

install.packages("tidyverse")
##install.packages("rlang") 
install.packages("ggplot2")
install.packages("mice")
install.packages("timeDate")
library(dplyr)
library(mice)
library(timeDate)
library(ggplot2)


# Load Data
setwd("C:\\Users\\Joanna\\Desktop\\R_coursera\\5_2_2\\")
path <- getwd()
path
url <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
download.file(url, file.path(path, "data.zip"))
unzip("data.zip")

## Remove NAs
d <- read.csv("activity.csv", header = TRUE,  na.strings = c(" ",NA))
na.omit(d)

##na.omit(head(d %>% group_by(date) %>% summarise(totalSteps = sum(steps)), 20))
avg <- na.omit(d %>% group_by(date) %>% summarise(totalSteps = sum(steps)))
avg


## Histogram of steps
qplot(avg$totalSteps, geom="histogram",
      main = "Histogram of total number of steps taken", 
      xlab = "Steps", 
      ylab="Frequency",
      fill=I("yellow"), 
      col=I("red"))

##Mean and median number of steps 
summary(avg)

##Mean and median number of steps 
##na.omit(d %>% group_by(date) %>% summarise(means = mean(steps), median= median(steps)))

## Time series plot of the average number of steps taken
s <- na.omit(d %>% group_by(date) %>% summarise(avgSteps = mean(steps)))
s

ggplot(s, aes(date, avgSteps)) + geom_point(na.rm=TRUE, color="blue", size=2) + 
  theme(axis.text.x = element_text(angle=90))

## 5-min interval with max # of steps
d <- read.csv("activity.csv", header = TRUE,  na.strings = c(" ",NA))
na.omit(d)

groupedByInterval <-na.omit(d %>% group_by(interval)) %>% summarise(totSteps = sum(steps))
head(arrange(groupedByInterval, -totSteps),1)


##Imputing missing values   REMOVE LINK !!https://datascienceplus.com/handling-missing-data-with-mice-package-a-simple-approach/
d <- read.csv("activity.csv", header = TRUE,  na.strings = c(" ",NA))
sapply(d, function(x) sum(is.na(x)))
## structure
str(d)
##missing data patterns
md.pattern(d)

## impute (using CART)
tempData <- mice(d, m=1, method='cart', printFlag=FALSE)

summary(tempData)
cleanData <- complete(tempData,1)
cleanData
summary(cleanData)
##check missing data pattern
md.pattern(cleanData)


## Histogram of steps (data with no missing values) 
qplot(cleanData$steps, geom="histogram",
      binwidth = 50,
      main = "Histogram of total number of steps taken", 
      xlab = "Steps", 
      ylab="Frequency",
      fill=I("red"), 
      col=I("blue"))


## Panel plot avg. steps taken per 5-minute interval across weekdays vs weekends
isWeekday("2012-10-01")

d <- read.csv("activity.csv", header = TRUE,  na.strings = c(" ",NA))
na.omit(d)

d$days <- ifelse(isWeekday(d$date) == TRUE, 1, 0)
d
summary(d)

weekday <-d %>% filter(!is.na(steps)) %>% filter (days==1)
weekday
weekdayAvg <-na.omit(weekday %>% group_by(interval)) %>% summarise(totSteps = sum(steps))
weekdayAvg
weekend <- d %>% filter(!is.na(steps)) %>% filter (days==0)
weekendAvg <-na.omit(weekend %>% group_by(interval)) %>% summarise(totSteps = sum(steps))
summary(weekdayAvg)


##R base
plot(weekdayAvg$interval, weekdayAvg$totSteps, xlab="5-min Intervals", ylab="AvgSteps", type="l",
     main="Avgerage number of steps over 5-minute interval, weekdays vs. weekends",  col="red",
     ylim=range(c(weekdayAvg$totSteps,weekendAvg$totSteps)))
par(new=TRUE)
plot(weekendAvg$interval, weekendAvg$totSteps,  xlab = "", ylab = "", type="l",  col="green", 
     ylim=range(c(weekdayAvg$totSteps,weekendAvg$totSteps)))


##ggplot2
ggplot() + 
  geom_line(data = weekdayAvg,  aes(x = interval, y = totSteps), color = "red") + 
  geom_line(data = weekendAvg,  aes(x = interval, y = totSteps), color = "blue") +
  labs(title="Histogram of avgerage number of steps over 5-minute interval, weekdays (red) vs. weekends (blue)")+
  xlab('5-min Intervals') +
  ylab('Avg. Steps')


