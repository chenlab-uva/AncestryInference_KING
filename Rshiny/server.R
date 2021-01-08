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
