library(leaflet)

#Choices for drop-downs
vars <- c(
  "Business Day" = 1,
  "Not Business Day" = 2

)


navbarPage("Taxi", id="nav", 
           #title = 'taxi menu',
           
           tabPanel("Interactive map",
                    div(class="outer",
                        
                        tags$head(
                          # Include our custom CSS
                          includeCSS("styles.css"),
                          includeScript("gomap.js")
                        ),
                        
                        leafletOutput("map", width="100%", height="100%"),
                        
                        # Shiny versions prior to 0.11 should use class="modal" instead.
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 60, left = 0, right = "auto", bottom = 0,
                                      width = 330, height = "auto",
                                      
                                      h2("Taxi"),
                                      
                                      selectInput("days", "Days", c("All Day", "Business Day", "Not Business Day"),selected = "All Day"),
                                      
                                      checkboxInput(inputId = "showhr",
                                                    label = strong("Show hours"),
                                                    value = FALSE),
                                      
                                        conditionalPanel(condition = "input.showhr == false"
                              
                                        ),
                                      
                                      
                                      conditionalPanel(condition = "input.showhr == true",
                                                       sliderInput(inputId = "hr_adjust",
                                                                   label = "Choose the time of the day:",
                                                                   min = 0, max = 23, value = NULL, step = 1)
                                      ),
                                      
                                      selectInput("size", "Size", vars, selected = "adultpop"),
                                      conditionalPanel("input.color == 'superzip' || input.size == 'superzip'",
                                                       # Only prompt for threshold when coloring or sizing by superzip
                                                       numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
                                      ),
                                      
                                      plotOutput("histCentile", height = 200),
                                      plotOutput("scatterCollegeIncome", height = 250)
                        )
                        
                    )
           ),
           
           # tabPanel("Data explorer",
           #          fluidRow(
           #            column(3,
           #                   selectInput("states", "States", c("All states"="", structure(state.abb, names=state.name), "Washington, DC"="DC"), multiple=TRUE)
           #            ),
           #            column(3,
           #                   conditionalPanel("input.states",
           #                                    selectInput("cities", "Cities", c("All cities"=""), multiple=TRUE)
           #                   )
           #            ),
           #            column(3,
           #                   conditionalPanel("input.states",
           #                                    selectInput("zipcodes", "Zipcodes", c("All zipcodes"=""), multiple=TRUE)
           #                   )
           #            )
           #          ),
           #          fluidRow(
           #            column(1,
           #                   numericInput("minScore", "Min score", min=0, max=100, value=0)
           #            ),
           #            column(1,
           #                   numericInput("maxScore", "Max score", min=0, max=100, value=100)
           #            )
           #          ),
           #          hr(),
           #          DT::dataTableOutput("ziptable")
           # ),
           
           conditionalPanel("false", icon("crosshair"))
)
