#!/usr/bin/env julia


#   This file can be modified as needed, and it will be used in the compile process
#   although any changes are very likely to break everything. There is an immutable
#   and hidden ._launch.bak folder if that does happen, use cp ._launch.bak _launch
#   to restore the not broken version. Note that this file is actually the template
#   imported by the meta in the main process, so the $sigils expand at compile time


module $mod3

source = @__FILE__
staged = "$path/staging/src/$mod"

#   Checks for whether the source is the original staging prefix. If it is then the 
#   system is in first time setup, otherwise it knows to execute the script instead
#   skipping the noisy or useless steps, and then this file can be reused saving on
#   the technical debt of dynamically managing different files depending on context
function picture()::Bool
    if source == staged
        println("[94msource image is " * source)
        println("[94mstaged image is " * staged)
        println("[95m    They\'re the same picture\n[94m")
    end
    return source == staged
end

if isfile(source)

    if picture(); print("[94mStaged file: "); print(@__DIR__); println("/[95m$arg[94m"); end

    path = joinpath(dirname(realpath(source)), "$arg")
    include(path)
else
    println("File not found in staging directory")
end
using .lithos


#   Entrypoint into $arg, common across compile modes. Called by certain mechanisms
#   depending on the compile mode, or indirectly used by the logic below. Also used
#   if built as a library, so functionality should be similar across contexts
function julia_main()::Cint
    
    try
        thread = lithos.main()
        return Int32(thread)    #   return the error code received from lithos
    catch 
        return Int32(1)     #   coerce any non success null to a C readable err = 1
    end

    return 0
end


#   Check if this is sourced as a sdin copy rather than the file, only executing if
#   it is a file. Otherwise the program would run at unintended times
if PROGRAM_FILE != "-"
    if realpath(PROGRAM_FILE) == path
        julia_main()
    end
end

end


#=#  Canvas


=## [0m
