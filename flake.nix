# 5888781975567541
{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    { input ? null , output ? null } :
                        let
                            implementation =
                                { config , lib , ... } @module :
                                    let
                                        identified =
                                            if builtins.typeOf input == "lambda" then input module
                                            else if builtins.typeOf input == "null" then module
                                            else builtins.throw "8050236596639547" ;
                                        in
                                            with identified ;
                                                {
                                                    options =
                                                        {
                                                            visitor =
                                                                lib.mkOption
                                                                    {
                                                                        default =
                                                                            {
                                                                                default ? path : value : config.trip "The definition at ${ builtins.toJSON path } is invalid.  It is of type ${ builtins.typeOf value }.  It is ${ if builtins.any ( t : t == builtins.typeOf value ) [ "bool" "float" "int" "null" "path" "string" ] then builtins.toJSON value else "unstringable" }." ,
                                                                                unknown ? path : value : config.trip "The definition at ${ builtins.toJSON path } is of unknown type.  It is of type ${ builtins.typeOf value }.  We only know about bool, float, int, lambda, list, null, path, set, string."
                                                                            } :
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
                                                                                                        else if type == "set" then visitors.set path ( builtins.mapAttrs ( name : value : visit ( builtins.concatLists [ path [ name ] ] ) value ) value )
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
                                                                        type = lib.types.functionTo ( lib.types.functionTo ( lib.types.functionTo lib.types.anything ) ) ;
                                                                    } ;
                                                        } ;
                                                } ;
                            in
                                {
                                    check =
                                        {
                                            failure ?
                                                { pkgs , ... } @module :
                                                    let
                                                        identified =
                                                            if builtins.typeOf input == "lambda" then input module
                                                            else if builtins.typeOf input == "null" then module
                                                            else builtins.throw "3089158225937633" ;
                                                        in
                                                            with identified ;
                                                                {
                                                                    environment.systemPackages =
                                                                        [
                                                                            (
                                                                                pkgs.writeShellApplication
                                                                                    {
                                                                                        name = "failure" ;
                                                                                        runtimeInputs = [ pkgs.coreutils ] ;
                                                                                        text =
                                                                                            ''
                                                                                                echo "$@" >&2
                                                                                                exit 108
                                                                                            '' ;
                                                                                    }
                                                                            )
                                                                        ] ;
                                                                } ,
                                            nixosTest ,
                                            obviated-by ,
                                            trip ?
                                                { lib , ... } @module:
                                                    let
                                                        identified =
                                                            if builtins.typeOf input == "lambda" then input module
                                                            else if builtins.typeOf input == "null" then module
                                                            else builtins.throw "8491044949862058" ;
                                                        in
                                                            with identified ;
                                                                {
                                                                    options.trip =
                                                                        lib.mkOption
                                                                            {
                                                                                default = uuid : builtins.throw uuid ;
                                                                                type = lib.types.functionTo lib.types.anything ;
                                                                            } ;
                                                                }
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
                                                                { config , pkgs , ... } @module :
                                                                    let
                                                                        identified =
                                                                            if builtins.typeOf input == "lambda" then input module
                                                                            else if builtins.typeOf input == "null" then module
                                                                            else builtins.throw "4956372387227342" ;
                                                                        in
                                                                            with identified ;
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
                                                                                                                ( config.failure { } )
                                                                                                            ] ;
                                                                                                        text =
                                                                                                            let
                                                                                                                expected = { success = success ; value = value ; } ;
                                                                                                                observed = builtins.tryEval ( config.visitor { } visitors arguments ) ;
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
                                                                                    imports = [ failure implementation trip ] ;
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
                                    implementation =
                                        if builtins.typeOf output == "lambda" then output implementation
                                        else if builtins.typeOf output == "null" then implementation
                                        else builtins.throw "6526026116388557" ;
                                } ;
            } ;
}