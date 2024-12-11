install.packages("mongolite")
library(mongolite)
install.packages("jsonlite")
library(jsonlite)
library(dplyr)

m <- mongo("planets")
m$count()

if (m$count() >0) {m$drop()}
m$import(
  file("planets.json")
)

m$count()

m$find() %>% tibble() %>% head()

m$find(
  query='{"rotation_period":"25"}'
  
)

m$find(
  query='{"rotation_period":"25"}',
  fields='{
  "_id":false, 
  "name":true, 
  "rotation_period":true, 
  "orbital_period":true, 
  "diameter":true}'
)


m$find(
    query='{"rotation_period":"25"}',
    fields='{"_id":false, "name":true, "rotation_period":true, "orbital_period":true, "diameter":true}',
    sort='{"diameter":-1}'
    )

df <- m$find() %>%
  tibble() %>%
  mutate(rotation_period=as.double(rotation_period), 
         orbital_period=as.double(orbital_period),
         diameter=as.double(diameter),
         climate=as.character(climate),
         terrain=as.character(terrain))


m$insert(df)

df <- m$find() %>%
  tibble() %>%
  mutate(
    rotation_period=as.double(rotation_period), 
    orbital_period=as.double(orbital_period),
    climate=str_split(climate, ", ")
  )

df
df_planets <- stream_in(file("planets.json"))
df_planets_nettoye <- df_planets %>%
  mutate(rotation_period=as.double(rotation_period), 
         orbital_period=as.double(orbital_period),
         diameter=as.double(diameter),
         climate=as.character(climate),
         terrain=as.character(terrain)) %>%
  select(rotation_period, orbital_period, diameter, climate, terrain)

df_planets_nettoye %>% arrange (desc(diameter))


m$find(
  query='{"name": {"$regex": "^T"}}',
  fields='{"_id":false, "name":true, "rotation_period":true, "orbital_period":true, "diameter":true}',
)

# Pipeline d'agrégation
m$aggregate('[
  {
    "$group": 
      {
        "_id": null,
        "count": {
          "$sum": 1
          }
      }
    }
]')

m$aggregate('[
            {
            "$match":{"terrain":{"regex":".*ice caves.*}}
            }
  {
        "$group": 
      {
        "_id": null,
        "count": {
          "$sum": 1
          }
      }
    }
]')
         