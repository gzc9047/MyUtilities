#4 useful shell statistic function: x sf adf scf. in tool\_cmd.sh
// My English is poor.

Use these shell function, I'm rarely need to write awk script for daily use.

Use these shell function, you can write the complex data process shell very fast, in several seconds.

Then you can do other things or just wait the result.

content of the example file, apache log:

127.0.0.1 - - [24/Nov/2012:20:18:12 +0800] "GET / HTTP/1.1" 304 -

127.0.0.1 - - [24/Nov/2012:20:18:12 +0800] "GET /favicon.ico HTTP/1.1" 404 209

127.0.0.1 - - [24/Nov/2012:20:18:14 +0800] "GET / HTTP/1.1" 304 -

127.0.0.1 - - [24/Nov/2012:20:18:14 +0800] "GET /favicon.ico HTTP/1.1" 404 209

# x()    like cut. For example, if you want:

the 1st column in file:

# x $file 1

127.0.0.1

127.0.0.1

127.0.0.1

127.0.0.1

2nd column in file with columns splited by '/' :
# x $file 2 /

Nov

Nov

Nov

Nov

last column and third column in file:
# x $file 'NF 3'

\- -

209 -

\- -

209 -

column before last in file:
# x $file '(NF-1)'

304

404

304

404

99th column (maybe not exist) in stdin:
# x - 99

(4 EMPTY row)

9th column with value \*2 in file:
# x $file '9\*2'

608

808

608
808

# x - 'NF-1' means the last column with value-1; awk '{print $NF-1}' -

-1

208

-1

208

# sf() like select count(\*) from file group by column. For example, if you want:
count of 1st column appear times in $file:
// use the example data of apache log.
# sf $file 1

127.0.0.1 4

count of 1st and 7th column appear times in stdin:
# cat $file | sf - '1 7'

127.0.0.1 / 2

127.0.0.1 /favicon.ico 2

count of 2nd column which splited by '"' appear times in $file:
# sf $file 2 '"'

GET / HTTP/1.1 2

GET /favicon.ico HTTP/1.1 2

# Parameter of choosing column is the same format of this 4 function.

# adf() sum the specify column with weight(another column)
// this example was translate to awk form.

adf $file 2 10 => awk '{num[$2]+=$10} END{for (i in num) print i, num[i]}' $file

adf $file '2 (NF-1)' '9\*2' => awk '{num[$2" "$(NF-1)]+=$9\*2} END{for (i in num) print i, num[i]}' $file
# The code is very short, you can write it in few seconds.

# scf(), like the "join" command, but you can specify multi column(in any order) for the SAMEKEY between 2 file.

FILE1:

Louix M 10085 Beijing

FILE2:

10085 Louix China

If you want the whole line of two file in one line, while 1st 3rd column in file1 is equal 2nd 1st column in file2:
# scf $file1 $file2 0 0 '1 3' '2 1' // 0 means the whole line, $0 in the awk script.
# result is:

Louix Gu 10085 Beijing 10085 Louix China

It's a little noisy, we just want the first name(1st column in file1) and country(2nd column in file2), use:
# scf $file1 $file2 1 3 '1 3' '2 1'
# result is:

Louix China
