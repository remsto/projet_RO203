# This file contains methods to solve an instance (heuristically or with CPLEX)
using CPLEX

include("generation.jl")

TOL = 0.00001

"""
Solve an instance with CPLEX
"""
function cplexSolve(inputFile::String)

    n, Visib, monstre_a_voir, nb_monstre, miroir = readInputFile(inputFile)
    # Create the model
    m = Model(CPLEX.Optimizer)


    @variable(m, x[1:n, 1:n, 1:3], Bin)

    @objective(m, Max, sum(x[1, j, 1] for j in 1:n))

    ##CONTRAINTES 

    @constraint(m, case_remplie[i in 1:n, j in 1:n], sum(x[i, j, k] + miroir[i, j] for k in 1:3) >= 1)
    @constraint(m, un_monstre_case[i in 1:n, j in 1:n], sum(x[i, j, k] for k in 1:3) <= 1)

    @constraint(m, total_monstre[k in 1:3], sum(x[i, j, k] for i in 1:n for j in 1:n) == nb_monstre[k])

    @constraint(m, nbr_visible[cote in 1:4, pos in 1:n], sum(x[i, j, k] for i in 1:n for j in 1:n for k in 2:3 if Visib[cote, pos, i, j] == 1) + sum(x[i, j, k] for i in 1:n for j in 1:n for k in 1:2:3 if Visib[cote, pos, i, j] == 2) == monstre_a_voir[cote, pos])



    # Start a chronometer
    start = time()

    # Solve the model
    optimize!(m)

    duree = time() - start


    # Return:
    # 1 - true if an optimum is found (faissable nan ?)
    # 2 - the resolution time
    # 3 - la solution
    solution_found = JuMP.primal_status(m) == JuMP.MathOptInterface.FEASIBLE_POINT
    if solution_found
        Vx = JuMP.value.(x)
        Vx = round.(Int64,Vx)
    else
        Vx = Array{Int,3}(zeros(n, n, 3))
    end

    return solution_found, duree, Vx

end

n, V, monstre_a_voir, nb_monstre, miroir = readInputFile("jeu1/data/inst_t5_dm0.2_dmaigue0.3_3.txt")
displayGrid(n, monstre_a_voir, nb_monstre, miroir)
found, duree, sol = cplexSolve("jeu1/data/inst_t5_dm0.2_dmaigue0.3_3.txt")
displaySolution(n, monstre_a_voir, nb_monstre, miroir, sol)


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

    dataFolder = "jeu1/data/"
    resFolder = "jeu1/res/"

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
        n, Visib, monstre_a_voir, nb_monstre, miroir = readInputFile(dataFolder * file)


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


                    # Solve it and get the results
                    isOptimal, resolutionTime, sol = cplexSolve(dataFolder * file)

                    # If a solution is found, write it
                    if isOptimal
                        # TODO
                        displaySolution_file(fout, n, monstre_a_voir, nb_monstre, miroir, sol)
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
                #println("In file resolution.jl, in method solveDataSet(), TODO: write the solution in fout")
                close(fout)
            end


            # Display the results obtained with the method on the current instance
            #include(outputFile)
            println(resolutionMethod[methodId], " optimal: ", isOptimal)
            println(resolutionMethod[methodId], " time: " * string(round(solveTime, sigdigits=2)) * "s\n")
        end
    end
end
