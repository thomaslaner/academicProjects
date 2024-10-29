# Energy Usage in European Union

This repository contains the cod and data for the lecture DOPP WS23 on the topic of energy usage and development in European Union.


## Run the Code

To run the code one needs to install conda and create an environment using the `environment.yml` file. This virtual environment can then be used to run the notebook. The environment will have the name `dopp`.

```
conda env create -f environment.yml
conda activate dopp
```

## Introduction

The purpose of this project is to answer the following questions:
1. How has European Union’s dependence on different types of fossil and renewable fuels changed since 2010?
2. What are the primary industrial and domestic uses of fossil and renewable fuels in European Union, and how have these usages changed since 2010?
3. How do fluctuations in electricity and natural gas end-user prices, affect the consumption of these goods
(correlation, other influences)? How do they affect the share of renewable energy in gross final energy
consumption?
4. Identify the main external and internal sources of fossil fuels for European Union. How has the reliance on these
sources shifted over time?

## Story

"Through this analysis of European Union's energy data we want to show how close is this region to successfully transitioning away from fossil fuels, and what might be still key obstacles need to be addressed."

## Folder Structure

The folder structure of this project is as follows:

- `data`: Contains the raw data files used for the analysis.
- `documentation`: All the documentation for the datasets.
- `output`: All output of this project.

## Data
- [estat_nrg_bal_s.tsv](https://ec.europa.eu/eurostat/databrowser/bulk?lang=en&searchFilter=nrg_bal_s): Simplified energy balances
- [estat_nrg_d_hhq.tsv](https://data.europa.eu/data/datasets/uvygjkxev6pywqwbgmgwyg?locale=en): disaggregated final energy consumption for households
- [siec.csv](https://dd.eionet.europa.eu/vocabulary/eurostat/siec/view): Siec Code Mappings
- [estat_nrg_ind_idooil.tsv](https://ec.europa.eu/eurostat/databrowser/bulk?lang=en&searchFilter=nrg_ind_idooil): Oil and petroleum products import dependency by country of origin
- [estat_ten00117_tabular.tsv](https://ec.europa.eu/eurostat/databrowser/bookmark/9ea800c3-cc3a-43c4-9d6e-40a6c3f351a0?lang=en): This dataset presents the natural gas prices charged to final consumers separated into households and non-households.
- [estat_ten00118_tabular.tsv](https://ec.europa.eu/eurostat/databrowser/bookmark/9ea800c3-cc3a-43c4-9d6e-40a6c3f351a0?lang=en): This dataset presents the energy prices charged to final consumers separated into households and non-households.
- [estat_nrg_ind_ren_tabular.tsv](https://ec.europa.eu/eurostat/databrowser/bookmark/3cb8abd5-21ca-4290-909f-e736e4612e80?lang=en): Share of renewable energy in gross final energy consumption by sector
- [iea_oil_prices_monthly.xlsx](https://www.iea.org/data-and-statistics/data-product/monthly-oil-price-statistics-2): IEA Energy Prices - Monthly Prices Excerpt
- [europe.geojson](https://github.com/leakyMirror/map-of-europe/tree/master): This data set contains the boundaries at country level of the europe

