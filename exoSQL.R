install.packages("DBI")
install.packages("RSQLite")
install.packages("dplyr")
library(DBI)
library(RSQLite)
library(dplyr)

con <- DBI::dbConnect(RSQLite::SQLite(), dbname="star.db")


dbListTables(con)

dbListFields(con,"Etat")
dbListFields(con,"Topologie")

dbGetQuery(con, "SELECT * FROM Topologie")

etat_db <- tbl(con, "Etat")
topologie_db <- tbl (con, "Topologie")

#pour transformer en véritable tibble on utilise le verbe collect()
q1tbl <- topologie_db %>% select (id, nom, id_proche_1, longitude, latitude)
q2tbl <- topologie_db %>% select (id, nom, id_proche_1) %>% collect()


q3tbl <- q1tbl %>% left_join(topologie_db, by=c("id_proche_1"="id"))

#####
q3tbl %>% collect()
#####
q3tbl %>% show_query()

##ajouter distance entre station et station la plus proche
q4tbl <- q3tbl %>% mutate(distance=(latitude.x -latitude.y)^2 + (longitude.x - longitude.y)^2)

##

q5tbl <- q4tbl %>% 
  mutate(distance_point_GPS=(latitude.x - 48.1179151)^2+(longitude.x + 1.7028661)^2) %>% 
  arrange(desc(distance_point_GPS)) %>% 
  head(3) %>%
  show_query()


dbDisconnect(con)


#####EXO sur MUSIQUE

con <- DBI::dbConnect(RSQLite::SQLite(), dbname="chinook.db")
dbListTables(con)

dbListFields(con,"Playlist")
dbListFields(con,"PlaylistTrack")
dbListFields(con,"Track")
dbListFields(con,"Album")

playlist_db <- tbl(con, "Playlist")
playlisttrack_db <- tbl(con, "PlaylistTrack")
track_db <- tbl(con, "Track")
album_db <- tbl (con, "Album")

playlisttrack_db %>% 
  group_by(PlaylistId) %>% 
  summarise(nb_total_pistes=n()) %>% 
  left_join(playlist_db, by="PlaylistId") %>%
  select(Name, nb_total_pistes) %>%
  arrange (desc(nb_total_pistes))


lien_playlist_album <- playlisttrack_db %>%
  left_join(track_db, by=("TrackId")) %>%
  left_join (album_db, by=("AlbumId"))


dbDisconnect(con)