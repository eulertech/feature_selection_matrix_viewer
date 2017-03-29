#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
source('global.R')
# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Time Series Interactive Visualization Demo (Dr. Liang Kuang)"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      uiOutput('testUI')
       # for (i in 1:dim(data)[2]-1){
       #    sliderUI <- paste0('slider',i)         
       #    uiOutput(sliderUI)
       #    print('create dynamic UI for sliders')
       #    },
      #  selectizeInput(
      #     'selectVar2PlotID', label = 'Select variables to explore (max =5)', choices = features2include ,
      #      options = list(maxItems=5,placeholder = 'select a feature variable')
      #  ),
      # radioButtons("normMethodID","Normalization method",
      #              c("MinMax" = "minmax",
      #              "Raw" = "raw")),
      # actionButton("go","Update"),
      # verbatimTextOutput('textID'),
      # tags$div(
      #   HTML("<p> Instructions to use the app: </p> 
      #             <ul>
      #               <li> 0. Search the variable ID in the variableID lookup table on the right</li>
      #               <li> 1. Choose the x-axis variable in date & time format</li>
      #             </ul>
      #        ")
        #)
    ),
     
    
    # Show a plot of the generated distribution
    mainPanel(
      img(src='logo.png',alt='IHS Markit', height=30, width=100,align = 'right'),
      tabsetPanel(
        tabPanel("Matrix Table",dataTableOutput("table")),
        tabPanel("Variable ID Lookup", dataTableOutput("lookupTable")),
        tabPanel("Visualization",
                 fluidRow(
                    column(8,plotOutput("tsplot"))
                 ),
                 fluidRow(
                    column(8,plotOutput("radarplot"))
                 )
                 )
      )
    )
  )
))
