# This file contains methods to generate a data set of instances (i.e., sudoku grids)
include("io.jl")
using Random

function coor_to_ligne(pos::Int, I::Int, J::Int)
    ligne = ((pos - 1) ÷ J) + 1
    colonne = pos - (ligne - 1) * J
    return ligne, colonne
end

"""
Generate an n*n grid with a given density

Argument
- n: size of the grid
- density: percentage in [0, 1] of initial values in the grid
"""
function generateInstance(n::Int64, I::Int64, J::Int64, density::Float64, instance::Int)

    fileName = "inst_L" * string(I) * "_C" * string(J) * "_tzone" * string(n) * "_dpal" * string(density) * "_" * string(instance) * ".txt"
    chemin = "jeu2/data/" * fileName

    if !isfile(chemin)

        dataFile = open(chemin, "w")

        println(dataFile, "n : ", n)
        println(dataFile, "I : ", I)
        println(dataFile, "J : ", J)

        nb_contr_pal = floor(Int64, density * I * J)

        #placement des contraintes de palissade
        Pal = (-1) * Array{Int64,2}(ones(I, J))
        perm = randperm(I * J)

        for i in 1:nb_contr_pal
            ligne, colonne = coor_to_ligne(perm[i], I, J)
            if ligne == 1 || ligne == I
                if colonne == 1 || colonne == J
                    Pal[ligne, colonne] = rand(2:3)
                else
                    Pal[ligne, colonne] = rand(1:3)
                end
            elseif colonne == 1 || colonne == J
                Pal[ligne, colonne] = rand(1:3)
            else
                Pal[ligne, colonne] = rand(0:3)
            end
        end


        for i in 1:I
            for j in 1:J
                if Pal[i, j] == -1
                    print(dataFile, " ")
                else
                    print(dataFile, Pal[i, j])
                end
                if j != J
                    print(dataFile, ", ")
                else
                    println(dataFile)
                end
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

    for I in 8:30
        for J in 8:30
            for n in 8:((I*J)÷3)
                if J * I % n == 0
                    for density in 0.1:0.1:0.5
                        for iteration in 1:5
                            generateInstance(n, I, J, density, iteration)
                        end
                    end
                end
            end
        end
    end
end



