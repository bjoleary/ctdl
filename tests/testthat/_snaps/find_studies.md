# find_studies works

    Code
      find_studies(data_studies = studies_mock, search_terms = terms_mock)
    Output
      # A tibble: 4 x 6
        nct_id      official_title                  brief_title term_found term  topic
        <chr>       <chr>                           <chr>       <chr>      <chr> <fct>
      1 NCT05338905 Intensive Symptom Surveillance~ The INSIGH~ "\\bMachi~ Mach~ AI/ML
      2 NCT01549457 The Effect of Weekly Text-mess~ TB mHealth~ "\\bmHeal~ mHea~ mHea~
      3 NCT03867903 BabySparks App: A Pilot Study ~ BabySparks~ "\\bmHeal~ mHea~ mHea~
      4 NCT01774669 Effectiveness of the YouGrabbe~ Study on a~ "\\bVirtu~ Virt~ AR/VR

