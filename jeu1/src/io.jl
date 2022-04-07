# This file contains functions related to reading, writing and displaying a grid and experimental results

using JuMP
using Plots
import GR

# Transforme la direction selon le miroir rencontré
function transfoDirection(dir::Tuple{Int64,Int64}, z_case::Int64)
    if z_case == 1
        return (dir[2], dir[1])
    elseif z_case == 2
        return (-dir[2], -dir[1])
    end
end

# Donne la direction souhaitée pour un côté donné
function giveDirection(c::Int64)
    if c == 1
        return (0, 1)
    elseif c == 2
        return (-1, 0)
    elseif c == 3
        return (0, -1)
    elseif c == 4
        return (1, 0)
    else
        println("Problème de valeur dans giveDirection")
    end
end

# Donne la case départ pour un côté donnée
function giveCaseDepart(c::Int64, k::Int64, n::Int64)
    if c == 1
        return (k, 1)
    elseif c == 2
        return (n, k)
    elseif c == 3
        return (k, n)
    elseif c == 4
        return (1, k)
    else
        println("Problème de valeur dans giveCaseDepart")
    end
end

function matrice_vis(n::Int64, miroirs::Array{Int64,2})
    V = Array{Int64}(zeros(4, n, n, n))
    for c in 1:4
        for k in 1:n
            dir = giveDirection(c)
            val = 1
            case = giveCaseDepart(c, k, n)
            while (case[1] > 0 && case[1] <= n && case[2] > 0 && case[2] <= n)
                if miroirs[case[1], case[2]] != 0
                    dir = transfoDirection(dir, miroirs[case[1], case[2]])
                    val = 2
                else
                    V[c, k, case[1], case[2],] = val
                end
                case = (case[1] + dir[1], case[2] + dir[2])
            end
        end
    end
    return V
end

"""
Read an instance from an input file

- Argument:
inputFile: path of the input file
"""
function readInputFile(inputFile::String)

    # Open the input file
    datafile = open(inputFile)

    data = readlines(datafile)
    close(datafile)


    n = parse(Int64, split(data[1], ":")[2])
    monstre_a_voir = Array{Int64}(undef, 4, n)
    nb_monstre = Array{Int64}(undef, 3)
    miroirs = Array{Int64}(undef, n, n)

    # For each line of the input file

    for (i, line) in enumerate(data)
        if i > 1 && i <= 4
            nb_monstre[i-1] = parse(Int64, split(line, ":")[2])
        elseif i == 5
            split_line = split(line, ",")
            for (i_element, element) in enumerate(split_line)
                monstre_a_voir[4, i_element] = parse(Int64, element)
            end
        elseif i == 5 + n + 1
            split_line = split(line, ",")
            for (i_element, element) in enumerate(split_line)
                monstre_a_voir[2, i_element] = parse(Int64, element)
            end
        elseif i != 1
            split_line = split(line, ",")
            monstre_a_voir[1, i-5] = parse(Int64, split_line[1])
            monstre_a_voir[3, i-5] = parse(Int64, last(split_line))
            for (i_element, element) in enumerate(split_line)
                if element == " r"
                    miroirs[i-5, i_element-1] = 0
                elseif element == " g"
                    miroirs[i-5, i_element-1] = 1
                elseif element == " a"
                    miroirs[i-5, i_element-1] = 2
                end
            end

        end

    end

    println(n)
    # Remplissage des matrices de visibilité
    V = matrice_vis(n, miroirs)

    return n, V, monstre_a_voir, nb_monstre, miroirs
end

#readInputFile("jeu1\\data\\instanceTest.txt")

