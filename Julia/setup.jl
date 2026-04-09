``###_____________________________________________________________________________
# Setup for the anomaly detection project to leverage Tidier and DotEnv
# Setup for the environment variables to be used to secure filepaths
###_____________________________________________________________________________

using Pkg

# Ensure required packages are available
Pkg.activate(".")
Pkg.instantiate()
Pkg.add(["Tidier", "TidierPlots", "DotEnv", "CSV", "DataFrames"])

# Load packages
using Tidier
using TidierPlots
using DotEnv
using CSV
using DataFrames

# Create .env file if it does not exist
if !isfile(".env")
    write(".env", """
IOWA_TRAUMA_REGISTRY_COUNT_PATH_2020=
IOWA_TRAUMA_REGISTRY_COUNT_PATH_2021=
IOWA_TRAUMA_REGISTRY_COUNT_PATH_2022=
IOWA_TRAUMA_REGISTRY_COUNT_PATH_2023=
IOWA_TRAUMA_REGISTRY_COUNT_PATH_2024=
IOWA_TRAUMA_REGISTRY_COUNT_PATH_2025=
IOWA_TRAUMA_REGISTRY_COUNT_PATH_2026=
""")
end

# Load .env file into ENV[]
DotEnv.load!()

# Assign environment variables (no paths yet)
iowa_trauma_registry_counts_path_2020 = ENV["IOWA_TRAUMA_REGISTRY_COUNTS_PATH_2020"]
iowa_trauma_registry_counts_path_2021 = ENV["IOWA_TRAUMA_REGISTRY_COUNTS_PATH_2021"]
iowa_trauma_registry_counts_path_2022 = ENV["IOWA_TRAUMA_REGISTRY_COUNTS_PATH_2022"]
iowa_trauma_registry_counts_path_2023 = ENV["IOWA_TRAUMA_REGISTRY_COUNTS_PATH_2023"]
iowa_trauma_registry_counts_path_2024 = ENV["IOWA_TRAUMA_REGISTRY_COUNTS_PATH_2024"]
iowa_trauma_registry_counts_path_2025 = ENV["IOWA_TRAUMA_REGISTRY_COUNTS_PATH_2025"]
iowa_trauma_registry_counts_path_2026 = ENV["IOWA_TRAUMA_REGISTRY_COUNTS_PATH_2026"]