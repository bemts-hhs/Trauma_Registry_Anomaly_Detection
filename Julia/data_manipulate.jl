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
end;

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
end;

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
	@mutate(
		mean_records = mean.(c(`2020`, `2021`, `2022`, `2023`, `2024`, `2025`)),
		var_records = var.(c(`2020`, `2021`, `2022`, `2023`, `2024`, `2025`)),
		sd_records = std.(c(`2020`, `2021`, `2022`, `2023`, `2024`, `2025`)),
		mean_diff = mean.(c(diff_2021, diff_2022, diff_2023, diff_2024, diff_2025)),
		var_diff = var.(c(diff_2021, diff_2022, diff_2023, diff_2024, diff_2025)),
		sd_diff = std.(c(diff_2021, diff_2022, diff_2023, diff_2024, diff_2025))
	)
	@mutate(
		pct_2021 = (diff_2021) / `2020`,
		pct_2022 = (diff_2022) / `2021`,
		pct_2023 = (diff_2023) / `2022`,
		pct_2024 = (diff_2024) / `2023`,
		pct_2025 = (diff_2025) / `2024`
	)
	@mutate(
		z_score_diff_2021 = (diff_2021 - mean_diff) / sd_diff,
		z_score_diff_2022 = (diff_2022 - mean_diff) / sd_diff,
		z_score_diff_2023 = (diff_2023 - mean_diff) / sd_diff,
		z_score_diff_2024 = (diff_2024 - mean_diff) / sd_diff,
		z_score_diff_2025 = (diff_2025 - mean_diff) / sd_diff
	)
	@mutate(
		z_anomaly_2021 = abs(z_score_diff_2021) >= 1.5,
		z_anomaly_2022 = abs(z_score_diff_2022) >= 1.5,
		z_anomaly_2023 = abs(z_score_diff_2023) >= 1.5,
		z_anomaly_2024 = abs(z_score_diff_2024) >= 1.5,
		z_anomaly_2025 = abs(z_score_diff_2025) >= 1.5,
		pct_anomaly_2021 = abs(pct_2021) >= 0.5,
		pct_anomaly_2022 = abs(pct_2022) >= 0.5,
		pct_anomaly_2023 = abs(pct_2023) >= 0.5,
		pct_anomaly_2024 = abs(pct_2024) >= 0.5,
		pct_anomaly_2025 = abs(pct_2025) >= 0.5
	)
	@mutate(
		any_z_anomaly = any(c(
			z_anomaly_2021,
			z_anomaly_2022,
			z_anomaly_2023,
			z_anomaly_2024,
			z_anomaly_2025,
		)),
		any_pct_anomaly = any(c(
			pct_anomaly_2021,
			pct_anomaly_2022,
			pct_anomaly_2023,
			pct_anomaly_2024,
			pct_anomaly_2025,
		)))
	@mutate(
		date_data = Date(Dates.now())
	)
end;

# Before additional data manipulation and modeling, plot differences
diff_long =
	@chain trauma_registry_counts_2020_2025_final begin
		@select(facility, contains(r"^(diff|pct)_\d{4}$"))
		@pivot_longer(
			contains(r"^(diff|pct)_\d{4}$"),
			names_to = :year,
			values_to = :diff
		)
		@mutate(
			measure = year,
			year = replace.(year, r"pct_|diff_" => ""),
			sign = ifelse(diff .< 0, "negative",
				ifelse(diff .> 0, "positive", "neutral"),
			))
	end;

# plot the distribution of differences
diff_distribution_plot = ggplot(
							 subset(diff_long, :measure => m -> occursin.("diff", m)),
						 ) +
						 geom_density(@aes(x = diff, fill = year)) +
						 facet_wrap(:year, scales = "free") +
						 theme_minimal();

draw_ggplot(diff_distribution_plot, (1000, 800));

# plot the distribution of the percent differences
pct_diff_distribution_plot = ggplot(
								 subset(diff_long, :measure => m -> occursin.("pct", m),
									 :diff => d -> isfinite.(d),
								 ),
							 ) +
							 geom_density(@aes(x = diff, fill = year)) +
							 facet_wrap(:year, scales = "free") +
							 theme_minimal();

draw_ggplot(pct_diff_distribution_plot, (1000, 800));

# Plots
# Get unique facility list
facilities = unique(diff_long.facility);

# For loop to make plots for each facility to examine 
# the distribution of their reporting differences over the
# years
for f in facilities

	# subset current facility
	df_f = subset(diff_long, :facility => x -> x .== f, :measure => m -> occursin.("diff", m))

	# build raincloud plots
	p_rain =
		ggplot(df_f, aes(x = :facility, y = :diff)) +
		geom_rainclouds(
			plot_boxplots = true,
			show_boxplot_outliers = true,
			show_median = true,
			fill = :cyan,
			size = 10,
			stroke = 0,
		) +
		labs(
			title = "Distribution of $f Reporting Differences 2021-2025",
			x = "",
			y = "Difference",
		) +
		theme_minimal()

	# save each raincloud plot
	ggsave(p_rain, "plots/boxplots/diff_boxplot_$(f).png")

end;

# move on to a loop for the column plots
for f in facilities

	# subset current facility
	df_f = subset(diff_long, :facility => x -> x .== f, :measure => m -> occursin.("diff", m))

	# create column plots
	p_col =
		ggplot(df_f) +
		geom_hline(yintercept = 0, color = :darkgray, linestyle = :solid) +
		geom_col(aes(x = :year, y = :diff), strokewidth = 1, fill = :cyan) +
		labs(
			title = "$f Reporting Differences 2021-2025",
			x = "",
			y = "Difference",
		) +
		theme_minimal()

	# save each plot
	ggsave(p_col, "plots/columnplots/diff_columnplot_$(f).png")
end;

# plot all differences over the years to assess the distribution
plot_all_diffs =
	ggplot(diff_long, aes(x = :year, y = :diff)) +
	geom_rainclouds(
		plot_boxplots = true,
		show_boxplot_outliers = true,
		show_median = true,
		color = :blue,
		fill = :coral,
		size = 5,
		stroke = 0,
	) +
	labs(
		title = "Distribution of Reporting Differences Across Facilities",
		x = "",
		y = "Difference",
	) +
	theme_minimal();

# save plot
ggsave(plot_all_diffs, "plots/diffplots_all/diffplots_all.png"; width = 1200, height = 700);

# subset the table with columns we want to see and fit
anomaly_table = @chain trauma_registry_counts_2020_2025_final begin
	@filter .!isnan.(pct_2025) & .!ismissing.(pct_2025) & isfinite.(pct_2025) & (pct_anomaly_2025 | z_anomaly_2025 == true)
	@select :facility, `2024`, `2025`, :diff_2025, :mean_records, :mean_diff, contains("2025"), :date_data
	@arrange facility
end;

# export anomaly_table to XLSX
XLSX.writetable("./output/anomaly_table.xlsx", Tables.columntable(anomaly_table); sheetname = "anomalies")
