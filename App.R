library(shiny)

setwd('~/Documents/work/Codeathon2021/')
library(usmap)
library(ggplot2)
#library(tibble)

df <- read.table('~/Downloads/fl_county_wise_latlong_coordinates.txt',
                 header = T, sep = '\t')
colnames(df) <- sub('^X','',colnames(df))


plotMap <- function(data, 
                    time = '2.24.21'){
  idNeed <- grep(time, colnames(data))
  if(length(idNeed) == 0) {print('Error !!! the input date is not available in the dataframe')}
  
  df_input <- tibble::tibble(fips = data$FIPS,
                             abbr = 'FL',
                             county = data$Admin2,
                             case   = data[,idNeed])
  plot_usmap(data = df_input, values = "case", include = 'FL', color = "blue") +
    scale_fill_continuous(low = "white", high = "blue",
                          name = paste("Case number", time, sep = '  '), label = scales::comma) +
    labs(title = "Florida", subtitle = paste("Case number", time, sep = '  ')) +
    theme(legend.position = "right")
}

library(tidyr)
county<-"Hillsborough"
long<-gather(df, "date", "cases", 8:length(df))
long$date<-as.Date(long$date, format="%m.%d.%y")
tmp<-long[which(long$Combined_Key==paste(county, ", Florida, US", sep="")),]

#g<-ggplot(data=tmp, aes(x=date, y=cases)) +
#  geom_line() +
#  theme_classic()
  
)

#pdf('florida.case.pdf', height = 5, width = 5)
#dev.off()





#ui <- pageWithSidebar(
  
  # App title ----
#  plotOutput("plot1", click="plot_click"), 
#  verbatimTextOutput("info"), 
#  headerPanel("COVID-19 distribution"),
  
  # Sidebar panel for inputs ----
#  sidebarPanel(
    
    # Input: Selector for variable to plot against mpg ----
#    selectInput("variable", "Model Type:", 
#                c("Current Data" = "Current",
#                  "Deep Learning Forecast" = "DL",
#                  "Regression Forecast" = "RG")),
#
#  ),
  
  # Main panel for displaying outputs ----
#  mainPanel()
  
#)


ui <- basicPage(
  headerPanel("COVID-19 distribution"),
  plotOutput("plot1", click="plot_click"), 
  #plotOutput("plot2", click="plot_click"), 
  verbatimTextOutput("info")
)


#COVID_Data <- mtcars
#mpgData$am <- factor(mpgData$am, labels = c("Automatic", "Manual"))

# Define server logic to plot various variables against mpg ----
server <- function(input, output) {

  formulaText <- reactive({
    paste("mpg ~", input$variable)
  })
  
  output$caption <- renderText({
    formulaText()
  })
  
  output$plot1 <- renderPlot({
    plotMap(df)
    })
  
  #output$plot2 <- renderPlot({
#    g
#  })
}

shinyApp(ui,server)
  