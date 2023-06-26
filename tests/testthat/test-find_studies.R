test_that("find_studies works", {
  studies_mock <-
    tibble::tribble(
      ~nct_id, ~official_title, ~brief_title,
      "NCT05338905",
      "Intensive Symptom Surveillance Guided by Machine Learning-Directed Risk",
      "The INSIGHT Trial",
      "NCT01549457"	,
      "The Effect of Weekly Text-message Communication on Treatment Completion",
      "TB mHealth Study - Use of Cell Phones to Improve Compliance in Patients",
      "NCT01774669",
      "Effectiveness of the YouGrabber System Using Virtual Reality in Stroke",
      "Study on a Virtual Reality Based Training System for Stroke Patients",
      "NCT03867903"	,
      "BabySparks App: A Pilot Study of mHealth Adherence to a Developmental",
      "BabySparks Developmental Application Pilot Study"
    )
  terms_mock <-
    tibble::tribble(
      ~term, ~topic,
      "Machine Learning", "AI/ML",
      "mHealth", "mHealth",
      "Virtual Reality", "AR/VR",
    ) |>
    dplyr::mutate(
      regex_term =
        stringr::regex(
          pattern = paste0("\\b", .data$term, "\\b"),
          ignore_case = TRUE
        )
    )
  expect_snapshot(
    x =
      find_studies(
        data_studies = studies_mock,
        search_terms = terms_mock
      )
  )
})
