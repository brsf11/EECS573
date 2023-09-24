echo "Generating ground truth outputs from original processor"

cd ~/eecs470/p3

# This only runs *.s files. How could you add *.c files?
for source_file in programs/*.s; do
    if [ "$source_file" = "programs/crt.s" ]; then continue; fi
    program=$(echo "$source_file" | cut -d '.' -f1 | cut -d '/' -f 2)
    
    echo "Running $program"

    make $program.out

    echo "Checking register writeback output"
    if diff /home/cassiesu/eecs470/p3_cassie/output/$program.wb output/$program.wb >/dev/null 2>&1
    #if diff output/$program.out output/$program.out >/dev/null 2>&1
      then echo "$program.wb matches"
      else echo "$program.wb does not match"
    fi
done

