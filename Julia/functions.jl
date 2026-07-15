###_____________________________________________________________________________
# Custom helper functions
###_____________________________________________________________________________

# -------------------------------------------------------------------------
# nb_pois_pred_interval
#
# Computes a two‑tailed prediction interval for annual registry counts by
# selecting either a Negative Binomial distribution (for overdispersed data)
# or a Poisson distribution (for equidispersed or mildly underdispersed
# data). The model selection is driven entirely by the empirical mean and
# variance of the supplied counts vector.
#
# Arguments
# ----------
# counts_raw
#     Inbound object containing registry counts. TidierData.jl may supply
#     this as many different structures, including:
#         • Vector{<:Real}           – standard rowwise vector
#         • NamedTuple               – from across(), one value per year
#         • Number                   – degenerate scalar case
#         • Vector{Vector{<:Real}}   – entire column of rowwise vectors
#
# upper_prob :: Real
#     Upper cumulative probability for the prediction interval. The lower
#     bound is computed as (1 - upper_prob). Example: 0.9332 for the
#     1.5‑sigma equivalent.
#
# Returns
# ----------
# (lower, upper) :: Tuple{Float64,Float64} OR Vector of such tuples
#     Returns lower and upper prediction interval bounds. If counts_raw is
#     a column‑level Vector{Vector}, the function returns a vector of row‑
#     level interval tuples.
#
# Interval Logic
# ----------
# Negative Binomial parameters follow the NB2 mean‑variance inversion:
#     r = mu^2 / (var - mu)
#     p = mu / var
#
# If var <= mu, NB is non‑identifiable; Poisson(mu) is used instead.
#
# Integration Notes
# ----------
# For TidierData.jl, generate per‑row vectors of year counts using:
#
#     counts_vec = c(`2020`, `2021`, ..., `2026`)
#
# Then call:
#
#     pred_interval = Main.nb_pois_pred_interval(counts_vec, 0.9332)
#
# -------------------------------------------------------------------------

function nb_pois_pred_interval(counts_raw, upper_prob::Real)

    # ------------------------------------------------------------------
    # Coerce ANY inbound structure into a usable Vector{Float64} or,
    # in the column‑level case, produce a vector of interval tuples.
    #
    # The ternary structure below is explicit. Each condition converts
    # counts_raw into a consistent representation for interval logic.
    # ------------------------------------------------------------------

    counts =
        # Case 1: Standard rowwise vector of numeric values
        counts_raw isa AbstractVector{<:Real} ?
            Float64.(counts_raw) :

        # Case 2: NamedTuple from across(), e.g. (2020 = 123, ...)
        counts_raw isa NamedTuple ?
            Float64.(collect(values(counts_raw))) :

        # Case 3: Degenerate scalar case, wrap into a 1‑element vector
        counts_raw isa Number ?
            [Float64(counts_raw)] :

        # Case 4: Full column supplied as Vector{Vector}. Apply the
        # interval logic rowwise and return a vector of interval tuples.
        counts_raw isa AbstractVector{<:AbstractVector} ?
            [begin
                # Extract row vector and coerce its elements
                row = Float64.(counts_raw[i])

                # Compute summary statistics for this row
                mu = mean(row)
                var_row = Statistics.var(row)
                lower_prob = 1 - upper_prob

                # Select distribution based on dispersion pattern
                dist =
                    var_row > mu ?
                        Distributions.NegativeBinomial(
                            (mu^2) / (var_row - mu),
                            mu / var_row
                        ) :
                        Distributions.Poisson(mu)

                # Return rowwise interval tuple
                (
                    Statistics.quantile(dist, lower_prob),
                    Statistics.quantile(dist, upper_prob)
                )
            end for i in eachindex(counts_raw)] :

        # Case 5: Unsupported inbound type
        error("Unsupported counts structure: $(typeof(counts_raw))")

    # ------------------------------------------------------------------
    # At this point, counts is guaranteed to be Vector{Float64}. Compute
    # interval normally for the row‑level case (not the column‑level case,
    # which already returned inside the mapping block).
    # ------------------------------------------------------------------

    mu = Statistics.mean(counts)
    var_counts = Statistics.var(counts)
    lower_prob = 1 - upper_prob

    # Check dispersion pattern to select distribution
    if var_counts > mu

        # Compute NB parameters for overdispersed counts
        r = (mu^2) / (var_counts - mu)
        p = mu / var_counts
        dist = Distributions.NegativeBinomial(r, p)

    else

        # Use Poisson for equidispersed or underdispersed counts
        dist = Distributions.Poisson(mu)
    end

    # Return prediction interval tuple
    lower = Statistics.quantile(dist, lower_prob)
    upper = Statistics.quantile(dist, upper_prob)

    return lower, upper
end