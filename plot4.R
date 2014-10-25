NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

library(plyr)

## extract SCC for coal combustion sources by looking at EI.Sector
coalMatch <- grep("Coal", SCC$EI.Sector, ignore.case = T)
coalSCC <- SCC$SCC[coalMatch]

## get the emissions from NEI that match coalSCC
coalNEI <- NEI[match(coalSCC, NEI$SCC, nomatch = 0),]

## sum the emissions by year
totalEmissions <- ddply(coalNEI, .(year), numcolwise(sum))

png(filename = "plot4.png", width = 480, height = 480, units = "px")

## reset global mfrow
par(mfrow = c(1, 1))

## plot total emissions by year
with(totalEmissions, plot(year, Emissions, type = "n", main = "US Coal Combustion Source Emissions by Year (1999-2008)", xlab = "Year", ylab = "Emissions (tons)"))
with(totalEmissions, lines(year, Emissions))
with(totalEmissions, axis(1, year[1]:tail(year, 1)))

dev.off()