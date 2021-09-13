function strand_plot(data::SafeBluesData, strand_id::Integer)
    model = data.parameters[strand_id, :model]

    times = data.strands[strand_id][:, :time_nzt]
    traces = GenericTrace[]

    # Recovered Trace
    if model == :SIR || model == :SEIR
        recovered = data.strands[strand_id][:, :recovered]
        push!(traces, scatter(;x=times, y=recovered, name="Recovered"))
    end

    # Infected Trace
    infected = data.strands[strand_id][:, :infected]
    push!(traces, scatter(;x=times, y=infected, name="Infected"))

    # Exposed Trace
    if model == :SEI || model == :SEIR
        exposed = data.strands[strand_id][:, :exposed]
        push!(traces, scatter(;x=times, y=exposed, name="Exposed"))
    end

    # Susceptible Trace
    susceptible = data.strands[strand_id][:, :susceptible]
    push!(traces, scatter(;x=times, y=susceptible, name="Susceptible"))

    layout = Layout(;xaxis_title="Time (NZST/NZDT)", yaxis_title="Participants")
    return plot(traces, layout)
end