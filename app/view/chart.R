box::use(
  dplyr,
  shiny[h3, moduleServer, NS, tagList, plotOutput, renderPlot, actionButton, reactiveVal, observeEvent],
)
box::use(
  app/logic/fct_utils[transform_data],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  tagList(
    h3("Chart"),
    actionButton(ns("show_chart"), "Afficher le graph"),
    plotOutput(ns("plot"))
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    data <- reactiveVal(NULL)

    observeEvent(input$show_chart, {
      # Simulation de données, peut être remplacé par une transformation de données réelle
      df <- data.frame(
        x = 1:10,
        y = rnorm(10)
      )
      data(df)
    })

    output$plot <- renderPlot({
      shiny::req(data())  # Attend que les données soient disponibles
      plot(data()$x, data()$y, type = "b", col = "blue", pch = 19, main = "Graphique")
    })
  })
}
