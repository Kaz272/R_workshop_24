# PUB Sector R Workshop 2024: Dashboarding for Leaders and Managing Data in Shiny

## Overview

The **PUB Sector R Workshop 2024** is designed to facilitate a 1-day workshop, focusing on working with your organization’s data from data collection to data management to data visualization. Participants will learn how to build a dashboard with Shiny, including dynamic calendars perfect for large-scale event tracking. Additionally, the workshop covers building a CRUD (create, read, update, delete) application that allows users to manage data themselves. We will also discuss concepts such as multi-tiered architectures, modularizing code, clear data visualizations, and managing user permissions in Shiny apps.

## Repository Structure

This repository contains the main application along with supporting folders and tutorial apps:

- **Full WNBA Dashboard and CRUD App:**
  - `app.R`: Main application script.
  - `00_data_operations`: Handles data operations and transformations.
  - `01_data`: Contains raw and processed data files.
  - `02_source`: Contains utility, CRUD modules, calendar modules, and dashboard modules.
  - `www`: Static files like images, CSS, and JavaScript.

- **Class Presentation:**
  - `03_presentation`: Contains the class presentation materials.

- **Additional Tutorials:**
  - `04_tutorial_reactives`: Tutorials to assist with understanding reactive programming in Shiny.
  - `05_tutorial_modules`: Tutorials to assist with understanding module usage in Shiny.
  - `06_tutorial_other_styles`: Tutorials to assist with other styles and best practices in Shiny.

## Workshop Goals

By the end of this workshop, participants will leave with:

1. Functional Shiny application templates.
2. An understanding of 
   * Shiny reactivity
   * Functions & Modules in Shiny
   * Dashboard design principles
   * Multi-tiered architectures
   * CRUD apps in R and Shiny
3. A network of peers for collaboration.
4. Enhanced skills in R and Shiny.

-
## To Get the Most Out of This Workshop

1. **Latest version of R** (Version 4.3.1)  
   - [Download R (CRAN Mirror)](https://cran.r-project.org/mirrors.html)  

2. **Latest version of RStudio** (Version 2023.09.0+463)  
   - [Download RStudio (Official Website)](https://posit.co/download/rstudio-desktop/)  

3. **Git experience**  
   - Basic understanding of Git for managing your codebase. 
   - [Download Git (Official Website)](https://git-scm.com/downloads)

4. **Basic R Shiny knowledge**

5. **Knowledge of your organization’s needs**

## Installation

To run the Shiny application locally:

1. In Git Bash or your RStudio terminal, clone the repository:
    ```
    git clone https://github.com/maxinedrake/R_workshop.git
    ```
    
2. Ensure you have R and RStudio installed.

3. In R, Install the required packages:
 ```R
install.packages(
c("ggimage",
"rhandsontable",
"reactable",
"timevis",
"shiny",
"shinydashboard",
"tidyverse",
"here",
"shinyWidgets",
"DT",
"data.table")
)
```

4. Once you are in the R_workshop project, run the main WNBA app:
   ```R
   shiny::runApp("app.R")
   ```
