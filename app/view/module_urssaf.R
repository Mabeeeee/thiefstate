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

  bslib::page_fluid(

    shiny::tags$head(
      shiny::tags$style(shiny::HTML("
      .btn-custom {
        background-color: #013220 !important; /* Vert sapin */
        color: white !important; /* Texte blanc */
        border-color: #013220 !important; /* Bordure assortie */
      }
    "))
    ),

    bslib::page_sidebar(

      sidebar = bslib::sidebar(
        "Great sidebar",
        width = 150,
        position = "left",
        open = "always"
      ),
      shiny::tags$script(
        src = "https://mon-entreprise.urssaf.fr/simulateur-iframe-integration.js",
        `data-module` = "simulateur-embauche",
        `data-couleur` = "#005aa1"
      )
    )
  )

}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {

  })
}
