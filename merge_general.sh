#!/bin/sh

if [ $# -lt 3 ]
then
    echo need merge_script and 2 sla file
    exit 1
fi

make_split_sla()
{
    cat $1 \
        | sort -k1n \
        | gawk '{
            if (1 == NR) {
                print
            } else {
                increase = ($2-lastSla) / 10;
                for (i = lastSla; i < $2; i += ($2-lastSla) / 10) {
                    printf("%0.16f %f\n", ($1 - lastT) / 10, i + increase);
                }
            }
            lastT = $1;
            lastSla = $2;
        }' > $2
}

part1=`mktemp $TMPDIR/merge_sla.part.XXXXXX`
part2=`mktemp $TMPDIR/merge_sla.part.XXXXXX`
make_split_sla $2 $part1
make_split_sla $3 $part2

merge=`mktemp $TMPDIR/merge_sla.merge.XXXXXX`
cat $part1 \
    | while read l
        do
            sed "s/^/$l /g" $part2
        done \
    | gawk -f $1 \
    | sort -k2n > $merge
    
for i in 0.5 0.9 0.99 0.999 1
do
    gawk '{
        p += $1;
        if (p >= '$i') {
            print p, $2;
            exit(0)
        }
    }' $merge
done
