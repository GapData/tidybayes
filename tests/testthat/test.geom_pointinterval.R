# Tests for interval geoms
#
# Author: mjskay
###############################################################################

library(dplyr)
library(purrr)
library(tidyr)
library(vdiffr)

context("geom_pointinterval")

# use a subset of RankCorr so tests are faster
data(RankCorr, package = "tidybayes")
RankCorr_u_tau = RankCorr %>%
  spread_draws(u_tau[i]) %>%
  filter(i %in% 1:3, .iteration %in% 1:50)

test_that("horizontal grouped pointintervals work", {
  forward_plot = RankCorr_u_tau %>%
    median_hdci(.width = c(.66, .95)) %>%
    ggplot(aes(y = i, x = u_tau)) +
    geom_pointintervalh()

  expect_doppelganger("grouped pointintervals (h)", forward_plot)

  stat_forward_plot = RankCorr_u_tau %>%
    ggplot(aes(y = i, x = u_tau)) +
    stat_pointintervalh(.width = c(.66, .95))

  expect_doppelganger("grouped pointintervals (h, stat)", stat_forward_plot)

  stat_forward_plot_mode_hdi = RankCorr_u_tau %>%
    ggplot(aes(y = i, x = u_tau)) +
    stat_pointintervalh(.width = c(.66, .95), point_interval = mode_hdi)

  expect_doppelganger("grouped pointintervals (h, stat, mode_hdi)", stat_forward_plot_mode_hdi)

  reverse_plot = RankCorr_u_tau %>%
    mode_hdi(.width = c(.66, .95)) %>%
    ggplot(aes(y = i, x = u_tau)) +
    geom_pointintervalh()

  expect_doppelganger("grouped pointintervals (h, reverse order)", reverse_plot)

  stat_reverse_plot = RankCorr_u_tau %>%
    ggplot(aes(y = i, x = u_tau)) +
    stat_pointintervalh(.width = c(.66, .95))

  expect_doppelganger("grouped pointintervals (h, stat, reverse order)", stat_reverse_plot)
})

test_that("grouped pointintervals work", {
  forward_plot = RankCorr_u_tau %>%
    mean_qi(.width = c(.66, .95)) %>%
    ggplot(aes(x = i, y = u_tau)) +
    geom_pointinterval()

  expect_doppelganger("grouped pointintervals", forward_plot)

  stat_forward_plot = RankCorr_u_tau %>%
    ggplot(aes(x = i, y = u_tau)) +
    stat_pointinterval(.width = c(.66, .95))

  expect_doppelganger("grouped pointintervals (stat)", stat_forward_plot)

  stat_forward_plot_mode_hdi = RankCorr_u_tau %>%
    ggplot(aes(x = i, y = u_tau)) +
    stat_pointinterval(.width = c(.66, .95), point_interval = mode_hdi)

  expect_doppelganger("grouped pointintervals (stat, mode_hdi)", stat_forward_plot_mode_hdi)

  reverse_plot = RankCorr_u_tau %>%
    mean_qi(.width = c(.66, .95)) %>%
    ggplot(aes(x = i, y = u_tau)) +
    geom_pointinterval()

  expect_doppelganger("grouped pointintervals (reverse order)", reverse_plot)

  stat_reverse_plot = RankCorr_u_tau %>%
    ggplot(aes(x = i, y = u_tau)) +
    stat_pointinterval(.width = c(.66, .95))

  expect_doppelganger("grouped pointintervals (stat, reverse order)", stat_reverse_plot)
})
