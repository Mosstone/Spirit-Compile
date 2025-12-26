import  strutils
import  osproc
import  os
import  threadpool


var version = "v.2.3.3"

proc printHelp() =
    echo """[094m
    Invokes the correct compiler for a given language using arguments optimized for performance over safety

    Arguments:                          Flags:
        spiritc     <target>.<ext>    | --verbose
                                      | --quiet         
                                      | -o          <target>
                                      | --project

    
    Output is in the same directory as source unless -o is present. If -o and nothing following pwd is used

    Supported compilers:
        Nim
        Elixir
        Go
        Rust
        Julia







    Buerer, D. (2025). Spirit Compile (""" & version & """) [Computer software]. https://doi.org/10.5281/zenodo.15605336 https://github.com/Mosstone/Spirit-Compile
    [0m"""

proc printVersion() =
    echo """[094m
        """ & version & """

    [0m"""

# Default flags
var quietitude = false
var verbose = false
var destination = false
var mode = "null"

var outputflag = "null"

proc arguments() =

    if paramCount() == 0:
        printHelp()
        quit(0)

    for arg in commandLineParams():

        case arg
            of "--help":
                printVersion()
                printHelp()
                quit(0)

            of "--version":
                printVersion()
                quit(0)

            of "--quiet":
                quietitude = true
            of "-q":
                quietitude = true

            of "--verbose":
                verbose = true
            of "-v":
                verbose = true

            of "--output":
                destination = true
                outputflag = "--output"
            of "-o":
                destination = true
                outputflag = "-o"

            of "--project":
                mode = "project"

            of "--app":
                mode = "app"

            else:
                discard
arguments()






##############################################################################################################################






proc brand() =
    let brand = r"""
grep -q \"虚\" /dev/shm/.imNotHere 2> /dev/null || cat <<-'EOF' > /dev/shm/.imNotHere 2> /dev/null

[094m                           .-*%%%*=:.     :.            .            .                .                                   .                                      .                                               
[094m                      :#虚虚虚虚虚虚虚虚虚虚%###%=  _ .      .                  .                      .                                                                                            .            
[094m                  .=虚虚虚虚虚虚虚%#*****-   .                                      .                                                                                   .                               .        
[094m        .  .     -虚虚虚虚虚虚%-                 .        .                                                                              .              .                                                        
[094m             .  =虚虚虚虚虚虚%=      .       .                   .          .                                .                                                                          .                        
[094m              .-%虚虚虚虚虚虚虚*.                                                 .                                          .                                                                                   
[094m      .  ...:*虚虚虚虚虚虚虚虚虚%-  .      .                                                  .                                                                                                                  
[094m        .+虚虚虚虚虚虚虚虚虚虚虚%+.             .   .        .                                                                                           .                                              .        
[094m       =虚虚虚虚虚虚虚虚虚虚虚虚*:                                     .                                                           .                                                 .                           
[094m      -虚虚虚虚虚虚虚虚虚虚虚+         .  .     .                                                                                                                       .                                        
[094m      #虚虚虚虚虚虚虚虚虚*.   .         .     .                                .            .                .                                         .                                                         
[094m      虚虚虚虚虚虚虚虚%*..:=-..                                                 .                                                                                                                                
[094m      %虚虚虚虚虚虚%--  #%%%*:   .   .  .          .                  .                                                                                                                                          
[094m      *虚虚虚虚虚*:  *虚虚虚%=.      :#=                    .                             .                                   .                                  .                                               
[094m      :虚虚虚虚虚#:*虚虚虚虚虚虚虚-:#%%%虚虚:                                                       .                                          .                                                                 
[094m       =虚虚虚虚%:%虚虚虚虚虚虚虚虚+:#虚虚#                       .               .                                                                                                                              
[094m        :%虚虚%+:#虚虚虚虚虚虚虚虚虚=-%虚虚虚#.                                                                                                                                                                  
[094m         .+%虚虚#.=虚虚虚虚虚虚虚虚#:+%虚%=            .                                                                                                                                                         
[094m           .-*%虚*.:%虚虚虚虚虚虚*:=%虚%=.                                                                                                                                                                       
[094m     .      .-=. :+#%虚虚虚%*=..=+=:                                                                                                                                                                             
	EOF

	grep -q \"imNotHere\" /dev/shm/.imAlsoNotHere 2>/dev/null || cat <<-EOF > /dev/shm/.imAlsoNotHere
		cat /dev/shm/.imNotHere
	EOF


	awk -v cols=$(($(tput cols)-8)) '{print substr($0, 1, cols)}' /dev/shm/.imNotHere


	cat <<< [0m
    """
    discard execCmd(brand)


    #   Snake Mono
