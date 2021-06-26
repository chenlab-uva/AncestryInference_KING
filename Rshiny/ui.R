ui <- fluidPage( 
  titlePanel(("Interface for Interactive Plot of Ancestry")),
  sidebarLayout(position = "left", 
                sidebarPanel( 
                  fileInput("file1", "Step1: Please choose a *.txt file with ancestry information",accept = "text"),
                  selectInput("Ancestry", label = "Step 2: Choose the ancestry group", choices = c(Choose=''), selected = NULL),
                  textInput(inputId = "FID", label = "Or Step 2b: please specify the family size", value = " "),
                  actionButton(inputId = "EnterFID", label = "Submit Family ID"),
                  width = 2
                ),
                mainPanel(
                  fluidRow(
                    splitLayout(
                      plotOutput(outputId = "plot1", width = "100%"),
                      plotOutput(outputId = "plot2", width = "100%", click = "plot_click"))
                  ),
                  fluidRow(
                    dataTableOutput('table1'),
                    dataTableOutput('table2')
                  ),
                  fluidRow(
                    column(width = 12,
                           verbatimTextOutput("click_info"),
                           verbatimTextOutput("last_infor"))))
                
  )
)
