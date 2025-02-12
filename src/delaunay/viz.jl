# Visualization

function viz(complex::CellComplex{DMT,SMT}; edge_color=:green) where {DMT,SMT}
    fig = Figure()
    lscene = LScene(fig[1, 1])
    viz!(complex; edge_color=edge_color)
end

function viz!(complex::CellComplex{DMT,SMT}; edge_color=:green) where {DMT,SMT}
    scatter!(complex.vertices)
    scatter!(complex.cell_centers)

    segment = zeros(3, 2)
    rowvec = rowvals(complex.E0T)

    for i in 1:n_edges(complex)
        if length(nzrange(complex.E0T, i)) != 2
            continue
        end

        for (c, j) in enumerate(nzrange(complex.E0T, i))
            v = rowvec[j]
            segment[:, c] .= @view complex.vertices[:, v]
        end

        lines!(segment, color=edge_color)
    end

    triangle = zeros(3, 3)
    for i in 1:n_faces(complex)
        edges_in_face = view(rowvals(complex.E1T), nzrange(complex.E1T, i))
        v0 = view(rowvals(complex.E0T), nzrange(complex.E0T, edges_in_face[1]))[1]
        triangle[:, 1] .= @view complex.vertices[:, v0]

        face_color = RGBf(rand(3)...)

        for j in @view edges_in_face[2:end]
            vertices_in_edge = view(rowvals(complex.E0T), nzrange(complex.E0T, j))

            if length(vertices_in_edge) != 2
                continue
            end

            for (c, j) in enumerate(vertices_in_edge)
                triangle[:, c+1] .= @view complex.vertices[:, j]
            end

            mesh!(triangle, [1 2 3], color=face_color, alpha=0.5)
        end
    end

    display(current_figure())
end

function viz(subcomplex::SubComplex{DMT,SMT,V}; edge_color=:green) where {DMT,SMT,V}
    fig = Figure()
    lscene = LScene(fig[1, 1])
    viz!(subcomplex; edge_color=edge_color)
end

function viz!(subcomplex::SubComplex{DMT,SMT,V}; edge_color=:green) where {DMT,SMT,V}
    complex = subcomplex.parent

    scatter!(complex.vertices[:, subcomplex.vertex_sub])
    scatter!(complex.cell_centers[:, subcomplex.volume_sub])

    segment = zeros(3, 2)
    rowvec = rowvals(complex.E0T)

    for i in 1:n_edges(complex)
        if !subcomplex.edge_sub[i] || length(nzrange(complex.E0T, i)) != 2
            continue
        end

        for (c, j) in enumerate(nzrange(complex.E0T, i))
            v = rowvec[j]
            segment[:, c] .= @view complex.vertices[:, v]
        end

        lines!(segment, color=edge_color)
    end

    triangle = zeros(3, 3)
    for i in 1:n_faces(complex)
        if !subcomplex.face_sub[i]
            continue
        end

        edges_in_face = view(rowvals(complex.E1T), nzrange(complex.E1T, i))
        v0 = view(rowvals(complex.E0T), nzrange(complex.E0T, edges_in_face[1]))[1]
        triangle[:, 1] .= @view complex.vertices[:, v0]

        face_color = RGBf(rand(3)...)

        for j in @view edges_in_face[2:end]
            vertices_in_edge = view(rowvals(complex.E0T), nzrange(complex.E0T, j))

            if length(vertices_in_edge) != 2
                continue
            end

            for (c, j) in enumerate(vertices_in_edge)
                triangle[:, c+1] .= @view complex.vertices[:, j]
            end

            mesh!(triangle, [1 2 3], color=face_color, alpha=0.5)
        end
    end

    display(current_figure())
end


function viz(simplex::DelaunaySimplex{DIM}, points) where {DIM}
    visited = Set{DelaunaySimplex{DIM}}()
    tovisit = Stack{DelaunaySimplex{DIM}}()

    fig, ax, plot = scatter(@view(points[:, 5:end]))

    push!(tovisit, simplex)

    while !isempty(tovisit)
        current = pop!(tovisit)
        push!(visited, current)

        viz!(current, points)

        for neighbor in current.neighbors
            if neighbor ∉ visited
                push!(tovisit, neighbor)
            end
        end
    end

    display(fig)
    return fig, ax, plot
end

function viz!(simplex::DelaunaySimplex{DIM}, points; color=:red) where {DIM}
    segment = zeros(DIM - 1, 2)

    for i in 1:(DIM-1)
        if simplex.vertices[i] ≤ 4
            continue
        end

        segment[:, 1] .= @view points[:, simplex.vertices[i]]

        for j in (i+1):DIM
            if simplex.vertices[j] ≤ 4
                continue
            end

            segment[:, 2] .= @view points[:, simplex.vertices[j]]
            lines!(segment, color=color)
        end
    end
end