const animationSnakeMono = [" ⠁", " ⠉", " ⠙", " ⠛", " ⠟", " ⠿", " ⠾", " ⠶", " ⠦", " ⠤", " ⠠", " ⠡"]; discard animationSnakeMono
    #   Snake
const animationSnake = ["⠉⠀", "⠉⠁", "⠉⠉", "⠋⠉", "⠛⠉", "⠛⠋", "⠛⠛", "⠛⠻", "⠛⠿", "⠻⠿", "⠿⠿", "⠾⠿", "⠶⠿", "⠶⠾", "⠶⠶", "⠶⠦", "⠶⠤", "⠦⠤", "⠤⠤", "⠠⠤", " ⠤", "⠁⠠"]; discard animationSnake
    #   Rotary Mono
const animationRotary = [" ⠋", " ⠙", " ⠹", " ⠸", " ⠼", " ⠴", " ⠦", " ⠧", " ⠇", " ⠏"]; discard animationRotary
    #   Rotary Carve
const animationCarve = ["⠊ ", "⠉⠉", " ⠑", " ⠸", " ⠔", "⠤⠤", "⠢ ", "⠇ "]; discard animationCarve
    #   Rotary Banner
const animationBanner = ["⠟⠁", "⠛⠛", "⠈⠻", " ⠿", "⠠⠾", "⠶⠶", "⠷⠄", "⠿ "]; discard animationBanner
    #   Shiny
const animationShiny = ["⠋⠴", "⠟⠡", "⠿⠟", "⠾⠿", "⠴⠿", "⠡⠾"]; discard animationShiny
    #   Bloom
const animationBloom = ["⠰⠆", "⠪⠕", "⠅⠨", "⠆⠰", "⠤⠤", "⠴⠦"]; discard animationBloom


#  	⠁	⠂	⠃	⠄	⠅	⠆	⠇	⠈	⠉	⠊	⠋	⠌	⠍	⠎	⠏
# ⠐	⠑	⠒	⠓	⠔	⠕	⠖	⠗	⠘	⠙	⠚	⠛	⠜	⠝	⠞	⠟
# ⠠	⠡	⠢	⠣	⠤	⠥	⠦	⠧	⠨	⠩	⠪	⠫	⠬	⠭	⠮	⠯
# ⠰	⠱	⠲	⠳	⠴	⠵	⠶	⠷	⠸	⠹	⠺	⠻	⠼	⠽	⠾	⠿

var spinning = false
var spinnerThread: Thread[string]

proc spinnerLoop(name: string) {.thread, gcsafe.} =
    var i = 0
    while spinning:
        stdout.write("\r\e[94m " & animationBloom[i mod animationBloom.len] & " Compiling " & name & "...\e[0m")
        flushFile(stdout)
        i.inc
        sleep(100)  # 100 ms between frames

proc startSpinner(name: string) =
    spinning = true
    createThread(spinnerThread, spinnerLoop, name)

proc stopSpinner(name: string) =
    spinning = false
    joinThread(spinnerThread)
    stdout.write("\r\e[94m  ✓ Compiling " & name & "...done\e[0m\n")
    flushFile(stdout)


##############################################################################################################################






#   Scans for the file extension
var language: string
var arg: string

if paramCount() > 0:
    if verbose == true:  brand()
    arg = paramStr(1)
    language = arg.split('.')[^1]

else:
    echo "[094m    No arguments passed...[0m"
    quit(1)






proc main() =
    case language
    
#<      Nim
        of "nim":
            # name = "Nim"
            proc build(): string =
                result = execProcess("CC=musl-gcc nim c -d:release --opt:speed --mm:orc --passC:-flto --passL:-flto --passL:-static --passL:-L/usr/x86_64-linux-musl/lib64 " & arg)

            if not quietitude: startSpinner("Nim")
            if not quietitude: flushFile(stdout)
            if not verbose:  discard build()
            if verbose:      echo build()
            if not quietitude: stopSpinner("Nim")


#<      Elixir
        of "ex":

            proc build(): string =
                result = execProcess("elixirc " & arg)

            if not quietitude: startSpinner("Elixir")
            if not quietitude: flushFile(stdout)
            if not verbose:  discard build()
            if verbose:      echo build()
            if not quietitude: stopSpinner("Elixir")


