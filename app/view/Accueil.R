#Accueil

# app/view/chart.R

box::use(
  dplyr,
  shiny[h3, moduleServer, NS, tagList, tags, HTML],
  bslib,
)
box::use(
  app/logic/fct_utils[transform_data],
  app/logic/fct_utils[create_config],
  app/view/module_urssaf,
  app/view/Accueil_detail
) #Ici on ajoute une fonction qui provient de logic/fct_utils

#' @export
ui <- function(id) {
  ns <- NS(id)

  bslib::page_fluid(

    tags$head(
      tags$style(HTML("
      .btn-custom {
        background-color: #013220 !important; /* Vert sapin */
        color: white !important; /* Texte blanc */
        border-color: #013220 !important; /* Bordure assortie */
      }
    "))
    ),

    # Conteneur dynamique qui pourra être remplacé par l'UI du module
    shiny::uiOutput(ns("main_ui"))
  )
}


#' @export
server <- function(id) { #Si chart depend d'un df on peut rentrer data en argument
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # UI de base affichée au début
    output$main_ui <- shiny::renderUI({
      Accueil_detail$ui(ns("Accueil_detail"))
    })

    # Récupérer les inputs du module d'accueil
    accueil_inputs <- Accueil_detail$server("Accueil_detail")

    shiny::observeEvent(accueil_inputs()$btn_simu, { # Utilisation correcte de reactive()
      print("bééééé")
      output$main_ui <- shiny::renderUI({
        module_urssaf$ui(ns("urssaf"))
      })
      module_urssaf$server("urssaf")

    })
  })
}





