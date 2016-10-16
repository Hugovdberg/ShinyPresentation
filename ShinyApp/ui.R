#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

theme = 'yeti'
if (!file.exists(paste0('www/', theme, '.css'))) {
    download.file(paste0("http://bootswatch.com/", theme, "/bootstrap.min.css"),
                  paste0('www/', theme, '.css'))
}

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = paste0(theme, '.css'),

    # Application title
    titlePanel("Waterquality in NW-Europe"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput("x", "Select X-range",
                        min = 4, max = 7, value = c(4,7), step = 0.01),
            sliderInput("y", "Select Y-range",
                        min = 50.5, max = 52, value = c(50.5, 52), step = 0.01),
            sliderInput("z", "Select screen depth range",
                        min = -300, max = 300, value = c(-300, 300), step = 0.1),
            selectInput("dataCol", "Color by column:",
                        c("Surface level",
                          "Screen depth",
                          "Acidity",
                          "Conductivity"),
                        selected = "Surface level"),
            selectInput("summFun", "Summary function:",
                        c("Mean", "Minimum", "Maximum"),
                        selected = "Mean"),
            checkboxInput("showMap", "Show map background (slow)", value = FALSE),
            submitButton("Apply filters")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(
                tabPanel("Plot",
                         h3("Plot"),
                         plotOutput("distPlot", height = "600px")
                         ),
                tabPanel("Summary",
                         h3("Dataset summary"),
                         pre(textOutput("summ")),
                         h3("Spatial summary"),
                         p("Formula:", pre(textOutput("ModelFormula"))),
                         pre(textOutput("summModel"))
                         ),
                tabPanel("Help",
                         h3("Help"),
                         p("This app shows fictitious water quality data for ",
                           "a region in north western Europe.",
                           "The data is linked to a number of ",
                           a("wells", href = "https://en.wikipedia.org/wiki/Water_well"),
                           "with a given X- and Y-coordinate, each with a",
                           "number of screens on different depths.",
                           "For these screens random values for the",
                           "conductivity and acidity were generated."),
                         p("The app consists of three main parts: the ",
                           a("sidebar", href = "#help_sidebar"),
                           " to filter the data, the ",
                           a("plot", href = "#help_plot"),
                           " to visualise the data, and finally the ",
                           a("summary", href = "#help_summary"),
                           " of the displayed data."
                         ),
                         h4("Plot", id = "help_plot"),
                         p("The plot panel shows a plot of the data, based on",
                           "the criteria in the ",
                           a("sidebar.", href = "#help_sidebar"),
                           "The extent of the map is always equal to the ",
                           "filter limits, while the colorbar is updated with ",
                           "the filtered values."),
                         h4("Summary", id = "help_summary"),
                         p("The summary panel shows a summary of the data as",
                           "it is visualised on the plot panel.",
                           "To save space it only shows a summary of the X and",
                           "Y coordinates, together with the column selected",
                           "for colouring the points on the plot."),
                         p("Secondly, the summary panel also shows a linear",
                           "regression of the selected column with the spatial",
                           "coordinates to see if there is a relation between",
                           "location and parameter."),
                         h4("Sidebar", id = "help_sidebar"),
                         p("The sidebar provides a number of filters to limit",
                           "the extent of the plotted data.",
                           "First of of the top two sliders allow you to set",
                           "the X- and Y- coordinates shown.",
                           "The third slider sets a limit on the screens shown",
                           "for each well based on its depth."),
                         p("The points in the plot are colored by the values",
                           "in the column selected in the first selectbox,",
                           "while the measurements for each well are summarised",
                           "using the function listed in the second selectbox."),
                         p("Finally, the checkbox allows you to show a map",
                           "as background for the plot.",
                           "This functionality is rather slow because the map",
                           "has to be generated for each plot, so it is",
                           "disabled by default."),
                         p("To apply the filters after setting new values, use",
                           "the button at the bottom of the sidebar.")
                         )
            )
        )
    )
))
