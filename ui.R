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
# Define UI for application that exploring feature selection matrix
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Feature Selection Matrix Visualization Demo (By Advanced Analytic (LK))"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
        uiOutput('slidersUI'),
        selectizeInput(
           'selectMetric2PlotID', label = 'Select metrics to explore (max =10)', choices = features2include ,
            options = list(maxItems=10,placeholder = 'select a feature variable')
        ),
        selectizeInput(
           'selectVar2PlotID', label = 'Select variables for Radar Plot (max =5)', choices = data[feature2exclude] ,
            options = list(maxItems=5,placeholder = 'select a feature variable')
        ),
       actionButton("go","Update"),
       verbatimTextOutput('textID'),
       tags$div(
         HTML("<p> Instructions to use the app: </p> 
                   <ul>
                     <li> 0. Search the variable ID in the variableID lookup table on the right</li>
                     <li> 1. Select metrics to explore (max=10)</li>
                     <li> 2. Adjust sliders selected at step 1 to view the database
                     <li> 3. Select variables to explore all matrics (max =5) </li>
                     <li> 4. Click 'update below to view updated restuls </li>
                   </ul>
              ")
        ),
       a("Model Notebook", href = "Stability+selection-RFE-other.html")
    ),
     
    
    # Show a plot of the generated distribution
    mainPanel(
      img(src='logo.png',alt='IHS Markit', height=30, width=100,align = 'right'),
      tabsetPanel(
        tabPanel("Matrix Table",dataTableOutput("table")),
        tabPanel("Radar Plot Data Table",dataTableOutput("radartable")),
        tabPanel("Variable ID Lookup", dataTableOutput("lookupTable")),
        tabPanel("Visualization",
                 fluidRow(
                    column(12,plotOutput("tsplot"))
                 ),
                 fluidRow(
                    column(12,plotOutput("radarplot"))
                 )
                 )
      )
    )
  )
))
