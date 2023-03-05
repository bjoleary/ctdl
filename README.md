
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ctdl: Clinical Trials Downloader

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/ctdl)](https://CRAN.R-project.org/package=ctdl)
<!-- badges: end -->

The goal of ctdl is to access [clinicaltrials.gov](clinicaltrials.gov)
data from R.

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
#> Checking for /var/folders/10/py32gfh16xjf_tx_6htqs6540000gn/T/RtmpxiiHqL directory...
#> Renaming /var/folders/10/py32gfh16xjf_tx_6htqs6540000gn/T/RtmpxiiHqL to /var/folders/10/py32gfh16xjf_tx_6htqs6540000gn/T/RtmpxiiHqL_archive_20230304185652/...
#> Unzipping ...
#> [1] "2023-03-02"
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
#>   nct_id      nlm_downl…¹ study_fi…² results_…³ disposit…⁴ last_upd…⁵ study_fi…⁶
#>   <chr>       <chr>       <date>     <date>     <date>     <date>     <date>    
#> 1 NCT02867735 <NA>        2016-08-09 NA         NA         2022-04-08 2016-08-12
#> 2 NCT02801084 <NA>        2016-05-18 NA         NA         2022-04-09 2016-06-10
#> 3 NCT04318470 <NA>        2020-03-10 NA         NA         2022-03-31 2020-03-19
#> 4 NCT02790723 <NA>        2016-05-03 NA         NA         2022-04-14 2016-05-31
#> 5 NCT02683824 <NA>        2016-01-21 NA         NA         2022-04-08 2016-02-10
#> 6 NCT02602769 <NA>        2015-11-07 NA         NA         2022-04-08 2015-11-09
#> # … with 62 more variables: study_first_posted_date <date>,
#> #   study_first_posted_date_type <chr>, results_first_submitted_qc_date <date>,
#> #   results_first_posted_date <date>, results_first_posted_date_type <chr>,
#> #   disposition_first_submitted_qc_date <date>,
#> #   disposition_first_posted_date <date>,
#> #   disposition_first_posted_date_type <chr>,
#> #   last_update_submitted_qc_date <date>, last_update_posted_date <date>, …
```

Create some search terms and associate them with topics:

We’ll also store some known false positives in a vector titled .

Now we’ll filter the tibble based on the search terms:

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
