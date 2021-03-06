#' View function as flow chart
#'
#' `flow_view()` shows the code of a function as a flow diagram, `flow_run()`
#' runs a call and draws the logical path taken by the code.
#'
#' @param x A call, a function, or a path to a script
#' @param prefix prefix to use for special comments in our code used as block headers,
#'   must start with `"#"`, several prefixes can be provided
#' @param truncate maximum number of characters to be printed per line
#' @param nested_fun if not NULL, the index or name of the function definition found in
#'   x that we wish to inspect
#' @param swap whether to change `var <- if(cond) expr` into
#'   `if(cond) var <- expr` so the diagram displays better
#' @param narrow `TRUE` makes sure the diagram stays centered on one column
#'   (they'll be longer but won't shift to the right)
#' @inheritParams build_nomnoml_code
#' @param browse whether to debug step by step (block by block),
#'   can also be a vector of block ids, in this case `browser()` calls will be
#'   inserted at the start of these blocks
#' @param out a path to save the diagram to.
#'   Special values "html", "htm", "png", "pdf", "jpg" and "jpeg" can be used to
#'   export the objec to a temp file of the relevant format and open it,
#'   if a regular path is used the format will be guessed from the extension.
#' @param engine Either `"nomnoml"` (default) or `"plantuml"` (experimental), if
#'   the latter, arguments `prefix`, `narrow`, and `code`
#'
#' @export
flow_view <- function(
  x,
  prefix = NULL,
  code = TRUE,
  narrow = FALSE,
  truncate = NULL,
  nested_fun = NULL,
  swap = TRUE,
  out = NULL,
  engine = c("nomnoml", "plantuml")) {

  engine = match.arg(engine)
  svg <- is.null(out) || endsWith(out, ".html") || endsWith(out, ".html")

    ## fetch fun name from quoted input

    f_chr <- deparse1(substitute(x))
    is_valid_named_list <-
      is.list(x) && length(x) == 1 && !is.null(names(x))

    ## is `x` a named list ?
    if(is_valid_named_list) {
      ## replace fun name and set the new `x`
      f_chr <- names(x)
      x <- x[[1]]
    }

    ## is the engine "plantuml" ?
    if(engine == "plantuml") {
      if(!"plantuml" %in% installed.packages()[,"Package"])
        stop("The package plantuml needs to be installed to use this feature. ",
             'To install it run `remotes::install_github("rkrug/plantuml")`, ',
             "You might also need to install java ('https://www.java.com'), ",
             "ghostcript ('https://www.ghostcript.com'), ",
             "and graphViz ('https://graphviz.org/')")

      ## are any unsupported argument not missing ?
      if(!is.null(prefix) ||
         narrow || !code) {
        ## warn that they will be ignored
        warning("The following arguments are ignored if `engine` is set to ",
                "\"plantuml\" : `prefix`, `narrow`, `code`")
      }

      ## run flow_view_plantuml
      flow_view_plantuml(
        x_chr = f_chr,
        x = x,
        prefix = prefix,
        truncate = truncate,
        nested_fun = nested_fun,
        swap = swap,
        out = out)
      return(invisible(NULL))
    }

    ## run flow_view_nomnoml
    flow_view_nomnoml(
      f_chr = f_chr,
      x  = x,
      prefix  = prefix,
      truncate = truncate,
      nested_fun = nested_fun,
      swap = swap,
      narrow = narrow,
      code = code,
      out = out,
      svg = svg,
      engine = engine)
}


