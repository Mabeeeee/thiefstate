library(httr)
library(jsonlite)
library(dplyr)
library(rlang)

# Expressions qu'on veut extraire
expressions <- c(
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
# expressions <- c(
#   #"salarié . cotisations",
#   "salarié . cotisations . maladie",
#   "salarié . cotisations . prévoyances . santé",
#   "salarié . cotisations . ATMP",
#   "salarié . cotisations . vieillesse . plafonnée",
#   "salarié . cotisations . vieillesse . déplafonnée",
#   "salarié . cotisations . retraite complémentaire-CEG-CET",
#   "salarié . cotisations . allocations familiales",
#   "salarié . cotisations . assurance chômage",
#   "salarié . cotisations . autres employeur",
#   "salarié . cotisations . CSG-CRDS . CSG . déductible",
#   "salarié . cotisations . CSG-CRDS . sur revenus imposables non déductible"
# )

# Corps de la requête
body <- list(
  expressions = expressions,
  situation = list(
    dirigeant = "non",
    `salarié . activité partielle` = "non",
    `salarié . rémunération . net . à payer avant impôt` = list(
      valeur = 2300,
      unité = "€/mois"
    )
  )
)

# Requête POST
response <- POST(
  url = "https://mon-entreprise.urssaf.fr/api/v1/evaluate",
  add_headers(
    "accept" = "application/json",
    "content-type" = "application/json"
  ),
  body = toJSON(body, auto_unbox = TRUE),
  encode = "raw"
)

# Parsing
res <- content(response, "parsed", simplifyVector = TRUE)

montants = res$evaluate$nodeValue


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


tab_cotisation <- data.frame(
  label = labels,
  montant = montants
)


# Détail Employeur / salariés ----
library(dplyr)
library(stringr)

df_clean <- tab_cotisation %>%
  mutate(
    type = ifelse(str_detect(label, "\\(Employeur\\)"), "employeur", "salarié"),
    label_base = str_trim(str_remove(label, "\\s*\\(.*\\)"))
  ) %>%
  select(label_base, type, montant) %>%
  tidyr::pivot_wider(
    names_from = type,
    values_from = montant,
    names_prefix = "montant_"
  ) %>%
  mutate(across(where(is.numeric), ~ifelse(is.na(.), 0, .))) %>%
  mutate(total = montant_employeur + montant_salarié) %>%
  filter(total != 0)


## PARTIE REVENUS ----

revenus_api <- c(
  "salarié . coût total employeur",
  "salarié . contrat . salaire brut",
  "salarié . rémunération . net . à payer avant impôt",
  "salarié . rémunération . net . payé après impôt"
)

rev_choisi <- revenus_api[3]

tempo_revenu <- c(
  "€/mois",
  "€/an"
)

tempo_choisie <- tempo_revenu[1]

body_salaires <- list(
  expressions = revenus_api,
  situation = list2(
    dirigeant = "non",
    `salarié . activité partielle` = "non",
    !!rev_choisi := list(
      valeur = 2300,
      unité = tempo_choisie
    )
  )
)

# Requête POST
response_salaires <- POST(
  url = "https://mon-entreprise.urssaf.fr/api/v1/evaluate",
  add_headers(
    "accept" = "application/json",
    "content-type" = "application/json"
  ),
  body = toJSON(body_salaires, auto_unbox = TRUE),
  encode = "raw"
)

# Parsing
res_salaires <- content(response_salaires, "parsed", simplifyVector = TRUE)

salaires = res_salaires$evaluate$nodeValue

labels_revenus <- c(
  "Coût Total Employeur",
  "Salaire Brut",
  "Net à Payer Avant Impôt",
  "Net Payé Après Impôt"
)

df_salaires <- data.frame(
  labels = labels_revenus,
  montant = salaires
)
