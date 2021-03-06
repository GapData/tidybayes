# Tests for [add_]predicted_draws
#
# Author: mjskay
###############################################################################

suppressWarnings(suppressMessages({
  library(bindrcpp)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(rstan)
  library(rstanarm)
}))
import::from(magrittr, set_rownames)

context("predicted_draws")


# data
mtcars_tbl = mtcars %>%
  set_rownames(seq_len(nrow(.))) %>%
  as_data_frame()


test_that("[add_]predicted_draws throws an error on unsupported models", {
  data("RankCorr", package = "tidybayes")

  expect_error(predicted_draws(RankCorr, data.frame()),
    'Models of type "mcmc.list" are not currently supported by `predicted_draws`')
  expect_error(add_predicted_draws(data.frame(), RankCorr),
    'Models of type "mcmc.list" are not currently supported by `predicted_draws`')
})


test_that("[add_]predicted_draws and basic arguments works on a simple rstanarm model", {
  m_hp_wt = readRDS("../models/models.rstanarm.m_hp_wt.rds")

  preds = posterior_predict(m_hp_wt, mtcars_tbl, draws = 100, seed = 123) %>%
    as.data.frame() %>%
    mutate(
      .chain = as.integer(NA),
      .iteration = as.integer(NA),
      .draw = seq_len(n())
    ) %>%
    gather(.row, .prediction, -.chain, -.iteration, -.draw) %>%
    as_data_frame()

  ref = mtcars_tbl %>%
    mutate(.row = rownames(.)) %>%
    inner_join(preds, by = ".row") %>%
    mutate(.row = as.integer(.row))

  expect_equal(ref, predicted_draws(m_hp_wt, mtcars_tbl, n = 100, seed = 123))
  expect_equal(ref, add_predicted_draws(mtcars_tbl, m_hp_wt, n = 100, seed = 123))
})


test_that("[add_]predicted_draws and basic arguments works on an rstanarm model with random effects", {
  m_cyl = readRDS("../models/models.rstanarm.m_cyl.rds")

  preds = posterior_predict(m_cyl, mtcars_tbl, draws = 100, seed = 123) %>%
    as.data.frame() %>%
    mutate(
      .chain = as.integer(NA),
      .iteration = as.integer(NA),
      .draw = seq_len(n())
    ) %>%
    gather(.row, .prediction, -.chain, -.iteration, -.draw) %>%
    as_data_frame()

  ref = mtcars_tbl %>%
    mutate(.row = rownames(.)) %>%
    inner_join(preds, by = ".row") %>%
    mutate(.row = as.integer(.row))

  expect_equal(ref, predicted_draws(m_cyl, mtcars_tbl, n = 100, seed = 123))
  expect_equal(ref, add_predicted_draws(mtcars_tbl, m_cyl, n = 100, seed = 123))
})


test_that("[add_]predicted_draws works on a simple brms model", {
  m_hp = readRDS("../models/models.brms.m_hp.rds")

  set.seed(123)
  preds = predict(m_hp, mtcars_tbl, summary = FALSE, nsamples = 100) %>%
    as.data.frame() %>%
    set_names(seq_len(ncol(.))) %>%
    mutate(
      .chain = as.integer(NA),
      .iteration = as.integer(NA),
      .draw = seq_len(n())
    ) %>%
    gather(.row, .prediction, -.chain, -.iteration, -.draw) %>%
    as_data_frame()

  ref = mtcars_tbl %>%
    mutate(.row = rownames(.)) %>%
    inner_join(preds, by = ".row") %>%
    mutate(.row = as.integer(.row))

  expect_equal(predicted_draws(m_hp, mtcars_tbl, n = 100, seed = 123), ref)
  expect_equal(add_predicted_draws(mtcars_tbl, m_hp, n = 100, seed = 123), ref)
})

test_that("[add_]predicted_draws throws an error when nsamples is called instead of n in brms", {
  m_hp = readRDS("../models/models.brms.m_hp.rds")

  expect_error(
    m_hp %>% predicted_draws(newdata = mtcars_tbl, nsamples = 100),
    "`nsamples.*.`n`.*.See the documentation for additional details."
  )
  expect_error(
    m_hp %>% add_predicted_draws(newdata = mtcars_tbl, nsamples = 100),
    "`nsamples.*.`n`.*.See the documentation for additional details."
  )
})

test_that("[add_]predicted_draws throws an error when draws is called instead of n in rstanarm", {
  m_hp_wt = readRDS("../models/models.rstanarm.m_hp_wt.rds")

  expect_error(
    m_hp_wt %>% predicted_draws(newdata = mtcars_tbl, draws = 100),
    "`draws.*.`n`.*.See the documentation for additional details."
  )
  expect_error(
    m_hp_wt %>% add_predicted_draws(newdata = mtcars_tbl, draws = 100),
    "`draws.*.`n`.*.See the documentation for additional details."
  )
})

test_that("[add_]predicted_draws throws an error when re.form is called instead of re_formula in rstanarm", {
  m_hp_wt = readRDS("../models/models.rstanarm.m_hp_wt.rds")

  expect_error(
    m_hp_wt %>% predicted_draws(newdata = mtcars_tbl, re.form = NULL),
    "`re.form.*.`re_formula`.*.See the documentation for additional details."
  )
  expect_error(
    m_hp_wt %>% add_predicted_draws(newdata = mtcars_tbl, re.form = NULL),
    "`re.form.*.`re_formula`.*.See the documentation for additional details."
  )
})
