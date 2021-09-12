struct SafeBluesData
    parameters::DataFrame
    strands::Vector{DataFrame}
    participants::DataFrame
end


function SafeBluesData(dir::String)
    parameters = CSV.File(
        joinpath(dir, "data", "strands.csv");
        types = [
            Int, Float64, Symbol, DateTime, DateTime, DateTime, DateTime, DateTime,
            DateTime, Float64, Float64, Float64, Union{Float64, Missing},
            Union{Float64, Missing}, Union{Float64, Missing}, Union{Float64, Missing}
        ]
    ) |> DataFrame

    strands = [CSV.File(
        joinpath(dir, "data", "hourly", "strands", "strand$(row.strand_id).csv");
        types = [
            Int, DateTime, DateTime, Int, Union{Int, Missing}, Int, Union{Int, Missing},
            Float64
        ]
    ) |> DataFrame for row in eachrow(parameters)]

    participants = CSV.File(
        joinpath(dir, "data", "hourly", "participants.csv");
        types = [
            DateTime, DateTime, Int, Int, Int, Union{Float64, Missing},
            Union{Float64, Missing}, Union{Float64, Missing}, Union{Float64, Missing},
            Union{Float64, Missing}, Union{Float64, Missing}
        ]
    ) |> DataFrame

    return SafeBluesData(parameters, strands, participants)
end