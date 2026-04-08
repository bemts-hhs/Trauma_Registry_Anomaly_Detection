###_____________________________________________________________________________
# Prepare data for modeling and analysis
###_____________________________________________________________________________

# union all rows from files and select the needed variables
trauma_registry_counts_2020_2025 = @chain trauma_registry_counts_2020 begin
    @bind_rows(
    trauma_registry_counts_2021, 
    trauma_registry_counts_2022, 
    trauma_registry_counts_2023, 
    trauma_registry_counts_2024, 
    trauma_registry_counts_2025
    )
    @select(year, facility, total)
end

# pivot columns wider
trauma_registry_counts_2020_2025_pivot = @chain trauma_registry_counts_2020_2025 begin 
    @pivot_wider(
        names_from = year, 
        values_from = total
    )
    @mutate(
        across(`2020`:`2025`, x -> coalesce.(x, 0))
    )
    @mutate(
        total_2020_2025 = `2020_function` + `2021_function` + `2022_function` + `2023_function` + `2024_function` + `2025_function`
    )
    @select(facility, `2020_function`:`2025_function`, total_2020_2025)
    @rename(
        `2020` = `2020_function`,
        `2021` = `2021_function`,
        `2022` = `2022_function`,
        `2023` = `2023_function`,
        `2024` = `2024_function`,
        `2025` = `2025_function`
    )
end

# finalize data by adding in differences between years 
trauma_registry_counts_2020_2025_final = @chain trauma_registry_counts_2020_2025_pivot begin
    @mutate(
        facility = replace.(facility, "\x96" => "–"),  # en dash,
        diff_2021 = `2021` - `2020`,
        diff_2022 = `2022` - `2021`,
        diff_2023 = `2023` - `2022`,
        diff_2024 = `2024` - `2023`,
        diff_2025 = `2025` - `2024`,
    )
    @relocate(diff_2021, after = `2021`)
    @relocate(diff_2022, after = `2022`)
    @relocate(diff_2023, after = `2023`)
    @relocate(diff_2024, after = `2024`)
    @relocate(diff_2025, after = `2025`)
    @mutate(
        mean_records = round(mean.(c(`2020`, `2021`, `2022`, `2023`, `2024`, `2025`)), digits = 3),
        var_records = round(var.(c(`2020`, `2021`, `2022`, `2023`, `2024`, `2025`)), digits = 3),
        sd_records = round(std.(c(`2020`, `2021`, `2022`, `2023`, `2024`, `2025`)), digits = 3),
        mean_diff = round(mean.(c(`diff_2021`, `diff_2022`, `diff_2023`, `diff_2024`, `diff_2025`)), digits = 3),
        var_diff = round(var.(c(`diff_2021`, `diff_2022`, `diff_2023`, `diff_2024`, `diff_2025`)), digits = 3),
        sd_diff = round(std.(c(`diff_2021`, `diff_2022`, `diff_2023`, `diff_2024`, `diff_2025`)), digits = 3),
        z_diff_2021 = diff_2021 / sd_diff
    )
end

# Before additional data manipulation and modeling, plot differences
diff_long =
@chain trauma_registry_counts_2020_2025_final begin
    @select(facility, diff_2021, diff_2022, diff_2023, diff_2024, diff_2025)
    @pivot_longer(
        diff_2021:diff_2025,
        names_to = :year,
        values_to = :diff
    )
    @mutate(year = replace.(year, "diff_" => ""))
end

# Plots
p_box =
    ggplot(diff_long) +
    geom_boxplot(aes(x = :facility, y = :diff)) +
    facet_wrap(:facility; ncol = 4) +
    labs(
        x = "Facility",
        y = "Differences",
        title = "Distribution of Year‑to‑Year Differences by Facility"
    ) +
    theme_ggplot2()

draw_ggplot(p_box)