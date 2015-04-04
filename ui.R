library(shiny)
library(ggplot2)

# Define the overall UI
shinyUI(
  
  # Use a fluid Bootstrap layout
  fluidPage(    
    
    # Give the page a title
    titlePanel("GoSplitGo"),
    
    # Generate a row with a sidebar
    sidebarLayout(      
      
      # Define the sidebar with one input
      sidebarPanel(
        selectInput("display", "Display:", 
                    choices=levels(dataset$show),
                    selected="score"),
        hr(),
        helpText("What do you want to see?"),
        
        sliderInput("past", "How many days to show:",
                    min=0, max = 30, value=6
        )
      ),
      
      # Create a spot for the barplot
      mainPanel(
        h3(textOutput('caption')),
        plotOutput("GSGPlot")  
      )
      
    )
  )
)
