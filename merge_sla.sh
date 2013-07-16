#!/bin/sh

if [ $# -lt 2 ]
then
    echo need 2 sla file
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
        }' > $1.part
}
make_split_sla $1
make_split_sla $2

cat $1.part \
    | while read l
        do
            sed "s/^/$l /g" $2.part
        done \
    | gawk '{printf("%0.16f %f\n", $1 * $3, $2 + $4);}' \
    | sort -k2n > $1.merge
    
for i in 0.5 0.9 0.99 0.999 1
do
    gawk '{
        p += $1;
        if (p >= '$i') {
            print p, $2;
            exit(0)
        }
    }' $1.merge
done
