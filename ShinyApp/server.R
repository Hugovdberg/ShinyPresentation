#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(datasets)
library(magrittr)
library(dplyr)
library(ggplot2)
library(ggmap)
library(Hmisc)
# library(ggalt)
library(plotly)
load('wells.RData')

shinyServer(function(input, output, session) {
    cols <- c("Surface level" = "z0",
              "Screen depth" = "z",
              "Acidity" = "pH",
              "Conductivity" = "conductivity")
    summFuns <- c("Mean" = "mean", "Minimum" = "min", "Maximum" = "max")

    output$summ <- renderPrint({
        data <- wells %>%
            filter(x >= input$x[1], x <= input$x[2],
                   y >= input$y[1], y <= input$y[2],
                   z >= input$z[1], z <= input$z[2]
                   ) %>%
            select_("x", "y", cols[input$dataCol])
        names(data) <- c("X-coordinate",
                         "Y-coordinate",
                         input$dataCol)
        summary(data)
    })
    output$ModelFormula <- renderText({
        paste0("`", input$dataCol, "` ~ `X-coordinate` + `Y-coordinate`")
    })
    output$summModel <- renderPrint({
        data <- wells %>%
            filter(x >= input$x[1], x <= input$x[2],
                   y >= input$y[1], y <= input$y[2],
                   z >= input$z[1], z <= input$z[2]
            ) %>%
            select_("x", "y", cols[input$dataCol])
        names(data) <- c("X-coordinate",
                         "Y-coordinate",
                         input$dataCol)
        form <- as.formula(paste0("`", input$dataCol,
                                  "` ~ `X-coordinate` + `Y-coordinate`"))
        summary(lm(form, data))
    })

    output$distPlot <- renderPlot({
        data <- wells %>% filter(x >= input$x[1], x <= input$x[2],
                                 y >= input$y[1], y <= input$y[2])
        updateSliderInput(session, "z",
                          min = round(min(data$z, na.rm = TRUE), 2),
                          max = round(max(data$z, na.rm = TRUE), 2),
                          value = c(round(max(min(data$z, na.rm = TRUE), input$z[1]), 2),
                                    round(min(max(data$z, na.rm = TRUE), input$z[2]), 2)),
                          step = 0.1)
        data %<>% filter(z >= input$z[1], z <= input$z[2]) %>%
            group_by(well_number, x, y) %>%
            summarise_(val = paste0(summFuns[input$summFun], "(",
                                    cols[input$dataCol],", na.rm = TRUE)")) %>%
            ungroup() %>%
            mutate(val = cut2(val, g = 7))
        if (input$showMap) {
            map <- ggmap(get_map(
                location = c(left = min(data$x),
                             right = max(data$x),
                             bottom = min(data$y),
                             top = max(data$y)),
                scale = 2
            ))
            map <- map +
                geom_point(aes_string("x", "y", color = "val"), data = data)
        } else {
            map <- data %>%
                ggplot(aes_string("x", "y", color = "val")) +
                geom_point() +
                coord_map("ortho", xlim = input$x, ylim = input$y)
        }
        map +
            scale_color_brewer(paste(input$summFun, input$dataCol),
                                   type = "seq", palette = "YlOrRd")
    })

})
