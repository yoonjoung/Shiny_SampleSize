library(shiny)
library(dplyr)
library(tidyverse)

date<-as.Date(Sys.time(	), format='%d%b%Y')

# This creates shiny app to calculate sample size for a survey. 

#******************************
# 1. USER INTERFACE 
#******************************
shinyUI(fluidPage(
    
    # Header panel 
    headerPanel("How big should my sample size be?"),

    # Title panel 
    titlePanel("Interactive application to determine sample sizes for surveys"),
    
    # Side panel: define input and output   
    sidebarLayout(
        
        # Side panel for inputs: only ONE in this case
        sidebarPanel(
            numericInput("level1", 
                        "What is expected level of a main indicator (%)?",
                        min = 0, max = 100, value = 50),        
            #sliderInput("level1", 
            #            "What is expected level of a main indicator?",
            #            min = 0, max = 100, value = 50, 
            
            precisionchoice<-c(1, 2, 3, 5, 10),
            selectInput("precision1", 
                        "What is required margin of error for estimates (+/- % point of estimates)?", 
                        choices = precisionchoice)
        ),
        
        # Main page for output display 
        mainPanel(
            h4("Sample size for a survey is determined by various factors.", 
               "Basic determinants are an expected level of metrics of interest and precision of the estimate we want from the survey,", 
               "in addition to many additional factors such as response rates, survey designs, etc."), 

            hr(),                        
            h4("This interactive tool assists you to determine the sample size, based on two most basic factors:"), 
            h4(strong("- expected level of a main metric"),"(e.g., % of registered voters who plan to cast ballet) and"), 
            h4(strong("- required/ideal level of precision."),"(e.g., margin of error +/- 3% point)"),
            h4("To get started select the two inputs on the left panel."),
            
            hr(),
            h4("If the expected level of a metric is"),
            verbatimTextOutput("text1"),
            h4("and the required/ideal precision is"),
            verbatimTextOutput("text2"),
            
            hr(),    
            h4("then, the required sample size is:"),
            verbatimTextOutput("text3"), 

            hr(),
            h6("Application last updated on: January 13, 2020"),
            h6("For code and further information, please", a("see GitHub.", href="https://github.com/yoonjoung/Shiny_SampleSize"))
            
        )
    )
)
)
