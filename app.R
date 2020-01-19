library(shiny)
library(dplyr)
library(tidyverse)

date<-as.Date(Sys.time(	), format='%d%b%Y')

# This creates shiny app to calculate sample size for a survey. 
# There are four parts in this document:
# 1. USER INTERFACE 
# 2. SERVER
# 3. CREATE APP 

#******************************
# 1. USER INTERFACE 
#******************************

ui<-fluidPage(
    
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
                        min = 0, max = 100, value = 35),        
            #sliderInput("level1", 
            #            "What is expected level of a main indicator?",
            #            min = 0, max = 100, value = 50, 
            
            precisionchoice<-c(1, 2, 3, 5),
            selectInput("precision1", 
                        "What is required margin of error for estimates (+/- % point of estimates)?", 
                        choices = precisionchoice
                        )
        ),
        
        # Main page for output display 
        mainPanel(
            h4("Sample size for a survey is determined by various factors.", 
               "Basic determinants are an expected level of metrics of interest (e.g., % of registered voters who plan to cast ballet) and precision of the estimate we want from the survey (e.g., margin of error +/- 3% point),", 
               "in addition to many additional factors such as response rates, survey designs, etc."), 

            hr(),                        
            h4("This interactive tool assists you to determine the sample size, based on two most basic factors:"), 
            h4(strong("- expected level of a main metric"),"and"), 
            h4(strong("- required/ideal level of precision.")),
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
            h4("See the sample size in the below figure (green circle), compared to sample sizes based on possible combinations of level (x axis) and precision (marker color)."),
            plotlyOutput("plot1"),             

            hr(),
            h6("Application last updated on: 1/19/2020")
        )
    )
)
#******************************
# 2. SERVER
#******************************

server<-function(input, output) {

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
        ssize <- round(p*(1-p)*1.96^2/(e^2))
        paste(ssize)
        })    
    
    # plot sample size
    library(dplyr)
    library(plotly)
    output$plot1 <- renderPlotly({
        p  <- input$level1/100 
        e  <- as.numeric(input$precision1)/100 
        ssize <- round(p*(1-p)*1.96^2/(e^2))
                
        p<-c(seq(0, 100, 5))
        e<-c(1,2,3,5)
        dta<-expand.grid(p,e)
        dta<-dta %>% rename(p=Var1,e=Var2)
        dta$ss = round(dta$p/100*(1-dta$p/100)*1.96^2/((dta$e/100)^2))

        plot_ly(dta, x=dta$p, y=dta$ss, 
            mode="markers",
            group = factor(dta$e),
            marker = list(
                color = factor(dta$e, label=c("darkorchid","mediumorchid","orchid","plum"))  
            ))  %>%
            layout(
                xaxis = list(title = "Level of indicator (%)"),
                yaxis = list(title = "Required sample size"),
                shapes= list(
                    type="circle",
                    xref="x", x0=input$level1-1,x1=input$level1+1,  
                    yref="y", y0=ssize-200,y1=ssize+200,
                    fillcolor='green',
                    opacity=0.5
                    )
                )        
        
    })        
    
}       

#******************************
# 3. CREATE APP 
#******************************

 shinyApp(ui = ui, server = server)