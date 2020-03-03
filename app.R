library(shiny)
library(dplyr)
library(tidyverse)
library(plotly)

date<-as.Date(Sys.time(	), format='%d%b%Y')

# This creates shiny app to calculate sample size for a survey. 
# There are four parts in this document:
# 1. USER INTERFACE 
# 2. SERVER
# 3. CREATE APP 

#******************************
# 1. USER INTERFACE 
#******************************
#precisionchoice<-c(1, 2, 3, 5)

ui<-fluidPage(
    
    # Header panel 
    headerPanel("How big should my sample size be?"),

    # Title panel 
    titlePanel("Interactive application to determine sample sizes for surveys"),
    
    # Side panel: define input and output   
    sidebarLayout(
        
        # Side panel for inputs: only ONE in this case
        sidebarPanel(
            h5("Part 1"),
            numericInput("level1", 
                        "What is an expected level of your main indicator (%)?",
                        min = 0, max = 100, value = 35),        
                    
            radioButtons("precision1", 
                        "What is your required margin of error for estimates?", 
                        choices = list("+/- 1 percentage point"=1, 
                                       "+/- 2 percentage points"=2, 
                                       "+/- 3 percentage points"=3, 
                                       "+/- 5 percentage points"=4),
                        selected= 3
                        ),
            br(),
            br(),
            h5("Part 2"),
            numericInput("responserate1", 
                        "What is your expected response rate (%) during survey implementation?",
                        min = 50, max = 100, value = 80),        
            br(),
            br(),
            h5("Part 3"),
            numericInput("designeffect1", 
                        "What is expected design effect in your survey design? (provide 1 if the sample design is simple random)",
                        min = 0.5, max = 10, value = 2),
            br(),
            br(),
            h5("Part 4"),
            numericInput("unit1", 
                        "What is an expected average number of denominators per sampling unit? (provide 1 if the sample unit is your denominator unit)", 
                        min = 0.05, max = 10, value = 1)
                    
        ),
        
        # Main page for output display 
        mainPanel(
            h5("Sample size for a survey is determined by various factors.", 
               "This interactive tool assists you to determine the sample size when a main objective of a survey is to estimate proportions."),
            h5("There are four parts:"), 
            h5("- Part 1 calculates a sample size based on the two basic factors;"),
            h5("- Part 2 adjusts the sample size with expected response rates; and"),
            h5("- Part 3 further adjusts the sample size incorporating any sample design that is not simple random."),
            h5("- If applicable, Part 4 further adjusts the sample size, reflecting any difference between sampling unit and the unit of denominator."),
        
            hr(),                        
            h5(strong("Part 1")),
            h5("The sample size is first calculated based on the",a("two basic factors:", href="https://en.wikipedia.org/wiki/Sample_size_determination")) , 
            h5(strong("- expected level of a main metric"),"(e.g., % of households with a BMX bike) and"), 
            h5(strong("- required or preferred level of precision."),"(e.g., margin of error +/- 3 % points)."),
            h5("With a given expected level of a metric, the lower margin of error (darker markers in the below figure), the larger sample size. Also, the sample size becomes larger, as the level of metrics moves away from 50%. See below figure."),
            h5("To get started select the first two inputs on the left panel."),
            
            hr(),
            h5("If the expected level of a metric is"),
            verbatimTextOutput("text1"),
            h5("and the required/ideal precision is"),
            verbatimTextOutput("text2"),
            h5("then, the required sample size is:"),
            verbatimTextOutput("text3"), 
            
            hr(),    
            h5("See the sample size in the below figure (green circle), compared to sample sizes based on possible combinations of level (x axis) and precision (marker color)."),
            plotlyOutput("plot1"),             

            hr(),                        
            h5(strong("Part 2")),
            h5("Few surveys have a response rate of 100%. Thus, without inflating sample size to some extent, we will end up with an insufficient sample size."), 
            h5("Provide expected response rate on the left panel."),
            
            hr(),
            h5("If the response rate is"),
            verbatimTextOutput("text4"),
            h5("then, the required sample size is increased to:"),
            verbatimTextOutput("text5"),             
            
            hr(),                        
            h5(strong("Part 3")),
            h5("Rarely, a large survey can have a simple random sample design, due to logistics challenges in field implementation and finite budget.", 
               "When non-random sample design is used (e.g., cluster sample),",a("design effect",href="https://www.statisticshowto.datasciencecentral.com/design-effect/"), "needs to be incorporated.",
               "In social science, design effect is typically (but not necessarily always) greater than 1, and the sample size is inflated by that effect."), 
            h5("Provide expected design effect on the left panel."),            
            
            hr(),
            h5("If the design effect is"),
            verbatimTextOutput("text6"),
            h5("then, the required sample size is increased to:"),
            verbatimTextOutput("text7"),             

            hr(),                        
            h5(strong("Part 4")),
            h5("Finally, sometimes the unit of your indicator's denominator is different from sampling unit."), 
            h5("For example, your sampling is based on a list of households, but a key indicator is percent of children under age-5 who are fully vaccinated. Not every household has children, and the average number of children per household would be less than one in the population. In such cases, we will need to inflate the number of households for sampling."), 
            h5("On the other hand, a key indicator can be percent of any household members who are fully vaccinated. Every household has at least one and often multiple people, and the average number of people per household would be greater than one in the population. In such cases, we actually can deflated the number of households for sampling."), 
            h5("Sometimes, your key indicator is indeed at the household-level (e.g., percentage of households with school-age children), and no further adjustment is needed."), 
            h5("Provide an expected number of denominators per sampling unit on the left panel."),            
            
            hr(),
            h5("If the average number of denominators per sampling unit is"),
            verbatimTextOutput("text8"),
            h5("then, the final required sample size is:"),
            verbatimTextOutput("text9"),  
            
            hr(),
            h5("Now you have a required sample size for",strong("one sampling stratum."), "If you have multiple sampling strata (which is likely the case in the real world), you will need to repeat the above steps for each stratum. Add them all, and you have the final total sample size. Then, you're now ready to plan your fieldwork. Good luck!"),
            h5("For more detailed resources on sampling methods for real world surveys: these are some of my favorites:"),                        
            h5("-",a("DHS Sampling and Household Listing Manual",href="https://www.dhsprogram.com/pubs/pdf/DHSM4/DHS6_Sampling_Manual_Sept2012_DHSM4.pdf")),
            h5("-",a("PMA Survey Methodology.",href="https://www.pmadata.org/data/survey-methodology"), "Scroll down and click 'PMA2020 General Sampling Strategy Memo'."),
            br(),
            h6(em("Okay, for DHS and PMA survey users, have you recognized one (potentially) missing component in this app? Hint: there are two or more units of interviews in those surveys!")),
               
            hr(),
            h6("See", a("GitHub",href="https://github.com/yoonjoung/Shiny_SampleSize"),"for more information."),
            h6("(Application last updated on:", as.Date(Sys.time(	), format='%d%b%Y'),")"),
            h6("For typos, errors, and questions:", a("contact me",href="https://www.isquared.global/YJ"))
        )
    )
)
#******************************
# 2. SERVER
#******************************

