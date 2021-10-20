const BLUE = "#3498DB"
const ORANGE = "#F39C12"
const RED = "#E74C3C"
const GREEN = "#18BC9C"

const OPACITY = 0.25


function ensemble_plot(strand_ids::Vector{T}) where T <: Integer
    traces = GenericTrace[]
    for strand_id in strand_ids
        push!(traces, scatter(;
            x=data.strands.hourly[strand_id][:, :time_nzt],
            y=data.strands.hourly[strand_id][:, :infected],
            line_color=RED,
            name="Strand $(strand_id)",
            opacity=OPACITY,
            showlegend=false
        ))
    end

    layout = Layout(;
        title="Strand Caseloads",
        xaxis_title="Time (NZST/NZDT)",
        yaxis_title="Infected Participants"
    )

    return plot(traces, layout)
end

function trajectory_plot(strand_id::Integer)
    model = data.parameters[strand_id, :model]

    times = data.strands.hourly[strand_id][:, :time_nzt]
    traces = GenericTrace[]

    # Susceptible Trace
    susceptible = data.strands.hourly[strand_id][:, :susceptible]
    push!(traces, scatter(;x=times, y=susceptible, line_color=BLUE, name="Susceptible"))

    if model == "SEI" || model == "SEIR"
        exposed = data.strands.hourly[strand_id][:, :exposed]
        push!(traces, scatter(;x=times, y=exposed, line_color=ORANGE, name="Exposed"))
    end

    # Infected Trace
    infected = data.strands.hourly[strand_id][:, :infected]
    push!(traces, scatter(;x=times, y=infected, line_color=RED, name="Infected"))

    # Recovered Trace
    if model == "SIR" || model == "SEIR"
        recovered = data.strands.hourly[strand_id][:, :recovered]
        push!(traces, scatter(;x=times, y=recovered, line_color=GREEN, name="Recovered"))
    end

    layout = Layout(;
        title="Strand $(strand_id) Trajectory",
        xaxis_title="Time (NZST/NZDT)",
        yaxis_title="Participants"
    )

    return plot(traces, layout)
end
