#!/bin/bash

alias grep_code_filte_file_name="grep '\.java:\|\.h:\|\.hpp:\|\.cpp:\|\.c:\|\.cc:\|\.[sS]:\|\.asm'"
export grep_code_split_pattern_start="[^\"a-zA-Z0-9_]"
export grep_code_split_pattern_end="[^\"a-zA-Z0-9_;]"

# JAVA_API_LIST generator:
# jar tf $JAR_FILE | grep '\.class$' | tr "/" "." | sed 's/.class$//g' | java -classpath .:$JAR_FILE JavaClassApiGenerator
# column format:
# column 1: class name
# column 2: method declaraton class name
# reset column method signature
export JAVA_API_LIST=~/3/code_mine/java_learn/java.api.list

enable_proxy()
{
    if [ "`uname`" != "Darwin" ]
    then
        echo "No mac os, do nothing."
        exit 1
    fi
    networksetup -setwebproxy Wi-Fi 127.0.0.1 8087
    networksetup -setwebproxy Ethernet 127.0.0.1 8087 
    networksetup -setwebproxystate Wi-Fi on
    networksetup -setwebproxystate Ethernet on
    echo "Web proxy enabled."
}

disable_proxy()
{
    if [ "`uname`" != "Darwin" ]
    then
        echo "No mac os, do nothing."
        exit 1
    fi
    networksetup -setwebproxystate Wi-Fi off
    networksetup -setwebproxystate Ethernet off
    echo "Web proxy disabled."
}

show_split_line()
{
    echo -e "\033[47;36m=========================================split line=====================================================================\033[0m"
    echo -e "\033[47;36m=========================================split line=====================================================================\033[0m"
    echo "#"
}

