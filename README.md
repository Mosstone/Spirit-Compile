    Invokes the correct compiler for a given language using arguments optimized for performance over safety

    Supported compilers:
        Nim
        Elixir
        Go
        Rust
        Julia   (via PackageCompiler.jl)

    The compile language is detected using the file extension which Spirit assumes will always be consistent
    
    Notably, spiritc targetting a .jl file is able to use PackageCompile.jl to compile any one module into a
    compiled binary. This is done by creating a valid, ephemeral environment in memory, populating it with a
    default module and set of identifiers, compiling it in that fashion, and then copying it back to the pwd
    it started in before closing the ephemeral environment. The result is a standalone julia module which is
    able to use and execute packages and manipulate data at low latency, marginally suitable for backend but
    providing the extensive scientific and machine learning libraries to applications which would require it


developed using the following:
    go version go1.23.9 linux/amd64
    6.14.6-200.fc41.x86_64
        fedora 41, current release

Buerer, D. (2025). Spirit Compile (Version 1.0.0) [Computer software]. https://doi.org/10.5281/zenodo.1560533
