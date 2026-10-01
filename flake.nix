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
                                            order
                                        } :
                                        {
                                            arguments ,
                                            success ,
                                            value ,
                                            visitors
                                        } :
                                            let
                                                value =
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
                                                                                                    ( config.failure { visitor = ignore : builtins.toJSON ; } )
                                                                                                ] ;
                                                                                            text =
                                                                                                let
                                                                                                    expected = { success = success ; value = value ; } ;
                                                                                                    observed = builtins.tryEval config.visitor visitors arguments ;
                                                                                                if expected == observed then ""
                                                                                                else
                                                                                                    ''
                                                                                                        failure 5942198107310342
                                                                                                    '' ;
                                                                                        }
                                                                                )
                                                                            ] ;
                                                                        imports = [ failure implementation ] ;
                                                                    } ;
                                                            testScript =
                                                                ''
                                                                    client.wait_for_unit("network-online.target")
                                                                    client.succeed("test-script")
                                                                '' ;
                                                        } ;
                                                    in
                                                        {
                                                            name = builtins.concatStringsSep "-" [ "check" ( builtins.toString order ) ] ;
                                                            order = order ;
                                                            value = ignore : value ;
                                                        } ;
                                } ;
            } ;
}