# format java code
ef()
{
    if [ $# -lt 1 ]
    then
        echo need item.
        return 1
    fi
    is_absolute=`echo $1 | grep '^/'`
    if [ "$is_absolute" != "" ]
    then
        path="$1"
    else
        path=`pwd`/"$1"
    fi
    /Applications/eclipse/eclipse -nosplash -application org.eclipse.jdt.core.JavaCodeFormatter -verbose -config ~/3/code_work/amazon_work/org.eclipse.jdt.core.prefs $path
}


#make alarm data
ma()
{
    tmpfile=`mktemp`
    tmpfile_dst="$HOME/3/code_mine/MyUtilities/alarm/data/"`echo $tmpfile | x - NF /`
    mv $tmpfile $HOME/3/code_mine/MyUtilities/alarm/data/
    echo $@ > $tmpfile_dst
}

# grep code non-filte file.
gn()
{
    if [ $# -lt 1 ]
    then
        echo need item.
        return 1
    fi
    show_split_line
    grep --exclude=. --color -RIn "$1" . 2> /dev/null
}

# grep code
gc()
{
    if [ $# -lt 1 ]
    then
        echo need item.
        return 1
    fi
    show_split_line
    grep --exclude=. -RIn  "$1" . | grep_code_filte_file_name | grep --color "$1"
}

# grep code
gcd()
{
    if [ $# -lt 1 ]
    then
        echo need item.
        return 1
    fi
    show_split_line
    grep --exclude=. "$grep_code_split_pattern_start""$1""$grep_code_split_pattern_end\|^$1""$grep_code_split_pattern_end" -RIn . | \
        grep_code_filte_file_name | grep --color "$1"
}

# grep target use
gu()
{
    if [ $# -lt 1 ]
    then
        echo need item.
        return 1
    fi
    show_split_line
    git grep -nI --color --break --heading "$grep_code_split_pattern_start""$1""$grep_code_split_pattern_start"
}

# grep java method info
gj()
{
    if [ $# -lt 1 ]
    then
        echo need item.
        return 1
    fi
    show_split_line
    grep --color "$1" $JAVA_API_LIST
}

# grep java method info of special class
gjc()
{
    if [ $# -lt 1 ]
    then
        echo need item.
        return 1
    fi
    show_split_line
    grep --color "^[^ ]*$1" $JAVA_API_LIST
}

# grep java method info
gjm()
{
    if [ $# -lt 1 ]
    then
        echo need item.
        return 1
    fi
    show_split_line
    grep --color " [^ ]*$1[^ ]*(" $JAVA_API_LIST
}

# grep function define
gd()
{
    if [ $# -lt 1 ]
    then
        echo need item.
        return 1
    fi
    show_split_line
    t=`echo -e "\t"`
    git grep -nI --break --color --heading --or -e "^[^=$t]*[ :\*]$1[ $t]*(" -e "^$1[ $t]*(" -e "define[^a-zA-Z0-9_]*$1[^a-zA-Z0-9_]"
}

# alarm me.
am()
{
    if [ $# -lt 2 ]
    then
        echo need time comment.
        return 1
    fi
    times=$1
    comment=$2
    now=`date +%Y:%m:%d:%H:%M:%S`
    echo "$now $times $comment" >> $TMPDIR/am_list
    nohup sleep $times 2>&1 > /dev/null && \
        open "http://localhost/alarm/index.html?$comment" && \
        echo "$now DONE $times $comment" >> $TMPDIR/am_list \
        &
}

amt()
{
    if [ $# -lt 2 ]
    then
        echo need time comment.
        return 1
    fi
    times=$1
    temp_file=`mktemp $TMPDIR/alarm_html/t.XXXXXX`
    echo "$2" > $temp_file
    cat ~/3/code_mine/MyUtilities/template.html.1 \
        $temp_file \
        ~/3/code_mine/MyUtilities/template.html.2 \
            > $temp_file.html
    comment=$2
    now=`date +%Y:%m:%d:%H:%M:%S`
    echo "$now $times $comment" >> $TMPDIR/am_list
    nohup sleep $times 2>&1 > /dev/null && \
        open "$temp_file".html && \
        echo "$now DONE $times $comment" >> $TMPDIR/am_list \
        &
}

# 所有需要制定列号的参数都可以制定多列：
# x - '3 4' => awk '{print $3, $4}'
# x - '3 (NF-1)' => awk '{print $3, $(NF-1)}'

alias generate_awk_line_choose_code_with_sed='sed "s/ /\" \"\$/g;s/^/\$/g"'

# count($column)
# cat $file | sf - 3
# cat $file | sf - 3 : # split columns with ':'
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
        keyCol="`echo "$2" | generate_awk_line_choose_code_with_sed`"
    fi
    spl=" "
    if [ $# -gt 2 ]
    then
        spl="$3"
    fi
    gawk -F "$spl" '{++num['"$keyCol"']}END{for(i in num)print i,num[i]}' $1
    return $?
}

# count($column) with weight($column2)
# cat $file | adf - 99 2 # value[$99] += $2; $99 not exist, so $99 = "", means sum $2.
# cat $file | adf - 3 2 : # split columns with ':'
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
        keyCol="`echo "$2" | generate_awk_line_choose_code_with_sed`"
    elif [ $# -eq 3 ]
    then
        keyCol="`echo "$2" | generate_awk_line_choose_code_with_sed`"
        valCol="$3"
    fi
    spl=" "
    if [ $# -gt 3 ]
    then
        spl="$4"
    fi
    gawk -F "$spl" '{num['"$keyCol"']+=$'$valCol'}END{for(i in num)print i,num[i]}' $1
    return $?
}

# show common in 2 file
# scf $file1 $file2 $outfile1 $outfile2 $key1 $key2
# scf f1 f2 0 3 '2 5' '3 6' # output $0 in f1 and $3 in f2, when '$2 $3' in f1 == '$3 $6' in f2
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
        outCol1="`echo "$3" | generate_awk_line_choose_code_with_sed`"
    fi
    if [ $# -gt 5 ]
    then
        outCol2="`echo "$4" | generate_awk_line_choose_code_with_sed`"
    fi
    if [ $# -gt 4 ]
    then
        keyCol1="`echo "$5" | generate_awk_line_choose_code_with_sed`"
    fi
    if [ $# -gt 5 ]
    then
        keyCol2="`echo "$6" | generate_awk_line_choose_code_with_sed`"
    fi
    spl=" "
    if [ $# -gt 6 ]
    then
        spl="$7"
    fi
    gawk -F "$spl" '{
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

# show uniq part in file2, compare to scf command.
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
        outCol1="`echo "$3" | generate_awk_line_choose_code_with_sed`"
    fi
    if [ $# -gt 5 ]
    then
        outCol2="`echo "$4" | generate_awk_line_choose_code_with_sed`"
    fi
    if [ $# -gt 4 ]
    then
        keyCol1="`echo "$5" | generate_awk_line_choose_code_with_sed`"
    fi
    if [ $# -gt 5 ]
    then
        keyCol2="`echo "$6" | generate_awk_line_choose_code_with_sed`"
    fi
    spl=" "
    if [ $# -gt 6 ]
    then
        spl="$7"
    fi
    gawk -F "$spl" '{
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
        echo need 2 parameter.
        return 1
    elif [ $# -lt 2 ]
    then
        target="NF"
    elif [ $# -gt 1 ]
    then
        target="$2"
    fi
    outCol1="`echo "$target" | generate_awk_line_choose_code_with_sed`"
    spl=" "
    if [ $# -gt 2 ]
    then
        spl="$3"
    fi
    gawk -F "$spl" '{print '"$outCol1"'}' $1
}

mf()
{
    keyCol='$1'
    valCol='$2'
    if [ $# -lt 1 ]
    then
        echo need file.
        return 1
    fi
    if [ $# -gt 1 ]
    then
        keyCol="`echo "$2" | generate_awk_line_choose_code_with_sed`"
    fi
    if [ $# -gt 2 ]
    then
        valCol="`echo "$3" | generate_awk_line_choose_code_with_sed`"
    fi
    spl=" "
    if [ $# -gt 3 ]
    then
        spl="$4"
    fi
    gawk -F "$spl" '{v['"$keyCol"']=v['"$keyCol"'] " " '$valCol'}END{for(i in v)print i,v[i]}' $1
    return $?
}
