# app/main.R

#Appeler des packages
box::use(
  shiny[bootstrapPage, moduleServer, NS],
)
#Appeler des modules
box::use(
  app/view/chart,
  app/view/Accueil,
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  bootstrapPage(
    Accueil$ui(ns("accueil")),
    #chart$ui(ns("chart"))

  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    Accueil$server("accueil")
    #chart$server("chart") #Si chart depend d'un df on peut rentrer data en argument
  })
}
