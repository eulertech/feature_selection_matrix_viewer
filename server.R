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
library(scales)
source('global.R')
source('func2CreateRadialPlot.R')

 if(!require('ggradar')){
   devtools::install_github("ricardo-bion/ggradar", 
                          dependencies=TRUE)
   library(ggradar)
   }

shinyServer(function(input, output) {
  
  output$slidersUI <- renderUI({
    numOfFeatureVariables <- length(input$selectMetric2PlotID) 
    slider_outout_list <- lapply(1:numOfFeatureVariables, function(i){
      slidername <- paste0("slider",i)
      description <- paste0("Select range for matrix: ",features2include[i])
      print(paste0('Creating the ', i-1,'the dynamic slider.',slidername))
      minV <- floor(min(data[features2include][i]))
      maxV <- ceiling(max(data[features2include][i]))
      print(paste0('minV is:', minV))
      stp <- round((maxV-minV)/20.0,2)
      sliderInput(slidername,description,
                  min=minV,max=maxV,value =c(minV,maxV),step = stp)
    })
    # convert the list to a tagList 
    do.call(tagList, slider_outout_list)
  })
  
   rv <- reactiveValues()
   rv$data <- NULL
   rv$numFeatureSelected <- NULL
   init <-  0 
   observe({  # will 'obseve' the button press
     if(input$go) {
       isolate(init <- init + 1)
       print(init)
       print('action !!!!')
       print("get selected variable from selectizeInput")
       selectedMetrix <- input$selectMetric2PlotID
       # subset data using the date range and selected variables list
       data2use <- subset(data, select = c(feature2exclude,selectedMetrix))
       numOfFeatureVariables <- dim(data2use)[2] - 1
      # create # of dynamic sliders based on selected matrix 
       rv$numFeatureSelected <- numOfFeatureVariables
       
       # update the data2use based on all the slider range selected value
      #datafinal <- lapply(1:numOfFeatureVariables, function(i){
      #  slidername <- paste0("slider",i)
      #  mv <- input[[slidername]][1]
      #  mx <- input[[slidername]][2]
      #  cname <- features2include[i]
      #  data2use <- data2use[data2use[cname] >=mv & data2use[cname]<= mx,]
      #})
         for (n in 1:numOfFeatureVariables) {
             slidername <- paste0("slider",n)
             mv <- input[[slidername]][1]
             mx <- input[[slidername]][2]
             cname <- features2include[n]
             print(paste0('n is:',n))
             print(paste0('min:',mv,'max:',mx))
             print(cname)
             print(data2use)
             filtervec <-  data2use[cname] >=mv & data2use[cname]<= mx
             if(sum(filtervec)<1){
               output$textID <- renderText(paste0('There are no data in these criteria, with dimension of:',dim(data2use))) 
             }else{
             data2use <- data2use[data2use[cname] >=mv & data2use[cname]<= mx,]
             }
         }
       
      rv$data <- data2use 
       return(rv) 
     }
   })  
   
   
   
   output$textID <- renderText(paste0('debug_slider1:',input$slider1)) 
   xymelt <-eventReactive(input$go, {melt(rv$data,id.vars = 'variableID')}) 
   observeEvent(input$go, {write.csv(rv$data, file = './www/test.csv')})
       
# generate time series plot    
     output$tsplot <- renderPlot({
       ggplot(xymelt(), aes(x = variableID, y = value, color=variableID)) + geom_line() +
         geom_point(data = xymelt(),aes(x = variableID, y = value, color=variableID))
     })
# generate radar plot     
     output$radarplot <- renderPlot({
       #normalize the data
       selectedVar2plot <- input$selectVar2PlotID
       data2plot <- subset(rv$data,variableID %in% selectedVar2plot)  #catch, here variableID is hardwired. Should we var: feature2exclude instead
       df2plot <- mutate_each(data2plot,funs(rescale),-contains(feature2exclude))
       write.csv(df2plot, file='./www/df2plot.csv')
       #df2plot <- mutate_each(rv$data,funs(rescale),-variableID)
#       CreateRadialPlot(df2plot,plot.legend=TRUE) 
       ggradar(df2plot)
       
     })
#     
     output[["table"]] <- renderDataTable(rv$data)
     output$lookupTable <- renderDataTable(lookupData)
})
    
    
    
    