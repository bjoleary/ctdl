#' Read Studies File
#'
#' Read the \code{studies.txt} file downloaded from clinicaltrials.gov.
#'
#' @param filepath_data The download directory where the data is stored.
#' @param filename_studies The filename of the studies file. Defaults to
#'   \code{studies.txt}.
#'
#' @return A tibble of study data.
#' @export
#'
read_studies <- function(filepath_data, filename_studies = "studies.txt") {
  readr::read_delim(
    file = paste0(
      filepath_data,
      filename_studies
    ),
    delim = "|",
    col_types = readr::cols(
      nct_id = readr::col_character(),
      nlm_download_date_description = readr::col_character(),
      study_first_submitted_date = readr::col_date(format = ""),
      results_first_submitted_date = readr::col_date(format = ""),
      disposition_first_submitted_date = readr::col_date(format = ""),
      last_update_submitted_date = readr::col_date(format = ""),
      study_first_submitted_qc_date = readr::col_date(format = ""),
      study_first_posted_date = readr::col_date(format = ""),
      study_first_posted_date_type = readr::col_character(),
      results_first_submitted_qc_date = readr::col_date(format = ""),
      results_first_posted_date = readr::col_date(format = ""),
      results_first_posted_date_type = readr::col_character(),
      disposition_first_submitted_qc_date = readr::col_date(format = ""),
      disposition_first_posted_date = readr::col_date(format = ""),
      disposition_first_posted_date_type = readr::col_character(),
      last_update_submitted_qc_date = readr::col_date(format = ""),
      last_update_posted_date = readr::col_date(format = ""),
      last_update_posted_date_type = readr::col_character(),
      start_month_year = readr::col_character(),
      start_date_type = readr::col_character(),
      start_date = readr::col_date(format = ""),
      verification_month_year = readr::col_character(),
      verification_date = readr::col_date(format = ""),
      completion_month_year = readr::col_character(),
      completion_date_type = readr::col_character(),
      completion_date = readr::col_date(format = ""),
      primary_completion_month_year = readr::col_character(),
      primary_completion_date_type = readr::col_character(),
      primary_completion_date = readr::col_date(format = ""),
      target_duration = readr::col_character(),
      study_type = readr::col_character(),
      acronym = readr::col_character(),
      baseline_population = readr::col_character(),
      brief_title = readr::col_character(),
      official_title = readr::col_character(),
      overall_status = readr::col_character(),
      last_known_status = readr::col_factor(),
      phase = readr::col_character(),
      enrollment = readr::col_double(),
      enrollment_type = readr::col_character(),
      source = readr::col_character(),
      limitations_and_caveats = readr::col_character(),
      number_of_arms = readr::col_double(),
      number_of_groups = readr::col_double(),
      why_stopped = readr::col_character(),
      has_expanded_access = readr::col_logical(),
      expanded_access_type_individual = readr::col_character(),
      expanded_access_type_intermediate = readr::col_character(),
      expanded_access_type_treatment = readr::col_character(),
      has_dmc = readr::col_logical(),
      is_fda_regulated_drug = readr::col_logical(),
      is_fda_regulated_device = readr::col_logical(),
      is_unapproved_device = readr::col_logical(),
      is_ppsd = readr::col_logical(),
      is_us_export = readr::col_logical(),
      biospec_retention = readr::col_character(),
      biospec_description = readr::col_character(),
      ipd_time_frame = readr::col_character(),
      ipd_access_criteria = readr::col_character(),
      ipd_url = readr::col_character(),
      plan_to_share_ipd = readr::col_character(),
      plan_to_share_ipd_description = readr::col_character(),
      created_at = readr::col_datetime(format = ""),
      updated_at = readr::col_datetime(format = "")
    )
  ) |>
    dplyr::mutate(
      # Make a new field that describes whether or not an FDA-regulated product
      # is being studied.
      fda_product =
        dplyr::case_when(
          .data$is_unapproved_device == TRUE ~ "New FDA-regulated device",
          .data$is_fda_regulated_device == TRUE ~ "FDA-regulated device",
          .data$is_fda_regulated_drug == TRUE ~ "FDA-regulated drug",
          # Otherwise:
          TRUE ~ "Other"
        ) |>
        # Make this field a factor
        forcats::as_factor() |>
        # Hard code the order in which this factor appears
        forcats::fct_relevel(
          c(
            "FDA-regulated device",
            "New FDA-regulated device",
            "FDA-regulated drug",
            "Other"
          )
        ),
      # Extract Download Dates
      date_download =
        stringr::str_extract(
          string = .data$nlm_download_date_description,
          # "Month day, year | YYYY-MM-DD"
          pattern = "\\b[A-z]*\\b\\s\\d{2},\\s\\d{4}|\\d{4}-\\d{2}-\\d{2}"
        ) |>
        lubridate::parse_date_time(
          orders =
            c(
              "%B %d, %Y",
              "%Y-%m-%d"
            )
        )
    ) |>
    # Remove the boolean fields used to calculate fda_product
    dplyr::select(
      -"is_unapproved_device", -"is_fda_regulated_device",
      -"is_fda_regulated_drug"
    )
}
