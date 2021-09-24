using Dates

using ArgParse
using CSV
using Dash
using DashHtmlComponents
using DashCoreComponents
using DataFrames
using HTTP
using PlotlyJS


include("data.jl")


function parse_command()
    settings = ArgParseSettings()
    @add_arg_table! settings begin
        "--host"
            action = :store_arg
            arg_type = String
            default = string(HTTP.Sockets.localhost)
            help = "an address at which to host the HTTP server"
        "--port"
            action = :store_arg
            arg_type = Int
            default = 8050
            help = "a port number on which to listen for HTTP traffic"
        "--debug", "-d"
            action = :store_true
            help = "enable dashboard development tools"
        "data"
            action = :store_arg
            arg_type = String
            help = "a directory containing the Safe Blues experiment data"
            required = true
    end

    return parse_args(settings; as_symbols=true)
end


function main()
    args = parse_command()
    data = SafeBluesData(args[:data])

    app = dash()
    app.layout = html_div()

    run_server(app, args[:host], args[:port]; debug=args[:debug])
end


main()
