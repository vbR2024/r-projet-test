install.packages("rvest")
library(rvest)
install.packages("dplyr")
library(dplyr)


###Récupérez le contenu de la page des pokemons avec la fonction read_html du package rvest.
url_pokemon <- "https://scrapeme.live/product-category/pokemon/"
data_html <- read_html(url_pokemon)
data_html

pokemon_nodes <- data_html %>% html_nodes(".woocommerce-loop-product__title")
pokemon_nodes %>% html_text()
pokemon_price_nodes <- data_html %>% html_nodes(".woocommerce-Price-amount")
pokemon_price_nodes %>% html_text()


pokemon_tbl <- tibble()


pokemon_tbl_name <- tibble()
for(k in seq_along(pokemon_nodes)) {
  pokemon_node <- pokemon_nodes[k]
  pokemon_tbl_name <- rbind(pokemon_tbl_name, pokemon_node%>% html_text())
}
pokemon_tbl_name <- pokemon_tbl_name %>% select (Nom = X.Bulbasaur.)

pokemon_tbl_price <- tibble()
for(k in seq_along(pokemon_nodes)) {
  pokemon_node <- pokemon_nodes[k]
  pokemon_tbl_price <- rbind(pokemon_tbl_price, pokemon_node%>% html_text())
}
pokemon_tbl_price <- pokemon_tbl_price %>% select (Price=X.Bulbasaur.)
pokemon_tbl <- cbind(pokemon_tbl_name,pokemon_tbl_price)
pokemon_tbl
