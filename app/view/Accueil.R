#Accueil

# app/view/chart.R

box::use(
  dplyr,
  shiny[h3, moduleServer, NS, tagList, tags, HTML],
  bslib,
)
box::use(
  app/logic/fct_utils[transform_data],
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

    bslib::page_sidebar(

      sidebar = bslib::sidebar(
        "Great sidebar",
        width = 150,
        position = "left",
        open = "always"
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
                      theme = "secondary",
                      bslib::popover(
                        shiny::actionButton("btn_simu", "Accès module", class = "btn-custom"),

                        "",
                        "",
                        placement = "right"
                      )
                    )),
        bslib::card(bslib::value_box(
                      value = "Fiche de paie",
                      showcase = bsicons::bs_icon("file-earmark-spreadsheet"),
                      showcase_layout = "top right",
                      theme = "primary",
                      bslib::popover(
                        shiny::actionButton("btn_paie", "Accès module", class = "btn-custom"),

                        "",
                        "",
                        placement = "right"
                      )
                    )),
        bslib::card(bslib::value_box(
                      value = "Consommation",
                      showcase = bsicons::bs_icon("car-front"),
                      showcase_layout = "top right",
                      theme = "secondary",
                      bslib::popover(
                        shiny::actionButton("btn_conso", "Accès module", class = "btn-custom"),

                        "",
                        "",
                        placement = "right"
                      )
                    )),
        bslib::card(bslib::value_box(
                      value = "Graphique",
                      showcase = bsicons::bs_icon("bar-chart-steps"),
                      showcase_layout = "top right",
                      theme = "primary",
                      bslib::popover(
                        shiny::actionButton("btn_graph", "Accès module", class = "btn-custom"),

                        "",
                        "",
                        placement = "right"
                      )
                    )),
        width = "400px",
        height = "500px"
      )
    )
  )
}

#' @export
server <- function(id) { #Si chart depend d'un df on peut rentrer data en argument
  moduleServer(id, function(input, output, session) {

  })
}





