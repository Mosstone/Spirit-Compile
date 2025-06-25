#!/usr/bin/env julia






using Pkg

#   Data
using JSON

#   Visualization
using Graphs
using GLMakie
using GraphMakie
using Colors






#   define vectors          #################################################

struct shape
    src::Int
    dst::Int
    weight::Float64
end


function monolith(input::String, output::String)


    #<  Extract data from json input
    vectors = JSON.parsefile(input)["vectors"]
    headers = collect(keys(vectors))


    #<  Define the set
    node = length(headers)
    g = DiGraph(node)
    println("\n[94m    Number of items: ", node)

    index_map = Dict{String, Int}()
    for (point, name) in enumerate(headers)
        index_map[name] = point
    end

    #<  Vectorize data
    nn_mapping = Dict{Int, Vector{Tuple{Int, Float64}}}()

    function add_pair(headerName::String, neighbour1::String, pct1::Float64, neighbour2::String, pct2::Float64)
        point = index_map[headerName]
        push!(get!(nn_mapping, point, Vector{Tuple{Int, Float64}}()), (index_map[neighbour1], pct1))
        push!(nn_mapping[point], (index_map[neighbour2], pct2))
    end

    #<  Map vectors
    for (source, association) in vectors
        sorted = sort(collect(association), by = x -> -x[2])    #   Picks the two strongest associations to map
        if length(sorted) ≥ 2
            add_pair(
                source,
                sorted[1][1], sorted[1][2],
                sorted[2][1], sorted[2][2]
            )
        else
            @warn "Skipping $(source): fewer than 2 neighbours"
        end
    end


    #<  Define geometry
    for point in 1:node
        if haskey(nn_mapping, point)
            for (neigh_idx, pct) in nn_mapping[point]
                add_edge!(g, point, neigh_idx)
                push!(Vector{shape}(), shape(point, neigh_idx, pct))
            end
        end
    end

#   geometry                #################################################


    layout      = [ (cos(2π*(point-1)/node), sin(2π*(point-1)/node)) for point in 1:node ]
    background  = RGB(0.2, 0.2, 0.2)
    colour      = Gray(0.15)
    txtcol      = :white


    fig = Figure(; size = (1200, 1200), backgroundcolor = background)
    axis = Axis(
        fig[1, 1];
        xticksvisible       = false,
        yticksvisible       = false,
        xgridvisible        = false,
        ygridvisible        = false,
        backgroundcolor     = background
    )

#<  background layer
    graphplot!(
        axis,
        g;
        layout              = layout,
        node_label_offset   = (0.0, 0.15),
        node_marker         = :circle,
        node_size           = 15,
        node_color          = colour,
        node_stroke         = (:purple, 6.0),
        edge_color          = colour,
        directed            = false,
        node_label_size     = 1,
        node_label_color    = txtcol,
        textposition        = :center,
        alignment           = (:center, :center),
    )

#<  foreground layer
    text!(
        axis,
        layout,
        text                = headers,
        color               = txtcol,
        fontsize            = 15,
        align               = (:center, :center),
    )

    function visualize(output:: String, image:: Makie.Figure) 
        # visual = display(image)
        # wait(visual)
        save(output, image)
        println("\r[94m    ", pwd(), "/[95m", output, "\n[0m")
    end

    visualize(output, fig)
    println("\r[94m  ✓ Generating...Done\n[0m")

end


if abspath(PROGRAM_FILE) == @__FILE__
    input  = get(ARGS, 1, "vectors.json")
    output = get(ARGS, 2, "output.png")
    monolith(input, output)
end