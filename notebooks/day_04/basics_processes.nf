params.step = 0
params.zip = 'zip'


process SAYHELLO {
    debug true
    output:
    stdout

    script:
    """
    echo 'Hello world!' 
    """
}

process SAYHELLO_PYTHON {
    debug true
    output:
    stdout

    script:
    """
    #!/usr/bin/env python
    print("Hello world!") 
    """
}

process SAYHELLO_PARAM {
    debug true
    input:
    val str
    output:
    stdout

    script:
    """
    echo ${str}
    """
}

process SAYHELLO_FILE{
    debug true

    input:
    val str

    output:
    path 'hello.txt'

    script:
    """
    echo ${str} > hello.txt
    """
}

process UPPERCASE {
    debug true
    input:
    val str
    output:
    path 'upper.txt'

    script:
    """
    echo $str | tr '[a-z]' '[A-Z]' > upper.txt
    """
}

process PRINTUPPER {
    debug true
    input:
    val str
    output:
    stdout
    script:
    """
    cat ${str}
    """
}

process COMPRESS {
    debug true
    input:
    path upper
    output:
    stdout
    script:
    """
    case "${params.zip}" in
      zip)
        zip ${upper}.zip ${upper}
        echo "Created file: \$PWD/${upper}.zip"
        ;;
      gzip)
        gzip -c ${upper} > ${upper}.gz
        echo "Created file: \$PWD/${upper}.gz"
        ;;
      bzip2)
        bzip2 -c ${upper} > ${upper}.bz2
        echo "Created file: \$PWD/${upper}.bz2"
        ;;
      *)
        echo "Unknown compression type: ${params.zip}"
        exit 1
        ;;
    esac
    """
}

process COMPRESS_ALL {
    debug true

    input:
    path upper_file

    output:
    stdout

    script:
    """
    # zip
    zip ${upper_file}.zip ${upper_file}
    echo "Created file: \$PWD/${upper_file}.zip"

    # gzip
    gzip -c ${upper_file} > ${upper_file}.gz
    echo "Created file: \$PWD/${upper_file}.gz"

    # bzip2
    bzip2 -c ${upper_file} > ${upper_file}.bz2
    echo "Created file: \$PWD/${upper_file}.bz2"
    """
}

process WRITETOFILE{
    debug true

    input:
    val entry

    output:
    path "results/names.tsv"

    script:
    """
    mkdir -p results
    echo -e "name\ttitle" > results/names.tsv
    for row in ${entry.collect {it.name + ":" + it.title }.join(" ") }; do
        name=\${row%%:*}
        title=\${row##*:}
        echo -e "\$name\t\$title" >> results/names.tsv
    done
    """
}

workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == 1) {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == 2) {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == 3) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == 5) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == 7) {
        greeting_ch = Channel.of("Hello world!")
        upper = UPPERCASE(greeting_ch)
        COMPRESS(upper)
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {
        greeting_ch = Channel.of("Hello world!")
        upper = UPPERCASE(greeting_ch)
        COMPRESS_ALL(upper)
    }

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == 9) {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )

        out_ch = WRITETOFILE(in_ch.toList())
        out_ch.view()
    }

}