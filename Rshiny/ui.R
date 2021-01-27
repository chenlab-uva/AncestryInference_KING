# ui.R
ui <- fluidPage( 
  titlePanel(("Interface for Interactive Plot of Ancestry")),
  sidebarLayout(position = "left",
                sidebarPanel( 
                  fileInput("file1", "Choose a text file with ancestry information",accept = "text"),
                  selectInput(inputId = "Ancestry", label = "Ancestry", choices=c(" ")),
                  width = 3
                ),
                mainPanel(
                  fluidRow(
                    plotOutput(outputId = "plot1", width = "100%"),
                    plotOutput(outputId = "plot2", width = "100%", click = "plot_click")),
                  fluidRow(
                    column(width = 12,
                           verbatimTextOutput("click_info"),
                           verbatimTextOutput("last_infor"))))
  )
)
