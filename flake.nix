# 5888781975567541
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
                                { lib , ... } :
                                    {
                                        options =
                                            {
                                                visitor =
                                                    lib.mkOption
                                                        {
                                                            default =
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
                                                                            builtins.trace
                                                                                "8772733081067398"
                                                                                (
                                                                                    path :
                                                                                        (
                                                                                            builtins.trace
                                                                                                "9543817905609605"
                                                                                                (
                                                                                                    value :
                                                                                                        let
                                                                                                            type = builtins.trace "5064599494262303" ( builtins.typeOf value ) ;
                                                                                                            in
                                                                                                                builtins.trace
                                                                                                                    "3463489126327058"
                                                                                                                    (
                                                                                                                        if builtins.hasAttr type visitors then
                                                                                                                            if type == "list" then builtins.genList ( index : visit ( builtins.concatLists [ path [ index ] ] ) ( builtins.elemAt value index ) ) ( builtins.length value )
                                                                                                                            else if type == "set" then visitors.set path ( builtins.mapAttrs ( name : value : visit ( builtins.concatLists [ path [ name ] ] ) value ) value )
                                                                                                                            else builtins.getAttr type visitors path value
                                                                                                                        else unknown path value
                                                                                                                    )
                                                                                                )
                                                                                        )
                                                                                ) ;
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
                                                                        in builtins.trace "8247132116671856" ( visit [ ] ) ;
                                                            type = lib.types.functionTo lib.types.package ;
                                                        } ;
                                            } ;
                                    } ;
                            in
                                {
                                    implementation = implementation ;
                                    check =
                                        {
                                            failure ,
                                            nixosTest ,
                                            obviated-by
                                        } :
                                        {
                                            arguments ,
                                            success ,
                                            value ,
                                            visitors
                                        } :
                                            let
                                                test =
                                                    nixosTest
                                                        {
                                                            name = "visitor" ;
                                                            nodes.client =
                                                                { config , pkgs , ... }  :
                                                                    {
                                                                        environment.systemPackages =
                                                                            [
                                                                                (
                                                                                    pkgs.writeShellApplication
                                                                                        {
                                                                                            name = "test-script" ;
                                                                                            runtimeInputs =
                                                                                                [
                                                                                                    pkgs.jq
                                                                                                    ( config.failure { visitor = ignore : builtins.toJSON ; } )
                                                                                                ] ;
                                                                                            text =
                                                                                                let
                                                                                                    expected = { success = success ; value = value ; } ;
                                                                                                    observed =
                                                                                                        let
                                                                                                            observed = builtins.tryEval ( builtins.trace "0484780767394769" ( config.visitor ( builtins.trace "7590963860331767" ( visitors ( builtins.trace "7066694716876078" arguments ) ) ) ) ;
                                                                                                            in builtins.trace "2323742362554359" observed ;
                                                                                                in
                                                                                                    if expected == observed then ""
                                                                                                    else
                                                                                                        ''
                                                                                                            EXPECTED="$( jq "." ${ builtins.toFile "expected" ( builtins.toJSON expected ) } )" || failure 4727697212392530
                                                                                                            OBSERVED="$( jq "." ${ builtins.toFile "observed" ( builtins.toJSON observed ) } )" || failure 8774722082080212
                                                                                                            jq \
                                                                                                                --null-input \
                                                                                                                --argjson EXPECTED "$EXPECTED" \
                                                                                                                --argjson OBSERVED "$OBSERVED" \
                                                                                                                '{
                                                                                                                    "expected" : $EXPECTED ,
                                                                                                                    "observed" : $OBSERVED
                                                                                                                }' >&2
                                                                                                                failure 5942198107310342
                                                                                                        '' ;
                                                                                        }
                                                                                )
                                                                            ] ;
                                                                        imports = [ failure implementation ] ;
                                                                    } ;
                                                            testScript =
                                                                ''
                                                                    client.wait_for_unit("multi-user.target")
                                                                    client.succeed("test-script")
                                                                '' ;
                                                        } ;
                                                    in
                                                        {
                                                            obviated-by = obviated-by ;
                                                            test = test ;
                                                            type = "visitor" ;
                                                        } ;
                                } ;
            } ;
}