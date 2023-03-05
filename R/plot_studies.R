#' Plot Studies
#'
#' @param studies A tibble of studies
#' @param description A descriptive term about the data in \code{studies} to be
#'   included in the plot title and captions.
#' @param this_year This year.
#' @param search_terms The terms used to filter the contents of \code{studies}.
#'
#' @return A plot.
#' @export
#'
plot_studies <- function(studies, description, this_year, search_terms) {
  estimate_study_count <-
    count_studies(studies) |>
    # Always underestimate to the nearest hundred
    plyr::round_any(accuracy = 100, floor)

  estimate_this_year_count <-
    studies |>
    # Filter to studies started last year
    dplyr::mutate(year_start = lubridate::year(.data$start_date)) |>
    dplyr::filter(.data$year_start == this_year) |>
    # Select only the NCT ID
    dplyr::select(.data$nct_id) |>
    # De-duplicate
    dplyr::distinct() |>
    # Count
    dplyr::pull(.data$nct_id) |>
    length() |>
    as.double() |>
    # Always underestimate to the nearest ten
    plyr::round_any(accuracy = 10, floor)

  cumulative_studies_by_topic <-
    studies |>
    # Get the start date, topic, and NCT ID of each study
    dplyr::select(.data$start_date, .data$topic, .data$nct_id) |>
    # Put them in order of start date
    dplyr::arrange(.data$start_date) |>
    # De-duplicate
    dplyr::distinct() |>
    # Group studies by start date and topic
    dplyr::group_by(.data$start_date, .data$topic) |>
    # Count the number of studies started by topic on each date
    dplyr::tally() |>
    # Ungroup
    dplyr::ungroup() |>
    # Group studies by topic only
    dplyr::group_by(.data$topic) |>
    # Sort studies by start date
    dplyr::arrange(.data$start_date) |>
    # Calculate the running cumulative total by topic on each date
    dplyr::mutate(cumulative_total = cumsum(.data$n))

  cumulative_studies <-
    studies |>
    # Get the start date and NCT ID of each study
    dplyr::select(.data$start_date, .data$nct_id) |>
    # Put them in order of start date
    dplyr::arrange(.data$start_date) |>
    # De-duplicate
    dplyr::distinct() |>
    # Group studies by start date
    dplyr::group_by(.data$start_date) |>
    # Count the number of studies started each date
    dplyr::tally() |>
    # Ungroup
    dplyr::ungroup() |>
    # Sort studies by start date
    dplyr::arrange(.data$start_date) |>
    # Calculate the running cumulative total by topic on each date
    dplyr::mutate(cumulative_total = cumsum(.data$n)) |>
    dplyr::mutate(topic = paste0("All ", description, " trials"))

  source_string <-
    paste0(
      "Source: ClinicalTrials.gov as of ",
      # Get the string from ClinicalTrials.gov that has the most recent update
      # date
      studies$start_date |> max(na.rm = TRUE),
      ".\n\n",
      "Topics are not mutually exclusive. Trials may appear in more than one ",
      "topic.\n\n",
      "Some search results have been excluded based on manual review.",
      "\n\n",
      "Search terms: \n",
      # Paste in all the search terms
      paste(search_terms$term, collapse = ", ") |>
        # Keep the string from exceeding the width of the plot
        stringr::str_wrap(width = 100)
    )

  # Finally prepped. Time to plot!
  plot <-
    ggplot2::ggplot() +
    ggplot2::geom_line(
      data = cumulative_studies,
      mapping = ggplot2::aes(
        x = .data$start_date,
        y = .data$cumulative_total,
        # There's only one topic here, "All [description] trials", but we want
        # that to show up in a legend, so we will "set" the linetype based on
        # that. Since there is only one topic in this geom, the linetype will
        # be a solid line.
        linetype = .data$topic
      )
    ) +
    ggplot2::geom_line(
      data = cumulative_studies_by_topic,
      mapping = ggplot2::aes(
        x = .data$start_date,
        y = .data$cumulative_total,
        color = .data$topic
      )
    ) +
    ggplot2::labs(
      title = paste0(
        "More than ", estimate_study_count,
        " ",
        description,
        " clinical trials have started as of ",
        studies$start_date |> max(na.rm = TRUE)
      ),
      subtitle = paste0(
        "And more than ", estimate_this_year_count,
        " started in ", this_year, " alone"
      ),
      x = "Date",
      y = "Cumulative number of trials started",
      # We don't want a legend title for the linetype legend, but leaving it
      # NA causes the linetype legend to appear below the color legend. It
      # looks better above the color legend, so we'll set it to a space
      # character to get that effect.
      linetype = " ",
      color = "Topic",
      caption = source_string
    ) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      # Left-align the caption
      plot.caption = ggplot2::element_text(hjust = 0),
      # Add half-inch margins
      plot.margin = ggplot2::margin(
        t = 0.5, r = 0.5, b = 0.5, l = 0.5,
        unit = "in"
      )
    )
}
