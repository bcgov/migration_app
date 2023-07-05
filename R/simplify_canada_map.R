# Copyright 2019 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

library(tidyverse)
library(rmapshaper)
library(sf)

## read in stat can cartography file for provinces
provinces <- read_sf("data/lpr_000b21a_e.shp")

## simplify, requires node.js to use sys argument
## as file is too big (see: https://github.com/ateucher/rmapshaper#using-the-system-mapshaper)
provinces <- provinces %>% ms_simplify(keep = 0.001, sys = TRUE)

## check that all geometries are valid after simplifying
st_is_valid(provinces)
provinces <- st_make_valid(provinces)

## print provinces to see details
## bbox for min and max latitude and longitude (use for cropping)
## geographic CRS (NAD83 / Statistics Canada Lambert = 3347)
provinces

## remove northern most tip for mapping
provinces_cropped <- provinces %>%
  st_transform(4326) %>%
  st_crop(xmin = -142, ymin = 41, xmax = -52, ymax = 74) %>%
  st_transform(3347)

## test
ggplot(data = provinces_cropped) + geom_sf()

## save simplified provinces/ provinces cropped to data as backup
saveRDS(provinces, "data/provinces.rds")
saveRDS(provinces_cropped, "data/provinces_cropped.rds")

## save cropped provinces for app
saveRDS(provinces_cropped, "app/data/provinces_cropped.rds")
