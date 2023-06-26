#' Find Studies
#'
#' @param data_studies A tibble including the columns \code{official_title},
#'   \code{brief_title}, and \code{nct_id}.
#' @param search_terms A tibble including the columns \code{regex_term} and
#'   \code{topic}.
#' @param known_fp A vector of NCT numbers that should be excluded from the
#'   search results. Defaults to \code{NULL}.
#' @param max_topics An integer value for the maximum number of topics to
#'   include in the results. Less frequent topics beyond this number will be
#'   collapsed into an "Other" topic.
#'
#' @return A tibble.
#' @export
#'
find_studies <- function(data_studies, search_terms, known_fp = NULL,
                         max_topics = 5L) {
  studies <-
    # For each search term in search topics...
    lapply(
      search_terms$regex_term,
      function(search_term) {
        data_studies |>
          # If we detect the search term in the official title, set hit to TRUE
          dplyr::mutate(
            hit =
              stringr::str_detect(
                string = .data$official_title,
                pattern = stringr::regex(
                  search_term,
                  ignore_case = TRUE
                )
              )
          ) |>
          # If we detect the search term in the brief title, set hit_brief to
          # TRUE
          dplyr::mutate(
            hit_brief =
              stringr::str_detect(
                string = .data$brief_title,
                pattern = stringr::regex(
                  search_term,
                  ignore_case = TRUE
                )
              )
          ) |>
          # Limit the results to those where either hit or hit_brief is TRUE
          dplyr::filter(
            .data$hit == TRUE | .data$hit_brief == TRUE
          ) |>
          # Record the search term in a new field
          dplyr::mutate(term_found = search_term) |>
          # Don't need the hit columns anymore
          dplyr::select(-"hit", -"hit_brief")
      }
    ) |>
    # After looping, bind all the rows into one tibble
    dplyr::bind_rows() |>
    # Remove known false positives
    dplyr::filter(!(.data$nct_id %in% known_fp)) |>
    # De-duplicate the table
    dplyr::distinct() |>
    # Join in the topics from the search topics table
    dplyr::left_join(
      y =
        search_terms |>
        dplyr::mutate(regex_term = as.character(.data$regex_term)),
      by = c("term_found" = "regex_term")
    )
  # Limit the topics to the top X plus an "Other" topic
  studies$topic <-
    forcats::fct_lump(studies$topic, n = max_topics) |>
    # Reorder the topic factor by frequency of appearance, most frequent to
    # least
    forcats::fct_infreq()
  # Return the whole tibble
  studies
}
