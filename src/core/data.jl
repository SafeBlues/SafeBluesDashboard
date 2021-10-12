const Maybe{T} = Union{T, Missing}


struct SafeBluesData
    parameters::DataFrame
    strands::NamedTuple{(:hourly, :daily), Tuple{Vector{DataFrame}, Vector{DataFrame}}}
    participants::NamedTuple{(:hourly, :daily), Tuple{DataFrame, DataFrame}}
end


function _load_parameters(path::String)::DataFrame
    return CSV.File(path; types=[
            Int64,           # strand_id
            String,          # batch
            Symbol,          # model
            DateTime,        # start_utc
            DateTime,        # seed_utc
            DateTime,        # stop_utc
            DateTime,        # start_nzt
            DateTime,        # seed_nzt
            DateTime,        # stop_nzt
            Float64,         # initial
            Float64,         # strength
            Float64,         # radius
            Maybe{Float64},  # incubation_mean
            Maybe{Float64},  # incubation_shape
            Maybe{Float64},  # infection_mean
            Maybe{Float64},  # infection_shape
    ]) |> DataFrame
end


function _load_strand(path::String)::DataFrame
    return CSV.File(path; types=[
        Int64,         # strand_id
        DateTime,      # time_nzt
        DateTime,      # time_utc
        Int64,         # susceptible
        Maybe{Int64},  # exposed
        Int64,         # infected
        Maybe{Int64},  # recovered
        Float64,       # distance_factor
    ]) |> DataFrame
end


function _load_participants(path::String)::DataFrame
    return CSV.File(path; types=[
        DateTime,        # time_utc
        DateTime,        # time_nzt
        Int64,           # count_campus
        Int64,           # count_reporting
        Int64,           # count_registered
        Maybe{Float64},  # hours_mean
        Maybe{Float64},  # hours_min
        Maybe{Float64},  # hours_q1
        Maybe{Float64},  # hours_q2
        Maybe{Float64},  # hours_q3
        Maybe{Float64},  # hours_max
    ]) |> DataFrame
end


function load_sbdata(dir::String)::SafeBluesData
    parameters::DataFrame = _load_parameters(joinpath(dir, "data", "strands.csv"))

    strands_hourly::Vector{DataFrame} = [
        _load_strand(joinpath(dir, "data", "hourly", "strands", "strand$(r.strand_id).csv"))
        for r in eachrow(parameters)
    ]
    strands_daily::Vector{DataFrame} = [
        _load_strand(joinpath(dir, "data", "daily", "strands", "strand$(r.strand_id).csv"))
        for r in eachrow(parameters)
    ]

    participants_hourly::DataFrame = _load_participants(joinpath(dir, "data", "hourly", "participants.csv"))
    participants_daily::DataFrame = _load_participants(joinpath(dir, "data", "daily", "participants.csv"))

    return SafeBluesData(
        parameters,
        (hourly=strands_hourly, daily=strands_daily),
        (hourly=participants_hourly, daily=participants_daily)
    )
end
