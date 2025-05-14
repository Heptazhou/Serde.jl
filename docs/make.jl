using Serde
using Documenter

DocMeta.setdocmeta!(Serde, :DocTestSetup, :(using Serde); recursive = true)

makedocs(;
    modules = [Serde],
    sitename = "Serde.jl",
    format = Documenter.HTML(),
    pages = [
        "Home" => "index.md",
        "API Reference" => [
            "pages/json.md",
            "pages/toml.md",
            "pages/utils.md",
        ],
        "For Developers" => ["pages/extended_ser.md", "pages/extended_de.md"],
    ],
    warnonly = [:doctest, :missing_docs],
)

deploydocs(;
    repo = "github.com/Heptazhou/Serde.jl",
    devbranch = "master",
    devurl = "latest",
    forcepush = true,
    push_preview = true,
)
