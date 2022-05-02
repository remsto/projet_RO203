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
    N = (I * J) ÷ n

    @objective(m, Max, 0)

    @variable(m, z[1:I, 1:J, 1:N], Bin)

    @variable(m, Prod[1:I, 1:J, 1:N, 1:4], Bin)

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




    ####contraintes palissades 
    #pour tous
    @constraint(m, produit1[i in 1:I, j in 1:J, k in 1:N, a in 1:4,], Prod[i, j, k, a] <= z[i, j, k])


    #dans les coins
    @constraint(m, produit2_1corner1[k in 1:N; Pa[1, 1] != -1], Prod[1, 1, k, 1] <= z[2, 1, k])
    @constraint(m, produit3_1corner1[k in 1:N; Pa[1, 1] != -1], Prod[1, 1, k, 1] >= z[2, 1, k] + z[1, 1, k] - 1)

    @constraint(m, produit2_2corner1[k in 1:N; Pa[1, 1] != -1], Prod[1, 1, k, 2] <= z[1, 2, k])
    @constraint(m, produit3_2corner1[k in 1:N; Pa[1, 1] != -1], Prod[1, 1, k, 2] >= z[1, 2, k] + z[1, 1, k] - 1)

    if Pa[1, 1] != -1
        @constraint(m, paliss_corner1, Pa[1, 1] == 2 + sum(2 * z[1, 1, k] - sum(Prod[1, 1, k, a] for a in 1:2) for k in 1:N))
    end

    @constraint(m, produit2_1corner2[k in 1:N; Pa[I, 1] != -1], Prod[I, 1, k, 1] <= z[I-1, 1, k])
    @constraint(m, produit3_1corner2[k in 1:N; Pa[I, 1] != -1], Prod[I, 1, k, 1] >= z[I, 1, k] + z[I-1, 1, k] - 1)

    @constraint(m, produit2_2corner2[k in 1:N; Pa[I, 1] != -1], Prod[I, 1, k, 2] <= z[I, 2, k])
    @constraint(m, produit3_2corner2[k in 1:N; Pa[I, 1] != -1], Prod[I, 1, k, 2] >= z[I, 1, k] + z[I, 2, k] - 1)

    if Pa[I, 1] != -1
        @constraint(m, paliss_corner2, Pa[I, 1] == 2 + sum(2 * z[I, 1, k] - sum(Prod[I, 1, k, a] for a in 1:2) for k in 1:N))
    end

    @constraint(m, produit2_1corner3[k in 1:N; Pa[1, J] != -1], Prod[1, J, k, 1] <= z[2, J, k])
    @constraint(m, produit3_1corner3[k in 1:N; Pa[1, J] != -1], Prod[1, J, k, 1] >= z[1, J, k] + z[2, J, k] - 1)

    @constraint(m, produit2_2corner3[k in 1:N; Pa[1, J] != -1], Prod[1, J, k, 2] <= z[1, J-1, k])
    @constraint(m, produit3_2corner3[k in 1:N; Pa[1, J] != -1], Prod[1, J, k, 2] >= z[1, J, k] + z[1, J-1, k] - 1)

    if Pa[1, J] != -1
        @constraint(m, paliss_corner3, Pa[1, J] == 2 + sum(2 * z[1, J, k] - sum(Prod[1, J, k, a] for a in 1:2) for k in 1:N))
    end

    @constraint(m, produit2_1corner4[k in 1:N; Pa[I, J] != -1], Prod[I, J, k, 1] <= z[I-1, J, k])
    @constraint(m, produit3_1corner4[k in 1:N; Pa[I, J] != -1], Prod[I, J, k, 1] >= z[I, J, k] + z[I-1, J, k] - 1)

    @constraint(m, produit2_2corner4[k in 1:N; Pa[I, J] != -1], Prod[I, J, k, 2] <= z[I, J-1, k])
    @constraint(m, produit3_2corner4[k in 1:N; Pa[I, J] != -1], Prod[I, J, k, 2] >= z[I, J, k] + z[I, J-1, k] - 1)

    if Pa[I, J] != -1
        @constraint(m, paliss_corner4, Pa[I, J] == 2 + sum(2 * z[I, J, k] - sum(Prod[I, J, k, a] for a in 1:2) for k in 1:N))
    end


    #bordures 
    @constraint(m, produit2_1border1[i in 2:(I-1), k in 1:N; Pa[i, 1] != -1], Prod[i, 1, k, 1] <= z[i+1, 1, k])
    @constraint(m, produit3_1border1[i in 2:(I-1), k in 1:N; Pa[i, 1] != -1], Prod[i, 1, k, 1] >= z[i, 1, k] + z[i+1, 1, k] - 1)

    @constraint(m, produit2_2border1[i in 2:(I-1), k in 1:N; Pa[i, 1] != -1], Prod[i, 1, k, 2] <= z[i-1, 1, k])
    @constraint(m, produit3_2border1[i in 2:(I-1), k in 1:N; Pa[i, 1] != -1], Prod[i, 1, k, 2] >= z[i, 1, k] + z[i-1, 1, k] - 1)

    @constraint(m, produit2_3border1[i in 2:(I-1), k in 1:N; Pa[i, 1] != -1], Prod[i, 1, k, 3] <= z[i, 2, k])
    @constraint(m, produit3_3border1[i in 2:(I-1), k in 1:N; Pa[i, 1] != -1], Prod[i, 1, k, 3] >= z[i, 1, k] + z[i, 2, k] - 1)

    @constraint(m, paliss_border1[i in 2:(I-1); Pa[i, 1] != -1], Pa[i, 1] == 1 + sum(3 * z[i, 1, k] - sum(Prod[i, 1, k, a] for a in 1:3) for k in 1:N))


    @constraint(m, produit2_1border2[j in 2:(J-1), k in 1:N; Pa[1, j] != -1], Prod[1, j, k, 1] <= z[2, j, k])
    @constraint(m, produit3_1border2[j in 2:(J-1), k in 1:N; Pa[1, j] != -1], Prod[1, j, k, 1] >= z[1, j, k] + z[2, j, k] - 1)

    @constraint(m, produit2_2border2[j in 2:(J-1), k in 1:N; Pa[1, j] != -1], Prod[1, j, k, 2] <= z[1, j-1, k])
    @constraint(m, produit3_2border2[j in 2:(J-1), k in 1:N; Pa[1, j] != -1], Prod[1, j, k, 2] >= z[1, j, k] + z[1, j-1, k] - 1)

    @constraint(m, produit2_3border2[j in 2:(J-1), k in 1:N; Pa[1, j] != -1], Prod[1, j, k, 3] <= z[1, j+1, k])
    @constraint(m, produit3_3border2[j in 2:(J-1), k in 1:N; Pa[1, j] != -1], Prod[1, j, k, 3] >= z[1, j, k] + z[1, j+1, k] - 1)

    @constraint(m, paliss_border2[j in 2:(J-1); Pa[1, j] != -1], Pa[1, j] == 1 + sum(3 * z[1, j, k] - sum(Prod[1, j, k, a] for a in 1:3) for k in 1:N))



    @constraint(m, produit2_1border3[i in 2:(I-1), k in 1:N; Pa[i, J] != -1], Prod[i, J, k, 1] <= z[i-1, J, k])
    @constraint(m, produit3_1border3[i in 2:(I-1), k in 1:N; Pa[i, J] != -1], Prod[i, J, k, 1] >= z[i, J, k] + z[i-1, J, k] - 1)

    @constraint(m, produit2_2border3[i in 2:(I-1), k in 1:N; Pa[i, J] != -1], Prod[i, J, k, 2] <= z[i+1, J, k])
    @constraint(m, produit3_2border3[i in 2:(I-1), k in 1:N; Pa[i, J] != -1], Prod[i, J, k, 2] >= z[i, J, k] + z[i+1, J, k] - 1)

    @constraint(m, produit2_3border3[i in 2:(I-1), k in 1:N; Pa[i, J] != -1], Prod[i, J, k, 3] <= z[i, J-1, k])
    @constraint(m, produit3_3border3[i in 2:(I-1), k in 1:N; Pa[i, J] != -1], Prod[i, J, k, 3] >= z[i, J, k] + z[i, J-1, k] - 1)

    @constraint(m, paliss_border3[i in 2:(I-1); Pa[i, J] != -1], Pa[i, J] == 1 + sum(3 * z[i, J, k] - sum(Prod[i, J, k, a] for a in 1:3) for k in 1:N))


    @constraint(m, produit2_1border4[j in 2:(J-1), k in 1:N; Pa[I, j] != -1], Prod[I, j, k, 2] <= z[I-1, j, k])
    @constraint(m, produit3_1border4[j in 2:(J-1), k in 1:N; Pa[I, j] != -1], Prod[I, j, k, 2] >= z[I, j, k] + z[I-1, j, k] - 1)

    @constraint(m, produit2_2border4[j in 2:(J-1), k in 1:N; Pa[I, j] != -1], Prod[I, j, k, 2] <= z[I, j-1, k])
    @constraint(m, produit3_2border4[j in 2:(J-1), k in 1:N; Pa[I, j] != -1], Prod[I, j, k, 2] >= z[I, j, k] + z[I, j-1, k] - 1)

    @constraint(m, produit2_3border4[j in 2:(J-1), k in 1:N; Pa[I, j] != -1], Prod[I, j, k, 3] <= z[I, j+1, k])
    @constraint(m, produit3_3border4[j in 2:(J-1), k in 1:N; Pa[I, j] != -1], Prod[I, j, k, 3] >= z[I, j, k] + z[I, j+1, k] - 1)

    @constraint(m, paliss_border4[j in 2:(J-1); Pa[I, j] != -1], Pa[I, j] == 1 + sum(3 * z[I, j, k] - sum(Prod[I, j, k, a] for a in 1:3) for k in 1:N))


    #milieu
    @constraint(m, produit2_1mid[i in 2:(I-1), j in 2:(J-1), k in 1:N; Pa[i, j] != -1], Prod[i, j, k, 1] <= z[i-1, j, k])
    @constraint(m, produit3_1mid[i in 2:(I-1), j in 2:(J-1), k in 1:N; Pa[i, j] != -1], Prod[i, j, k, 1] >= z[i, j, k] + z[i-1, j, k] - 1)

    @constraint(m, produit2_2mid[i in 2:(I-1), j in 2:(J-1), k in 1:N; Pa[i, j] != -1], Prod[i, j, k, 2] <= z[i+1, j, k])
    @constraint(m, produit3_2mid[i in 2:(I-1), j in 2:(J-1), k in 1:N; Pa[i, j] != -1], Prod[i, j, k, 2] >= z[i, j, k] + z[i+1, j, k] - 1)

    @constraint(m, produit2_3mid[i in 2:(I-1), j in 2:(J-1), k in 1:N; Pa[i, j] != -1], Prod[i, j, k, 3] <= z[i, j-1, k])
    @constraint(m, produit3_3mid[i in 2:(I-1), j in 2:(J-1), k in 1:N; Pa[i, j] != -1], Prod[i, j, k, 3] >= z[i, j, k] + z[i, j-1, k] - 1)

    @constraint(m, produit2_4mid[i in 2:(I-1), j in 2:(J-1), k in 1:N; Pa[i, j] != -1], Prod[i, j, k, 4] <= z[i, j+1, k])
    @constraint(m, produit3_4mid[i in 2:(I-1), j in 2:(J-1), k in 1:N; Pa[i, j] != -1], Prod[i, j, k, 4] >= z[i, j, k] + z[i, j+1, k] - 1)

    @constraint(m, paliss_mid[i in 2:(I-1), j in 2:(J-1); Pa[i, j] != -1], Pa[i, j] == sum(4 * z[i, j, k] - sum(Prod[i, j, k, a] for a in 1:4) for k in 1:N))






    ####contraintes connexité 

    #max dans chaque direction 
    @constraint(m, colmax[j in 1:J, k in 1:N, i in 1:I], col[j, k] >= z[i, j, k])
    @constraint(m, colmax_sum[j in 1:J, k in 1:N], col[j, k] <= sum(z[i, j, k] for i in 1:I))
    @constraint(m, ligmax[i in 1:I, k in 1:N, j in 1:J], lig[i, k] >= z[i, j, k])
    @constraint(m, ligmax_sum[i in 1:I, k in 1:N], lig[i, k] <= sum(z[i, j, k] for j in 1:J))

    @constraint(m, diagaimax1[a in 1:(I+J-1), k in 1:N, b in 0:(min(a, I, J)-1); a <= J && a <= I], diagai[a, k] >= z[a-b, 1+b, k])
    @constraint(m, diagaimax1_sum[a in 1:(I+J-1), k in 1:N; a <= J && a <= I], diagai[a, k] <= sum(z[a-b, 1+b, k] for b in 0:(min(a, I, J)-1)))
    @constraint(m, diagaimax2[a in 1:(I+J-1), k in 1:N, b in 0:(min(a, I, J)-1); a <= J && a > I], diagai[a, k] >= z[I-b, a-I+1+b, k])
    @constraint(m, diagaimax2_sum[a in 1:(I+J-1), k in 1:N; a <= J && a > I], diagai[a, k] <= sum(z[I-b, a-I+1+b, k] for b in 0:(min(a, I, J)-1)))
    @constraint(m, diagaimax3[a in 1:(I+J-1), k in 1:N, b in 0:(min(I + J - a, I, J)-1); a > J && a <= I], diagai[a, k] >= z[a-b, 1+b, k])
    @constraint(m, diagaimax3_sum[a in 1:(I+J-1), k in 1:N; a > J && a <= I], diagai[a, k] <= sum(z[a-b, 1+b, k] for b in 0:(min(I + J - a, I, J)-1)))
    @constraint(m, diagaimax4[a in 1:(I+J-1), k in 1:N, b in 0:(min(I + J - a, I, J)-1); a > J && a > I], diagai[a, k] >= z[I-b, a-I+1+b, k])
    @constraint(m, diagaimax4_sum[a in 1:(I+J-1), k in 1:N; a > J && a > I], diagai[a, k] <= sum(z[I-b, a-I+1+b, k] for b in 0:(min(I + J - a, I, J)-1)))

    @constraint(m, diaggrmax1[a in 1:(I+J-1), k in 1:N, b in 0:(min(a, I, J)-1); a <= J && a <= I], diaggr[a, k] >= z[I+1-a+b, 1+b, k])
    @constraint(m, diaggrmax1_sum[a in 1:(I+J-1), k in 1:N; a <= J && a <= I], diaggr[a, k] <= sum(z[I+1-a+b, 1+b, k] for b in 0:(min(a, I, J)-1)))
    @constraint(m, diaggrmax2[a in 1:(I+J-1), k in 1:N, b in 0:(min(a, I, J)-1); a <= J && a > I], diaggr[a, k] >= z[1+b, a-I+1+b, k])
    @constraint(m, diaggrmax2_sum[a in 1:(I+J-1), k in 1:N; a <= J && a > I], diaggr[a, k] <= sum(z[1+b, a-I+1+b, k] for b in 0:(min(a, I, J)-1)))
    @constraint(m, diaggrmax3[a in 1:(I+J-1), k in 1:N, b in 0:(min(I + J - a, I, J)-1); a > J && a <= I], diaggr[a, k] >= z[I+1-a+b, 1+b, k])
    @constraint(m, diaggrmax3_sum[a in 1:(I+J-1), k in 1:N; a > J && a <= I], diaggr[a, k] <= sum(z[I+1-a+b, 1+b, k] for b in 0:(min(I + J - a, I, J)-1)))
    @constraint(m, diaggrmax4[a in 1:(I+J-1), k in 1:N, b in 0:(min(I + J - a, I, J)-1); a > J && a > I], diaggr[a, k] >= z[1+b, a-I+1+b, k])
    @constraint(m, diaggrmax4_sum[a in 1:(I+J-1), k in 1:N; a > J && a > I], diaggr[a, k] <= sum(z[1+b, a-I+1+b, k] for b in 0:(min(I + J - a, I, J)-1)))


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
    @constraint(m, max_dro_col1[j in 2:J-1, k in 1:N, j_d in j+1:J], cold[j, k] >= col[j_d, k])
    @constraint(m, max_dro_col2[j in 2:J-1, k in 1:N], cold[j, k] <= sum(col[j_d, k] for j_d in j+1:J))
    @constraint(m, max_dro_lig1[i in 2:I-1, k in 1:N, i_d in i+1:I], ligd[i, k] >= lig[i_d, k])
    @constraint(m, max_dro_lig2[i in 2:I-1, k in 1:N], ligd[i, k] <= sum(lig[i_d, k] for i_d in i+1:I))
    @constraint(m, max_dro_diagai1[i in 2:(I+J-1)-1, k in 1:N, i_d in i+1:(I+J-1)], diagaid[i, k] >= diagai[i_d, k])
    @constraint(m, max_dro_diagai2[i in 2:(I+J-1)-1, k in 1:N], diagaid[i, k] <= sum(diagai[i_d, k] for i_d in i+1:(I+J-1)))
    @constraint(m, max_dro_diaggr1[i in 2:(I+J-1)-1, k in 1:N, i_d in i+1:(I+J-1)], diaggrd[i, k] >= diaggr[i_d, k])
    @constraint(m, max_dro_diaggr2[i in 2:(I+J-1)-1, k in 1:N], diaggrd[i, k] <= sum(diaggr[i_d, k] for i_d in i+1:(I+J-1)))
    #min sur gauche et droite
    @constraint(m, min_col[j in 2:J-1, k in 1:N], col[j, k] >= colg[j, k] + cold[j, k] - 1)
    @constraint(m, min_lig[i in 2:I-1, k in 1:N], lig[i, k] >= ligg[i, k] + ligd[i, k] - 1)
    @constraint(m, min_diagai[i in 2:(I+J-1)-1, k in 1:N], diagai[i, k] >= diagaig[i, k] + diagaid[i, k] - 1)
    @constraint(m, min_diaggr[i in 2:(I+J-1)-1, k in 1:N], diaggr[i, k] >= diaggrg[i, k] + diaggrd[i, k] - 1)





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
        Vz = Array{Int,3}(zeros(I, J, N))

    end

    return solution_found, duree, Vz

end

"""
Heuristically solve an instance
"""
function heuristicSolve(inputFile::String)

    n, I, J, Pa = readInputFile(inputFile)
    N = (I * J) ÷ n




end

"""
Solve all the instances contained in "../data" through CPLEX and heuristics

The results are written in "../res/cplex" and "../res/heuristic"

Remark: If an instance has previously been solved (either by cplex or the heuristic) it will not be solved again
"""
function solveDataSet()

    dataFolder = "jeu2/data/"
    resFolder = "jeu2/res/"

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

        n, I, J, Pa = readInputFile(dataFolder * file)

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
                        displaySolution_file(fout, n, I, J, Pa, sol)
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
                # println("In file resolution.jl, in method solveDataSet(), TODO: write the solution in fout")
                close(fout)
            end


            # Display the results obtained with the method on the current instance
            # include(outputFile)
            println(resolutionMethod[methodId], " optimal: ", isOptimal)
            println(resolutionMethod[methodId], " time: " * string(round(solveTime, sigdigits=2)) * "s\n")
        end
    end
end
