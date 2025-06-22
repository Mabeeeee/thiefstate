# app/logic/data_transformation.R

box::use(
  tidyr[pivot_wider],
)

#' @export
transform_data <- function(data) {
  pivot_wider(
    data = data,
    names_from = Species,
    values_from = Population
  )
}

#' @export
create_config <- function(){

  config <- list(
    urssaf = FALSE,
    fiche_paie = FALSE,
    conso = FALSE,
    graph = FALSE
  )
  return(config)
}

#' @export
api_create_body <- function(expressions,
                            type_salaire = "salarié . rémunération . net . à payer avant impôt",
                            type_contrat = "CDI",
                            temp_partiel = "non",
                            statut_cadre = "oui",
                            heures_partiel = NULL,
                            montant_salaire = 2300, tempo_salaire = "€/mois"){
  unit <- "unité"
  contrat <- paste0("salarié . contrat . ", type_contrat)
  act_part <- "salarié . activité partielle"
  cadre_ou_non <- "salarié . contrat . statut cadre"
  body <- rlang::list2(
    expressions = expressions,
    situation = rlang::list2(
      dirigeant = "non",
      !!cadre_ou_non := statut_cadre,
      !!act_part := temp_partiel,
      !!contrat := "oui",
      !!!if (temp_partiel == "oui") rlang::list2(
        `salarié . contrat . temps de travail . temps partiel . heures par semaine` = heures_partiel
      ),
      !!type_salaire := rlang::list2(
        valeur = montant_salaire,
        !!unit := tempo_salaire
      )
    )
  )
  return(body)
}

#' @export
api_get_result <- function(body, type_montant = "cotis"){

  # Requête POST
  response <- httr::POST(
    url = "https://mon-entreprise.urssaf.fr/api/v1/evaluate",
    httr::add_headers(
      "accept" = "application/json",
      "content-type" = "application/json"
    ),
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    encode = "raw"
  )

  # Parsing
  res <- httr::content(response, "parsed", simplifyVector = TRUE)

  montants = res$evaluate$nodeValue

  labels <- api_beau_labels(type_montant)

  montants_df <- data.frame(
    labels = labels,
    montants = montants
  ) |>
    transform_labels(type_montant)

}

#' @export
api_beau_labels <- function(type_montant = "cotis"){

  if(type_montant == "cotis"){

    labels <- c(
      "Cotisations - Maladie (Employeur)",
      "Cotisations - Maladie (Salarié)",
      "Cotisations - Prévoyances - Santé (Employeur)",
      "Cotisations - Prévoyances - Santé (Salarié)",
      "Cotisations - ATMP (Employeur)",
      "Cotisations - ATMP (Salarié)",
      "Cotisations - Vieillesse - Plafonnée (Employeur)",
      "Cotisations - Vieillesse - Plafonnée (Salarié)",
      "Cotisations - Vieillesse - Déplafonnée (Employeur)",
      "Cotisations - Vieillesse - Déplafonnée (Salarié)",
      "Cotisations - Retraite complémentaire-CEG-CET (Employeur)",
      "Cotisations - Retraite complémentaire-CEG-CET (Salarié)",
      "Cotisations - Allocations Familiales (Employeur)",
      "Cotisations - Allocations Familiales (Salarié)",
      "Cotisations - Assurance Chômage (Employeur)",
      "Cotisations - Assurance Chômage (Salarié)",
      "Cotisations - Autres Employeur (Employeur)",
      "Cotisations - Autres Employeur (Salarié)",
      "Cotisations - CSG-CRDS - CSG - Déductible (Employeur)",
      "Cotisations - CSG-CRDS - CSG - Déductible (Salarié)",
      "Cotisations - CSG-CRDS - Sur Revenus Imposables Non Déductible (Employeur)",
      "Cotisations - CSG-CRDS - Sur Revenus Imposables Non Déductible (Salarié)",
      "Cotisations - APEC (Employeur)",
      "Cotisations - APEC (Salarié)",
      "Cotisations - Exonérations (Employeur)",
      "Cotisations - Exonérations (Salarié)"
    )
  }else{
    labels <- c(
      "Coût Total Employeur",
      "Salaire Brut",
      "Net à Payer Avant Impôt",
      "Net Payé Après Impôt"
    )
  }

}

#' @export
transform_labels <- function(df, type_montant = "cotis"){

  if(type_montant == "cotis"){
    df_final <- df |>
      dplyr::mutate(
        type = ifelse(stringr::str_detect(labels, "\\(Employeur\\)"), "employeur", "salarié"),
        label_base = stringr::str_trim(stringr::str_remove(labels, "\\s*\\(.*\\)"))
      ) |>
      dplyr::select(label_base, type, montants) |>
      tidyr::pivot_wider(
        names_from = type,
        values_from = montants,
        names_prefix = "montant_"
      ) |>
      dplyr::mutate(across(where(is.numeric), ~ifelse(is.na(.), 0, .))) |>
      dplyr::mutate(total = montant_employeur + .data[["montant_salarié"]]) |>
      dplyr::filter(total != 0)
  }else{
    df_final <- df
  }
  return(df_final)
}


