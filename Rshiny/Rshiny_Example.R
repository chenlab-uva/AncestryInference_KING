library(shiny)
library(ggplot2)
options(scipen = 999)
# global.R
ex_df <- read.table("example_InferredAncestry.txt", header = TRUE, stringsAsFactors = FALSE)
ex_df$Ancestry[grep(";", ex_df$Ancestry)] <- "Missing"

x.low <- min(ex_df$PC1)
x.high <- max(ex_df$PC1)
y.low <- min(ex_df$PC2)
y.high <- max(ex_df$PC2)

Palette <- c("#1F78B4", "#33A02C", "#E31A1C", "#FF7F00", "#6A3D9A", "#B15928", "#A6CEE3", 
             "#B2DF8A", "#FB9A99", "#FDBF6F", "#CAB2D6", "#FFFF99")
n <- length(unique(ex_df$Ancestry))
cols = Palette[1:n]


# server.R
server <- function(input, output) {
  output$plot1 <- renderPlot({
    ggplot(filter(ex_df, PC1 >= input$slide[1] & PC1 <= input$slide[2] & PC2 >= input$slide2[1] & PC2 <= input$slide2[2]), 
           aes(PC1, PC2, color=Ancestry))  + geom_point() + xlim(x.low, x.high) + ylim(y.low, y.high) + scale_colour_manual(values=cols)
  })
  output$click_info <- renderPrint({
    if(!is.null(input$plot_click)){
      print(paste0("x=", round(input$plot_click$x,4), ";y=", round(input$plot_click$y,4)))
      sample.click <- ex_df[which.min((ex_df$PC1-input$plot_click$x)^2 + (ex_df$PC2-input$plot_click$y)^2), ]
      if (abs(sample.click$PC1-input$plot_click$x) <= 0.001 & abs(sample.click$PC2-input$plot_click$y) <= 0.001){
        print(sample.click )} else {
          print("Please click one dot")
        }
    }
  })
  output$plot2 <- renderPlot({
    ggplot(filter(ex_df, Ancestry==input$Ancestry), aes(PC1, PC2)) + 
      #geom_point(color=cols[levels(as.factor(ex_df$Ancestry))%in%input$Ancestry]) + 
      geom_point(color="Grey") + 
      facet_wrap(~ Ancestry) + xlim(x.low, x.high) + ylim(y.low, y.high)
  })
} 

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

shinyApp(ui, server)
