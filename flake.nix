# 5888781975567541
{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    {
                        config-identity ? x : x ,
                        lib-identity ? x : x ,
                        implementation-identity ? x : x ,
                        pkgs-identity ? x : x
                    } :
                        let
                            implementation =
                                { config , lib , ... } :
                                    let
                                        _config = config-identity config ;
                                        _lib = lib-identity lib ;
                                        in
                                            {
                                                options =
                                                    {
                                                        visitor =
                                                            _lib.mkOption
                                                                {
                                                                    default =
                                                                        {
                                                                            default ? path : value : _config.trip "The definition at ${ builtins.toJSON path } is invalid.  It is of type ${ builtins.typeOf value }.  It is ${ if builtins.any ( t : t == builtins.typeOf value ) [ "bool" "float" "int" "null" "path" "string" ] then builtins.toJSON value else "unstringable" }." ,
                                                                            unknown ? path : value : _config.trip "The definition at ${ builtins.toJSON path } is of unknown type.  It is of type ${ builtins.typeOf value }.  We only know about bool, float, int, lambda, list, null, path, set, string."
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
                                                                    type = _lib.types.functionTo ( _lib.types.functionTo ( _lib.types.functionTo _lib.types.anything ) ) ;
                                                                } ;
                                                    } ;
                                            } ;
                            in
                                {
                                    implementation = implementation-identity implementation ;
                                    check =
                                        {
                                            failure ?
                                                { pkgs , ... } :
                                                    let
                                                        _pkgs = pkgs-identity pkgs ;
                                                        in
                                                            {
                                                                environment.systemPackages =
                                                                    [
                                                                        (
                                                                            _pkgs.writeShellApplication
                                                                                {
                                                                                    name = "failure" ;
                                                                                    runtimeInputs = [ _pkgs.coreutils ] ;
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
                                                { lib , ... } :
                                                    let
                                                        _lib = lib-identity lib ;
                                                        in
                                                            {
                                                                options.trip =
                                                                    _lib.mkOption
                                                                        {
                                                                            default = uuid : builtins.throw uuid ;
                                                                            type = _lib.types.functionTo _lib.types.anything ;
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
                                                                { config , pkgs , ... }  :
                                                                    let
                                                                        _config = config-identity config ;
                                                                        _pkgs = pkgs-identity pkgs ;
                                                                        in
                                                                            {
                                                                                environment.systemPackages =
                                                                                    [
                                                                                        (
                                                                                            _pkgs.writeShellApplication
                                                                                                {
                                                                                                    name = "test-script" ;
                                                                                                    runtimeInputs =
                                                                                                        [
                                                                                                            _pkgs.jq
                                                                                                            ( _config.failure { } )
                                                                                                        ] ;
                                                                                                    text =
                                                                                                        let
                                                                                                            expected = { success = success ; value = value ; } ;
                                                                                                            observed = builtins.tryEval ( _config.visitor { } visitors arguments ) ;
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
                                } ;
            } ;
}