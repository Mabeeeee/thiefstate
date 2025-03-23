# app/main.R

#Appeler des packages
box::use(
  shiny[bootstrapPage, moduleServer, NS],
)
#Appeler des modules
box::use(
  app/view/chart,
  app/view/Accueil,
  app/view/module_urssaf,
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  bootstrapPage(
    shiny::tabsetPanel(
      id = "main_tabs",
      shiny::tabPanel("Module Accueil",
                      Accueil$ui(ns("accueil"))),
      shiny::tabPanel("Module URSSAF",
                      module_urssaf$ui(ns("urssaf")))
      #chart$ui(ns("chart"))
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    Accueil$server("accueil")
    module_urssaf$server("urssaf")
    #chart$server("chart") #Si chart depend d'un df on peut rentrer data en argument
  })
}
