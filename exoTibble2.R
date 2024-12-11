library(tidyverse)

rg <- read.csv("rolandgarros2013.csv")

rg <- as_tibble((rg))
class(rg)

rg %>% filter (Round==6) %>% select (Player1,Player2)

rg %>% group_by(Round) %>% summarise (moyenne_ace_par_match=mean(ACE.1 + ACE.2))

rg1 <- rg %>% select (Joueur=Player1)
rg2 <- rg %>% select (Joueur=Player2)

rg_joueurs <- bind_rows(rg1, rg2)
rg_joueurs_distincts <- rg_joueurs %>% distinct(Joueur)


rg_victoires <- function(Joueur)
{
  return (
    rg %>%
      filter(
        (Player1==Joueur  & Result==1)
        | (Player1 == Joueur & Result ==0)
      ) %>% nrow()
  )
}
    
rg_joueurs <- rg_joueurs %>% 
   rowwise() %>%
   mutate(Victoires=rg_victoires (Joueur)) %>% distinct(Joueur, Victoires) %>% arrange(desc(Victoires))
 

oa <- read.csv("openaustralie2013.csv")
oa <- as.tibble(oa)

tennis <- bind_rows(RG=rg,OA=oa, .id="Tournoi") 
tennis %>% group_by(Tournoi) %>% summarise(nb_total_matches=n())

tennis %>% group_by(Tournoi, Round) %>% summarise (moyenne_ace_par_match=mean(ACE.1 + ACE.2))


oa1 <- oa %>% select (Joueur=Player1)
oa2 <- oa %>% select (Joueur=Player2)

oa_joueurs <- bind_rows(oa1, oa2)
oa_joueurs_distincts <- oa_joueurs %>% distinct(Joueur)

oa_victoires <- function(Joueur)
{
  return (
    oa %>%
      filter(
        (Player1==Joueur  & Result==1)
        | (Player1 == Joueur & Result ==0)
      ) %>% nrow()
  )
}

oa_joueurs <- oa_joueurs %>% 
  rowwise() %>%
  mutate(Victoires=oa_victoires (Joueur)) %>% distinct(Joueur, Victoires) %>% arrange(desc(Victoires))


left_join <- rg_joueurs %>% left_join(oa_joueurs, by=("Joueur"))
right_join <- rg_joueurs %>% right_join(oa_joueurs, by=("Joueur"))
inner_join <- rg_joueurs %>% inner_join(oa_joueurs, by=("Joueur"))
full_join <- rg_joueurs %>% full_join(oa_joueurs, by=("Joueur"))
