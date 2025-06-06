import  strutils
import  osproc
import  os


var versionnn = "v.2.0.2"


proc help() =
    echo """[094m
    Invokes the correct compiler for a given language using arguments optimized for performance over safety

    Arguments:                          Flags:
        spiritc     <target>.<ext>    | --verbose
                                      | --quiet         
                                      | -o          <target>

    
    Output is in the same directory as source unless -o is present. If -o and nothing following pwd is used

    Supported compilers:
        Nim
        Elixir
        Go
        Rust
        Julia   (via PackageCompiler.jl)    (experimental)

    Intended for standalone modules, not project directories

    Buerer, D. (2025). Spirit Compile (""" & versionnn & """) [Computer software]. https://doi.org/10.5281/zenodo.15605336 https://github.com/Mosstone/Spirit-Compile
    [0m"""

proc version() =
    echo """[094m
        """ & versionnn & """

    [0m"""

# Default flags
var quietitude = false
var verbosity = false
var destination = false

var outputflag = "null"

proc arguments() =

    if paramCount() == 0:
        help()
        quit(0)

    for arg in commandLineParams():

        case arg
            of "--help":
                help()
                quit(0)

            of "--version":
                version()
                quit(0)

            of "--quiet":
                quietitude = true
            of "-q":
                quietitude = true

            of "--verbose":
                verbosity = true
            of "-v":
                verbosity = true

            of "--output":
                destination = true
                outputflag = "--output"
            of "-o":
                destination = true
                outputflag = "-o"

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
    echo execProcess(brand)






##############################################################################################################################






#   Scans for the file extension
var language: string
var arg: string

if paramCount() > 0:
    if verbosity == true:  brand()
    arg = paramStr(1)
    language = arg.split('.')[^1]

else:
    echo "[094m    dfgsrgreg💥[0m"
    quit(1)






proc main() =
    case language
    
#<      Nim
        of "nim":
            
            proc build(): string =
                result = execProcess("CC=musl-gcc nim c -d:release --opt:speed --mm:orc --passC:-flto --passL:-flto --passL:-static " & arg)

            if not quietitude: stdout.write("\e[94m    Compiling Nim...\e[0m")
            if not quietitude: flushFile(stdout)
            if not verbosity:  discard build()
            if verbosity:      echo build()
            if not quietitude: stdout.write("\r\e[94m  ✓ Compiling Nim...done\e[0m\n")


#<      Elixir
        of "ex":

            proc build(): string =
                result = execProcess("elixirc " & arg)

            if not quietitude: stdout.write("\e[94m    Compiling Elixir...\e[0m")
            if not quietitude: flushFile(stdout)
            if not verbosity:  discard build()
            if verbosity:      echo build()
            if not quietitude: stdout.write("\r\e[94m  ✓ Compiling Elixir...done\e[0m\n")


#<      Go
        of "go":

            proc build(): string =
                result = execProcess("GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags='-s -w' " & arg)

            if not quietitude: stdout.write("\e[94m    Compiling Go...\e[0m")
            if not quietitude: flushFile(stdout)
            if not verbosity:  discard build()
            if verbosity:      echo build()
            if not quietitude: stdout.write("\r\e[94m  ✓ Compiling Go...done\e[0m\n")
            flushFile(stdout)


#<      Julia
        of "jl":
        #   DONT    TOUCH   ANYTHING
            proc build(): string =
                let uuid = execProcess("julia -e \"using UUIDs; println(UUIDs.uuid4())\"").strip()
                let script = """
                    uuid="""" & uuid & """"
                    arg="""" & arg & """"
                    echo "arg is $arg"
                    package=$(basename "$arg" .jl)
                    echo "package is $package"

                    nonce=$(openssl rand -hex 32)
                    path=/dev/shm/$nonce

                    mkdir -p "$path/staging/src"
                    cp "$(pwd)/$arg" "$path/staging/src/$package-body.jl"
                    cd "$path/staging"



                    {
                        echo "module $package"
                        echo "include(\"$package-body.jl\")"
                        echo "function julia_main(); main(); end"
                        echo "end"
                    } > "$path/staging/src/$package.jl"

                    echo "using $package; $package.julia_main()" > "$path/staging/precompile_script.jl"

                    cat <<EOF > "$path/staging/Project.toml"
name = "$package"
uuid = "$uuid"
authors = ["$USER"]
version = "0.1.0"
EOF

                    julia --project=. -e "using Pkg; Pkg.add(\"PackageCompiler\"); using PackageCompiler; create_app(\".\", \"build/\", precompile_execution_file=\"precompile_script.jl\")"

                    "$path/staging/build/bin/$package"

                    # rm -fr "$path"
                    """
                echo execProcess("bash -c '" & script & "'")

            if not quietitude: stdout.write("\e[94m    Compiling Julia...\e[0m")
            if not quietitude: flushFile(stdout)
            if not verbosity:  discard build()
            if verbosity:      echo build()
            if not quietitude: stdout.write("\r\e[94m  ✓ Compiling Julia...done\e[0m\n")


#<      Rust
        of "rs":

            proc build(): string =
                result = execProcess("rustc -C opt-level=3 -C target-cpu=native file.rs " & arg)

            if not quietitude: stdout.write("\e[94m    Compiling Rust...\e[0m")
            if not quietitude: flushFile(stdout)
            if not verbosity:  discard build()
            if verbosity:      echo build()
            if not quietitude: stdout.write("\r\e[94m  ✓ Compiling Rust...done\e[0m\n")


        else:
            echo "[094m    Unknown extension...\n[0m"
            quit(1)

#<  Moves the compiled file is -o is detected
    if destination:

        proc loc(): string =

            var mut: string = paramStr(commandLineParams().find("-o") + 2)
            var loc = ""
            try:
                loc = expandFilename(mut)
            except:
                echo "\n    [095m>><<[094m " & mut & " does not exist or is not a directory[0m"
            return loc


        var script: string = """
            src="""" & paramStr(1).rsplit('.', 1)[0] & """"
            loc="""" & loc() & """"

            mv $src $loc

        """
        echo execProcess("bash -c '" & script & "'")

main()