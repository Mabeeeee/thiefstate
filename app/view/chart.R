# app/view/chart.R

box::use(
  dplyr,
  shiny[h3, moduleServer, NS, tagList],
)
box::use(
  app/logic/fct_utils[transform_data],
) #Ici on ajoute une fonction qui provient de logic/fct_utils

#' @export
ui <- function(id) {
  ns <- NS(id)

  h3("Chart")
}

#' @export
server <- function(id) { #Si chart depend d'un df on peut rentrer data en argument
  moduleServer(id, function(input, output, session) {
    print("Chart module server part works!")
  })
}
