transform <- function(input, output) {
    result <- readr::read_delim(input, 
                                delim = "|", 
                                locale = readr::locale(encoding = "windows-1252"))
    result <- janitor::clean_names(result)
    readr::write_excel_csv2(result, output, quote = "needed", na = "")
}

main <- function(args) {
    input <- args[1]
    output <- args[2]
    suppressMessages(transform(input, output))
}

main(commandArgs(trailingOnly = TRUE))
