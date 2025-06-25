





mode='project'

#   The julia commands to run using the environment built above

case $mode in

    app)
julia --project=$path/staging <<-EOF
    using Pkg; 
    Pkg.activate(@__DIR__); 
    $(Paquiet $arg)
    Pkg.add("PackageCompiler"); 
    Pkg.instantiate(); Pkg.resolve(); 
    using PackageCompiler; 

    create_app(".", "build/", include_transitive_dependencies = true, precompile_execution_file="precompile.jl", force=true)
EOF
    ;;

    project)
        echo project
    ;;
esac


































































