box::use(
  dplyr,
  shiny[h3, moduleServer, NS, tagList, plotOutput, renderPlot, actionButton, reactiveVal, observeEvent],
)
box::use(
  app/logic/fct_utils[get_tva_data],
  app/logic/fct_utils[get_tva_tab],
  app/view/Accueil_detail
)

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

    shiny::fluidRow(
      shiny::column(2,
                    shiny::fileInput("file_banque", "Importez vos consommations", accept = ".csv")),
      shiny::column(10,
                    DT::DTOutput(ns("table_tva"))
      ),

    ),
    shiny::fluidRow(
      shiny::column(12,
                    DT::DTOutput(ns("table_tva_bq"))
      ),

    )
  )



}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    shinyjs::useShinyjs()

    donnees <- shiny::reactive({
      readr::read_csv2("app/static/data/Tableau_TVA_moyenne.csv")
    })

    data_banque <- shiny::reactive({
      shiny::req(input$file_banque)

      ext <- tools::file_ext(input$file_banque$name)
      switch(ext,
             csv = vroom::vroom(input$file_banque$datapath, delim = ","),
             tsv = vroom::vroom(input$file_banque$datapath, delim = "\t"),
             shiny::validate("Invalid file; Please upload a .csv or .tsv file")
      )
    })

    output$table_tva <- DT::renderDT({

      testo <- vroom::vroom("app/static/data/Tableau_TVA_moyenne_v2.csv", delim = ",") |>
        dplyr::mutate(
          Taux_TVA_Moyen = paste0(format(round(Taux_TVA_Moyen, 4), decimal.mark = ",", nsmall = 2), " %")
        ) |>
        dplyr::select(1, 3, 2, 4) |>
        dplyr::rename(`Taux Moyen` = Taux_TVA_Moyen)

      DT::datatable(
        testo,
        escape = FALSE,
        rownames = FALSE,
        options = list(
          autoWidth = TRUE,
          dom = 'Brtp',
          pageLength = 5,
          columnDefs = list(
            list(width = '120px', targets = c(0, 2)),
            list(width = '400px', targets = c(1)),  # 2x plus large
            list(width = '80px', targets = c(3))   # pour les colonnes de taux
          )
        )
      )

    })

    output$table_tva_bq <- DT::renderDT({

      DT::datatable(
        data_banque() |>
          get_tva_data() |>
          get_tva_tab() |>
          dplyr::mutate(Part_TVA_Moyenne = mnt_tot * (Taux_TVA_Moyen/100)),
        escape = FALSE,
        rownames = FALSE,
        options = list(
          autoWidth = TRUE,
          dom = 'Brtp',
          pageLength = 5,
          columnDefs = list(
            list(width = '90px', targets = c(1, 2)),
            list(width = '400px', targets = c(0)),  # 2x plus large
            list(width = '80px', targets = c(3))   # pour les colonnes de taux
          )
        )
      )

    })
    # Retourner l'input du module pour être accessible ailleurs
    return(shiny::reactive({ list(btn_retour = input$btn_retour) }))
  })
}
