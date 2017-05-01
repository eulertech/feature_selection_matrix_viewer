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
library(dplyr)
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
   rv$radardata <- NULL
   rv$numFeatureSelected <- NULL
   init <-  0
   observe({  # will 'obseve' the button press
     if(input$go) {
       isolate(init <- init + 1)
       print(init)
       print('action !!!!')
       print("get selected variable from selectizeInput")
       selectedMetrix <- isolate(input$selectMetric2PlotID)
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
             mv <- isolate(input[[slidername]][1])
             mx <- isolate(input[[slidername]][2])
             cname <- selectedMetrix[n]
             print(paste0('n is:',n))
             print(paste0('min:',mv,'max:',mx))
             print(cname)
             print(data2use)
             filtervec <-  data2use[cname] >=mv & data2use[cname]<= mx
             if(sum(filtervec)<1){
               output$textID <- renderText(paste0('There are no data in these criteria, with dimension of:',dim(data2use)))
               rv$data <- NULL
               return(rv)
             }else{
             data2use <- data2use[data2use[cname] >=mv & data2use[cname]<= mx,]
             }
         }

      # create dataframe for radar plot
       selectedVar2plot <- isolate(input$selectVar2PlotID)
       data2plot <- subset(data,variableID %in% selectedVar2plot)  #catch, here variableID is hardwired. Should we var: feature2exclude instead
       df2plot <- mutate_each(data2plot,funs(rescale),-contains(feature2exclude))
       rv$radardata <- df2plot
       write.csv(df2plot, file='./www/df2plot.csv')

      rv$data <- data2use
      print('update data from slider input')
      print(rv$data)
       return(rv)
     }
   })



   output$textID <- renderText(paste0('debug_slider1:',input$slider1))
     # observeEvent(input$go, {write.csv(rv$data, file = './www/test.csv')})
        xymelt <-eventReactive(input$go, {
          numMetricSelected <- isolate(length(input$selectMetric2PlotID))
          if(numMetricSelected >1){
            data2use <- rv$data
            data2useT <- t(data2use)
            data2useT <- data2useT[-c(1),] #remove the first row with all the variable names
            print(data2use['variableID'])
            print(data2useT)
            write.csv(data2use,file='./www/data2usedebug.csv')
            write.csv(data2useT, file='./www/debug.csv')
            colnames(data2useT) <- t(data2use['variableID'])
            print('pring the colnames for data2useT')
            print(names(data2useT))
            dmelt <- melt(data2useT,id.vars = 1)
            print(names(dmelt))
            names(dmelt) <- c('metrics','variableID','value')
            print(names(dmelt))
            print('convert data to melted form finished!!!!')
            return(dmelt)
            }else{
              return()
            }
          })
# generate time series plot
     output$tsplot <- renderPlot({
       if(!input$go){
         return
       }
       MetricSelected <- isolate(input$selectMetric2PlotID)
       tryCatch(
           if(length(MetricSelected)==1)
             {
             # for only one metrix column selected.
             print('only one metric selected.')
             print(rv$data)
             ggplot(rv$data, aes(x=variableID, y = MetricSelected)) +  geom_line()+
               geom_point(data = rv$data,aes(x = variableID, y = MetricSelected, color=variableID))

             }else{
               # for more than two column metrix :melt
           print(names(xymelt()))
           print(xymelt())
           write.csv(xymelt(), file='./www/xymelt.csv')
           ggplot(xymelt(), aes(x = metrics, y = value, color=variableID)) +
              geom_line(aes(group = variableID)) +
              geom_point(aes(group = variableID))
            },error = function(e) NULL) # tryCatch
     })

# generate radar plot
     output$radarplot <- renderPlot({
       if(!input$go){
         return()
       }
       #normalize the data
      # selectedVar2plot <- input$selectVar2PlotID
      # data2plot <- subset(data,variableID %in% selectedVar2plot)  #catch, here variableID is hardwired. Should we var: feature2exclude instead
      # df2plot <- mutate_each(data2plot,funs(rescale),-contains(feature2exclude))
      # write.csv(df2plot, file='./www/df2plot.csv')
      # #df2plot <- mutate_each(rv$data,funs(rescale),-variableID)
#       CreateRadialPlot(df2plot,plot.legend=TRUE)
       tryCatch(
         ggradar(rv$radardata), error = function(e) NULL)
     })
#
     output[["table"]] <- renderDataTable(rv$data)
     output[["radartable"]] <- renderDataTable(rv$radardata)
     output$lookupTable <- renderDataTable(lookupData)
})
