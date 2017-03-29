#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(reshape2)
library(ggplot2)
source('global.R')

# if(!require('ggradar')){
#   devtools::install_github("ricardo-bion/ggradar", 
#                          dependencies=TRUE)
#   library(ggradar)
#   }

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  # rv <- reactiveValues()
  # rv$data <- NULL
  # rv$startDate <- NULL
  # rv$endDate <- NULL
  # observe({  # will 'obseve' the button press
  #   if(input$go) {
  #      print('action !!!!')
  #     data
  #     return(rv$data) 
  #   }
  #   
  # })  

   output$testUI <- renderUI({sliderInput('slider','sfsdfsd',
                             min = 0,max = 1, value = c(0,1), step = 0.1)})   
   # xymelt <-eventReactive(input$go, {melt(rv$data,id.vars = 'variableID')}) 
    #observeEvent(input$go, {write.csv(xymelt(), file = './www/test.csv')})
    # for (i in 2:dim(data)[2]) {
    #     sliderUI <- paste0('slider',i)
    #     minV <- floor(data$features2include[i-1])
    #     maxV <- ceiling(data$features2include[i-2])
    #     stp <- round((maxV-minV)/20.0,2)
    #     output$eval(sliderUI) <- renderUI(sliderInput(sliderUI,paste0('Select range for ',features2include[i-1]),
    #                          min = minV,max = maxV, value = c(minV,maxV), step = stp))   
    # }
    
#     output$textID <- renderText(paste0('debug',as.character(rv$startDate))) 
#     
#     output$plot <- renderPlot({
#       # ggplot(data = data2use(), aes(x = date, y = selectedVars())) +
#       #  geom_line()
# #      ggplot(xymelt(), aes(x = date, y = value, color=variable)) + geom_line() +
# #        geom_point(data = xymelt(),aes(x = date, y = value, color=variable))
#     })
#     
#     output$table <- renderDataTable(rv$data)
#     output$lookupTable <- renderDataTable(lookupData)
})
    
    
    
    