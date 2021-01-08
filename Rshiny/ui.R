# ui.R
ui <- fluidPage( 
                 titlePanel(h4("Input Information")),
                 sidebarLayout(position = "left",
                               sidebarPanel( 
                                 sliderInput(inputId = "slide",label = "PC1 Range",min = x.low,max = x.high,value = c(x.low,x.high)),
                                 sliderInput(inputId = "slide2",label = "PC2 Range",min = y.low,max = y.high,value = c(y.low,y.high)),
                                 selectInput(inputId = "Ancestry", label = "Ancestry", choices = unique(as.character(ex_df$Ancestry))),
                               ),
                               mainPanel(
                                 
                                         fluidRow(splitLayout(style = "border: 1px solid silver:", 
                                                              cellWidths = c("50%", "50%"),
                                                              plotOutput(outputId = "plot1", width = "100%",click = "plot_click"),
                                                              plotOutput(outputId = "plot2",width = "100%"))),
                                         fluidRow(
                                           column(width = 8,
                                                  verbatimTextOutput("click_info"),
                                                  verbatimTextOutput("last_infor"))))
                               )
                 )
