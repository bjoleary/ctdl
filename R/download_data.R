#' Download CTTI Data
#'
#' Downloads the most recent archive of clinicaltrials.gov from the CTTI site.
#'
#' @param filepath_data The location to download the archive to. This defaults
#'   to \code{data-raw/}. /If this path already exists, it and its contents will
#'   be archived and the directory will be created fresh.
#'
#' @return The date associated with the data file downloaded.
#' @export
#'
download_data <- function(filepath_data = "data-raw/") {
  # First, check to see if the data filepath exists
  message(paste0("Checking for ", filepath_data, " directory..."))
  if (dir.exists(filepath_data)) {
    # If so, change the name
    filepath_archive <-
      paste0(
        filepath_data |>
          # Remove the final trailing slash
          stringr::str_remove(stringr::regex("/\\B")),
        "_archive_",
        lubridate::now() |>
          stringr::str_remove_all(stringr::regex("[- :]")),
        "/"
      )
    message(paste0("Renaming ", filepath_data, " to ", filepath_archive, "..."))
    file.rename(filepath_data, filepath_archive)
    dir.create(filepath_data)
  } else {
    # If not, create it
    message(paste0("Creating ", filepath_data, "directory..."))
    dir.create(filepath_data)
  }
  # Set up filepaths and get data ----------------------------------------------
  url_datafile_page <- "https://aact.ctti-clinicaltrials.org/pipe_files"
  page <-
    rvest::read_html(url_datafile_page) |>
    rvest::html_elements(css = ".form-select") |>
    as.character() |>
    unlist() |>
    paste0(collapse = "<br><br>")

  url_study_data <-
    page |>
    stringr::str_extract_all(
      pattern = "(?<=href=\")[^\"]*"
    ) |>
    unlist() |>
    utils::head(1)

  date_today <-
    page |>
    stringr::str_extract_all(
      pattern = "(?<=>).*(?=[</option>])"
    ) |>
    unlist() |>
    magrittr::extract2(2) |>
    stringr::str_extract_all("(?<=^ )\\d*") |>
    unlist() |>
    lubridate::ymd()

  options(timeout = max(300, getOption("timeout")))
  utils::download.file(
    url_study_data,
    destfile = paste0(filepath_data, "data.zip")
  )

  message("Unzipping ...")
  utils::unzip(paste0(filepath_data, "data.zip"),
    exdir = filepath_data,
    overwrite = TRUE
  )
  date_today
}
