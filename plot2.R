NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

library(plyr)

## sum the emissions by year just for baltimore city (fips == "24510")
baltimoreData <- subset(NEI, fips == "24510")
totalEmissions <- ddply(baltimoreData, .(year), numcolwise(sum))

png(filename = "plot2.png", width = 480, height = 480, units = "px")

## reset global mfrow
par(mfrow = c(1, 1))

## plot total emissions by year
with(totalEmissions, plot(year, Emissions, type = "n", main = "Baltimore City Emissions by Year (1999-2008)", xlab = "Year", ylab = "Emissions (tons)"))
with(totalEmissions, lines(year, Emissions))
with(totalEmissions, axis(1, year[1]:tail(year, 1)))

dev.off()