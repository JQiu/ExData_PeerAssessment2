NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

library(plyr)

## join NEI and SCC by SCC
joinedData <- join(NEI, SCC, by = "SCC")

## get data for baltimore city
baltimoreData <- subset(joinedData, fips == "24510")

## split by type to look at more closely
baltimoreRoad <- subset(baltimoreData, type == "ON-ROAD")
baltimoreNonRoad <- subset(baltimoreData, type == "NON-ROAD")
baltimorePoint <- subset(baltimoreData, type == "POINT")
baltimoreNonPoint <- subset(baltimoreData, type == "NONPOINT")

## examining Short.Name, SCC.Level.One - SCC.Level.Four
## motor vehicles will be a combination of ON-ROAD and NON-ROAD types
## all ON-ROAD type are motor vehicles

## most off road vehicles can be identified by checking SCC.Level.Two by search
## of "vehicle"
nonRoadVehicles <- baltimoreNonRoad[grep("vehicle", baltimoreNonRoad$SCC.Level.Two, ignore.case = T), ]

## other off road vehicles may be classified under LPG or CNG
## these may include sweepers, scrubbers, lifts, mowers, ec.
offRoad = "sweeper|scrubber|lift|tractor|blower|cart|mower"

nonRoadLPG <- baltimoreNonRoad[grep("lpg|cng", baltimoreNonRoad$SCC.Level.Two, ignore.case = T), ]
nonRoadLPGVehicles <- nonRoadLPG[grep(offRoad, nonRoadLPG$SCC.Level.Four, ignore.case = T), ]

## combine the non road vehicles
nonRoadVehicles <- rbind(nonRoadVehicles, nonRoadLPGVehicles)

baltimoreVehicles <- rbind(baltimoreRoad, nonRoadVehicles)

## sum the emissions by year
totalEmissions <- ddply(baltimoreVehicles, .(year), numcolwise(sum))

png(filename = "plot5.png", width = 480, height = 480, units = "px")

## reset global mfrow
par(mfrow = c(1, 1))

## plot total emissions by year
with(totalEmissions, plot(year, Emissions, type = "n", main = "Baltimore City Motor Vehicle Emissions by Year (1999-2008)", xlab = "Year", ylab = "Emissions (tons)"))
with(totalEmissions, lines(year, Emissions))
with(totalEmissions, axis(1, year[1]:tail(year, 1)))

dev.off()