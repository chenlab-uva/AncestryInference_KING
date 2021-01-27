# ui.R
ui <- fluidPage( 
  titlePanel(h4("Input Information")),
  sidebarLayout(position = "left",
                sidebarPanel( 
                  fileInput("file1", "Choose txt file",accept = "text"),
                  selectInput(inputId = "Ancestry", label = "Ancestry", choices=c(" ")),
                  width = 2
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
