# This file contains methods to solve an instance (heuristically or with CPLEX)
using CPLEX

include("generation.jl")

TOL = 0.00001

"""
Solve an instance with CPLEX
"""
function cplexSolve(inputFile::String)

    # Create the model
    m = Model(CPLEX.Optimizer)

    # TODO

    n, I, J, Pa = readInputFile(inputFile)
    N = (I * J)/n 
    @variable(m, z[1:I, 1:J, 1:N], Bin)
    @objective(m, Max, sum(z[1, j, 1] for j in 1:n))
    
    @variable(m, 0 <= P[1:I, 1:J] <= 4, Int)
    @variable(m, col[1:J, 1:N], Bin)
    @variable(m, lig[1:I, 1:N], Bin)
    @variable(m, diagai[1:(I+J-1), 1:N], Bin)
    @variable(m, diaggr[1:(I+J-1), 1:N], Bin)
    @variable(m, colg[2:J, 1:N], Bin)
    @variable(m, cold[1:J-1, 1:N], Bin)
    @variable(m, ligg[2:I, 1:N], Bin)
    @variable(m, ligd[1:I-1, 1:N], Bin)
    @variable(m, diagaig[2:(I+J-1), 1:N], Bin)
    @variable(m, diagaid[1:(I+J-1)-1, 1:N], Bin)
    @variable(m, diaggrg[2:(I+J-1), 1:N], Bin)
    @variable(m, diaggrd[1:(I+J-1)-1, 1:N], Bin)

    #contraintes de zones
    @constraint(m, case_par_zone[k in 1:N], sum(z[i, j, k] for i in 1:I for j in 1:J) == n)
    @constraint(m, case_exclusive[i in 1:I, j in 1:J], sum(z[i, j, k] for k in 1:N) == 1)

    #contraintes palissades 
    @constraint(m, paliss[i in 1:I, j in 1:J; Pa[i, j] != -1], Pa[i, j] == P[i, j])

    ####contraintes connexité 

    #max dans chaque direction 
    @constraint(m, colmax[j in 1:J, k in 1:N], col[j, k] == max(z[i, j] for i in 1:I))
    @constraint(m, ligmax[j in 1:J, k in 1:N], lig[j, k] == max(z[i, j] for i in 1:I))
    @constraint(m, diagaimax[a in 1:(I+J-1), k in 1:N], diagai[a, k] == max(z[]))
    for a in 1:(I+J-1)
        if a <= I
            if    

    #max a gauche 
    @constraint(m, max_gau_col1[j in 2:J-1, k in 1:N, j_g in 1:(j-1)], colg[j, k] >= col[j_g, k])
    @constraint(m, max_gau_col2[j in 2:J-1, k in 1:N], colg[j, k] <= sum(col[j_g, k] for j_g in 1:(j-1)))
    @constraint(m, max_gau_lig1[i in 2:I-1, k in 1:N, i_g in 1:(i-1)], ligg[i, k] >= lig[i_g, k])
    @constraint(m, max_gau_lig2[i in 2:I-1, k in 1:N], ligg[i, k] <= sum(lig[i_g, k] for i_g in 1:(i-1)))
    @constraint(m, max_gau_diagai1[i in 2:(I+J-1)-1, k in 1:N, i_g in 1:(i-1)], diagaig[i, k] >= diagai[i_g, k])
    @constraint(m, max_gau_diagai2[i in 2:(I+J-1)-1, k in 1:N], diagaig[i, k] <= sum(diagai[i_g, k] for i_g in 1:(i-1)))
    @constraint(m, max_gau_diaggr1[i in 2:(I+J-1)-1, k in 1:N, i_g in 1:(i-1)], diaggrg[i, k] >= diaggr[i_g, k])
    @constraint(m, max_gau_diaggr2[i in 2:(I+J-1)-1, k in 1:N], diaggrg[i, k] <= sum(diaggr[i_g, k] for i_g in 1:(i-1)))
    #max a droite 
    @constraint(m, max_gau_col1[j in 2:J-1, k in 1:N, j_d in j+1:J], cold[j, k] >= col[j_d, k])
    @constraint(m, max_gau_col2[j in 2:J-1, k in 1:N], cold[j, k] <= sum(col[j_d, k] for j_d in j+1:J))
    @constraint(m, max_gau_lig1[i in 2:I-1, k in 1:N, i_d in i+1:I], ligd[i, k] >= lig[i_d, k])
    @constraint(m, max_gau_lig2[i in 2:I-1, k in 1:N], ligd[i, k] <= sum(lig[i_d, k] for i_d in i+1:I))
    @constraint(m, max_gau_diagai1[i in 2:(I+J-1)-1, k in 1:N, i_d in i+1:(I+J-1)], diagaid[i, k] >= diagai[i_d, k])
    @constraint(m, max_gau_diagai2[i in 2:(I+J-1)-1, k in 1:N], diagaid[i, k] <= sum(diagai[i_d, k] for i_d in i+1:(I+J-1)))
    @constraint(m, max_gau_diaggr1[i in 2:(I+J-1)-1, k in 1:N, i_d in i+1:(I+J-1)], diaggrd[i, k] >= diaggr[i_d, k])
    @constraint(m, max_gau_diaggr2[i in 2:(I+J-1)-1, k in 1:N], diaggrd[i, k] <= sum(diaggr[i_d, k] for i_d in i+1:(I+J-1)))
    #min sur gauche et droite
    @constraint(m, min_col[j in 2:J-1, k in 1:N], col[j,k]>=colg[j,k]+cold[j,k]-1)
    @constraint(m, min_lig[i in 2:I-1, k in 1:N], lig[i,k]>=ligg[i,k]+ligd[i,k]-1)
    @constraint(m, min_diagai[i in 2:(I+J-1)-1, k in 1:N], diagai[i,k]>=diagaig[i,k]+diagaid[i,k]-1)
    @constraint(m, min_diaggr[i in 2:(I+J-1)-1, k in 1:N], diaggr[i,k]>=diaggrg[i,k]+diaggrd[i,k]-1)




    # Start a chronometer
    start = time()

    # Solve the model
    optimize!(m)


    duree = time() - start

    solution_found = JuMP.primal_status(m) == JuMP.MathOptInterface.FEASIBLE_POINT
    if solution_found
        Vz = JuMP.value.(z)
        Vz = round.(Int64, Vz)
    else
        Vz = Array{Int,N}(zeros(I, J, N))
    end

    return solution_found, duree, Vz

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
