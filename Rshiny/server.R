# server.R
server <- function(input, output, session) {
  data <- reactive({
    file1 <- input$file1
    if (is.null(file1)) return()
    ex_df <- read.table(file = file1$datapath, header = TRUE, stringsAsFactors = FALSE)
    ex_df$Ancestry[grep(";", ex_df$Ancestry)] <- "Missing"
    updateSelectInput(session, "Ancestry", choices = unique(ex_df$Ancestry))
    return(ex_df)
  })
  
  filename <- reactive({
    file.info <- input$file1
    if (is.null(file.info)) return(NULL)
    filename.tmp <- gsub(".*/", "", file.info$name)
    file_prefix <- gsub("_.*", "", filename.tmp)
    return(file_prefix)
  })
  
  subset.df <- reactive({
    if (is.null(data())) return(NULL)
    ex_df2 <- data()
    sub_ex_df <- ex_df2[ex_df2$Ancestry == input$Ancestry, ]
    return(sub_ex_df)
  })
  
  output$plot1 <- renderPlot({
    if (is.null(data())) return(NULL)
    ex_df <- data()
    uniq.grp <- unique(ex_df$Ancestry)
    studyname <- filename()
    sample.size <- nrow(ex_df)
    if ("Missing" %in% uniq.grp) {
      legend.group <- c(sort(uniq.grp[uniq.grp != "Missing"]), "Missing")
    } else {
      legend.group <- sort(uniq.grp)
    }
    n = length(uniq.grp)
    if ("Missing" %in% uniq.grp) {
      cols = c(Palette[1:(n - 1)], "#999999")
    } else {
      cols = Palette[1:n]
    }
    ggplot(ex_df, aes(PC1, PC2, color = Ancestry)) + geom_point(aes(colour = factor(Ancestry, levels = legend.group))) + 
      scale_colour_manual(values = cols) + 
      ggtitle(paste0("PC Coordinates and Inferred Ancestry for Samples in ", studyname," (N=", sample.size, ")")) + 
      theme(text=element_text(size=16))
  })
  
  
  # PLOT 2
  output$plot2 <- renderPlot({
    if (is.null(subset.df())) return(NULL)
    full.df <- data()
    uniq.grp <- unique(full.df$Ancestry)
    if ("Missing" %in% uniq.grp) {
      legend.group <- c(sort(uniq.grp[uniq.grp != "Missing"]), "Missing")
    } else {
      legend.group <- sort(uniq.grp)
    }
    n = length(uniq.grp)
    if ("Missing" %in% uniq.grp) {
      cols = c(Palette[1:(n - 1)], "#999999")
    } else {
      cols = Palette[1:n]
    }
    sub.group.num <- sum(full.df$Ancestry == input$Ancestry)
    subset.df.2 <- subset.df()
    ggplot(subset.df.2, aes(PC1, PC2)) + geom_point(color = cols[legend.group %in% input$Ancestry]) + 
      ggtitle(paste0("Interactive Plot for Samples of ", input$Ancestry, " Ancestry (N=", sub.group.num, ")")) + 
      theme(text = element_text(size = 16))
  })
  output$click_info <- renderPrint({
    if (!is.null(input$plot_click)) {
      subdf <- subset.df()
      range.PC1 <- max(subdf$PC1) - min(subdf$PC1)
      range.PC2 <- max(subdf$PC2) - min(subdf$PC2)
      print(paste0("PC1 = ", round(input$plot_click$x, 4), ";PC2 = ", round(input$plot_click$y, 4)))
      sample.click <- subdf[which.min((subdf$PC1 - input$plot_click$x)^2 + (subdf$PC2 - input$plot_click$y)^2), ]
      if (abs(sample.click$PC1 - input$plot_click$x) <= range.PC1/100 & abs(sample.click$PC2 - input$plot_click$y) <= range.PC2/100) {
        print(sample.click)
      } else {
        print("No sample with this PC information. Please click one dot")
      }
    }
  })
  
  session$onSessionEnded(function() {
    stopApp()
  })
  
}