function displayGrid(n::Int, monstre_a_voir::Array{Int,2}, nb_monstre::Array{Int,1}, miroir::Array{Int,2})

    println("Nombre de monstres")
    println("Fantôme : ", nb_monstre[1])
    println("Vampire : ", nb_monstre[2])
    println("Zombie : ", nb_monstre[3])
    println()


    print("   ")
    for k in 1:n
        print(" ", monstre_a_voir[4, k], "  ")
    end
    println()
    for i in 1:n
        print("  -")
        for tiret in 1:n
            print("----")
        end
        println()
        for j in 1:n
            if j == 1
                print(monstre_a_voir[1, i], " ")
            end
            print("| ")
            if miroir[i, j] == 1
                print("\\ ")
            elseif miroir[i, j] == 2
                print("/ ")
            else
                print("  ")
            end
            if j == n
                println("| ", monstre_a_voir[3, i])
            end
        end
    end
    print("  -")
    for tiret in 1:n
        print("----")
    end
    println()
    print("   ")
    for k in 1:n
        print(" ", monstre_a_voir[2, k], "  ")
    end
    println("\n")


end

#n = 4
#monstre_a_voir = [2 4 0 1; 1 0 3 2; 0 4 2 2; 2 3 1 1]
#nb_monstre = [1, 2, 6]
#miroir = [1 0 1 0; 0 0 0 0; 1 0 0 1; 0 1 1 1]

#displayGrid(n, monstre_a_voir, nb_monstre, miroir)

function displaySolution(n::Int, monstre_a_voir::Array{Int,2}, nb_monstre::Array{Int,1}, miroir::Array{Int,2}, sol::Array{Int,3})

    println("Nombre de monstres")
    println("Fantôme : ", nb_monstre[1])
    println("Vampire : ", nb_monstre[2])
    println("Zombie : ", nb_monstre[3])
    println()

    print("   ")
    for k in 1:n
        print(" ", monstre_a_voir[4, k], "  ")
    end
    println()
    for i in 1:n
        print("  -")
        for tiret in 1:n
            print("----")
        end
        println()
        for j in 1:n
            if j == 1
                print(monstre_a_voir[1, i], " ")
            end

            print("| ")

            if miroir[i, j] == 1
                print("\\ ")
            elseif miroir[i, j] == 2
                print("/ ")
            elseif sol[i, j, 1] == 1
                print("F ")
            elseif sol[i, j, 2] == 1
                print("V ")
            elseif sol[i, j, 3] == 1
                print("Z ")
            else
                print("  ")
            end

            if j == n
                println("| ", monstre_a_voir[3, i])
            end
        end
    end
    print("  -")
    for tiret in 1:n
        print("----")
    end
    println()
    print("   ")
    for k in 1:n
        print(" ", monstre_a_voir[2, k], "  ")
    end
    println("\n")


end


function displaySolution_file(fout::IOStream, n::Int, monstre_a_voir::Array{Int,2}, nb_monstre::Array{Int,1}, miroir::Array{Int,2}, sol::Array{Int,3})

    println(fout, "Nombre de monstres")
    println(fout, "Fantôme : ", nb_monstre[1])
    println(fout, "Vampire : ", nb_monstre[2])
    println(fout, "Zombie : ", nb_monstre[3])
    print(fout, "\n")

    print(fout, "   ")
    for k in 1:n
        print(fout, " ", monstre_a_voir[4, k], "  ")
    end
    println(fout,)
    for i in 1:n
        print(fout, "  -")
        for tiret in 1:n
            print(fout, "----")
        end
        print(fout, "\n")
        for j in 1:n
            if j == 1
                print(fout, monstre_a_voir[1, i], " ")
            end

            print(fout, "| ")

            if miroir[i, j] == 1
                print(fout, "\\ ")
            elseif miroir[i, j] == 2
                print(fout, "/ ")
            elseif sol[i, j, 1] == 1
                print(fout, "F ")
            elseif sol[i, j, 2] == 1
                print(fout, "V ")
            elseif sol[i, j, 3] == 1
                print(fout, "Z ")
            else
                print(fout, "  ")
            end

            if j == n
                println(fout, "| ", monstre_a_voir[3, i])
            end
        end
    end
    print(fout, "  -")
    for tiret in 1:n
        print(fout, "----")
    end
    print(fout, "\n")
    print(fout, "   ")
    for k in 1:n
        print(fout, " ", monstre_a_voir[2, k], "  ")
    end
    print(fout, "\n")

end


