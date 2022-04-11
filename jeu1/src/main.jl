include("io.jl")
include("resolution.jl")
include("generation.jl")

generateDataSet()
solveDataSet()

performanceDiagram("../res/diagramme.pdf")
resultsArray("../res/Array.tex")



#n, V, monstre_a_voir, nb_monstre, miroir = readInputFile("jeu1/data/inst_t5_dm0.2_dmaigue0.3_3.txt")
#displayGrid(n, monstre_a_voir, nb_monstre, miroir)
#found, duree, sol = cplexSolve("jeu1/data/inst_t5_dm0.2_dmaigue0.3_3.txt")
#displaySolution(n, monstre_a_voir, nb_monstre, miroir, sol)
