#!bin/sh
for file in $(ls tests/)
do
  sh exec.sh tests/${file} > output/${file}.out
  diff output/${file}.out std/${file}.std > diff/${file}.diff
done
