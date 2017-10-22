module DijkstrasAlgorithm

    export dijkstras_algorithm

    # Returns w - vector of distances from origin to every other node
    function dijkstras_algorithm(origin, start_nodes, end_nodes, c)
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
            min_val = Inf
            q = 0
            for (i, j) in XXbar
                if w[i] + c_dict[(i, j)] < min_val
                    min_val = w[i] + c_dict[(i, j)]
                    q = j
                end
            end

            # Step 3
            w[q] = min_val
            push!(X, q)

            # Step 4
            Xbar = setdiff(N, X)
        end

        return w
    end

end