#= 
sol = Array{Int,3}(zeros(4, 4, 3))
sol[1, 4, 1] = 1
sol[3, 3, 2] = 1
sol[4, 1, 2] = 1
sol[1, 2, 3] = 1
sol[2, 1, 3] = 1
sol[2, 2, 3] = 1
sol[2, 3, 3] = 1
sol[2, 4, 3] = 1
sol[3, 2, 3] = 1
displaySolution(n, monstre_a_voir, nb_monstre, miroir, sol)
 =#

"""
Create a pdf file which contains a performance diagram associated to the results of the ../res folder
Display one curve for each subfolder of the ../res folder.

Arguments
- outputFile: path of the output file

Prerequisites:
- Each subfolder must contain text files
- Each text file correspond to the resolution of one instance
- Each text file contains a variable "solveTime" and a variable "isOptimal"
"""
function performanceDiagram(outputFile::String)

    resultFolder = "jeu1/res/"

    # Maximal number of files in a subfolder
    maxSize = 0

    # Number of subfolders
    subfolderCount = 0

    folderName = Array{String,1}()

    # For each file in the result folder
    for file in readdir(resultFolder)

        path = resultFolder * file

        # If it is a subfolder
        if isdir(path)

            folderName = vcat(folderName, file)

            subfolderCount += 1
            folderSize = size(readdir(path), 1)

            if maxSize < folderSize
                maxSize = folderSize
            end
        end
    end

    # Array that will contain the resolution times (one line for each subfolder)
    results = Array{Float64}(undef, subfolderCount, maxSize)

    for i in 1:subfolderCount
        for j in 1:maxSize
            results[i, j] = Inf
        end
    end

    folderCount = 0
    maxSolveTime = 0

    # For each subfolder
    for file in readdir(resultFolder)

        path = resultFolder * file

        if isdir(path)

            folderCount += 1
            fileCount = 0

            # For each text file in the subfolder
            for resultFile in filter(x -> occursin(".txt", x), readdir(path))

                fileCount += 1
                include(path * "/" * resultFile)

                if isOptimal
                    results[folderCount, fileCount] = solveTime

                    if solveTime > maxSolveTime
                        maxSolveTime = solveTime
                    end
                end
            end
        end
    end

    # Sort each row increasingly
    results = sort(results, dims=2)

    println("Max solve time: ", maxSolveTime)

    # For each line to plot
    for dim in 1:size(results, 1)

        x = Array{Float64,1}()
        y = Array{Float64,1}()

        # x coordinate of the previous inflexion point
        previousX = 0
        previousY = 0

        append!(x, previousX)
        append!(y, previousY)

        # Current position in the line
        currentId = 1

        # While the end of the line is not reached 
        while currentId != size(results, 2) && results[dim, currentId] != Inf

            # Number of elements which have the value previousX
            identicalValues = 1

            # While the value is the same
            while results[dim, currentId] == previousX && currentId <= size(results, 2)
                currentId += 1
                identicalValues += 1
            end

            # Add the proper points
            append!(x, previousX)
            append!(y, currentId - 1)

            if results[dim, currentId] != Inf
                append!(x, results[dim, currentId])
                append!(y, currentId - 1)
            end

            previousX = results[dim, currentId]
            previousY = currentId - 1

        end

        append!(x, maxSolveTime)
        append!(y, currentId - 1)

        # If it is the first subfolder
        if dim == 1

            # Draw a new plot
            plot(x, y, label=folderName[dim], legend=:bottomright, xaxis="Time (s)", yaxis="Solved instances", linewidth=3)

            # Otherwise 
        else
            # Add the new curve to the created plot
            savefig(plot!(x, y, label=folderName[dim], linewidth=3), outputFile)
        end
    end
end

