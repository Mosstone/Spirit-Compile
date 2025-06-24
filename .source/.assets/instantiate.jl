#!/usr/bin/env julia

using PackageCompiler

create_sysimage(
    ["$modBase"], 
    sysimage_path="$modEnv/build/lib/Project.so";
    project = normpath(@__DIR__),
    incremental=true
)