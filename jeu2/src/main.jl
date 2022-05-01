
include("generation.jl")
include("io.jl")
include("resolution.jl")

n, I, J, Pa = readInputFile("jeu2/data/instanceTestVnr.txt")
displayGrid(n, I, J, Pa)
found, duree, sol = cplexSolve("jeu2/data/instanceTestVnr.txt")
displaySolution(n, I, J, sol)

n, I, J, Pa = readInputFile("jeu2/data/inst_L9_C12_tzone4_dpal0.4_3.txt")
displayGrid(n, I, J, Pa)
found, duree, sol = cplexSolve("jeu2/data/inst_L9_C12_tzone4_dpal0.4_3.txt")
displaySolution(n, I, J, sol)


generateDataSet()
solveDataSet()