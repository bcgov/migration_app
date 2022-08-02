[![img](https://img.shields.io/badge/Lifecycle-Maturing-007EC6)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)

migration_app
============================

### Usage

Shiny App for visualizing provincial and international migration to/from BC.

The data used in the app comes from the BC Data Catalogue: https://catalogue.data.gov.bc.ca/dataset/inter-provincial-and-international-migration

There are two stages, first scripts and data for preparing the map of Canada to be used in the app and second scripts and data for running the app.

Preparing the map of Canada:

- data/ contains the cartographic boundary file (lpr_b00021a_e) of Canada and it's provinces from Statistics Canada. The files are too big to push to github but can be found here: https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21
- R/simplify_canada_map.R uses the rmapshapper package to simplify the boundary file for easier/faster mapping

The app:

- app/data/provinces_cropped.rds is the resulting simplified boundary data for Canada
- app/R/global.R contains the global definitions for the app
- app/www/ contains syle files for the app (including BC Sans font files, BCStats logo, etc.)
- app/app.R contains the code for the app


### Project Status

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an [issue](https://github.com/bcgov/migration_app/issues/).

### How to Contribute

If you would like to contribute, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

### License

```
Copyright 2022 Province of British Columbia

Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.
```
---
*This project was created using the [bcgovr](https://github.com/bcgov/bcgovr) package.* 
