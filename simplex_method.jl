module SimplexMethod

    using Combinatorics

    export simplex_method

    type SimplexTableau
        z_c     ::Array{Float64}
        Y       ::Array{Float64}
        x_B     ::Array{Float64}
        obj     ::Float64
        b_idx   ::Array{Int64}
    end


    function is_non_negative(x::Array{Float64})
        return length(x[x .< 0]) == 0
    end


    function initial_BFS(A, b)
        m, n = size(A)

        combos = collect(combinations(1:n, m))
        for i in length(combos):-1:1
            b_idx = combos[i]
            B = A[:, b_idx]
            x_B = inv(B) * b
            if is_non_negative(x_B)
                return b_idx, x_B, B
            end
        end

        error("Infeasible")
    end


    function initialize(c, A, b)
        c = Array{Float64}(c)
        A = Array{Float64}(A)
        b = Array{Float64}(b)

        m, n = size(A)

        b_idx, x_B, B = initial_BFS(A, b)

        Y = inv(B) * A
        c_B = c[b_idx]
        obj = dot(c_B, x_B)

        # z_c is a row vector
        z_c = zeros(1, n)
        # setdiff(a, b) - constructs the set of elements in a but not b
        n_idx = setdiff(1:n, b_idx) # Represents J, set of indices for non-basic variables
        z_c[n_idx] = c_B' * inv(B) * A[:, n_idx] - c[n_idx]' # A[:, n_idx] represents N

        return SimplexTableau(z_c, Y, x_B, obj, b_idx)
    end


    function pivot_point(tableau::SimplexTableau)
        # Index of entering variable, i.e. z_j - c_j > 0
        # Index in x
        entering = findfirst(tableau.z_c .> 0)
        if entering == 0
            error("Optimal")
        end

        # Min ratio test
        pos_idx = find(tableau.Y[:, entering] .> 0) # Finds indices of rows with y_ik > 0

        # If all elements of Y are negative, the problem is unbounded
        if length(pos_idx) == 0
            error("Unbounded")
        end

        # Index of exiting variable (index in x_B)
        # t.Y[pos_idx, entering] corresponds to y_ik with k
        exiting = pos_idx[indmin(tableau.x_B[pos_idx] ./ tableau.Y[pos_idx, entering])] # Returns the index of pos_idx for the min ration

        return entering, exiting
    end


    # ! indicates that the function changes the content of the input argument
    function pivoting!(tableau::SimplexTableau)
        m, n = size(tableau.Y)

        entering, exiting = pivot_point(tableau)

        # Pivoting: exiting-row, entering-column
        # updating exiting-row
        coef = tableau.Y[exiting, entering]
        tableau.Y[exiting, :] /= coef
        tableau.x_B[exiting] /= coef

        # For all other rows in tableau.Y, perofrom row operations to make
        # the values in column entering equal to 0
        for i in setdiff(1:m, exiting)
            coef = tableau.Y[i, entering]
            tableau.Y[i, :] -= coef * tableau.Y[exiting, :]
            tableau.x_B[i] -= coef * tableau.x_B[exiting]
        end

        # Update the row for the reduced costs
        coef = tableau.z_c[entering]
        tableau.z_c -= coef * tableau.Y[exiting, :]'
        tableau.obj -= coef * tableau.x_B[exiting]

        # Update b_idx
        tableau.b_idx[find(tableau.b_idx .== tableau.b_idx[exiting])] = entering
    end


    function is_optimal(tableau)
        return findfirst(tableau.z_c .> 0) == 0
    end

    function simplex_method(c, A, b)
        tableau = initialize(c, A, b)

        while !is_optimal(tableau)
            pivoting!(tableau)
        end

        opt_x = zeros(length(c))
        opt_x[tableau.b_idx] = tableau.x_B

        return opt_x, tableau.obj
    end

end
