# Trauma Registry Anomaly Detection

A Julia-based framework for data quality surveillance in statewide trauma registry reporting.

## Overview

This project implements a reproducible analytic workflow for detecting anomalous reporting patterns in facility-level submissions to the Iowa Trauma Registry (2020–present). The objective is to identify irregular year‑over‑year fluctuations that may indicate data quality issues, reporting gaps, or operational changes that warrant follow‑up with facilities.

The system is designed for epidemiologists, statisticians, and data scientists who require transparent, statistically rigorous methods for longitudinal surveillance of registry data.

## Key Features

- Full data union across years (2020–present) with schema‑aligned variable selection.
- Automated data reshaping using wide‑format pivoting for facility‑year reporting matrices.
- Derivation of absolute and percent year‑over‑year differences for all facilities.
- Facility‑level summary metrics including mean, variance, standard deviation of counts and differences.
- Z‑score‑based anomaly detection, identifying facilities with $>=1.5 SD$ deviations from their mean difference pattern.
- Percent‑change anomaly detection, flagging extreme shifts (\|percent change\| >= 50%).
- Global anomaly indicators summarizing whether any z‑score or percent‑change outliers occur for each facility.

### Comprehensive visualization suite, including:

- Density plots of difference distributions across years
- Facility‑specific raincloud plots (distributional profiles)
- Facility‑specific column/bar plots of year‑to‑year differences
- An overall distributional assessment across all facilities

## Analytic Approach

Reporting differences are computed for each transition (2020→2021 through 2024→2025).

### For each facility:

#### Absolute difference:

$diff_year = records_{year} – records_{previous\_year}$

#### Percent difference:

$pct_{year} = \frac{diff_{year}}{records_{previous\_year}}$

#### Statistical standardization:

$z = \frac{(diff_{year} – mean_{diff})}{sd_{diff}}$

#### Binary anomaly flags based on thresholds:

$abs(z) >= 1.5$

$abs(percent\_diff) >= 0.5$

### Summary anomaly indicators across all reporting years

These outputs support structured data quality review, targeted follow‑up, and operational interpretation.

## Visual Analytics
The analysis produces statewide and agency‑level visualizations:

- Density estimation of absolute and percent differences
- Raincloud plots capturing within‑agency variability
- Column plots illustrating magnitude and direction of reporting shifts
- Aggregated statewide raincloud visualization

### Technologies and Dependencies

This project uses a modern Julia workflow for data ingestion, transformation, statistical analysis, and reproducible reporting.

#### Core Data Manipulation

- Tidier.jl – Tidy‑syntax transformation pipelines
- TidierDates.jl – Date parsing and manipulation
- DataFrames.jl – Tabular structures and joins
- CSV.jl – High‑performance delimited file I/O

### Visualization

- TidierPlots.jl – Grammar‑of‑graphics plotting in a tidy interface

### Statistical Computation

- Dates.jl – Handling of date and time fields
- Statistics – Core measures including mean, variance, and standard deviation

### Configuration and Environment Management

- DotEnv.jl – Secure handling of Iowa EMS registry filepaths through environment variables

### Reporting

- Quarto.jl – Fully reproducible reporting and documentation
- PrettyTables.jl – High‑quality summary tables

### Package Environment

- Pkg – Reproducible environment activation and dependency management

## Purpose and Intended Use

This workflow supports statewide trauma system performance monitoring and routine quality assurance. It is suitable for:

- Registry program managers
- Injury/EMS epidemiologists
- Health services researchers
- Data scientists evaluating longitudinal health data quality