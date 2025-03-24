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

