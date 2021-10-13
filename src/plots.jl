const BLUE = "#3498DB"
const ORANGE = "#F39C12"
const RED = "#E74C3C"
const GREEN = "#18BC9C"

const OPACITY = 0.25


function ensemble_plot(selector)
    traces = GenericTrace[]
    for row in Iterators.filter(selector, eachrow(data.parameters))
        push!(traces, scatter(;
            x=data.strands.hourly[row.strand_id][:, :time_nzt],
            y=data.strands.hourly[row.strand_id][:, :infected],
            line_color=RED,
            name="Strand $(row.strand_id)",
            opacity=OPACITY,
            showlegend=false
        ))
    end

    layout = Layout(
        title="Strand Trajectories",
        xaxis_title="Time (NZST/NZDT)",
        yaxis_title="Infected Participants"
    )

    return plot(traces, layout)
end
