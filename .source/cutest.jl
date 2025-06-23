#!/usr/bin/env julia


using CUDA


struct data

    arrayident::String
    arraystart::Int
    arrayfinal::Int

end

function monolith()

    print("[94m    Turning [1, 2] into [2, 4] using cuda...")
    p = data("Parameter", 1, 2)
    print("[95m    " * string(Array(CuArray(p.arraystart:p.arrayfinal) * 2)))
    print("[0m\n")

end                 #   This is called when you launch using the *_launch.jl
                    #   either directly or using the wrapper, created at cwd
function main()     #<  The entire file gets turned into a module and called
                    #   that way to execute the code, without altering logic
    monolith()
                    #   Not using the main causes PackageCompiler to execute
end                 #   the code multiple times during the compile which may
                    #   slow down or interfere with the compile process, but
                    #   still works, as long as main() appears in the script
                    #   somewhere. Without any main() at all the build fails

                    #   Internally, this file is converted to a module which
                    #   is then used locally using a user facing module. The
                    #   internal 'lithos' module is only intended to be used
                    #   by the compile logic. There is a second module named
                    #   by the base name of the target .jl file, and defined
                    #   in the _launch.jl in the *_env/staging/src directory

                    #   So in this example, "spiritc cutest.jl" to build the
                    #   env and then there are a few ways to run the CuArray

                    #       ./cutest    #   use the portable wrapper created

                    #       julia -e ' \
                    #             using cutest_launch; \
                    #             cutest_launch.julia_main()'

main()