server<-function(input, output) {

    #################################### 
    # PART 1        
    # text output of selected parameters
    output$text1 <- renderText({
        paste(input$level1,"%") 
        })
    output$text2 <- renderText({
        paste("+/-", input$precision1, "% point of the estimate") 
        })    
    
    # calculated sample size
    output$text3 <- renderText({
        p  <- input$level1/100 
        e  <- as.numeric(input$precision1)/100 
        ssize <- round(p*(1-p)*1.96^2/(e^2))
        paste(ssize)
        })    
    
    # plot sample size
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
                )
            )  %>%
            layout(
                autosize = F, width = 600, height = 400, 
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
    
    #################################### 
    # PART 2    
    # text output of selected parameters
    output$text4 <- renderText({
        paste(input$responserate1,"%") 
        })

    # calculated sample size
    output$text5 <- renderText({
        p  <- input$level1/100 
        e  <- as.numeric(input$precision1)/100 
        ssize <- round(p*(1-p)*1.96^2/(e^2))
        ssize2 <- round(ssize/(input$responserate1/100))
        paste(ssize2)
        })  
    
    #################################### 
    # PART 3    
    # text output of selected parameters
    output$text6 <- renderText({
        paste(input$designeffect1) 
        })

    # calculated sample size
    output$text7 <- renderText({
        p  <- input$level1/100 
        e  <- as.numeric(input$precision1)/100 
        ssize <- round(p*(1-p)*1.96^2/(e^2))
        ssize2 <- round(ssize/(input$responserate1/100))
        ssize3 <- round(ssize2*input$designeffect1)
        paste(ssize3)
        })    
    
    #################################### 
    # PART 4    
    # text output of selected parameters
    output$text8 <- renderText({
        paste(input$unit1) 
        })

    # calculated sample size
    output$text9 <- renderText({
        p  <- input$level1/100 
        e  <- as.numeric(input$precision1)/100 
        ssize <- round(p*(1-p)*1.96^2/(e^2))
        ssize2 <- round(ssize/(input$responserate1/100))
        ssize3 <- round(ssize2*input$designeffect1)        
        ssize4 <- round(ssize3*(1/input$unit1))
        paste(ssize4)
        })        
    
}       

#******************************
# 3. CREATE APP 
#******************************

 shinyApp(ui = ui, server = server)