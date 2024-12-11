install.packages("jsonlite")
library(jsonlite)

json <- toJSON(
  list(name="Test", valeur=42),
  auto_unbox=TRUE, # Option : évite les vecteurs de taille 1
  pretty=TRUE # Option : améliore l'affichage
  )
json

obj <- fromJSON(json)

obj

df <- data.frame(iris)

iris <- toJSON (df, pretty=TRUE)
iris

iris_par_col <- toJSON (df, pretty=TRUE, dataframe = "columns")
iris_par_row <- toJSON (df, pretty=TRUE, dataframe = "rows")
iris_par_val <- toJSON (df, pretty=TRUE, dataframe = "values")
iris_par_col
iris_par_row
iris_par_val

iris_con <- file("iris.json", open="w")
stream_out (df, con=iris_con)
close(iris_con)

iris_con <- file("iris.json", open="r")
stream_in (iris_con)
close(iris_con)




##################STARWARS########################
url_next <- "https://swapi.dev/api/planets/?format=json"
planets <- NULL
while(!is.null(url_next)) { # Tant qu'il y a une URL à visiter
  obj <- fromJSON(url_next)
  planets <- rbind(planets, obj[["results"]])
  url_next <- obj[["next"]]
}
planets %>% summarise(n_planet=n())

planets_par_col <- toJSON (planets, pretty=TRUE, dataframe = "columns")

sw_con <- file("planets.json", open="w")
stream_out (planets, con=sw_con)
close(sw_con)

sw_con <- file("planets.json", open="r")
stream_in (sw_con)
close(sw_con)
