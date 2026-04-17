# Trauma Registry Anomaly Detection

A Julia-based framework for data quality surveillance in statewide trauma registry reporting.

## Overview

This project implements a reproducible analytic workflow for detecting anomalous reporting patterns in facility-level submissions to the Iowa Trauma Registry (2020–2025). The objective is to identify irregular year‑over‑year fluctuations that may indicate data quality issues, reporting gaps, or operational changes that warrant follow‑up with facilities.

The system is designed for epidemiologists, statisticians, and data scientists who require transparent, statistically rigorous methods for longitudinal surveillance of registry data.

## Key Features

- Full data union across years (2020–2025) with schema‑aligned variable selection.
- Automated data reshaping using wide‑format pivoting for facility‑year reporting matrices.
- Derivation of absolute and percent year‑over‑year differences for all facilities.
- Facility‑level summary metrics including mean, variance, standard deviation of counts and differences.
- Z‑score‑based anomaly detection, identifying facilities with $≥2 SD$ deviations from their mean difference pattern.
- Percent‑change anomaly detection, flagging extreme shifts (\|percent change\| ≥ 100%).
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

$abs(z) ≥ 2$

$abs(percent\_diff) ≥ 1$

### Summary indicators aggregating anomalies across years

These metrics support structured data quality review and epidemiologic interpretation.

## Visual Analytics

Plots are generated for statewide distributions and individual facilities. The workflow includes:

- Density estimation of absolute and percent differences
- Raincloud plots to evaluate within‑facility variability
- Column plots to inspect magnitude and direction of differences
- An aggregated raincloud visualization across all facilities

All visuals are stored in organized output directories (plots/boxplots/, plots/columnplots/, etc.).

## Technologies and Dependencies

This project uses a modern Julia workflow for data ingestion, transformation, statistical computation, and reproducible reporting. Key packages include:

### Core Data Manipulation and Transformation

- Tidier.jl – Tidy‑syntax data transformation pipelines
- TidierDates.jl – Date parsing, extraction, and manipulation
- DataFrames.jl – Tabular data structures and joins
- CSV.jl – High‑performance delimited‑file I/O

### Visualization

- TidierPlots.jl – Grammar‑of‑graphics plotting using a tidy interface

### Statistical Computation

- Dates.jl – Built‑in date and time types for interval calculations
- Statistics (Base) – Means, variances, standard deviations, and related metrics

### Environment and Configuration Management

DotEnv.jl – Secure management of registry filepaths via environment variables

### Reporting

- Quarto.jl – Reproducible document rendering
- PrettyTables.jl – High‑quality table display for summaries and outputs

### Julia Package Environment

- Pkg – Environment activation, dependency resolution, and reproducibility

## Purpose and Intended Use

This workflow supports statewide trauma system performance monitoring and routine quality assurance. It is suitable for:

- Registry program managers
- Injury/EMS epidemiologists
- Health services researchers
- Data scientists evaluating longitudinal health data quality