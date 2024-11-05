#echo "Generating ground truth outputs from original processor"

cd ~/eecs470/p3

# This only runs *.s files. How could you add *.c files?
#for source_file in programs/*.s programs/*.c; do
for source_file in programs/mult_no_lsq.s; do
    if [ "$source_file" = "programs/crt.s" ]; then continue; fi
    program=$(echo "$source_file" | cut -d '.' -f1 | cut -d '/' -f 2)
    
    #echo "Running $program"

    echo "   "
    make $program.out
    grep "CPI" output/$program.out
    #echo "Comparing writeback output for $program"
    pass=$(diff /home/cassiesu/eecs470/p3_cassie/output/$program.wb output/$program.wb >/dev/null 2>&1)
     if $pass
    #if diff /home/cassiesu/eecs470/p3_cassie/output/$program.wb output/$program.wb >/dev/null 2>&1
    #if diff output/$program.out output/$program.out >/dev/null 2>&1
      then echo "$program.wb matches"
      else echo "$program.wb does not match"
    fi

    #echo "Comparing memory output for $program"
    
    #if diff <(grep "^@@@" /home/cassiesu/eecs470/p3_cassie/output/$program.out) <(grep "^@@@" output/$program.out) >/dev/null 2>&1
    #  then echo "$program.out matches"
    #  else echo "$program.out does not match"
    #fi

    #echo "Printing Passed or Failed"
    #if $pass
    #  then echo "$program Failed"
    #  else echo "$program Passed"
    #fi

done











