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
  app/view/module_tva,
  app/view/Accueil_detail
)

box::use(
  app/logic/fct_utils[transform_data],
  app/logic/fct_utils[api_create_body],
  app/logic/fct_utils[api_get_result],
  app/logic/fct_utils[api_beau_labels],
  app/logic/fct_utils[transform_labels],
)

#' @export
ui <- function(id) {
  ns <- NS(id)

  bootstrapPage(
    shinyjs::useShinyjs(),
    Accueil$ui(ns("accueil")),
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    Accueil$server("accueil")
  })
}
