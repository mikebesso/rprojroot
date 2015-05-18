#' Find the root of a directory hierarchy
#'
#' Starting from the working directory, this function searches for a file
#' whose name matches a given pattern and which optionally contains a given text.
#' If such a file is not found, the search proceeds up the directory hierarchy.
#'
#' @param filename A regular expression to match the file name
#' @param contents A regular expression to match the file contents
#' @param path The start directory
#' @inheritParams base::readLines
#' @param ... Additional params passed to \code{\link{file.path}}
#' @return The normalized path of the root as specified by the search criteria.
#'   Throws an error if no root is found
#'
#' @seealso \code{\link[utils]{glob2rx}} \code{\link{file.path}}
find_root <- function(filename, contents = NULL, n = -1L, path = getwd(), ...) {
  original_path <- path
  path <- normalizePath(path, mustWork = TRUE)

  repeat {
    files <- list_files(path, filename)
    for (f in files) {
      if (!is.null(contents)) {
        fc <- readLines(f, n)
        if (!any(grepl(contents, fc))) {
          next
        }
      }
      return(file.path(path, ...))
    }

    if (is_root(path)) {
      stop("No file matching '", filename,
           if (!is.null(contents)) {
             paste0("' with contents matching '", contents, "'",
                    if (n >= 0L) paste(" in the first", n, "lines"))
           },
           " found in ", original_path, " or above", call. = FALSE)
    }

    path <- normalizePath(file.path(path, ".."))
  }
}

list_files <- function(path, filename) {
  files <- dir(path = path, pattern = filename, all.files = TRUE)
  files <- file.info(file.path(path, files), extra_cols = FALSE)
  files <- subset(files, !isdir)
  files <- rownames(files)
  files
}

is_root <- function(path) {
  identical(path, dirname(path))
}