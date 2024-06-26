% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Analogy_Functions.R
\name{shift_letters}
\alias{shift_letters}
\title{Shift Letters}
\usage{
shift_letters(string, n)
}
\arguments{
\item{string}{The string to shift.}

\item{n}{The number of positions to shift each letter.}
}
\value{
The modified string with shifted letters.
}
\description{
Applies a cyclic shift to each letter in the provided string by a specified number of positions.
}
\examples{
shift_letters("ABCD", 1)  # Returns "BCDE"
}
