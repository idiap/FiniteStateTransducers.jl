using Documenter #, DocumenterLaTeX
using FiniteStateTransducers

makedocs(
    sitename = "FiniteStateTransducers",
    format = [Documenter.HTML()],#, DocumenterLaTeX.LaTeX()],
    authors = "Niccolò Antonello",
    modules = [FiniteStateTransducers],
    pages = [
        "Home" => "index.md",
        "Introduction" => "1_intro.md",
        "Weights" => "2_semirings.md",
        "Contructing WFSTs" => "3_wfsts.md",
        "Algorithms" => "4_algorithms.md",
        "I/O" => "5_io.md",
    ],
    doctest=false,
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/idiap/FiniteStateTransducers.jl.git",
    devbranch = "main",
)
