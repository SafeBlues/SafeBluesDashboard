control_card(data::SafeBluesData) = dbc_card(body=true) do
    dbc_formgroup(row=true) do
        dbc_label("Model", html_for="model-radio", width=2),
        dbc_col(
            dbc_radioitems(id="model-radio", inline=true, options=model_options(data)),
            width=10
        )
    end,

    dbc_form() do
        dbc_formgroup(row=true) do
            dbc_label("Phase", html_for="phase-radio", width=2),
            dbc_col(
                dbc_radioitems(id="phase-radio", inline=true, options=phase_options(data)),
                width=10
            )
        end,

        dbc_formgroup(row=true) do
            dbc_label("Batch", html_for="batch-dropdown", width=2),
            dbc_col(dcc_dropdown(id="batch-dropdown"), width=10)
        end
    end
end


graph_card() = dbc_card(body=true) do
    dcc_graph()
end


layout(data::SafeBluesData) = html_div() do
    dbc_row() do
        dbc_col(control_card(data), width=4),
        dbc_col(graph_card(), width=8)
    end
end
