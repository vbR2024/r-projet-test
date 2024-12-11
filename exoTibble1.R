library(tidyverse)

iris_tbl <- as_tibble(iris)

select (iris_tbl, Petal.Width, Species)
iris_tbl %>% filter (Species!="setosa")

iris_tbl %>% filter (Species=="setosa") %>% summarise(nb_iris_setosa=n())

iris_tbl %>% filter (Species=="versicolor") %>% summarise (moy_petale_largeur=mean(Petal.Width))

iris_tbl %>% mutate (Sum.width=Petal.Width+Sepal.Width)

iris_tbl %>% group_by (Species) %>% summarise (moyenne_par_espece_sepal_longueur=mean(Sepal.Length), variance_sepale_longueur= var(Sepal.Length))

##############

install.packages("hflights")
library(hflights)
hflights <- as_tibble(hflights)

hflights %>% select (ends_with("Time"))

hflights %>% select (contains("Taxi")|matches("D.*st"))

hflights %>% mutate (AverageSpeed=Distance/(ArrTime-DepTime)) %>% filter(AverageSpeed > 0) %>% arrange(AverageSpeed)

hflights %>% filter (Dest=="JFK")

hflights %>% filter (Dest=="JFK") %>% summarise (nb_vol_dest_JFK=n())

hflights %>% summarise (nb_total_vols=n(), n_dest=n_distinct(Dest), n_carrier=n_distinct(UniqueCarrier))

hflights %>% filter (UniqueCarrier=="AA") %>% summarise (nb_total_vols=n(), n_total_vols_annules=sum(Cancelled), delai_moyen_arrivee=mean(ArrDelay, is.na()))