#<      Go
        of "go":

            proc build(): string =
                result = execProcess("GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -ldflags='-s -w' " & arg)

            if not quietitude: startSpinner("Go")
            if not quietitude: flushFile(stdout)
            if not verbose:  discard build()
            if verbose:      echo build()
            if not quietitude: stopSpinner("Go")


#<      Julia
        of "jl":

        #   Default mode reassigment
            if mode == "null":
                mode = "project"
                if verbose: echo "[94m    Defaulting to [95m" & mode & "[94m mode[0m"


        #   Redefine the staging area to any path, default is /dev/shm/
            proc loc(): string =

                var mut: string = paramStr(commandLineParams().find("--prefix") + 2)
                var loc = ""
                try:
                    loc = expandFilename(mut)
                except:
                    echo "\n    [031m    >><<[095m " & mut & "[94m does not exist or is not a directory[0m"
                return loc
            
            var prefix = "/dev/shm"
            if "--prefix" in commandLineParams():
                prefix = loc()

        #   Info
            if not quietitude: discard execCmd("""cat <<-EOF | ../.resource/annotate --blue 
				Creating a precompile image of """ & arg & """ in the [95m""" & prefix & """[94m directory

				This will be build in a staging/ folder in that location, and then moved to pwd where
				this command was used from along with a symbolic link to the executable file. This is
				suitable both for direct invocation or importing into a larger julia module

				If memory resources are an issue, specify a different location with [95m--prefix <folder>[94m

				Use --verbose to view the build process, and use --quiet to suppress all output. This
				orchestrator should yield a fully functional 
			EOF""")

