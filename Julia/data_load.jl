###_____________________________________________________________________________
# Load data for the anomaly detection project using environment variables
###_____________________________________________________________________________

# Simple validation for missing paths
required_paths = [
    ("2020", iowa_trauma_registry_counts_path_2020),
    ("2021", iowa_trauma_registry_counts_path_2021),
    ("2022", iowa_trauma_registry_counts_path_2022),
    ("2023", iowa_trauma_registry_counts_path_2023),
    ("2024", iowa_trauma_registry_counts_path_2024),
    ("2025", iowa_trauma_registry_counts_path_2025),
    ("2026", iowa_trauma_registry_counts_path_2026)
];

for (yr, p) in required_paths
    if isempty(p)
        @warn "Path for $yr is empty. Update .env before attempting to load data."
    end
end;

# Load all project data for anomaly detection via environment variable paths
 trauma_registry_counts_2020 = CSV.read(iowa_trauma_registry_counts_path_2020, DataFrame);
 trauma_registry_counts_2021 = CSV.read(iowa_trauma_registry_counts_path_2021, DataFrame);
 trauma_registry_counts_2022 = CSV.read(iowa_trauma_registry_counts_path_2022, DataFrame);
 trauma_registry_counts_2023 = CSV.read(iowa_trauma_registry_counts_path_2023, DataFrame);
 trauma_registry_counts_2024 = CSV.read(iowa_trauma_registry_counts_path_2024, DataFrame);
 trauma_registry_counts_2025 = CSV.read(iowa_trauma_registry_counts_path_2025, DataFrame);

 # Use @glimpse() macro to examine each dataframe.
 