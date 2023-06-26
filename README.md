
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ctdl: Clinical Trials Downloader

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/ctdl)](https://CRAN.R-project.org/package=ctdl)
[![R-CMD-check](https://github.com/bjoleary/ctdl/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bjoleary/ctdl/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/bjoleary/ctdl/branch/main/graph/badge.svg)](https://app.codecov.io/gh/bjoleary/ctdl?branch=main)
<!-- badges: end -->

The goal of ctdl is to access
[clinicaltrials.gov](https://www.clinicaltrials.gov) data from R.

## Installation

You can install the development version of ctdl like so:

``` r
# install.packages("devtools")
devtools::install_github("bjoleary/ctdl")
```

## Example: Find and plot clinical trials associated with digital health topics

First, download the most recent clinical trials data:

``` r
library(ctdl)
library(fs)
download_directory <- fs::path_temp()
download_data(filepath_data = download_directory)
#> Checking for /var/folders/10/py32gfh16xjf_tx_6htqs6540000gn/T/RtmpjZLp1w directory...
#> Renaming /var/folders/10/py32gfh16xjf_tx_6htqs6540000gn/T/RtmpjZLp1w to /var/folders/10/py32gfh16xjf_tx_6htqs6540000gn/T/RtmpjZLp1w_archive_20230626122613.520003/...
#> Unzipping ...
#> [1] "2023-06-23"
```

Read in the study data:

``` r
studies <- read_studies(paste0(download_directory, "/"))
#> Warning: One or more parsing issues, call `problems()` on your data frame for details,
#> e.g.:
#>   dat <- vroom(...)
#>   problems(dat)
head(studies)
#> # A tibble: 6 × 69
#>   nct_id    nlm_download_date_de…¹ study_first_submitte…² results_first_submit…³
#>   <chr>     <chr>                  <date>                 <date>                
#> 1 NCT02972… <NA>                   2016-11-07             NA                    
#> 2 NCT00007… <NA>                   2000-12-29             NA                    
#> 3 NCT03288… <NA>                   2017-09-18             NA                    
#> 4 NCT00007… <NA>                   2000-12-29             NA                    
#> 5 NCT00112… <NA>                   2005-06-02             NA                    
#> 6 NCT00112… <NA>                   2005-06-02             NA                    
#> # ℹ abbreviated names: ¹​nlm_download_date_description,
#> #   ²​study_first_submitted_date, ³​results_first_submitted_date
#> # ℹ 65 more variables: disposition_first_submitted_date <date>,
#> #   last_update_submitted_date <date>, study_first_submitted_qc_date <date>,
#> #   study_first_posted_date <date>, study_first_posted_date_type <chr>,
#> #   results_first_submitted_qc_date <date>, results_first_posted_date <date>,
#> #   results_first_posted_date_type <chr>, …
```

Create some search terms and associate them with topics:

``` r
search_terms <- 
  tibble::tribble(
    ~term, ~topic,
    "Activity Monitor", "Wearable",
    "Activity Tracker", "Wearable",
    "Adaptive Algorithm", "AI/ML",
    "Android", "mHealth",
    "Apple Heart", "Wearable",
    "Apple Watch", "Wearable",
    "Apple Women", "mHealth",
    "Apple Hearing", "Wearable",
    "Artificial Intelligence", "AI/ML",
    "Augmented Reality", "Extended Reality",
    "Deep Learning", "AI/ML",
    "Digital Biomarker", "Digital Biomarker",
    "Digital Health", "Digital Health",
    "Extended Reality", "Extended Reality",
    "Fitbit", "Wearable",
    "Fitness Tracker", "Wearable",
    "Google", "Google",
    "Health Information Tech", "Health IT",
    "Health IT", "Health IT",
    "in silico", "in silico",
    "iPad", "mHealth",
    "iPhone", "mHealth",
    "Machine Learning", "AI/ML",
    "mHealth", "mHealth",
    "Mobile App", "mHealth",
    "Mobile Health", "mHealth",
    "Mobile Medical App", "mHealth",
    "Oura", "Wearable",
    "Remote Patient Monitoring", "Telemedicine",
    "Remote Monitoring", "Telemedicine",
    "ResearchKit", "mHealth",
    "RPM", "Telemedicine",
    "SaMD", "SaMD",
    "SiMD", "SiMD",
    "Smart Phone", "mHealth",
    "Smartphone", "mHealth",
    "Smartwatch", "Wearable",
    "Software as a Medical Device", "SaMD",
    "Software in a Medical Device", "SiMD",
    "Tele-Medicine", "Telemedicine",
    "Telehealth", "Telemedicine",
    "Telemedicine", "Telemedicine",
    "Verily", "Verily",
    "Virtual Reality", "Extended Reality",
    "Accelerometer", "Wearable",
    "Wearable Sensor", "Wearable",
    "Wristwatch", "Wearable"
  ) |>
    # Add the escaped (\) word boundary term "\\b" to the beginning and end
    # of each search term.
    dplyr::mutate(regex_term = paste0("\\b", .data$term, "\\b"))
```

We’ll also store some known false positives in a vector titled
`known_fp`.

``` r
known_fp <- 
  c(
    "NCT03189251", "NCT04226612", "NCT00342394", "NCT00905346", "NCT00051363",
    "NCT01282814", "NCT04226612", "NCT00342394", "NCT00905346", "NCT00051363",
    "NCT01282814", "NCT00829452", "NCT00759954", "NCT00863915", "NCT00475605",
    "NCT00649467", "NCT00649805", "NCT00296127", "NCT01512459", "NCT00568152",
    "NCT00368719", "NCT01467570", "NCT01027117", "NCT01552252", "NCT01097226",
    "NCT01130051", "NCT01123395", "NCT02560077", "NCT02680119", "NCT01445964",
    "NCT02799433", "NCT01456507", "NCT03214276", "NCT01514019", "NCT01449786",
    "NCT01585519", "NCT01690676", "NCT01649492", "NCT01932112", "NCT02029781",
    "NCT01988389", "NCT02044419", "NCT02101112", "NCT02068014", "NCT02159313",
    "NCT02160158", "NCT02013856", "NCT02224365", "NCT02340039", "NCT02396615",
    "NCT02542033", "NCT02493140", "NCT02974491", "NCT03227874", "NCT02565472",
    "NCT03714464", "NCT04116580", "NCT03053986", "NCT02940249", "NCT03593135",
    "NCT02856893", "NCT03523403", "NCT03329638", "NCT03381664", "NCT03608319",
    "NCT03749031", "NCT03911050", "NCT03802682", "NCT03795324", "NCT03846986",
    "NCT04120259", "NCT04004182", "NCT04073719", "NCT01418625", "NCT00474682",
    "NCT00219388", "NCT00001330", "NCT00000335", "NCT01221116", "NCT00454974",
    "NCT01446965", "NCT01484938", "NCT01448005", "NCT01476722", "NCT01740999",
    "NCT01847105", "NCT02201706", "NCT03555123", "NCT03835390"
  )
```

Now we’ll filter the `studies` tibble based on the search terms:

``` r
dh_studies <- 
  find_studies(
    data_studies = studies,
    search_terms = search_terms,
    known_fp = known_fp,
    max_topics = 5L
  ) |> 
  # Remove any studies with a start date in the future
  dplyr::filter(.data$start_date <= lubridate::today())
```

And, finally, we’ll plot the results:

``` r
plot_studies(
  studies = dh_studies,
  description = "Digital Health",
  this_year = lubridate::year(lubridate::today()),
  search_terms = search_terms
) |> 
  plot()
```

<img src="man/figures/README-plot-results-1.png" width="100%" />

# Other info

This is a hobby project and is built on my own time. It’s not from my
employer and is not endorsed by my employer. For that matter, it’s not
even endorsed by me. (Also, see the license for some important
disclaimers.) It’s not intended for any medical or therapeutic use.
