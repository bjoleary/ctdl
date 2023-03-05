#' Count the number of unique studies included in a tibble
#'
#' @param data A tibble
#' @param nct_column The name of the column of \code{data} that corresponds to
#'   the NCT ID. Defaults to \code{"nct_id"}.
#'
#' @return A count of the number of unique NCT IDs in the table, as a double.
#' @export
#'
count_studies <- function(data, nct_column = "nct_id") {
  data[[nct_column]] |>
    unique() |>
    length() |>
    as.double()
}