"""
Create a latex file which contains an array with the results of the ../res folder.
Each subfolder of the ../res folder contains the results of a resolution method.

Arguments
- outputFile: path of the output file

Prerequisites:
- Each subfolder must contain text files
- Each text file correspond to the resolution of one instance
- Each text file contains a variable "solveTime" and a variable "isOptimal"
"""
function resultsArray(outputFile::String)

    resultFolder = "../res/"
    dataFolder = "../data/"

    # Maximal number of files in a subfolder
    maxSize = 0

    # Number of subfolders
    subfolderCount = 0

    # Open the latex output file
    fout = open(outputFile, "w")

    # Print the latex file output
    println(
        fout,
        raw"""\documentclass{article}

\usepackage[french]{babel}
\usepackage [utf8] {inputenc} % utf-8 / latin1 
\usepackage{multicol}

\setlength{\hoffset}{-18pt}
\setlength{\oddsidemargin}{0pt} % Marge gauche sur pages impaires
\setlength{\evensidemargin}{9pt} % Marge gauche sur pages paires
\setlength{\marginparwidth}{54pt} % Largeur de note dans la marge
\setlength{\textwidth}{481pt} % Largeur de la zone de texte (17cm)
\setlength{\voffset}{-18pt} % Bon pour DOS
\setlength{\marginparsep}{7pt} % Séparation de la marge
\setlength{\topmargin}{0pt} % Pas de marge en haut
\setlength{\headheight}{13pt} % Haut de page
\setlength{\headsep}{10pt} % Entre le haut de page et le texte
\setlength{\footskip}{27pt} % Bas de page + séparation
\setlength{\textheight}{668pt} % Hauteur de la zone de texte (25cm)

\begin{document}"""
    )

    header = raw"""
\begin{center}
\renewcommand{\arraystretch}{1.4} 
 \begin{tabular}{l"""

    # Name of the subfolder of the result folder (i.e, the resolution methods used)
    folderName = Array{String,1}()

    # List of all the instances solved by at least one resolution method
    solvedInstances = Array{String,1}()

    # For each file in the result folder
    for file in readdir(resultFolder)

        path = resultFolder * file

        # If it is a subfolder
        if isdir(path)

            # Add its name to the folder list
            folderName = vcat(folderName, file)

            subfolderCount += 1
            folderSize = size(readdir(path), 1)

            # Add all its files in the solvedInstances array
            for file2 in filter(x -> occursin(".txt", x), readdir(path))
                solvedInstances = vcat(solvedInstances, file2)
            end

            if maxSize < folderSize
                maxSize = folderSize
            end
        end
    end

    # Only keep one string for each instance solved
    unique(solvedInstances)

    # For each resolution method, add two columns in the array
    for folder in folderName
        header *= "rr"
    end

    header *= "}\n\t\\hline\n"

    # Create the header line which contains the methods name
    for folder in folderName
        header *= " & \\multicolumn{2}{c}{\\textbf{" * folder * "}}"
    end

    header *= "\\\\\n\\textbf{Instance} "

    # Create the second header line with the content of the result columns
    for folder in folderName
        header *= " & \\textbf{Temps (s)} & \\textbf{Optimal ?} "
    end

    header *= "\\\\\\hline\n"

    footer = raw"""\hline\end{tabular}
\end{center}

"""
    println(fout, header)

    # On each page an array will contain at most maxInstancePerPage lines with results
    maxInstancePerPage = 30
    id = 1

    # For each solved files
    for solvedInstance in solvedInstances

        # If we do not start a new array on a new page
        if rem(id, maxInstancePerPage) == 0
            println(fout, footer, "\\newpage")
            println(fout, header)
        end

        # Replace the potential underscores '_' in file names
        print(fout, replace(solvedInstance, "_" => "\\_"))

        # For each resolution method
        for method in folderName

            path = resultFolder * method * "/" * solvedInstance

            # If the instance has been solved by this method
            if isfile(path)

                include(path)

                println(fout, " & ", round(solveTime, digits=2), " & ")

                if isOptimal
                    println(fout, "\$\\times\$")
                end

                # If the instance has not been solved by this method
            else
                println(fout, " & - & - ")
            end
        end

        println(fout, "\\\\")

        id += 1
    end

    # Print the end of the latex file
    println(fout, footer)

    println(fout, "\\end{document}")

    close(fout)

end
