###https://umizenbonsai.com/shop/bonsai/coniferes/
install.packages("rvest")
library(rvest)
install.packages("dplyr")
library(dplyr)

####1. Récupérez le contenu de la page des conifères avec la fonction read_html du package rvest.
url_conifere <- "https://umizenbonsai.com/shop/bonsai/coniferes/"
data_html <- read_html(url_conifere)
data_html

#####2. Écrivez un sélecteur CSS pour capturer les éléments li qui contiennent les blocs correspondants aux
#####bonsaïs. Vérifiez sur le site que le nombre de bonsaïs affichés correspond.
bonsai_nodes <- data_html %>% html_nodes("li.entry")
bonsai_nodes


#####Codez une fonction qui prend un bloc de la liste précédente et retourne une liste contenant le nom, le
#####prix et le lien de description du bonsaï.
bonsais <- tibble()
for (k in seq_along(bonsai_nodes))
{
  bonsai_node <- bonsai_nodes[k]
  nom <- bonsai_node %>%
    html_node("li.title") %>%
    html_text()
  
  prix <- bonsai_node %>% 
    html_node("span.woocommerce-Price-amount") %>% 
    html_text()
  
  lien <- bonsai_node %>%
    html_node ("a.woocommerce-LoopProduct-link") %>%
    html_attr("href")
  
  bonsais <- bonsais %>% bind_rows(
    tibble(nom=nom, prix=prix, lien)
  )
}
bonsais


######EXO CATE BLANCHETT
url_wikipedia <- "https://fr.wikipedia.org/"
url_blanchett <- "wiki/Cate_Blanchett"
data_html <- paste0(url_wikipedia, url_blanchett) %>% read_html()
film_selector <- "#mw-content-text div ul:nth-of-type(3) li i a"
film_nodes <- data_html %>% html_nodes(film_selector) %>% html_attrs()
films <- tibble()
for(k in seq_along(film_nodes)) {
  film_node <- film_nodes[[k]]
  if("class" %in% names(film_node)) next # Absence de page dédiée
  if(film_node["title"] == "Galadriel") next # Mauvais lien
  films <- rbind(
    films,
    list(titre=film_node["title"], url=film_node["href"])
  )
}

get_url_imdb <- function(url_film) {
  # Les liens externes comme IMDb ont tous la classe "external text"
  external_selector <- "a[class='external text']"
  data_html <- paste0(url_wikipedia, url_film) %>% read_html()
  external_nodes <- data_html %>% html_nodes(external_selector)
  # Recherche du lien IMDb
  url <- NULL
  for(external_node in external_nodes) {
    if(external_node %>% html_text() == "IMDb") {
      external_attrs <- external_node %>% html_attrs()
      url <- external_attrs["href"]
      break
    }
  }
  # Extraction de l'URL IMDb par expression régulière
  # La regex "url_prefix=(.*)$" capture tout ce qui se trouve entre "url_prefix="
  # et la fin de la chaîne de caractères
  return(str_extract(url, "url_prefix=(.*)$", group=1))
}

films <- films %>%
  rowwise() %>%
  mutate(url_imdb=get_url_imdb(url))

films %>% select(titre, url_imdb) %>% head(3)

fix_url_imdb <- function(url_imdb) {
  # Extraction de l'identifiant IMDb par expression régulière
  # La regex "id=(.*)$" extrait l'identifiant entre le champs "id=" et la fin
  # de la chaîne de caractères
  imdb_id <- str_extract(url_imdb, "id=(.*)$", group=1)
  # L'adresse de la page IMDb contenant la liste des acteurs d'un film d'identifiant
  # FILM_ID est https://www.imdb.com/title/FILM_ID/fullcredits
  return(paste0("https://www.imdb.com/title/", imdb_id, "/fullcredits"))
}
films <- films %>%
  rowwise() %>%
  mutate(url_imdb_ok=fix_url_imdb(url_imdb))
films %>% select(titre, url_imdb_ok) %>% head(3)


liste_acteurs <- function(url_imdb) {
  # La liste des acteurs se trouve dans un élément "table" de classe "cast_list"
  acteurs_selector <- "table.cast_list"
  data_html <- read_html(url_imdb)
  acteurs <- data_html %>%
    html_node(acteurs_selector) %>%
    html_table() %>%
    filter(
      # Suppression des valeurs inutiles
      X2 != "" & X2 != "Rest of cast listed alphabetically:"
    ) %>%
    pull(X2) # Les noms des acteurs sont dans la colonne X2
  return(list(acteurs=acteurs))
}
films <- films %>%
  rowwise() %>%
  mutate(acteurs=liste_acteurs(url_imdb_ok))
films %>% select(titre, acteurs) %>% head(3)

# Mise en commun de tous des noms des acteurs
acteurs <- tibble()
for(k in seq_len(nrow(films))) {
  acteurs <- acteurs %>% rbind(tibble(nom=unlist(films[k,] %>% pull(acteurs))))
}
# La réponse vient en comptant les occurrences de chaque acteur.
# Nous retrouvons bien les acteurs de la trilogie du Seigneur des Anneaux :-)
acteurs %>%
  group_by(nom) %>%
  summarise(n=n()) %>%
  arrange(desc(n)) %>%
  head(4)