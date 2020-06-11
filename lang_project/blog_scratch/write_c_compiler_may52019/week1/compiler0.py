import sys, os, re

# a regex that searches the main function for a number 
# and store it in a group named 'ret' 
source_re = r"int main\s*\(\s*\)\s*{\s*return\s+(?P<ret>[0-9]+)\s*;\s*}"

# a formatting for the assembly wed like to return
assembly_format = """
    .globl_main
_main:
    movl ${}, %eax
    ret
"""

# read in the assembly file name compiled by gcc
source_file = sys.argv[1]
assembly_file = os.path.splitext(source_file)[0] + ".s"

with open(source_file, 'r') as infile, open(assembly_file, 'w') as outfile:
    source = infile.read().strip()
    match = re.match(source_re, source)
    
    # extract the 'ret' group containing our return value
    retval = match.group('ret')
    # plug our return value into the assembly and write it out
    outfile.write(assembly_format.format(retval))
