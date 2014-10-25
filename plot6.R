NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

library(plyr)
library(ggplot2)
library(grid)
library(gridExtra)

## join NEI and SCC by SCC
joinedData <- join(NEI, SCC, by = "SCC")

## code from plot5.R refactored to function
motorvehicles <- function(x, f) {
  cityData <- subset(x, fips == f)
  
  ## split by type to look at more closely
  cityRoad <- subset(cityData, type == "ON-ROAD")
  cityNonRoad <- subset(cityData, type == "NON-ROAD")
  cityPoint <- subset(cityData, type == "POINT")
  cityNonPoint <- subset(cityData, type == "NONPOINT")
  
  ## examining Short.Name, SCC.Level.One - SCC.Level.Four
  ## motor vehicles will be a combination of ON-ROAD and NON-ROAD types
  ## all ON-ROAD type are motor vehicles
  
  ## most off road vehicles can be identified by checking SCC.Level.Two by search
  ## of "vehicle"
  nonRoadVehicles <- cityNonRoad[grep("vehicle", cityNonRoad$SCC.Level.Two, ignore.case = T), ]
  
  ## other off road vehicles may be classified under LPG or CNG
  ## these may include sweepers, scrubbers, lifts, mowers, ec.
  offRoad = "sweeper|scrubber|lift|tractor|blower|cart|mower"
  
  nonRoadLPG <- cityNonRoad[grep("lpg|cng", cityNonRoad$SCC.Level.Two, ignore.case = T), ]
  nonRoadLPGVehicles <- nonRoadLPG[grep(offRoad, nonRoadLPG$SCC.Level.Four, ignore.case = T), ]
  
  ## combine the non road vehicles
  nonRoadVehicles <- rbind(nonRoadVehicles, nonRoadLPGVehicles)
  
  cityVehicles <- rbind(cityRoad, nonRoadVehicles)
}

## get baltimore vehicles
baltimoreVehicles <- motorvehicles(joinedData, "24510")

## get los angeles county vehicles
losAngelesVehicles <- motorvehicles(joinedData, "06037")

baltimoreEmissions <- ddply(baltimoreVehicles, .(year), numcolwise(sum))
losAngelesEmissions <- ddply(losAngelesVehicles, .(year), numcolwise(sum))

png(filename = "plot6.png", width = 480, height = 480, units = "px")

p1 <- ggplot(baltimoreEmissions, aes(year, Emissions)) + 
      geom_line() +
      xlab("Year") +
      ylab("Emissions (tons)") +
      ggtitle("Baltimore City")

p2 <- ggplot(losAngelesEmissions, aes(year, Emissions)) + 
      geom_line() +
      xlab("Year") +
      ylab("Emissions (tons)") +
      ggtitle("Los Angeles County")

grid.arrange(p1, p2, ncol = 1, main = textGrob("Motor Vehicle Emissions (1999-2008)", gp = gpar(fontsize=20)))

dev.off()