#<          if --project is used, uses create_app which can be used as a base for a larger julia project. Use Recompile.jl to 
            proc buildEnv(): string =

            #   Get the UUID for later
                let uuid = execProcess("julia -e \"using UUIDs; println(UUIDs.uuid4())\"").strip()

            #   Use bash to manually create the environment in the staging directory
                let script = """

                    uuid="""" & uuid & """"
                    arg="""" & paramStr(1) & """"
                    here="""" & getAppDir() & """"
                    prefix="""" & prefix & """"
                    mode="""" & mode & """"
                    nonce=".$(openssl rand -hex 32).atom"
                    path=$prefix/$nonce                #   Collision resistant tmpfs to atomically build in

                    mod=$(basename "${arg::-3}")_launch.jl
                    modBase="${arg::-3}"
                    modEnv="$modBase"_env


                    if ! grep -E "^function main\(" "$arg" &>/dev/null; then
                        echo "[31m    >><<[94m Sourced julia file [95m$arg[94m needs a [95mmain()[94m function for [95mPackageCompiler.jl[94m to work"
                        exit 1
                    fi


                #   Create minimal atomic env in mem
                    mkdir -p "$path/staging/src"
                    cp "$(realpath $arg)" "$path/staging/src/$arg"
                    prevdir="$(realpath .)"
                    lithos="$(realpath $path/staging/src/$arg)"
                    cd "$path/staging"


#<                  Dot Imports
                    . $here/.resource/Functions.sh
                    #   provides:
                    #       Paq()           Get the packages in a julia file
                    #       Paquiet()       Same thing but with no error out
                    #       getUUID()       Get UUID list Project.toml needs
                    #       getNomEtUUIDs() Same thing, joined and formatted

                    . $here/.resource/imply
                    #   provides:
                    #       imply()         Pull files and expands variables

                    . $here/.resource/annotate
                    #   provides:
                    #       annotate()      Create a box bracket around text
                    #                       provided from stdin and print it
                    #                       to cli formatted and with colour 




                #   Converts the target .jl file into a module so that it can use "top" level imports without refactoring
                    echo -e "#!/usr/bin/env julia\n\nmodule lithos\n\n" >> $path/tmp
                    cat $lithos >> $path/tmp
                    echo -e "\n\nend\n" >> $path/tmp
                    mv $path/tmp $lithos



#<                  *_launch.jl
                    export path=$path
                    export mod=$mod
                    export mod3=${mod::-3}
                    export arg="""" & paramStr(1) & """"
                    export hasMain=$hasMain

                    imply $(realpath "$prevdir/.assets/_launch.jl") > "$path/staging/src/$mod"   #   Provided by .resource/Functions.sh
                    annotate [95m"$mod" --blue <<< "$(cat "$path/staging/src/$mod")"; echo -e "\n"

#<                  precompile.jl
                    cat <<-EOF > "$path/staging/precompile.jl"
						using ${mod::-3}


						${mod::-3}.julia_main()
					EOF


#<                  Project.toml
                    cat <<-EOF > "$path/staging/Project.toml"
						name = "${mod::-3}"
						uuid = "$uuid"
						authors = ["Daniel Buerer"]
						version = "1.0.2"

						[deps]
						PackageCompiler = "9b87118b-4619-50d2-8e1e-99f35a4d4d9d"
						$(getNomEtUUIDs "$path/staging/src/$arg")

					EOF

                    annotate [95m"Project.toml" --blue <<< "$(cat "$path/staging/Project.toml")"
                    echo ""


#<                  instantiate.jl
                    # export path=$path
                    export modBase=$modBase
                    export modEnv=$modEnv

                    imply $(realpath "$prevdir/.assets/instantiate.jl") > "$path/staging/instantiate.jl"

                    annotate [95m"instantiate.jl" --blue <<< "$(cat "$path/staging/instantiate.jl")"


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

								create_app(
                                    ".",
                                    "build/",
                                    include_transitive_dependencies = true,
                                    precompile_execution_file="precompile.jl",
                                    force=true
                                )
					EOF
                        ;;

                        project)
                        ;;
                    esac


                #   Moves the now complete environment to cwd, creates a symlink to the correct file for convenience, and verifies the path
                    mkdir -p $(realpath "$prevdir")/"$modEnv"/
                    cp -a $(realpath "$path"/staging) $(realpath "$prevdir")/"$modEnv"/
                    ln -s $(realpath "$prevdir"/"$modEnv"/staging/src/"$mod") $(realpath "$prevdir"/"$modBase")
                    cd $prevdir
                    chmod +x "$prevdir"/"$modEnv"/staging/instantiate.jl
                    chmod +x "$prevdir"/"$modEnv"/staging/src/*
                    chmod +x $(realpath "$prevdir"/"$modBase")
                    "$prevdir"/"$modEnv"/staging/instantiate.jl
                    ls -l $(realpath "$prevdir"/"$modBase") | grep "$(realpath "$prevdir"/"$modBase")" || echo "[31m    >><<[95m Link broken[0m"


                #   Cleanup
                    rm -fr $path
                    exit 0
                    """


            #   Executes the above bash logic defined as "script". The difference here is that in nim execCmd() prints the command output
            #   line by line even if the result is discarded, but execProcess() only echoes or discard the return once it terminates
                if not verbose:
                    echo execProcess("bash -c '" & script & "'")
                if verbose:
                    echo "[94m\n"
                    echo execCmd("bash -c '" & script & "'")
                    echo "[0m"

            if not  verbose:
                if not quietitude:  startSpinner("Julia")
            if not   quietitude:    flushFile(stdout)

        #   If the --project flag is not included, also build with create_app() for now
            if mode == "project":
                if not quietitude:  discard execCmd("""echo "Building a full project environment with PackageCompiler.create_app() with compiled dependencies" | ../.resource/annotate [95m"Project Mode" --blue""")
                if not  verbose:    discard buildEnv()
                if      verbose:    echo    buildEnv()

            if mode == "project":
                if not quietitude:  discard execCmd("""echo "Using create_app() to precompile. This is an official preset for create_sysimage() using conservative, generic optimizations" | ../.resource/annotate [95m"App Mode" --blue""")
                if not  verbose:    discard buildEnv()
                if      verbose:    echo    buildEnv()

            if not quietitude:
                stopSpinner("Julia")


#<      Rust
        of "rs":

            proc build(): string =
                result = execProcess("rustc -C opt-level=3 -C target-cpu=native file.rs " & arg)

            if not  quietitude: startSpinner("Rust")
            if not  quietitude: flushFile(stdout)
            if not  verbose:    discard build()
            if      verbose:    echo build()
            if not  quietitude: stopSpinner("Rust")


        else:
            echo "[094m    Unknown extension...\n[0m"
            quit(1)

#<  if -o is passed as an argument, moves the compiled output to the location passed in the following argument
    if destination:

        proc loc(): string =

            var mut: string = paramStr(commandLineParams().find("-o") + 2)
            var loc = ""
            try:
                loc = expandFilename(mut)
            except:
                echo "\n    [031m    >><<[095m " & mut & "[94m does not exist or is not a directory[0m"
            return loc


        var script: string = """
            src="""" & paramStr(1).rsplit('.', 1)[0] & """"
            loc="""" & loc() & """"

            mv $src $loc

        """
        echo execProcess("bash -c '" & script & "'")

main()
