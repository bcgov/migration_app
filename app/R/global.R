
## Some useful libraries
library(shiny)
library(magrittr) ## for pipe %>%
## to improve load time of app, replaced library statements with namespace syntax
#library(tidyverse)  ## for data manipulation
#library(janitor)    ## for cleaning data (includes rounding functions)
#library(DT)         ## for tables
#library(bcdata)     ## for connecting with BCDC
#library(grid)       ## arrows on map

## Migration data ----
interprovincial <- bcdata::bcdc_get_data(record = '56610cfc-02ba-41a7-92ef-d9609ef507f1',
                                 resource = '95579825-bfa2-4cab-90fa-196e0ecc8626')

international <-  bcdata::bcdc_get_data(record = '56610cfc-02ba-41a7-92ef-d9609ef507f1',
                                resource = 'c99d63f6-5ec4-4ac0-9c07-c0352f2f1928')

quarter_labels <- tibble::tribble(
  ~Quarter,          ~Label,
  1L, "Q1: Jan - Mar",
  2L, "Q2: Apr - Jun",
  3L, "Q3: Jul - Sep",
  4L, "Q4: Oct - Dec"
)

### Spatial data ----
provinces <- readRDS("data/provinces_cropped.rds")

locations <- tibble::tribble(
  ~Jurisdiction, ~Latitude, ~Longitude, ~BC_Latitude, ~BC_Longitude, ~hjust, ~vjust,
  "Alta.",            49.5,      -112L,         50.5,         -119L,       1,     1,
  "Sask.",            49,      -106L,         51.5,         -122L,     0.4,   1.5,
  "Man.",               49,       -99L,           52,         -119L,       0,   0,
  "Ont.",               48,       -85L,           54,         -125L,       0,   0.5,
  "Que.",               52,       -75L,           57,         -122L,       0,   0.5,
  "N.L.",               54,       -63L,         57.5,         -122L,       0,     0,
  "N.S.",               46,       -62L,         55.5,         -123L,       0,     0,
  "N.B.",               46,       -67L,         54.5,         -122L,       1,     1,
  "P.E.I.",          49.25,       -63L,           56,         -122L,       0,     0,
  "Nvt.",               65,      -100L,           59,         -122L,       0,     0,
  "N.W.T.",             65,      -120L,           59,         -124L,       0,     0,
  "Y.T.",               65,      -135L,           59,         -128L,       0,     0,
  "International",      55,      -144L,           55,         -129L,       1.05,   0.5
)

## Mapping formatting ----

colors <- c("pos" = "#40c77a","neg" = "#a31515")

theme_map <- function(base_size=9, base_family="") {
  
  '%+replace%' <- ggplot2::'%+replace%'
  ggplot2::theme_bw(base_size=base_size, base_family=base_family) %+replace%
    ggplot2::theme(axis.line=ggplot2::element_blank(),
                   axis.text=ggplot2::element_blank(),
                   axis.ticks=ggplot2::element_blank(),
                   axis.title=ggplot2::element_blank(),
                   panel.background=ggplot2::element_blank(),
                   panel.border=ggplot2::element_blank(),
                   panel.grid=ggplot2::element_blank(),
                   panel.spacing=ggplot2::unit(0, "lines"),
                   plot.background=ggplot2::element_blank(),
                   legend.justification = c(0,0),
                   legend.position = c(0,0)
    )
}
ggplot2::theme_set(theme_map())

