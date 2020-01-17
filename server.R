library(shiny)
library(dplyr)
library(tidyverse)

date<-as.Date(Sys.time(	), format='%d%b%Y')

# This creates shiny app to calculate sample size for a survey. 
#******************************
# 2. SERVER
#******************************

shinyServer(function(input, output) {  
    # text output of selected parameters
    output$text1 <- renderText({
        paste(input$level1,"%,") 
        })
    output$text2 <- renderText({
        paste("+/-", input$precision1, "% point of the estimate,") 
        })    
    
    # calculated sample size
    output$text3 <- renderText({
        p  <- input$level1/100 
        e  <- as.numeric(input$precision1)/100 
        ss <- round(p*(1-p)*1.96^2/(e^2))
        paste(ss)
        })    
})       

