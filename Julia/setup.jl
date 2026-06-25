###_____________________________________________________________________________
# Setup for the anomaly detection project to leverage Tidier and DotEnv
# Setup for the environment variables to be used to secure filepaths
###_____________________________________________________________________________

using Pkg

# Ensure required packages are available
Pkg.activate(".");
Pkg.instantiate();

# only need to install packages the first time
# Pkg.add(["Tidier", "TidierPlots", "TidierDates", "Dates", "DotEnv", "CSV", "XLSX", "DataFrames", "Quarto"]);

# Load packages
using Tidier
using TidierDates
using Dates
using TidierPlots
using DotEnv
using CSV
using XLSX
using DataFrames
using Quarto
using PrettyTables

# Create .env file if it does not exist
if !isfile(".env")
    write(".env", """
IOWA_TRAUMA_REGISTRY_COUNT_PATH=
""")
end;

# Load .env file into ENV[]
DotEnv.load!();

# Assign environment variables (no paths yet)
iowa_trauma_registry_counts_path = ENV["IOWA_TRAUMA_REGISTRY_COUNTS_PATH"];
