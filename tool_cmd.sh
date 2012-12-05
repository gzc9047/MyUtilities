#!/bin/bash

# 所有需要制定列号的参数都可以制定多列：
# sf - '3 4' => awk '{print $3, $4}'
# sf - '3 (NF-1)' => awk '{print $3, $(NF-1)}'

# count($column)
# cat $file | sf - 3
# cat $file | sf - 3 :
# sf $file 3 :
sf()
{
    keyCol='$1'
    if [ $# -lt 1 ]
    then
        echo need file.
        return 1
    elif [ $# -gt 1 ]
    then
        keyCol="`echo "$2" | sed 's/ /\" \"\$/g;s/^/\$/g'`"
    fi
    spl=" "
    if [ $# -gt 2 ]
    then
        spl="$3"
    fi
    awk -F "$spl" '{++num['"$keyCol"']}END{for(i in num)print i,num[i]}' $1
    return $?
}

# count($column) with weight($column2)
# cat $file | adf - 99 2 # 对第二列求和。
# cat $file | adf - 3 2 :
# adf $file 3 1 :
adf()
{
    keyCol='$1'
    valCol='$2'
    if [ $# -lt 1 ]
    then
        echo need file.
        return 1
    elif [ $# -eq 2 ]
    then
        keyCol="`echo "$2" | sed 's/ /\" \"\$/g;s/^/\$/g'`"
    elif [ $# -eq 3 ]
    then
        keyCol="`echo "$2" | sed 's/ /\" \"\$/g;s/^/\$/g'`"
        valCol="$3"
    fi
    spl=" "
    if [ $# -gt 3 ]
    then
        spl="$4"
    fi
    awk -F "$spl" '{num['"$keyCol"']+=$'$valCol'}END{for(i in num)print i,num[i]}' $1
    return $?
}

# show common in 2 file
# scf $file1 $file2 $outfile1 $outfile2 $key1 $key2
# scf f1 f2 0 3 '2 5' '3 6' # 输出f1中2、5列等于f2中3、6列的f1整行和f2的第三列。
scf()
{
    keyCol1='$1'
    keyCol2='$1'
    outCol1='$999'
    outCol2='$0'
    if [ $# -lt 2 ]
    then
        echo need 2 file.
        return 1
    fi
    if [ $# -gt 2 ]
    then
        outCol1="`echo "$3" | sed 's/ /\" \"\$/g;s/^/\$/g'`"
    fi
    if [ $# -gt 5 ]
    then
        outCol2="`echo "$4" | sed 's/ /\" \"\$/g;s/^/\$/g'`"
    fi
    if [ $# -gt 4 ]
    then
        keyCol1="`echo "$5" | sed 's/ /\" \"\$/g;s/^/\$/g'`"
    fi
    if [ $# -gt 5 ]
    then
        keyCol2="`echo "$6" | sed 's/ /\" \"\$/g;s/^/\$/g'`"
    fi
    spl=" "
    if [ $# -gt 6 ]
    then
        spl="$7"
    fi
    awk -F "$spl" '{
        if ( 1 == ARGIND )
        {
            key[ '"$keyCol1"' ] = '"$outCol1"';
        }
        else if ( '"$keyCol2"' in key )
        {
            print key[ '"$keyCol2"' ], '"$outCol2"';
        }
    }' $1 $2
    return $?
}

# show not common in 2 file
# 输出两个文件不共有的行。
sncf()
{
    keyCol1='$1'
    keyCol2='$1'
    outCol1='$999'
    outCol2='$0'
    if [ $# -lt 2 ]
    then
        echo need 2 file.
        return 1
    fi
    if [ $# -gt 2 ]
    then
        outCol1="`echo "$3" | sed 's/ /\" \"\$/g;s/^/\$/g'`"
    fi
    if [ $# -gt 5 ]
    then
        outCol2="`echo "$4" | sed 's/ /\" \"\$/g;s/^/\$/g'`"
    fi
    if [ $# -gt 4 ]
    then
        keyCol1="`echo "$5" | sed 's/ /\" \"\$/g;s/^/\$/g'`"
    fi
    if [ $# -gt 5 ]
    then
        keyCol2="`echo "$6" | sed 's/ /\" \"\$/g;s/^/\$/g'`"
    fi
    spl=" "
    if [ $# -gt 6 ]
    then
        spl="$7"
    fi
    awk -F "$spl" '{
        if ( 1 == ARGIND )
        {
            key[ '"$keyCol1"' ] = '"$outCol1"';
        }
        else if (!( '"$keyCol2"' in key ))
        {
            print '"$outCol2"';
        }
    }' $1 $2
    return $?
}

# cut
x()
{
    if [ $# -lt 1 ]
    then
        echo need 2 file.
        return 1
    elif [ $# -lt 2 ]
    then
        target="NF"
    elif [ $# -gt 1 ]
    then
        target="$2"
    fi
    outCol1="`echo "$target" | sed 's/ /\" \"\$/g;s/^/\$/g'`"
    spl=" "
    if [ $# -gt 2 ]
    then
        spl="$3"
    fi
    awk -F "$spl" '{print '"$outCol1"'}' $1
}

