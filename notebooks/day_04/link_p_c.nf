#!/usr/bin/env nextflow

process SPLITLETTERS {
    debug true

    input:
    val row  // each row from the samplesheet channel (a map)

    output:
    path("${row.out_name}_*.txt")

    script:
    """
    str="${row.input_str}"
    size=${row.block_size}
    name=${row.out_name}
 
    i=1
    while [ -n "\$str" ]; do
        chunk=\${str:0:\$size}
        echo "\$chunk" > "${row.out_name}_\${i}.txt"
        str=\${str:\$size}
        ((i++))
    done
    """
}

process CONVERTTOUPPER {
    input:
    path txt_files

    output:
    stdout

    script:
    """
    for f in ${txt_files}; do
        echo "=== \$f ==="
        tr 'a-z' 'A-Z' < \$f
    done
    """
} 

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    // 2. Create a process that splits the "in_str" into sizes with size block_size. 
    // The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout
    // read in samplesheet}
    samplesheet = channel.fromPath('samplesheet_2.csv').splitCsv(header:true)
    // split the input string into chunks
    split_files = SPLITLETTERS(samplesheet)
    // lets remove the metamap to make it easier for us, as we won't need it anymore

    // convert the chunks to uppercase and save the files to the results directory
    out = CONVERTTOUPPER(split_files)
    out.view()

}