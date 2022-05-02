
include("generation.jl")
include("io.jl")
include("resolution.jl")

n, I, J, Pa = readInputFile("jeu2/data/instanceTest.txt")
displayGrid(n, I, J, Pa)
found, duree, sol = cplexSolve("jeu2/data/instanceTest.txt")
displaySolution(n, I, J, sol)

n, I, J, Pa = readInputFile("jeu2/data/inst_L_C7_tzone7_dpal0.1_3.txt")
displayGrid(n, I, J, Pa)
found, duree, sol = cplexSolve("jeu2/data/inst_L10_C10_tzone10_dpal0.3_4.txt")
displaySolution(n, I, J, sol)



generateDataSet()
solveDataSet()

generateInstance(10, 10, 10, 0.3, 4)


performanceDiagram("jeu2/res/diagramme4a10.pdf")
resultsArray("jeu2/res/Array4a10.tex")
graph_temps_facteur("jeu2/res/diagramme_tempstaille_4a8.pdf", "jeu2/res/diagramme_tempstaille_4a8.pdf")

using CairoMakie


xs = [1, 2, 3, 1, 2, 3, 1, 2, 3]
ys = [1, 1, 1, 2, 2, 2, 3, 3, 3]
zs = [1, 2, 3, 4, 5, 6, 7, 8, NaN]

CairoMakie.heatmap(xs, ys, zs)
