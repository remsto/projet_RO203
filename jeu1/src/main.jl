include("io.jl")
include("resolution.jl")
include("generation.jl")

generateDataSet()
solveDataSet()

performanceDiagram("jeu1/res/diagramme2.pdf")
resultsArray("jeu1/res/Array2.tex")
performanceDiagram_tempsfonctiontaille("jeu1/res/diagramme_tempstaille.pdf")



#n, V, monstre_a_voir, nb_monstre, miroir = readInputFile("jeu1/data/inst_t5_dm0.2_dmaigue0.3_3.txt")
#displayGrid(n, monstre_a_voir, nb_monstre, miroir)
#found, duree, sol = cplexSolve("jeu1/data/inst_t5_dm0.2_dmaigue0.3_3.txt")
#displaySolution(n, monstre_a_voir, nb_monstre, miroir, sol)
