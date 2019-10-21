
#' Normalize GHG names based on ghg_dictionary
#'
#' @importFrom tibble tibble
#' @import dplyr
#' @export
normalize_ghg_names <- function(x) {

  input <- tibble(
    wildcaught_name = x
  )

  output <- left_join(input, ghg_dictionary, by = "wildcaught_name")

  stopifnot(nrow(input) == nrow(output))

  res <- pull(output, "normalized_common_name")

  res
}
