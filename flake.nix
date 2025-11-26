{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        default ? ( path : value : builtins.throw "The definition at ${ builtins.toJSON path } is invalid.  It is of type ${ builtins.typeOf value }.  It is ${ if builtins.any ( t : t == builtins.typeOf value ) [ "bool" "float" "int" "null" "path" "string" ] then builtins.toJSON value else "unstringable" }." ) ,
                        unknown ? ( path : value : builtins.throw "The definition at ${ builtins.toJSON path } is of unknown type.  It is of type ${ builtins.typeOf value }.  We only know about bool, float, int, lambda, list, null, path, set, string." )
                    } :
                        let
                            implementation =
                                {
                                   bool ? default ,
                                   float ? default ,
                                   int ? default ,
                                   lambda ? default ,
                                   list ? ( path : list : list ) ,
                                   null ? default ,
                                   path ? default ,
                                   set ? ( path : set : set ) ,
                                   string ? default
                                } :
                                    let
                                        visit =
                                            path : value :
                                                let
                                                    type = builtins.typeOf value ;
                                                    in
                                                        if builtins.hasAttr type visitors then
                                                            if type == "list" then builtins.genList ( index : visit ( builtins.concatLists [ path [ index ] ] ) ( builtins.elemAt value index ) ) ( builtins.length value )
                                                            else if type == "set" then builtins.trace "89764279280543a15cc6dc5758dacfd0fcf91c1bb1d8045888ecc64223334bc6b7dda28486b0103a5edb8816b2bb523fa6066506ae18d262a170fec7f7424d76 ${ builtins.toJSON path }" ( builtins.mapAttrs ( name : value : visit ( builtins.concatLists [ path [ name ] ] ) value ) value )
                                                            else builtins.getAttr type visitors path value
                                                        else unknown path value ;
                                        visitors =
                                            {
                                                bool = bool ;
                                                float = float ;
                                                int = int ;
                                                lambda = lambda ;
                                                list = list ;
                                                null = null ;
                                                path = path ;
                                                set = set ;
                                                string = string ;
                                            } ;
                                        in visit [ ] ;
                            in
                                {
                                    implementation = implementation ;
                                    check =
                                        {
                                            coreutils ,
                                            diffutil ,
                                            expected ? false ,
                                            mkDerivation ,
                                            success ? false ,
                                            value ? null ,
                                            visitors ? { } ,
                                            writeShellApplication ,
                                            yq-go
                                        } :
                                            let
                                                eval = builtins.tryEval ( implementation visitors value ) ;
                                                status = { success = success ; value = expected ; } == eval ;
                                                in
                                                    mkDerivation
                                                        {
                                                            installPhase =
                                                                ''
                                                                    execute-test "$out"
                                                                '' ;
                                                            name = "test-visitor" ;
                                                            nativeBuildInputs =
                                                                [
                                                                    (
                                                                        if status then
                                                                            writeShellApplication
                                                                                {
                                                                                    name = "execute-test" ;
                                                                                    runtimeInputs = [ coreutils ] ;
                                                                                    text =
                                                                                        ''
                                                                                            OUT="$1"
                                                                                            touch "$OUT"
                                                                                        '' ;
                                                                                    }
                                                                        else
                                                                            writeShellApplication
                                                                                {
                                                                                    name = "execute-test" ;
                                                                                    runtimeInputs = [ coreutils yq-go ] ;
                                                                                    text =
                                                                                        ''
                                                                                            TEMPORARY=/build/temporary
                                                                                            mkdir --parents "$TEMPORARY"
                                                                                            echo '${ builtins.toJSON { success = success ; value = expected ; } }' | yq --prettyPrint "." > "$TEMPORARY/expected.yaml"
                                                                                            echo '${ builtins.toJSON eval }' | yq --prettyPrint "." > "$TEMPORARY/observed.yaml"
                                                                                            cat "$TEMPORARY/expected.yaml" >&2
                                                                                            echo >&2
                                                                                            cat "$TEMPORARY/observed.yaml" >&2
                                                                                            echo >&2
                                                                                            diff --unified "$TEMPORARY/expected.yaml" "$TEMPORARY/observed.yaml"
                                                                                            rm --recursive --force "$TEMPORARY"
                                                                                            exit 64
                                                                                        '' ;
                                                                                }
                                                                    )
                                                                ] ;
                                                            src = ./. ;
                                                        } ;
                                } ;
            } ;
}