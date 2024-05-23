#!/usr/bin/env Rscript

# Check whether pacman is available, if not install
if (!require("pacman")) install.packages("pacman")

# Install or load the required packages
pacman::p_load(
  devtools,
  tidyverse,
  rio,
  optparse,
  lubridate
)