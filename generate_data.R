library(magrittr)
library(dplyr)

set.seed(2016-10-15)

n_wells <- 100
x_min <- 4
x_max <- 7
y_min <- 50.5
y_max <- 52
z0_mean <- 20
z0_sd <- 5
screens_mean <- 4
screens_mean_diff <- 5

wells_x <- runif(n_wells, x_min, x_max)
wells_y <- runif(n_wells, y_min, y_max)
wells_z0 <- rnorm(n_wells, 5 * (wells_x - 5) + 15 * (51 - wells_y), z0_sd) + 10
# wells_z0 <- 5 * (wells_x - 5) + 15 * (51 - wells_y)
n_screens <- rpois(n_wells, screens_mean) + 1

wells <- data.frame()
for (w in seq(1, n_wells)) {
    screens_z <- cumsum(1 + screens_mean_diff*rexp(n_screens[w], screens_mean_diff))
    screens <- data.frame(well_number = w,
                          screen_number = seq(1, n_screens[w]),
                          n_screens = n_screens[w],
                          x = wells_x[w],
                          y = wells_y[w],
                          z0 = wells_z0[w],
                          z = wells_z0[w] - screens_z) %>%
        mutate(label = paste(well_number, screen_number, sep = "-"))
    wells %<>% bind_rows(screens)
}

n_obs <- 5*nrow(wells)
row_number <- sample(nrow(wells), n_obs, replace = TRUE)
well_number <- wells$well_number[row_number]
screen_number <- wells$screen_number[row_number]
cond <- rnorm(n_obs, 35, 10)
pH <- rnorm(n_obs, 6.5, 1.5)
wells_obs <- data.frame(well_number = well_number,
                     screen_number = screen_number,
                     conductivity = cond,
                     pH = pH)
wells %<>% left_join(wells_obs, by = c("well_number", "screen_number"))
save(wells, file = 'ShinyApp/wells.RData')
# rm(list = ls())
# library(leaflet)
# wells %>% leaflet() %>%
#     addTiles() %>%
#     addMarkers(
#         lng = ~x,
#         lat = ~y,
#         popup = wells$label,
#         clusterOptions = markerClusterOptions()
#         ) %>% print
library(ggplot2)
wells %>%
    distinct(x,y,z0) %>%
    ggplot(aes(x, y, color = z0)) +
    geom_point()
