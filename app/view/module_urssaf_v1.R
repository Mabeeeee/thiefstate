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

  bslib::page_sidebar(

    sidebar = bslib::sidebar(
      "Great sidebar",
      width = 200,
      position = "left",
      open = "always",
      fillable = TRUE
    ),

    shiny::tagList(
      shiny::div(id = "simulator-container"),  # Un conteneur pour l'iframe
      shiny::tags$script(shiny::HTML(
        '
      setTimeout(function() {
        var script = document.createElement("script");
        script.src = "https://mon-entreprise.urssaf.fr/simulateur-iframe-integration.js";
        script.setAttribute("data-module", "simulateur-embauche");
        script.setAttribute("data-couleur", "#005aa1");
        document.getElementById("simulator-container").appendChild(script);
      }, 500);
      '
      ))
    )
  )


}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {

  })
}
