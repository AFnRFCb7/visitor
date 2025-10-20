{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        default ? path : value : builtins.throw "The definition at ${ builtins.map builtins.toJSON path } is invalid.  It is of type ${ builtins.typeOf value }.  It is ${ if builtins.any ( t : t == builtins.typeOf value ) [ "bool" "float" "int" "null" "path" "string" ] then  builtins.toJSON value else "unstringable" }." ,
                        unknown ? path : value : builtins.throw "The definition at ${ builtins.toJSON path } is of unknown type.  It is of type ${ builtins.typeOf value }.  We only know about bool, float, int, lambda, list, null, path, set, string."
                    } :
                        let
                            implementation =
                                {
                                    bool ? default ,
                                    float ? default ,
                                    int ? default ,
                                    lambda ? default ,
                                    list ? path : list : list ,
                                    null ? default ,
                                    path ? builtins.null ,
                                    set ? path : set : set ,
                                    string ? default
                                } :
                                    let
                                        visitor =
                                            value :
                                                let
                                                    type = builtins.typeOf value ;
                                                    in
                                                        if type == "bool" then bool value
                                                        else if type == "float" then float value
                                                        else if type == "int" then int value
                                                        else if type == "lambda" then lambda value
                                                        else if type == "list" then builtins.map implementation value
                                                        else if type == "null" then null value
                                                        else if type == "path" then path value
                                                        else if type == "set" then builtins.mapAttrs ( name : value : implementation value ) value
                                                        else if type == "string" then string value
                                                        else unknown ;
                                        in visitor ;
                            in
                                {
                                    implementation = implementation ;
                                    test =
                                        {
                                            coreutils ,
                                            expected ,
                                            mkDerivation ,
                                            success ? true ,
                                            visitors ,
                                            value ,
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
                                                                    execute-test $out"
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