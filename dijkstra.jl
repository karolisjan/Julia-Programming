module DijkstrasAlgorithm

    export dijkstras_algorithm

    function get_shortest_path(parents, destination)
        node = destination
        path = Array{Int}([])

        while node != - 1
            push!(path, node)
            node = parents[node]
        end

        return path[end:-1:1]
    end

    # Returns the shortest path and its distance from origin to destination
    function dijkstras_algorithm(origin, destination, start_nodes, end_nodes, c)
        num_nodes = max(maximum(start_nodes), maximum(end_nodes))
        num_links = length(start_nodes)

        # Set of nodes
        N = Set(1:num_nodes)
        # Set of links
        A = Set{Tuple{Int, Int}}()
        c_dict = Dict()
        for i in 1:num_links
            push!(A, (start_nodes[i], end_nodes[i]))
            c_dict[(start_nodes[i], end_nodes[i])] = c[i]
        end

        w = Array{Float64}(num_nodes)
        w[origin] = 0
        X = Set{Int}(origin)
        Xbar = setdiff(N, X)

        # Stores parent nodes in the shortest path
        parents = Array{Int}(zeros(num_nodes))
        parents[origin] = -1

        # Main loop
        while !isempty(Xbar)
            # Step 1
            XXbar = Set{Tuple{Int, Int}}()
            for i in X, j in Xbar
                if (i, j) in A
                    push!(XXbar, (i, j))
                end
            end

            # Step 2
            min_distance = Inf
            p, q = 0, 0
            for (i, j) in XXbar
                if w[i] + c_dict[(i, j)] < min_distance
                    min_distance = w[i] + c_dict[(i, j)]
                    p, q = i, j
                end
            end

            parents[q] = p

            # Step 3
            w[q] = min_distance
            push!(X, q)

            # Step 4
            Xbar = setdiff(N, X)
        end

        return w[destination], get_shortest_path(parents, destination)
    end

end
