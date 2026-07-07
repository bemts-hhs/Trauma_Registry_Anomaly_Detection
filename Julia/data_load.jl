###_____________________________________________________________________________
# Load data for the anomaly detection project using environment variables
###_____________________________________________________________________________

# Simple validation for missing paths
required_paths = iowa_trauma_registry_counts_path

	if isempty(required_paths)
		@warn "Path for $required_paths is empty. Update .env before attempting to load data."
    else 
        @info "Path for $required_paths is valid."
	end;

# Load all project data for anomaly detection via environment variable paths
trauma_registry_counts_file = DataFrames.DataFrame(
    XLSX.readtable(
        iowa_trauma_registry_counts_path, "Count-Of-Incidents-by-Facility-"
    )
);

# Use @glimpse() macro to examine each dataframe.
@glimpse(trauma_registry_counts_file)

# clean names
trauma_registry_counts = @chain trauma_registry_counts_file begin
    @rename_with col -> str_remove_all(col, r"\s*\(.+\)$")
    @clean_names()
    @mutate facility_id = ifelse(
        ismissing(facility_id), 9999, facility_id
    )
    @mutate across(`2020`:`2026`, x -> coalesce.(x, 0))
    @select -(`2020`:`2026`)
    @rename_with col -> str_remove_all(col, r"_function$")
    @relocate(starts_with("count_of_incidents"), after = `2026`)

end;