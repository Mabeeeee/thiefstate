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

library(rvest)
library(RSelenium)
url <- "https://mon-entreprise.urssaf.fr/simulateurs/salaire-brut-net?salaire-net=2300%E2%82%AC%2Fmois&salari%C3%A9+.+contrat=%27CDI%27&unite=%E2%82%AC%2Fmois"

page <- read_html(url)

html_text(page)

grid <- page %>%
  html_nodes(".payslip__cotisationsSection") %>%
  html_table(fill = TRUE)

remDr <- RSelenium::remoteDriver(
  remoteServerAddr = "localhost",
  port = 4567,
  browserName = "chrome"
)




library(webdriver)

webdriver::install_phantomjs()

pjs <- webdriver::run_phantomjs()
session <- webdriver::Session$new(port = pjs$port)
session$go(url)
html <- session$getSource()
print(html)
