app = dash(external_stylesheets=[dbc_themes.FLATLY])


# ---------------------------------------------------------------------------------------- #
# Utility Functions                                                                        #
# ---------------------------------------------------------------------------------------- #

function phase_options()
    batches = unique(data.parameters[:, :batch])
    matches = Iterators.filter(!isnothing, match.(r"^(\d+).\d+$", batches))
    phases = unique(Iterators.map(match -> match.captures[begin], matches))

    return [Dict("label" => "Phase $phase", "value" => parse(Int, phase)) for phase in phases]
end

function batch_options(phase::Int)
    batches = unique(data.parameters[:, :batch])
    regex = Regex("^$(phase).\\d+\$")
    batches = Iterators.filter(batch -> occursin(regex, batch), batches)

    return [Dict("label" => batch, "value" => batch) for batch in batches]
end

function model_options()
    models = unique(data.parameters[:, :model])
    return [Dict("label" => model, "value" => model) for model in models]
end


# ---------------------------------------------------------------------------------------- #
# Layout                                                                                   #
# ---------------------------------------------------------------------------------------- #

control_card = dbc_card(body=true) do
    dbc_formgroup(row=true) do
        dbc_label("Model", html_for="model-radio", width=2),
        dbc_col(
            dbc_radioitems(id="model-radio", inline=true, options=model_options()),
            width=10
        )
    end,

    dbc_form() do
        dbc_formgroup(row=true) do
            dbc_label("Phase", html_for="phase-radio", width=2),
            dbc_col(
                dbc_radioitems(id="phase-radio", inline=true, options=phase_options()),
                width=10
            )
        end,

        dbc_formgroup(row=true) do
            dbc_label("Batch", html_for="batch-dropdown", width=2),
            dbc_col(dcc_dropdown(id="batch-dropdown"), width=10)
        end
    end
end

graph_card = dbc_card(body=true) do
    dcc_graph(id="ensemble-graph")
end

app.layout = html_div() do
    dbc_row() do
        dbc_col(control_card, width=4),
        dbc_col(graph_card, width=8)
    end
end


# ---------------------------------------------------------------------------------------- #
# Callbacks                                                                                   #
# ---------------------------------------------------------------------------------------- #

callback!(app, Output("batch-dropdown", "options"), Input("phase-radio", "value")) do phase
    return batch_options(phase)
end

callback!(
    app,
    Output("ensemble-graph", "figure"),
    Input("model-radio", "value"), Input("batch-dropdown", "value")
) do model, batch
    return ensemble_plot(row -> row.model == model && row.batch == batch)
end
