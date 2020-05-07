#!bin/sh
for file in $(ls tests/)
do
  sh exec.sh tests/${file} > output/${file}.out
done
