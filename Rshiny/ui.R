# ui.R
ui <- fluidPage( 
  titlePanel(("Interface for Interactive Plot of Ancestry")),
  sidebarLayout(position = "left",
                sidebarPanel( 
                  fileInput("file1", "Choose a text file with ancestry information",accept = "text"),
                  selectInput("Ancestry", label = "Ancestry", choices = c(Choose=''), selected = NULL),
                  #textInput("FID_IID", "FID_IID", value = ""),
                  fluidRow(
                    column(5, textInput(inputId = "SampleFID",
                                        label = "FID",
                                        value = " ",
                                        width = "100px")
                    ),
                    column(5, ofset = 3,
                           textInput(inputId = "SampleIID",
                                     label = "IID",
                                     value = "",
                                     width = "100px")
                    )),
                  actionButton(inputId = "EnterID", label = "Enter Sample FID and IID"),
                  width = 3
                ),
                mainPanel(
                  fluidRow(
                    plotOutput(outputId = "plot1", width = "100%"),
                    plotOutput(outputId = "plot2", width = "100%", click = "plot_click")),
                  fluidRow(
                    column(width = 12,
                           verbatimTextOutput("click_info"),
                           verbatimTextOutput("last_infor"),
                           dataTableOutput('table'))))
                
  )
)
