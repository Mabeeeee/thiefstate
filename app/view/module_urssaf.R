box::use(
  dplyr,
  shiny[h3, moduleServer, NS, tagList, plotOutput, renderPlot, actionButton, reactiveVal, observeEvent],
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

  bslib::page_sidebar(

    sidebar = bslib::sidebar(
      "Navigation",
      width = 200,
      position = "left",
      open = "open",
      fillable = TRUE,
      shiny::actionButton(ns("btn_retour"), "Retour page principale")
    ),

    shiny::tagList(
      bslib::accordion(
        bslib::accordion_panel(
          "Paramétrage du montant",
          shiny::fluidRow(

            shiny::column(4,
                          shinyWidgets::prettyRadioButtons(ns("btn_mnt_tempo"),
                                                           label = "Temporalité de la somme",
                                                           choices = c("€/mois", "€/an"),
                                                           selected = "€/mois",
                                                           status = "primary",
                                                           inline = TRUE)
            ),
            shiny::column(4,
                          shiny::numericInput(
                            inputId = ns("mnt"),
                            label = "Votre montant",
                            value = 2300)),

            shiny::column(4,
                          shinyWidgets::pickerInput(inputId = ns("type_mnt"),
                                                    label = "Quel est le type du montant ?",
                                                    choices = c("Super brut" = "salarié . coût total employeur",
                                                                "Brut" = "salarié . contrat . salaire brut",
                                                                "Net avant impots" = "salarié . rémunération . net . à payer avant impôt",
                                                                "Net après impots" = "salarié . rémunération . net . payé après impôt")
                          )),

          ),

        ),
        bslib::accordion_panel(
          "Paramétrage du contrat",
          shiny::fluidRow(

            shiny::column(4,
                          shinyWidgets::pickerInput(inputId = ns("type_ctr"),
                                                    label = "Quel est le type du contrat",
                                                    choices = c("CDI",
                                                                "CDD",
                                                                "apprentissage",
                                                                'professionnalisation',
                                                                'stage')
                          )),
            shiny::column(4,shinyWidgets::prettyRadioButtons(ns("btn_ctr"),
                                                             label = "Statut cadre",
                                                             choices = c("oui","non"),
                                                             selected = "oui",
                                                             inline = TRUE)
            ),
            shiny::column(4,shinyWidgets::materialSwitch(ns("ctr_tp"),
                                                         label = "Votre contrat est-il en temps partiel ?",
                                                         value = FALSE),
                          shinyjs::hidden(
                            shiny::div(id = ns("div_temp_part"),
                                       shiny::numericInput(
                                         inputId = ns("temp_sem"),
                                         label = "Votre temps d'heures par semaine",
                                         value = 35))

                          )
            ),
          )
        )
      ),
      shiny::fluidRow(
        shiny::actionButton(
          ns("btn_fiche"),
          "Générer la fiche de paie"
        )
      ),

      shiny::fluidRow(
        shiny::column(6,
                      DT::DTOutput(ns("table_fiche_paie_emp"))
        ),
        shiny::column(6,
                      DT::DTOutput(ns("table_fiche_paie_sala"))
        ),

      )

    )
  )


}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns



    shinyjs::useShinyjs()

    tempo <- input$btn_mnt_tempo
    montant <- input$mnt
    type_montant <- input$type_mnt
    type_contrat <- input$type_ctr
    cadre <- input$btn_ctr
    temps_part <- "non"

    shiny::observeEvent(input$btn_mnt_tempo,{
      tempo <- input$btn_mnt_tempo
    })
    shiny::observeEvent(input$mnt,{
      montant <- input$mnt
    })
    shiny::observeEvent(input$type_mnt,{
      type_montant <- input$type_mnt
    })
    shiny::observeEvent(input$type_ctr,{
      type_contrat <- input$type_ctr
    })
    shiny::observeEvent(input$btn_ctr,{
      cadre <- input$btn_ctr
    })
    shiny::observeEvent(input$ctr_tp,{

      if(input$ctr_tp){
        temps_part <- "oui"
        shinyjs::show("div_temp_part")
        heures_tp <- input$temp_sem
      }else{
        temps_part <- "non"
        shinyjs::hide("div_temp_part")
      }

    })

    shiny::observeEvent(input$btn_fiche,{

      print("Génération de la fiche de paie")

      tempo <- input$btn_mnt_tempo
      montant <- input$mnt
      type_montant <- input$type_mnt
      type_contrat <- input$type_ctr
      cadre <- input$btn_ctr
      temps_part <- temps_part
      heures_tp <- input$temp_sem

      if(type_contrat == "alternance"){
        cadre <- "non"
      }

      #on lance la création du body de la requete API : pour la partie salaire
      expression <-c(
        "salarié . coût total employeur",
        "salarié . contrat . salaire brut",
        "salarié . rémunération . net . à payer avant impôt",
        "salarié . rémunération . net . payé après impôt"
      )
      body <- api_create_body(expression,
                              type_salaire = type_montant,
                              type_contrat = type_contrat,
                              temp_partiel = temps_part,
                              statut_cadre = cadre,
                              heures_partiel = heures_tp,
                              montant_salaire = montant,
                              tempo_salaire = tempo)

      salaires <- api_get_result(body, type_montant = "salaire")

      api_beau_labels(type_montant = "salaire")

      transform_labels(salaires, type_montant = "salaire")

      #on lance la création du body de la requete API : pour la partie cotisations
      expression <-c(
        "salarié . cotisations . maladie . employeur",
        "salarié . cotisations . maladie . salarié",
        "salarié . cotisations . prévoyances . santé . employeur",
        "salarié . cotisations . prévoyances . santé . salarié",
        "salarié . cotisations . ATMP",
        "salarié . cotisations . ATMP . salarié",
        "salarié . cotisations . vieillesse . plafonnée . employeur",
        "salarié . cotisations . vieillesse . plafonnée . salarié",
        "salarié . cotisations . vieillesse . déplafonnée . employeur",
        "salarié . cotisations . vieillesse . déplafonnée . salarié",
        "salarié . cotisations . retraite complémentaire-CEG-CET . employeur",
        "salarié . cotisations . retraite complémentaire-CEG-CET . salarié",
        "salarié . cotisations . allocations familiales",
        "salarié . cotisations . allocations familiales . salarié",
        "salarié . cotisations . assurance chômage",
        "salarié . cotisations . assurance chômage . salarié",
        "salarié . cotisations . autres employeur",
        "salarié . cotisations . autres employeur . salarié",
        "salarié . cotisations . CSG-CRDS . CSG . déductible . employeur",
        "salarié . cotisations . CSG-CRDS . CSG . déductible",
        "salarié . cotisations . CSG-CRDS . sur revenus imposables non déductible . employeur",
        "salarié . cotisations . CSG-CRDS . sur revenus imposables non déductible",
        "salarié . cotisations . APEC . employeur",
        "salarié . cotisations . APEC . salarié",
        "salarié . cotisations . exonérations . employeur",
        "salarié . cotisations . exonérations . salarié"
      )
      body <- api_create_body(expression,
                              type_salaire = type_montant,
                              type_contrat = type_contrat,
                              temp_partiel = temps_part,
                              statut_cadre = cadre,
                              heures_partiel = heures_tp,
                              montant_salaire = montant,
                              tempo_salaire = tempo)

      cotisations <- api_get_result(body, type_montant = "cotis")

      api_beau_labels(type_montant = "cotis")

      tab_super_brut <- salaires |>
        dplyr::filter(labels == "Coût Total Employeur") |>
        rbind(cotisations |> dplyr::filter(montant_employeur != 0) |>
                dplyr::mutate(montant_employeur = -montant_employeur) |>
                dplyr::select(label_base, montant_employeur) |> dplyr::rename(labels = label_base,
                                                                              montants = montant_employeur)) |>
        rbind(salaires |> dplyr::filter(labels == "Salaire Brut"))

      tab_super_net <- salaires |> dplyr::filter(labels == "Salaire Brut") |>
        rbind(cotisations |> dplyr::filter(.data[["montant_salarié"]] != 0) |>
                               dplyr::mutate(!!"montant_salarié" := -.data[["montant_salarié"]]) |>
                               dplyr::select(label_base, .data[["montant_salarié"]]) |> dplyr::rename(labels = label_base,
                                                                                                      montants = .data[["montant_salarié"]])) |>

        rbind(salaires |> dplyr::filter(labels %in% c("Net à Payer Avant Impôt", "Net Payé Après Impôt")))

      output$table_fiche_paie_emp <- DT::renderDT({
        DT::datatable(tab_super_brut,
                      escape = FALSE,
                      rownames = FALSE,
                      options = list(dom = 'Brt',
                                     pageLength = 30,
                                     columnDefs = list(
                                       list(width = '150px', targets = 0),
                                       list(width = '80px', targets = 1)
                                     ))) |>
          DT::formatStyle(
            'montants',
            color = DT::styleInterval(0, c('red', 'black'))
          ) |>
          DT::formatCurrency(columns = "montants", currency = "€", mark = " ", dec.mark = ",")
      })

      output$table_fiche_paie_sala <- DT::renderDT({
        DT::datatable(tab_super_net,
                      escape = FALSE,
                      rownames = FALSE,
                      options = list(dom = 'Brt',
                                     pageLength = 30,
                                     columnDefs = list(
                                       list(width = '150px', targets = 0),
                                       list(width = '80px', targets = 1)
                                     ))) |>
          DT::formatStyle(
            'montants',
            color = DT::styleInterval(0, c('red', 'black'))
          ) |>
          DT::formatCurrency(columns = "montants", currency = "€", mark = " ", dec.mark = ",")
      })
    })

  })
}
