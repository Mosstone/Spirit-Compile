#!/usr/bin/env julia


using CUDA

struct data

    arrayident::String
    arraystart::Int
    arrayfinal::Int

end

function monolith()

    p = data("Parameter", 1, 2)
    
    print("[95m    " * string(Array(CuArray(p.arraystart:p.arrayfinal) * 2)))

end

function notmain()

    print("[94m    Turning [1, 2] into [2, 4] using cuda...")
    monolith()
    print("[0m\n")

end


notmain()
