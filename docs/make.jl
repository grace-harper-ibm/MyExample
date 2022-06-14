using MyExample
using Documenter

DocMeta.setdocmeta!(MyExample, :DocTestSetup, :(using MyExample); recursive=true)

makedocs(;
    modules=[MyExample],
    authors="Grace Harper",
    repo="https://github.com/grace-harper-ibm/MyExample.jl/blob/{commit}{path}#{line}",
    sitename="MyExample.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://grace-harper-ibm.github.io/MyExample.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/grace-harper-ibm/MyExample.jl",
    devbranch="main",
)
