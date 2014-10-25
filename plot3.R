NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

library(plyr)
library(ggplot2)
library(grid)
library(gridExtra)

## sum the emissions by year and type for baltimore city (fips == "24510")
baltimoreData <- subset(NEI, fips == "24510")
totalEmissionsType <- ddply(baltimoreData, .(year, type), numcolwise(sum))

png(filename = "plot3.png", width = 480, height = 480, units = "px")

p1 <- ggplot(subset(totalEmissionsType, type == "NON-ROAD"), aes(year, Emissions)) + 
      geom_line() +
      xlab("Year") +
      ylab("Emissions (tons)") +
      ggtitle("Non-Road")

p2 <- ggplot(subset(totalEmissionsType, type == "NONPOINT"), aes(year, Emissions)) + 
      geom_line() +
      xlab("Year") +
      ylab("Emissions (tons)") +
      ggtitle("Nonpoint")

p3 <- ggplot(subset(totalEmissionsType, type == "ON-ROAD"), aes(year, Emissions)) + 
      geom_line() +
      xlab("Year") +
      ylab("Emissions (tons)") +
      ggtitle("On-Road")

p4 <- ggplot(subset(totalEmissionsType, type == "POINT"), aes(year, Emissions)) + 
      geom_line() +
      xlab("Year") +
      ylab("Emissions (tons)") +
      ggtitle("Point")

grid.arrange(p1, p2, p3, p4, ncol = 2, main = textGrob("Baltimore City Emissions by Year (1999-2008)", gp = gpar(fontsize=20)))

dev.off()

