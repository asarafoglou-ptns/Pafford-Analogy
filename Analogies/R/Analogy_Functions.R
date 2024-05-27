
## Analogies App
## Alexandra Pafford
setwd("C:/Users/alexa/Documents/Programming2/Analogies/R")
getwd()

# --------------------------------------------------------------------------

## Install dependencies
# install.packages(c("shiny", "readr", "writexl"))

## Load libraries with namespaces
library(shiny)
library(readr)
library(writexl)

# --------------------------------------------------------------------------
## Functions

#' @title Generate Sequential String of Letters
#' @description Generates a sequential string of a specified length starting from a random letter.
#' @param length The length of the letter string to generate.
#' @return A string of sequential letters of the specified length.
#' @examples
#' generate_sequential_string(5)
#' @export
generate_sequential_string <- function(length) {
  start_letter <- sample(LETTERS[1:(26 - length + 1)], 1)
  start_index <- utf8ToInt(start_letter)
  sequential_string <- intToUtf8(start_index:(start_index + length - 1))
  paste(sequential_string, collapse = "")
}

#' @title Shift Letters
#' @description Applies a cyclic shift to each letter in the provided string by a specified number of positions.
#' @param string The string to shift.
#' @param n The number of positions to shift each letter.
#' @return The modified string with shifted letters.
#' @examples
#' shift_letters("ABCD", 1)  # Returns "BCDE"
#' @export
shift_letters <- function(string, n) {
  shifted <- sapply(strsplit(string, "")[[1]], function(char) {
    intToUtf8((utf8ToInt(char) - utf8ToInt(ifelse(grepl("[A-Z]", char), 'A', 'a')) + n) %% 26 + utf8ToInt(ifelse(grepl("[A-Z]", char), 'A', 'a')))
  })
  paste(shifted, collapse = "")
}

#' @title Reverse String
#' @description Returns a new string that is the 'mirror' of the input string.
#' @param string The string to reverse.
#' @return The reversed string.
#' @examples
#' reverse_string("hello")  # Returns "olleh"
#' @export
reverse_string <- function(string) {
  paste(rev(strsplit(string, "")[[1]]), collapse = "")
}

#' @title Letter Deletion
#' @description Removes the last letter from the given string.
#' @param string The string from which to delete the last letter.
#' @return The string minus the last letter.
#' @examples
#' letter_deletion("hi")  # Returns "h"
#' @export
letter_deletion <- function(string) {
  substring(string, 1, nchar(string) - 1)
}

#' @title Letter Addition
#' @description Adds the next sequential letter to the end of the string. Wraps around to 'A' after 'Z'.
#' @param string The string to which a letter will be added.
#' @return The string with an additional letter appended.
#' @examples
#' letter_addition("ABC")  # Returns "ABCD"
#' @export
letter_addition <- function(string) {
  last_char <- substring(string, nchar(string))
  next_char <- intToUtf8((utf8ToInt(last_char) - utf8ToInt(ifelse(grepl("[A-Z]", last_char), 'A', 'a')) + 1) %% 26 + utf8ToInt(ifelse(grepl("[A-Z]", last_char), 'A', 'a')))
  paste0(string, next_char)
}

#' @title Generate Letter String Analogy
#' @description Constructs an analogy using a base string and a transformation function.
#' @param base_string The base string to use in the analogy.
#' @param transformation A function that applies a transformation to a string.
#' @return A formatted string representing the analogy.
#' @examples
#' generate_analogy("ABCD", reverse_string)  # Returns "ABCD : DCBA :: BCDE : EDCB"
#' @export
generate_analogy <- function(base_string, transformation) {
  A <- base_string
  B <- transformation(A)
  C <- shift_letters(A, 1)
  D <- transformation(C)
  sprintf("%s : %s :: %s : %s", A, B, C, D)
}

# --------------------------------------------------------------------------
## Shiny UI

# Define UI for application
ui <- shiny::fluidPage(
  # Add custom CSS to style the app
  shiny::tags$head(
    shiny::tags$style(shiny::HTML("
      body { 
        background-color: #FFD1DC; 
        color: #333333; 
        font-family: 'Arial', sans-serif; 
      }
      .well { 
        background-color: #FFC0CB; 
        border-color: #FFB6C1;
      }
      h1 { 
        color: #CC8899; 
      }
      .btn { 
        background-color: #FFB6C1;
        color: #FFFFFF;
        border: none;
      }
      .btn:hover {
        background-color: #FFA6B9;
      }
      .form-control {
        border-color: #FFA6B9;
      }
      .shiny-output-error {
        color: #660033;
      }
      .shiny-output-error:before {
        content: 'Error: ';
      }
    "))
  ),
  
  shiny::titlePanel("Letter String Analogy Generator"),
  
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::numericInput("num_problems", "Number of problems:", 5, min = 1),
      shiny::selectInput("transformation_type", "Transformation Type:",
                         choices = c("Shift Letters", "Reverse String", "Shift Two Letters", "Letter Deletion", "Letter Addition")),
      shiny::downloadButton("downloadData", "Download")
    ),
    shiny::mainPanel(
      shiny::tableOutput("analogy_table")
    )
  )
)


# Shiny server logic
server <- function(input, output) {
  generate_analogies <- reactive({
    num_problems <- input$num_problems
    transformation_type <- input$transformation_type
    
    base_strings <- replicate(num_problems, generate_sequential_string(4))
    
    transformation <- switch(transformation_type,
                             "Shift Letters" = function(s) shift_letters(s, 1),
                             "Reverse String" = reverse_string,
                             "Shift Two Letters" = function(s) shift_letters(s, 2),
                             "Letter Deletion" = letter_deletion,
                             "Letter Addition" = letter_addition)
    
    analogies <- sapply(base_strings, generate_analogy, transformation = transformation)
    data.frame(Analogy = analogies)
  })
  
  output$analogy_table <- shiny::renderTable({
    generate_analogies()
  })
  
  output$downloadData <- shiny::downloadHandler(
    filename = function() {
      paste("analogies-", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      analogies <- generate_analogies()
      readr::write_csv(analogies, file)
    }
  )
}

# Run the app
shiny::shinyApp(ui = ui, server = server)

