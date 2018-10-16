# FPL Dashboard

library(shiny)
fpl <- readRDS("fpl_data.rds")
fpl_grouped <- fpl %>%
  group_by(name) %>%
  summarise(
    team = min(team), 
    position = min(position),
    total_points = sum(total_points),
    now_cost = min(position),          
    minutes = sum(minutes),                      
    goals = sum(goals_scored),                  
    assists = sum(assists),
    clean_sheets = sum(clean_sheets),
    goals_conceded = sum(goals_conceded),                 
    yellow_cards = sum(yellow_cards),                   
    red_cards = sum(red_cards),                      
    bonus = sum(bonus),                         
    bps = sum(bps),                            
    image_url = min(image_url)
    )

# Define UI for application
ui <- fluidPage(
   
   # Application title
   titlePanel("FPL Dashboard"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
      
      # Select variable for y-axis  
      selectInput(inputId = "y", 
                  label = "Y-axis:",
                  choices = names(fpl_grouped), 
                  selected = "goals"),
      
      # Select variable for x-axis
      selectInput(inputId = "x", 
                  label = "X-axis:",
                  choices = names(fpl_grouped), 
                  selected = "minutes"),
      
      # Select variable for color
      selectInput(inputId = "z", 
                  label = "Colour",
                  choices = c("team", "position"),
                  selected = "position")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("scatterPlot")
      )
   )
)

# Define server logic required to for any plots
server <- function(input, output) {
   
   output$scatterPlot <- renderPlot({
     ggplot(data = fpl_grouped, aes_string(x = input$x, y = input$y,
                                           colour = input$z)) +
       geom_point()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

