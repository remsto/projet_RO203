# This file contains methods to generate a data set of instances (i.e., sudoku grids)
include("io.jl")
using Random


function coor_to_ligne(pos::Int, n::Int)
    ligne = n - (pos - 1) ÷ n
    colonne = 1 + (pos - 1) % n
    return ligne, colonne
end

"""
Generate an n*n grid with a given density

Argument
- n: size of the grid
- density: percentage in [0, 1] of initial values in the grid
"""
function generateInstance(n::Int64, densite_miroir::Float64, densite_miroir_aigu::Float64, instance::Int)

    fileName = "inst_t" * string(n) * "_dm" * string(densite_miroir) * "_dmaigue" * string(densite_miroir_aigu) * "_" * string(instance) * ".txt"
    chemin = "jeu1/data/" * fileName

    if !isfile(chemin)

        dataFile = open(chemin, "w")

        println(dataFile, "n : ", n)

        nb_miroir = floor(Int64, densite_miroir * n * n)
        nb_mir_aigu = floor(Int64, densite_miroir_aigu * nb_miroir)
        nb_mir_grave = nb_miroir - nb_mir_aigu
        nb_monstre = n * n - nb_miroir

        #creation du tableau des miroirs
        miroir = Array{Int64,2}(zeros(n, n))
        perm = randperm(n * n)
        place_mir = perm[1:nb_mir_aigu+nb_mir_grave]

        for i in 1:nb_mir_aigu+nb_mir_grave
            a_placer = Int(1)
            if i <= nb_mir_aigu
                a_placer = 2
            end
            ligne, colonne = coor_to_ligne(perm[i], n)
            miroir[ligne, colonne] = a_placer
        end

        #creation matrice visibilite
        Vis = matrice_vis(n, miroir)

        #positionnement des monstres 
        nb_monstre = Array{Int,1}(zeros(3))
        tab_monstre = Array{Int64,2}(zeros(n, n))
        place_monstre = setdiff(1:n*n, place_mir)
        for place in place_monstre
            ligne, colonne = coor_to_ligne(place, n)
            type = rand(1:3)
            nb_monstre[type] += 1
            tab_monstre[ligne, colonne] = type
        end

        #calcul des valeurs sur les bords 
        monstre_a_voir = Array{Int,2}(zeros(4, n))
        for cote in 1:4, k in 1:n, i in 1:n, j in 1:n
            if Vis[cote, k, i, j] == 1 && (tab_monstre[i, j] == 2 || tab_monstre[i, j] == 3)
                monstre_a_voir[cote, k] += 1
            elseif Vis[cote, k, i, j] == 2 && (tab_monstre[i, j] == 1 || tab_monstre[i, j] == 3)
                monstre_a_voir[cote, k] += 1
            end
        end

        println(dataFile, "g : ", nb_monstre[1])
        println(dataFile, "v : ", nb_monstre[2])
        println(dataFile, "z : ", nb_monstre[3])

        print(dataFile, "   ")
        for j in 1:n
            print(dataFile, monstre_a_voir[4, j])
            if j != n
                print(dataFile, ", ")
            else
                print(dataFile, "\n")
            end
        end

        for i in 1:n
            print(dataFile, monstre_a_voir[1, i], ", ")
            for j in 1:n
                if miroir[i, j] == 0
                    print(dataFile, "r")
                elseif miroir[i, j] == 1
                    print(dataFile, "g")
                elseif miroir[i, j] == 2
                    print(dataFile, "a")
                end
                print(dataFile, ", ")
            end
            println(dataFile, monstre_a_voir[3, i])
        end

        print(dataFile, "   ")
        for j in 1:n
            print(dataFile, monstre_a_voir[2, j])
            if j != n
                print(dataFile, ", ")
            else
                print(dataFile, "\n")
            end
        end

        close(dataFile)
    end
end

"""
Generate all the instances

Remark: a grid is generated only if the corresponding output file does not already exist
"""
function generateDataSet()
    for n in 4:12
        for densite_miroir in 0.2:0.1:0.4
            for densite_miroir_aigu in 0.1:0.2:0.9
                for iteration in 1:10
                    generateInstance(n, densite_miroir, densite_miroir_aigu, iteration)
                end
            end
        end
    end
end



