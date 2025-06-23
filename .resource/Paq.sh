#!/usr/bin/env bash


getPaquet() {

#   Does the file exist or cap
    if ! ls $1 &>/dev/null; then
        if ! [[ $2 =~ '--quiet' ]]; then
            echo -e "\e[94m    >><< File $1 does not exist\e[0m"
        fi
        return 1
    fi


#   Are packages being referenced
    if ! grep 'using' $1 &>/dev/null; then
        if ! [[ $2 =~ '--quiet' ]]; then
            echo -e "\e[94m    >><< No package names to extract\e[0m"
        fi
    fi

    grep '^using ' $1 2>/dev/null | awk '{print $2}'

}
    
Paq() {

    local fichier="$(realpath $1)"


    local liste=$(getPaquet $fichier)
    if [[ $liste != *'>><<'* ]]; then
        for paquet in $liste; do
            local commande+=" Pkg.add(\"$paquet\"); "
        done
    else        #   if $liste is actually an error message with the >><< tag, print it to terminal instead of trying to use it
        echo $liste
    fi

    echo $commande

}


#   Active filtering of errors. This is theoretically more powerful than Paq --quiet because it filters all errors
#   with the >><< tag if such errors are ever added which are not emitted by $commande
Paquiet() {

    commande=$(Paq $1)
    
    if ! [[ $commande == *'>><<'* ]]; then
        echo $commande
    fi
}


getUUID() {

    uuid=$(julia -e "

using Pkg

for (uuid, pkg) in Pkg.dependencies()
    if pkg.name == \"$1\"
    println(uuid)
end

end

    ")

    if ! [[ ${#uuid} == 0 ]]; then
        echo -e "\e[94m$uuid\e[0m"
    else
        echo -e "\e[94m#    >><< Package $1 not installed\e[0m"
    fi

}


getNomEtUUIDs() {   #   Scans the file for 'using *', returns every uuid formatted 

    minilith() {

        #   reuse the existing $path, otherwise create one
        if [[ $path == '' ]]; then
            path=/dev/shm/.$(openssl rand -hex 32)
        fi

        zone="$path"/Paq.Hacer.tmp
        mkdir -p $(dirname $zone)
        touch $zone

        for p in $(getPaquet $1 --quiet); do

            uuid=$(julia -e "

    using Pkg

    for (uuid, pkg) in Pkg.dependencies()
        if pkg.name == \"$p\"
        println(uuid)
    end

    end

            ")

            echo "$(cat <<< "$p = \"$uuid\"" >> $zone)"

        done

        awk -i inplace 'NF' $zone
        cat $zone | cat
        rm $zone
    }

    cat <<< $(minilith $@ | awk 'NF')

}


listUUID() {

    #   reuse the existing $path, otherwise create one
    if [[ $path == '' ]]; then
        path=/dev/shm/.$(openssl rand -hex 32)
    fi

    zone="$path"/Paq.listUUID.tmp
    mkdir -p $(dirname $zone)
    touch $zone
    
    for p in $(getPaquet $1); do
        cat <<< $(getUUID $p) >> $zone
    done

    cat $zone
    rm $zone

}
