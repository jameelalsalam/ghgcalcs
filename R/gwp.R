#' Pull GWP values
#'
#' Defaults to AR4 100-year GWP currently.
#' Accepted values: c("gwp_ar4_100", "gwp_ar4_20", "gwp_ar4_500", "gwp_sar_100")
#'
#' @export
#' @examples
#' gwp_value(c("Carbon dioxide", "Nitrous oxide"))
gwp_value <- function(x, gwp_type = c("gwp_ar4_100")) {

  gwp_type <- if(length(gwp_type) > 1 | is.null(gwp_type)) "gwp_ar4_100" else gwp_type

  col <- gwp_type # tidyselect here? which or something?

  input <- tibble(
    common_name = x
  )

  output <- left_join(input,
                      ghgcalcs::gwp_ipcc_ar4, by = "common_name")

  stopifnot(nrow(input) == nrow(output))

  res <- pull(output, col)
  res
}
