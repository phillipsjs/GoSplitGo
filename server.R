library(shiny)
library(ggplot2)
library(tidyr)
#devtools::install_github("corynissen/fitbitScraper")
library("fitbitScraper")

mypassword <- "Lsf87Qq6"
cookie <- login(email="phillipsjonathans@gmail.com", password=mypassword) 
startDate <- Sys.Date()-6
endDate <- Sys.Date()
goal <- 600
bonus <- 826
penalty <- 229

dataset <- get_premium_export(cookie, what="ACTIVITIES", start_date=as.character(startDate), 
                              end_date=as.character(endDate))
dataset$score <- dataset$Minutes.Lightly.Active + dataset$Minutes.Fairly.Active*2 + dataset$Minutes.Very.Active*4

dataset$goal[dataset$Date==endDate] <- "Today"
dataset$goal[dataset$score>=bonus & dataset$Date<endDate] <- "Bonus"
dataset$goal[dataset$score<bonus & dataset$Date<endDate] <- "Goal"
dataset$goal[dataset$score<goal & dataset$Date<endDate] <- "Rest"
dataset$goal[dataset$score<=penalty & dataset$Date<endDate] <- "Penalty"
dataset$goal <- factor(dataset$goal, levels = c("Today","Bonus","Goal","Rest","Penalty"))

dataset$Date <- weekdays(as.Date(dataset$Date))
weekdays <- c(weekdays(as.Date(startDate)),weekdays(as.Date(startDate+1)),weekdays(as.Date(startDate+2)),weekdays(as.Date(startDate+3))
              ,weekdays(as.Date(startDate+4)),weekdays(as.Date(startDate+5)),weekdays(as.Date(startDate+6)))
dataset$Date <- factor(dataset$Date, levels=weekdays)

## this converts character numeric vectors to integers 
for (i in names(dataset[,-1])) {
   if (class(dataset[[i]])=="character") {
     dataset[[i]] <- gsub(",", "", dataset[[i]])
     dataset[[i]] <- as.integer(dataset[[i]])
   }
 }
  
dataset <- gather(dataset,show,score,2:11)
dataset$show <- factor(c("Calories Burned","Steps Taken","Distance","Floors Climbed","Minutes Sedentary",
                         "Low Activity Minutes","Medium Activity Minutes","High Activity Minutes",
                         "Active Calories Burned","GoSplitGo Score")[dataset$show])
dataset$show <- factor(dataset$show, levels=c("GoSplitGo Score", "High Activity Minutes", "Medium Activity Minutes",
                                              "Low Activity Minutes","Minutes Sedentary","Steps Taken","Distance","Floors Climbed",
                                              "Calories Burned","Active Calories Burned"))

shinyServer(function(input, output) {
  
  show <- reactive({paste(input$display)})
  output$caption <- renderText({show()})
  
  # Fill in the spot we created for a plot
  output$GSGPlot <- renderPlot({
    
    ##ggplot    
    print(ggplot(dataset[dataset$show==input$display,], aes(x=Date, y=score, fill=goal)) +
          geom_bar(stat="identity",position="dodge") +
          geom_text(aes(label=score,y=score*1.1)) +
                ylab("") +
                xlab("") +
                theme(axis.text.x = element_text(angle = 90, hjust = 1))
          )
  })
})
