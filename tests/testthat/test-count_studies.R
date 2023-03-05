test_that("counting studies works", {
  if (rlang::is_installed("tibble")) {
    expect_equal(
      count_studies(
        c(
          "nct1234",
          "nct1235",
          "nct1236"
        ) |>
          tibble::enframe(
            value = "nct_id"
          ),
        "nct_id"
      ),
      3L
    )
    expect_equal(
      count_studies(
        c(
          "nct1234",
          "nct1234",
          "nct1235",
          "nct1236"
        ) |>
          tibble::enframe(
            value = "nct_id"
          ),
        "nct_id"
      ),
      3L
    )
  }
})
