#Accueil

# app/view/chart.R

box::use(
  dplyr,
  shiny[h3, moduleServer, NS, tagList, tags, HTML],
  bslib,
)
box::use(
  app/logic/fct_utils[transform_data],
  app/view/module_urssaf,
  app/view/module_tva
) #Ici on ajoute une fonction qui provient de logic/fct_utils

#' @export
ui <- function(id) {
  ns <- NS(id)

  bslib::page_sidebar(

    sidebar = bslib::sidebar(
      "Navigation",
      width = 200,
      position = "left",
      open = "open",
      fillable = TRUE,
      shiny::actionButton(ns("btn_retour"), "Retour page principale")
    ),

    shiny::h2("Application"),
    shiny::h6("Grâce à cette application vous pouvez consulter les flux d'argent\n de votre super brut
                à votre salaire consommé. "),
    shiny::p("Pour cela, 4 modules sont à disposition :",
             "- Un module reprenant le calculateur de l'URSSAF qui permet de générer une fiche de paie
                au format pdf. Ce fichier permet d'obtenir les données de flux du super brut au salaire net avant impôt.",
             "- Un deuxieme module permettant de générer les données à partir de la fiche créée dans le premier.",
             "- Un troisième module permettant d'extraire depuis un relevé bancaire l'ensemble des consommations et taxes payées.",
             "- Un dernier module représentant les flux générés précédemment sous forme de tableau et graphique."),
    shiny::br(),

    bslib::layout_column_wrap(
      bslib::card(bslib::value_box(
        value = "Calculateur URSSAF",
        showcase = bsicons::bs_icon("piggy-bank"),
        showcase_layout = "top right",
        theme = "blue",
        bslib::popover(
          shiny::actionButton(ns("btn_simu"), value ="module_urssaf",
                              label = "Accès module", class = "btn-custom"),

          "Simulateur URSSAF",
          "Créez votre fiche de paie à partir du simulateur.",
          placement = "right"
        )
      )),
      bslib::card(bslib::value_box(
        value = "Consommation",
        showcase = bsicons::bs_icon("car-front"),
        showcase_layout = "top right",
        theme = "white",
        bslib::popover(
          shiny::actionButton(ns("btn_conso"), value ="module_conso",
                              label = "Accès module", class = "btn-custom"),

          "",
          "",
          placement = "right"
        )
      )),
      bslib::card(bslib::value_box(
        value = "Graphique",
        showcase = bsicons::bs_icon("bar-chart-steps"),
        showcase_layout = "top right",
        theme = "red",
        bslib::popover(
          shiny::actionButton(ns("btn_graph"), value ="module_graph",
                              label = "Accès module", class = "btn-custom"),

          "",
          "",
          placement = "right"
        )
      )),
      width = "500px",
      height = "500px"
    )
  )

}

#' @export
server <- function(id) { #Si chart depend d'un df on peut rentrer data en argument
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Retourner l'input du module pour être accessible ailleurs
    return(shiny::reactive({ list(btn_simu = input$btn_simu,
                                  btn_conso = input$btn_conso,
                                  btn_graph = input$btn_graph,
                                  btn_retour = input$btn_graph) }))

    shiny::observeEvent(input$btn_retour, { # Utilisation correcte de reactive()

      shiny::renderUI({
        Accueil_detail$ui(ns("Accueil_detail"))
      })
      Accueil_detail$server("Accueil_detail")

    })

  })
}





