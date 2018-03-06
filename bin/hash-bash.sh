#!/bin/bash -x


TESTDATA=( "a" "b" "c" "d" "e" )


#
# Copy array AName to array BName
#
cp_array()
{
        local AName=
        local BName=
        local Filter=

        AName="$1" ; shift
        BName="$1" ; shift
        Filter="s/^.*${AName}/${BName}/"

#       declare -p $AName | sed -e 's/\[[0-9]\]=//g'
#       declare -p $AName | eval sed -e \'s/\\[/${BName}\\[/g\'
        declare -p $AName | eval sed -e \'$Filter\'
}

test_run()
{
        echo "Foo=([0]="a" [1]="b" [2]="c" [3]="d" [4]="e")"
}

# cp_array TESTDATA Foo

eval $(test_run)
echo "Foo: ${!Foo[@]} , ${Foo[@]}"



