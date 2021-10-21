app = dash(external_stylesheets=[dbc_themes.FLATLY])


# ---------------------------------------------------------------------------------------- #
# Utility Functions                                                                        #
# ---------------------------------------------------------------------------------------- #

function phase_options()
    phases = unique(data.batches[:, :phase])
    return [
        Dict("label" => "Phase $phase", "value" => phase)
        for phase in phases if phase != 0 && phase !== missing
    ]
end

function batch_options(phase::Int)
    format = "dd/mm/yy"
    return [Dict(
        "label" => "$(row.batch) ($(Dates.format(row.start_nzt, format)) - $(Dates.format(row.stop_nzt, format)))",
        "value" => row.batch
    ) for row in eachrow(data.batches) if row.phase == phase]
end

function model_options(batch::String)
    parameters = filter(row -> row.batch == batch, data.parameters)

    enabled(model::String) = any(row.model == model for row in eachrow(parameters))
    return [
        Dict("label" => model, "value" => model, "disabled" => !enabled(model))
        for model in ("SEIR", "SIR", "SEI", "SI")
    ]
end


# ---------------------------------------------------------------------------------------- #
# Layout                                                                                   #
# ---------------------------------------------------------------------------------------- #

control_card = dbc_card(body=true) do
    dbc_form() do
        dbc_formgroup(row=true) do
            dbc_label("Phase"; html_for="phase-radio", width=2),
            dbc_col(dbc_radioitems(;id="phase-radio", inline=true); width=10)
        end,

        dbc_formgroup(row=true) do
            dbc_label("Batch"; html_for="batch-dropdown", width=2),
            dbc_col(dcc_dropdown(;id="batch-dropdown"); width=10)
        end,

        dbc_formgroup(row=true) do
            dbc_label("Model"; html_for="model-radio", width=2),
            dbc_col(dbc_radioitems(;id="model-radio", inline=true); width=10)
        end,

        dbc_formtext(;className="text-right", id="strand-count")
    end
end

ensemble_graph_card = dbc_card(;body=true) do
    dcc_graph(;id="ensemble-graph")
end

trajectory_graph_card = dbc_card(;body=true) do
    dcc_graph(;id="trajectory-graph")
end

participants_graph_card = dbc_card(;body=true) do
    dcc_graph(;id="participants-graph")
end

app.layout = html_div() do
    dbc_row() do
        dbc_col(control_card; width=4),
        dbc_col(ensemble_graph_card; width=8)
    end,

    dbc_row() do
        dbc_col(participants_graph_card; width=6),
        dbc_col(trajectory_graph_card; width=6)
    end,

    html_div(;id="init"),
    dcc_store(;id="ensemble-store", data=Int[])
end


# ---------------------------------------------------------------------------------------- #
# Callbacks                                                                                #
# ---------------------------------------------------------------------------------------- #

callback!(
    app,
    Output("phase-radio", "options"), Output("phase-radio", "value"),
    Input("init", "id")
) do _
    options = phase_options()
    default = isempty(options) ? nothing : first(options)["value"]
    return options, default
end

callback!(
    app,
    Output("participants-graph", "figure"),
    Input("init", "id")
) do _
    return participants_plot()
end

callback!(
    app,
    Output("batch-dropdown", "options"), Output("batch-dropdown", "value"),
    Input("phase-radio", "value")
) do phase
    options = batch_options(phase)
    default = isempty(options) ? nothing : first(options)["value"]
    return options, default
end

callback!(
    app,
    Output("model-radio", "options"), Output("model-radio", "value"),
    Input("batch-dropdown", "value"),
    State("model-radio", "value")
) do batch, previous
    options = model_options(batch)
    selectable = filter(option -> !option["disabled"], options)

    if isempty(selectable)
        default = nothing
    elseif previous in get.(selectable, "value", nothing)
        default = previous
    else
        default = first(selectable)["value"]
    end

    return options, default
end

callback!(
    app,
    Output("ensemble-store", "data"), Output("strand-count", "children"),
    Output("strand-count", "color"),
    Input("model-radio", "value"), Input("batch-dropdown", "value"),
    State("ensemble-store", "data")
) do model, batch, previous
    use(row) = row.model == model && row.batch == batch
    strand_ids = Int[row.strand_id for row in eachrow(data.parameters) if use(row)]

    response = "Strands Selected: $(length(strand_ids))"
    color = length(strand_ids) != 0 ? "info" : "warning"
    strand_ids = length(strand_ids) != 0 ? strand_ids : previous

    return strand_ids, response, color
end

callback!(
    app,
    Output("ensemble-graph", "figure"),
    Input("ensemble-store", "data")
) do strand_ids
    return ensemble_plot(Vector{Int}(strand_ids))
end

callback!(
    app,
    Output("trajectory-graph", "figure"),
    Input("ensemble-graph", "hoverData"), Input("ensemble-store", "data")
) do hover_data, strand_ids
    if isnothing(hover_data)
        strand_id = rand(strand_ids)

    else
        point, = hover_data.points
        strand_id = strand_ids[mod1(point.curveNumber + 1, length(strand_ids))]
    end

    return trajectory_plot(strand_id)
end
