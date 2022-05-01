# This file contains methods to solve an instance (heuristically or with CPLEX)
using CPLEX

include("generation.jl")

TOL = 0.00001

"""
Solve an instance with CPLEX
"""
function cplexSolve()

    # Create the model
    m = Model(CPLEX.Optimizer)

    # TODO

    n, I, J, Pa = readInputFile("path")
    N = n / (I * J)
    @variable(m, z[1:I, 1:J, 1:N], Bin)
    @objective(m, Max, sum(z[1, j, 1] for j in 1:n))
    
    @variable(m, 0 <= P[1:I, 1:J] <= 4, Int)
    @variable(m, col[1:J, 1:N], Bin)
    @variable(m, lig[1:I, 1:N], Bin)
    @variable(m, diagai[1:(I+J-1), 1:N], Bin)
    @variable(m, diaggr[1:(I+J-1), 1:N], Bin)
    @variable(m, colg[1:J, 1:N], Bin)
    @variable(m, cold[1:J, 1:N], Bin)
    @variable(m, ligg[1:I, 1:N], Bin)
    @variable(m, ligd[1:I, 1:N], Bin)
    @variable(m, diagaig[1:(I+J-1), 1:N], Bin)
    @variable(m, diagaid[1:(I+J-1), 1:N], Bin)
    @variable(m, diaggrg[1:(I+J-1), 1:N], Bin)
    @variable(m, diaggrd[1:(I+J-1), 1:N], Bin)

    @constraint(m, case_par_zone[k in 1:N], sum(z[i, j, k] for i in 1:I for j in 1:J) == n)
    @constraint(m, case_exclusive[i in 1:I, j in 1:J], sum(z[i, j, k] for k in 1:N) == 1)
    for i in 1:I
        for j in 1:J
            if Pa[i, j] != -1
                @constraint(m, Pa[i, j] == P[i, j])
            end
        end
    end
    @constraint(m, colmax[j in 1:J, k in 1:N], col[j, k] == max(z[i, j] for i in 1:I))
    @constraint(m, ligmax[j in 1:J, k in 1:N], lig[j, k] == max(z[i, j] for i in 1:I))
    @constraint(m, diagaimax[a in 1:(I+J-1), k in 1:N], diagai[a, k] == max(z[]))
    for a in 1:(I+J-1)
        if a <= I
            if    



    println("In file resolution.jl, in method cplexSolve(), TODO: fix input and output, define the model")

    # Start a chronometer
    start = time()

    # Solve the model
    optimize!(m)

    # Return:
    # 1 - true if an optimum is found
    # 2 - the resolution time
    return JuMP.primal_status(m) == JuMP.MathOptInterface.FEASIBLE_POINT, time() - start

end

"""
Heuristically solve an instance
"""
function heuristicSolve()

    # TODO
    println("In file resolution.jl, in method heuristicSolve(), TODO: fix input and output, define the model")

end

"""
Solve all the instances contained in "../data" through CPLEX and heuristics

The results are written in "../res/cplex" and "../res/heuristic"

Remark: If an instance has previously been solved (either by cplex or the heuristic) it will not be solved again
"""
function solveDataSet()

    dataFolder = "../data/"
    resFolder = "../res/"

    # Array which contains the name of the resolution methods
    resolutionMethod = ["cplex"]
    #resolutionMethod = ["cplex", "heuristique"]

    # Array which contains the result folder of each resolution method
    resolutionFolder = resFolder .* resolutionMethod

    # Create each result folder if it does not exist
    for folder in resolutionFolder
        if !isdir(folder)
            mkdir(folder)
        end
    end

    global isOptimal = false
    global solveTime = -1

    # For each instance
    # (for each file in folder dataFolder which ends by ".txt")
    for file in filter(x -> occursin(".txt", x), readdir(dataFolder))

        println("-- Resolution of ", file)
        readInputFile(dataFolder * file)

        # TODO
        println("In file resolution.jl, in method solveDataSet(), TODO: read value returned by readInputFile()")

        # For each resolution method
        for methodId in 1:size(resolutionMethod, 1)

            outputFile = resolutionFolder[methodId] * "/" * file

            # If the instance has not already been solved by this method
            if !isfile(outputFile)

                fout = open(outputFile, "w")

                resolutionTime = -1
                isOptimal = false

                # If the method is cplex
                if resolutionMethod[methodId] == "cplex"

                    # TODO 
                    println("In file resolution.jl, in method solveDataSet(), TODO: fix cplexSolve() arguments and returned values")

                    # Solve it and get the results
                    isOptimal, resolutionTime = cplexSolve()

                    # If a solution is found, write it
                    if isOptimal
                        # TODO
                        println("In file resolution.jl, in method solveDataSet(), TODO: write cplex solution in fout")
                    end

                    # If the method is one of the heuristics
                else

                    isSolved = false

                    # Start a chronometer 
                    startingTime = time()

                    # While the grid is not solved and less than 100 seconds are elapsed
                    while !isOptimal && resolutionTime < 100

                        # TODO 
                        println("In file resolution.jl, in method solveDataSet(), TODO: fix heuristicSolve() arguments and returned values")

                        # Solve it and get the results
                        isOptimal, resolutionTime = heuristicSolve()

                        # Stop the chronometer
                        resolutionTime = time() - startingTime

                    end

                    # Write the solution (if any)
                    if isOptimal

                        # TODO
                        println("In file resolution.jl, in method solveDataSet(), TODO: write the heuristic solution in fout")

                    end
                end

                println(fout, "solveTime = ", resolutionTime)
                println(fout, "isOptimal = ", isOptimal)

                # TODO
                println("In file resolution.jl, in method solveDataSet(), TODO: write the solution in fout")
                close(fout)
            end


            # Display the results obtained with the method on the current instance
            include(outputFile)
            println(resolutionMethod[methodId], " optimal: ", isOptimal)
            println(resolutionMethod[methodId], " time: " * string(round(solveTime, sigdigits=2)) * "s\n")
        end
    end
end
