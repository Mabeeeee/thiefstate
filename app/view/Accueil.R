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
  app/view/module_tva,
  app/view/Accueil_detail
) #Ici on ajoute une fonction qui provient de logic/fct_utils

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
    urssaf_inputs <- module_urssaf$server("urssaf")
    tva_inputs <- module_tva$server("conso")


    #Gestion du retour à la page principale ----
    shiny::observeEvent(tva_inputs()$btn_retour, { # Utilisation correcte de reactive()

      output$main_ui <- shiny::renderUI({
        Accueil_detail$ui(ns("Accueil_detail"))
      })
      Accueil_detail$server(ns("Accueil_detail"))

    })
    shiny::observeEvent(urssaf_inputs()$btn_retour, { # Utilisation correcte de reactive()

      output$main_ui <- shiny::renderUI({
        Accueil_detail$ui(ns("Accueil_detail"))
      })
      Accueil_detail$server(ns("Accueil_detail"))

    })

    #Lancement des pages des calculs ----
    shiny::observeEvent(accueil_inputs()$btn_simu, { # Utilisation correcte de reactive()

      output$main_ui <- shiny::renderUI({
        module_urssaf$ui(ns("urssaf"))
      })
      module_urssaf$server("urssaf")

    })
    shiny::observeEvent(accueil_inputs()$btn_conso, { # Utilisation correcte de reactive()

      output$main_ui <- shiny::renderUI({
        module_tva$ui(ns("conso"))
      })
      module_tva$server("conso")

    })




  })
}





