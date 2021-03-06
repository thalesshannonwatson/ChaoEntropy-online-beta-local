require(shiny)
require(knitr)
# require(shinyIncubator)

loadingBar <- tags$div(class="progress progress-striped active",
                       tags$div(class="bar", style="width: 100%;"))
# Code for loading message
loadingMsg <- tags$div(class="modal", tabindex="-1", role="dialog", 
                       "aria-labelledby"="myModalLabel", "aria-hidden"="true",
                       tags$div(class="modal-header",
                                tags$h3(id="myModalHeader", "Loading...")),
                       tags$div(class="modal-footer",
                                loadingBar))
# The conditional panel to show when shiny is busy
loadingPanel <- conditionalPanel(paste("input.goButton > 0 &&", 
                                       "$('html').hasClass('shiny-busy')"),
                                 loadingMsg)


shinyUI(navbarPage(
#   theme = "bootstrap.css",
  title=("ChaoEntropy Online"),
  tabPanel(("Shannon entropy"),
           h1("ChaoEntropy"),
           sidebarLayout(
             sidebarPanel(
               tags$head(
                 tags$style(type="text/css", "label.radio { display: inline-block; }", ".radio input[type=\"radio\"] { float: none; }"),
                 tags$style(type="text/css", "select { max-width: 250px; }"),
                 tags$style(type="text/css", "input { max-width: 250px; }"),
                 tags$style(type="text/css", "textarea { max-width: 230px; }"),
                 tags$style(type='text/css', ".span4 { max-width: 300px; }")
               ),
               actionButton("goButton", span("Run!", style="font-size: 40px"), icon = icon("rocket", "fa-3x")),
               p(h4("Data Setting")),
               wellPanel(
                 selectInput(inputId="datatype", label="Select data type:",
                             choices=c("Abundance data"="abu", "Incidence data"="inc")),
                 
                 radioButtons(inputId="source", "Choose one:", 
                              choices=c("Import data" = "import", "Upload data" = "upload")
                 ),
                 conditionalPanel(condition="input.source == 'upload'",
                                  fileInput("files", "Choose File (.csv)", accept=".csv")
                 ),
                 
                 conditionalPanel(condition="input.source == 'import'",
                                  p("Import data:"),
                                  conditionalPanel(
                                    condition="input.datatype == 'abu'",
                                    tags$textarea(id="copyAndPaste_abu", rows=5, 
                                                  "Spider 46 22 17 15 15  9  8  6  6  4  2  2  2  2  1  1  1  1  1  1  1  1  1  1  1  1  \nBirds 752 276 194 126 121 97  95  83  72  44  39  0  16  15  0  13  9  9  9  8  7  4  0  0  2  2  1  1  1")
                                  ),
                                  conditionalPanel(
                                    condition="input.datatype == 'inc'",
                                    tags$textarea(id="copyAndPaste_inc", rows=5, 
                                                  "Ant 62  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  2  3  3  3  3  3  3  3  3  3  3  3  3  3  4  4  4  4  4  4  4  5  5  5  5  6  6  7  9  9  9  9 10 10 12 13 14 14 14 15 15 16 18 19 19 20 29 \nSeedlings 121  61  47  52  43  43   9  24   5  24  11  11  13  17   6  10   3   8   9   9  3   6   6   1   7   4   6   6   4   3   4   2   2   1   1")
                                  ),          
                                  p(em("Refer to user guide for importing data"))
                 ),
                 
                 uiOutput("choose_dataset"),
                 p(em("Using ctrl / command key to select multiple datasets you want"))
               ),
               
               p(h4("General Setting")),
               wellPanel(
                 conditionalPanel(
                   condition = "input.datatype == 'abu'",
                   checkboxGroupInput(inputId="method1", label="Select the methods:",
                                      choices=c("Chao", "ChaoShen", "Grassberger", "Jackknife", "Zhang", "Observed"),
                                      selected=c("Chao", "ChaoShen", "Grassberger", "Jackknife", "Zhang", "Observed"))
                 ),
                 
                 conditionalPanel(
                   condition = "input.datatype == 'inc'",
                   checkboxGroupInput(inputId="method2", label="Select the methods:",
                                      choices=c("Chao", "Observed"), selected=c("Chao", "Observed"))
                 ),
                 numericInput(inputId="nboot", label="Number of bootstraps", value=100, min=1, max=1000, step=1),
                 numericInput(inputId="conf", label="Confidence level", value=0.95, min=0, max=1, step=0.01)
               )
               
             ),
             mainPanel(
               tabsetPanel(
                 tabPanel("Data Summary", h3("Basic data information"),
                          icon = icon("list-alt"),
                          verbatimTextOutput("data_summary")
                 ),
                 tabPanel("Estimation", h3("Estimation of entropy"), 
                          loadingPanel,
                          icon = icon("thumbs-up"),
                          verbatimTextOutput('est'),
                          downloadLink("dlest", "Download as csv file"),
                          conditionalPanel(
                            condition="input.datatype == 'abu'",
                            includeMarkdown("man/estimator_abu.md")),
                          conditionalPanel(
                            condition="input.datatype == 'inc'",
                            includeMarkdown("man/estimator_inc.md"))
                 ),
                 
                 tabPanel("Visualization", h3("Comparison with different methods"), 
                          loadingPanel,
                          icon = icon("bar-chart-o"),
                          plotOutput("visualization", width="800px", height="auto")
                          
                 ),
                 tabPanel("User Guide", icon = icon("question-circle"),includeMarkdown("man/user.md")),
                 tabPanel("R code", icon = icon("wrench"), includeMarkdown("man/[R]code.md"))
               )
             )
           )
  ),
  
  tabPanel(
    title=("Mutual Information "),
    h1("ChaoMI"),
    sidebarLayout(
      sidebarPanel(
        tags$head(
          tags$style(type="text/css", "label.radio { display: inline-block; }", ".radio input[type=\"radio\"] { float: none; }"),
          tags$style(type="text/css", "select { max-width: 250px; }"),
          tags$style(type="text/css", "input { max-width: 250px; }"),
          tags$style(type="text/css", "textarea { max-width: 230px; }"),
          tags$style(type='text/css', ".span4 { max-width: 300px; }")
        ),
        actionButton("MIgoButton", span("Run!", style="font-size: 40px"), icon = icon("rocket", "fa-3x")),
        p(h4("Data Setting")),
        wellPanel(
          radioButtons(inputId="MIsource", "Choose one:", 
                       choices=c("Demo data" = "MIdemo", "Upload data" = "MIupload")
          ),
          conditionalPanel(condition="input.MIsource == 'MIupload'",
                           fileInput("MIfiles1", "Choose File (.csv)", accept=".csv"),
                           fileInput("MIfiles2", "Choose File (.csv)"),
                           fileInput("MIfiles3", "Choose File (.csv)")
          ),
          uiOutput("MIchoose_dataset"),
          p(em("Using ctrl / command key to select multiple datasets you want"))
        ),
        
        p(h4("General Setting")),
        wellPanel(
          checkboxGroupInput(inputId="MImethod", label="Select the methods:",
                             choices=c("Chao", "ChaoShen", "Jackknife", "Bias Correct 1", "Bias Correct 2", "Observed"),
                             selected=c("Chao", "ChaoShen", "Jackknife", "Bias Correct 1", "Bias Correct 2", "Observed")),
          numericInput(inputId="MInboot", label="Number of bootstraps", value=100, min=1, max=1000, step=1),
          numericInput(inputId="MIconf", label="Confidence level", value=0.95, min=0, max=1, step=0.01)
        )
      ),
      mainPanel(
        tabsetPanel(
          tabPanel("Data Viewer", h3("Show raw data"),
                   icon = icon("list-alt"),
                   uiOutput('MIdata_summary')
          ),
          tabPanel("Estimation", h3("Estimation of entropy"), 
                   loadingPanel,
                   icon = icon("thumbs-up"),
                   verbatimTextOutput('MIest'),
                   downloadLink("MIdlest", "Download as csv file"),
                   includeMarkdown("man-mi/estimator-mi.md")
          ),
          tabPanel("Visualization", h3("Comparison with different methods"), 
                   loadingPanel,
                   icon = icon("bar-chart-o"),
                   plotOutput("MIvisualization", width="800px", height="auto")
          ),
          tabPanel("User Guide", icon = icon("question-circle"), 
                   includeMarkdown("man-mi/user-mi.md"))
          #           tabPanel("R code", icon = icon("wrench"), 
          #                    p("Coming soon :)"))
        )
      )
      
    )
  )
  
  
))
