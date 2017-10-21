module MCNF

    using JuMP, Clp

    export min_cost_network_flow

    function min_cost_network_flow(nodes, links, c_dict, u_dict, b)
        model = Model(solver=ClpSolver())

        @variable(model, 0 <= x[link in links] <= u_dict[link])

        @objective(model, Min, sum(c_dict[link] * x[link] for link in links))

        for i in nodes
            @constraint(model, sum(x[(ii, j)] for (ii, j) in links if ii == i)
                             - sum(x[(j, ii)] for (j, ii) in links if ii == i) == b[i])
        end

        status = solve(model)

        return getvalue(x), getobjectivevalue(model), status, model
    end

end