# PArtie sur la TVA ----

# test <- readr::read_csv2("app/static/data/Tableaux-flux-2023-2025.csv") |>
#   get_tva_data() |>
#   get_tva_tab() |>
#   dplyr::mutate(Part_TVA_Moyenne = mnt_tot * (Taux_TVA_Moyen/100))
#
# test2 <- readr::read_csv2("app/static/data/Tableaux-flux-2024.csv") |>
#   get_tva_data() |>
#   get_tva_tab() |>
#   dplyr::mutate(Part_TVA_Moyenne = mnt_tot * (Taux_TVA_Moyen/100))

#' @export
get_tva_data <- function(df){

  if(any(stringr::str_detect(tolower(colnames(df)), "debit"))){

    df <- df |>
      dplyr::select(dplyr::matches("categorie", ignore.case = TRUE), Debit, Credit) |>
      dplyr::mutate(Credit = stringr::str_remove_all(Credit, "`+`"),
                    Credit = as.double(stringr::str_replace_all(Credit, ",", "."))) |>
      dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~ifelse(is.na(.), 0, .))) |>
      dplyr::mutate(Montant = Debit + Credit) |>
      dplyr::select(dplyr::matches("categorie", ignore.case = TRUE), Montant)

  }else{
    df <- df |>
      dplyr::select(dplyr::matches("categorie", ignore.case = TRUE),
                    dplyr::matches("montant", ignore.case = TRUE))
  }

    return(df)
}

#Get TVA data afficahage
#' @export
get_tva_tab <- function(df){

  df <- df |>
    dplyr::summarise(.by = `Sous categorie`,
                     mnt_tot = sum(Montant, na.rm = TRUE)) |>
    dplyr::left_join(vroom::vroom("app/static/data/Tableau_TVA_moyenne_v2.csv", delim = ",") |>
                       dplyr::select(dplyr::all_of(c("Catégorie", "Taux_TVA_Moyen"))),
                     by = c("Sous categorie" = "Catégorie"))

  return(df)

}


create_tva_tab <- function(){

  # t <- vroom::vroom("app/static/data/Tableaux-flux-2023-2025.csv", delim = ";") |>
  #   dplyr::select(dplyr::matches("categorie", ignore.case = TRUE), Debit, Credit) |>
  #   dplyr::mutate(Credit = stringr::str_remove_all(Credit, "`+`"),
  #                 Credit = as.double(stringr::str_replace_all(Credit, ",", "."))) |>
  #   dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~ifelse(is.na(.), 0, .))) |>
  #   dplyr::mutate(Montant = Debit + Credit) |>
  #   dplyr::select(dplyr::matches("categorie", ignore.case = TRUE), Montant)
  #
  # tt <- t |> dplyr::summarise(.by = Categorie,
  #                             mnt = sum(Montant, na.rm = TRUE))


  test <- vroom::vroom("app/static/data/tva_categories_france_final.csv", delim = ",") |>
    dplyr::mutate(Tx_tva = stringr::str_replace_all(stringr::str_remove_all(`Taux de TVA`, " %"), ",", ".")) |>
    dplyr::mutate(Tx_tva = stringr::str_replace_all(Tx_tva, ";", ",")) |>
    dplyr::mutate(Tx_tva = stringr::str_replace_all(Tx_tva, "/", ",")) |>
    dplyr::mutate(Tx_tva = trimws(stringr::str_replace_all(Tx_tva, " ", "")))

  gg<-test |>
    dplyr::rowwise() |>
    dplyr::mutate(Tx = list(list(trimws(unlist(trimws(strsplit(Tx_tva, ","))))))) |>
    dplyr::ungroup() |>
    tidyr::unnest(Tx)

  gg<-test |>
    dplyr::summarise(.by = dplyr::everything(),
                     Tx = list(trimws(strsplit(Tx_tva, ",")))) |>
    dplyr::mutate(
      Tx = ifelse(Tx %in% c("-", "Variable", "Exonéré", "Nonsoumis"), 0, Tx),
      Tx = purrr::map(Tx, ~ as.character(eval(parse(text = .x))))) |>
    tidyr::unnest(Tx) |>
    dplyr::mutate(Tx = as.numeric(ifelse(is.na(as.numeric(Tx)), 0, Tx))) |>
    dplyr::summarise(.by = c(1,2,3),
                     Taux_TVA_Moyen = round(mean(Tx, na.rm = TRUE), 2))

  write.csv(gg, file = "app/static/data/Tableau_TVA_moyenne_v2.csv", row.names = FALSE)
}
#create_tva_tab()

