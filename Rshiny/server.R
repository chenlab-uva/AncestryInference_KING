server <- function(input, output, session) {
  
  data <- reactive({
    req(input$file1)
    file1 <- input$file1
    ex_df <- read.table(file = file1$datapath, header = TRUE, stringsAsFactors = FALSE)
    ex_df$Ancestry[is.na(ex_df$Ancestry)] <- "Missing"
    ex_df$Ancestry[grep(";", ex_df$Ancestry)] <- "Missing"
    updateSelectInput(session, "Ancestry", label = "Step 2: Choose the ancestry group", choices = c(Choose='', unique(ex_df$Ancestry)), selected = NULL)
    return(ex_df)
  })
  
  filename <- reactive({
    req(input$file1)
    file.info <- input$file1
    filename.tmp <- gsub(".*/", "", file.info$name)
    file_prefix <- gsub("_.*", "", filename.tmp)
    return(file_prefix)
  })
  
  subset.df <- reactive({
    req(data())
    ex_df2 <- data()
    sub_ex_df <- ex_df2[ex_df2$Ancestry == input$Ancestry, ]
    return(sub_ex_df)
  })
  
  output$plot1 <- renderPlot({
    req(data())
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
    if (n <= 13) {
      Palette <- predefined.col[1:n]
    } else {
      Palette <- ggcolor_hue(n)
    }
    if ("Missing" %in% uniq.grp) {
      cols = c(Palette[1:(n - 1)], "#999999")
    } else {
      cols = Palette[1:n]
    }
    ggplot(ex_df, aes(PC1, PC2, color = Ancestry)) + geom_point(aes(colour = factor(Ancestry, levels = legend.group))) + 
      scale_colour_manual(values = cols) + 
      ggtitle(paste0("PC Coordinates and Inferred Ancestry for Samples in ", studyname," (N=", sample.size, ")")) + 
      theme(text=element_text(size=12))
  })
  
  
  # PLOT 2
  output$plot2 <- renderPlot({
    req(input$Ancestry)
    full.df <- data()
    uniq.grp <- unique(full.df$Ancestry)
    if ("Missing" %in% uniq.grp) {
      legend.group <- c(sort(uniq.grp[uniq.grp != "Missing"]), "Missing")
    } else {
      legend.group <- sort(uniq.grp)
    }
    n = length(uniq.grp)
    if (n <= 13) {
      Palette <- predefined.col[1:n]
    } else {
      Palette <- ggcolor_hue(n)
    }
    if ("Missing" %in% uniq.grp) {
      cols = c(Palette[1:(n - 1)], "#999999")
    } else {
      cols = Palette[1:n]
    }
    sub.group.num <- sum(full.df$Ancestry == input$Ancestry)
    subset.df.2 <- subset.df()
    ggplot(subset.df.2, aes(PC1, PC2)) + geom_point(color = cols[legend.group %in% input$Ancestry]) + 
      ggtitle(paste0("Interactive Plot for Samples of ", input$Ancestry, " Ancestry (N=", sub.group.num, ")")) + 
      theme(text = element_text(size = 12))
  })
  
  output$click_info <- renderPrint({
    req(input$plot_click)
    req(subset.df())
    subdf <- subset.df()
    range.PC1 <- max(subdf$PC1) - min(subdf$PC1)
    range.PC2 <- max(subdf$PC2) - min(subdf$PC2)
    #cat(paste0("PC1 = ", round(input$plot_click$x, 4), "; PC2 = ", round(input$plot_click$y, 4)))
    #cat("\n")
    sample.click <- subdf[which.min((subdf$PC1 - input$plot_click$x)^2 + (subdf$PC2 - input$plot_click$y)^2), ]
    
    
    if (abs(sample.click$PC1 - input$plot_click$x) >= range.PC1/100 | abs(sample.click$PC2 - input$plot_click$y) >= range.PC2/100) {
      sample.click <- NULL 
      print("No sample with this PC information. Please click one dot")
    }
    output$table1 <- renderDataTable({
      sample.click
    })
  })
  
  output$table2 <- renderDataTable({
    req(input$EnterFID)
    req(input$FID)
    req(data())
    select.df <- data()
    select.df <- select.df[select.df$FID == input$FID, ]
    validate(
      need(nrow(select.df) > 0, "Please choose a valid Family ID")
    )
    select.df
  })
  
  session$onSessionEnded(function() {
    stopApp()
  })
  
}
