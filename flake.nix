{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        default ? ( path : value : builtins.throw "The definition at ${ builtins.map builtins.toJSON path } is invalid.  It is of type ${ builtins.typeOf value }.  It is ${ if builtins.any ( t : t == builtins.typeOf value ) [ "bool" "float" "int" "null" "path" "string" ] then builtins.toJSON value else "unstringable" }." ) ,
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
                                   path ? builtins.null ,
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
                                                            else if type == "set" then builtins.mapAttrs ( name : value : visit ( builtins.concatLists [ path [ name ] ] ) value ) value
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
                                            expected ,
                                            mkDerivation ,
                                            success ? true ,
                                            value ,
                                            writeShellApplication ,
                                            yq-go
                                        } :
                                            let
                                                eval = builtins.tryEval ( implementation value ) ;
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
                                                                                            echo '${ builtins.toJSON { expected = { success = success ; value = expected ; } ; observed = eval ; } }' | yq --prettyPrint "." >&2
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