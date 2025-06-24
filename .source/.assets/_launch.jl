#!/usr/bin/env julia

module $mod3

source = @__FILE__
staged = "$path/staging/src/$mod"

function picture()::Bool
    # if source == staged
    #     println("[94msource image is " * source)
    #     println("[94mstaged image is " * staged)
    #     println("[94m    They'\''re the [95msame picture[94m")
    # end
    return source == staged
end

if isfile(source)

    if picture(); print("[94m    Staged file: "); print(@__DIR__); println("/[95m$arg[94m"); end

    path = joinpath(dirname(realpath(source)), "$arg")
    include(path)
else
    println("File not found in staging directory")
end
using .lithos

function julia_main()::Cint
    return lithos.main()
    return 0
end


if PROGRAM_FILE != "-"
    if realpath(PROGRAM_FILE) == path
        julia_main()
    end
end

end