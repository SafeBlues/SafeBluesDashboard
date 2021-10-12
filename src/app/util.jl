function phase_options(data::SafeBluesData)
    batches = unique(data.parameters[:, :batch])
    matches = Iterators.filter(!isnothing, match.(r"^(\d+).\d+$", batches))
    phases = unique(Iterators.map(match -> match.captures[begin], matches))

    return [Dict("label" => "Phase $phase", "value" => parse(Int, phase)) for phase in phases]
end

function model_options(data::SafeBluesData)
    models = unique(data.parameters[:, :model])
    return [Dict("label" => model, "value" => Symbol(model)) for model in models]
end
