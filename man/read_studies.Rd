% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_studies.R
\name{read_studies}
\alias{read_studies}
\title{Read Studies File}
\usage{
read_studies(filepath_data, filename_studies = "studies.txt")
}
\arguments{
\item{filepath_data}{The download directory where the data is stored.}

\item{filename_studies}{The filename of the studies file. Defaults to
\code{studies.txt}.}
}
\value{
A tibble of study data.
}
\description{
Read the \code{studies.txt} file downloaded from clinicaltrials.gov.
}
