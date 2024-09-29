# PUB Sector R Workshop 2024: Dashboarding for Leaders and Managing Data in Shiny

## Overview

The **PUB Sector R Workshop 2024** is designed to facilitate a 1-day workshop, focusing on working with your organization’s data from data collection to data management to data visualization. Participants will learn how to build a dashboard with Shiny, including dynamic calendars perfect for large-scale event tracking. Additionally, the workshop covers building a CRUD (create, read, update, delete) application that allows users to manage data themselves. We will also discuss concepts such as multi-tiered architectures, modularizing code, clear data visualizations, and managing user permissions in Shiny apps.

## Repository Structure

This repository contains the main application along with supporting folders and two tutorial apps:

- **Main Application:** `app.R` [app.R](https://github.com/maxinedrake/R_workshop/blob/main/app.R)
- **Tutorial Apps:**
  - `app_modules.R` located in the `understanding_modules` folder [app_modules.R](https://github.com/maxinedrake/R_workshop/blob/main/understanding_modules/app_modules.R)
  - `app_reactive.R` located in the `understanding_reactives` folder

## Folder Structure
- `02_source`: Contains utility, CRUD modules, calendar modules, and dashboard modules.
- `understanding_modules`: Contains tutorial app demonstrating module usage.
- `understanding_reactives`: Contains tutorial app demonstrating reactive programming in Shiny.

## Installation

To run the Shiny application locally:

1. Clone the repository:
    ```
2. Ensure you have R and RStudio installed.
3. Install the required packages:
   ```R
   install.packages(c("shiny", "shinydashboard", "here", "tictoc"))
   ```
   shiny::runApp("app.R")
     ```
