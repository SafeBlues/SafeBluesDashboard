const Maybe{T} = Union{T, Missing}


struct SafeBluesData
    batches::DataFrame
    parameters::DataFrame
    strands::Vector{DataFrame}
    participants::DataFrame
end


function _load_batches(path::String)::DataFrame
    return CSV.File(path; types=[
        Maybe{Int64},     # phase
        String,           # batch
        Maybe{DateTime},  # start_utc
        Maybe{DateTime},  # seed_utc
        Maybe{DateTime},  # stop_utc
        Maybe{DateTime},  # start_nzt
        Maybe{DateTime},  # seed_nzt
        Maybe{DateTime},  # stop_nzt
    ]) |> DataFrame
end


function _load_parameters(path::String)::DataFrame
    return CSV.File(path; types=[
            Int64,           # strand_id
            String,          # batch
            String,          # model
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


function load_sbdata(dir::String, daily::Bool)::SafeBluesData
    batches::DataFrame = _load_batches(joinpath(dir, "data", "batches.csv"))
    parameters::DataFrame = _load_parameters(joinpath(dir, "data", "strands.csv"))

    type = daily ? "daily" : "hourly"
    strands::Vector{DataFrame} = [
        _load_strand(joinpath(dir, "data", type, "strands", "strand$(row.strand_id).csv"))
        for row in eachrow(parameters)
    ]
    participants::DataFrame = _load_participants(joinpath(dir, "data", type, "participants.csv"))

    return SafeBluesData(
        batches,
        parameters,
        strands,
        participants
    )
end
