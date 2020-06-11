import sys, os, re

# a formatting for the assembly wed like to return
assembly_format = """
    .globl_main
_main:
    movl ${}, %eax
    ret
"""

lexer_matches = {
    "{":"o_bracket",
    "}":"c_bracket",
    "(":"o_paren",
    ")":"c_paren",
    ";":"semicolon"
}

lexer_keywords = {
    "return":"return_keyword",
    "int":"integer_keyword"
}

lexer_regexes = [
    r"[0-9]+",
    r"[a-zA-z]\w*"
]

def lex(file_string):
    '''
    a func that returns a list of tokens from
    a program file
    '''
    # iterate through the file if we fine a single
    # char token then add that token, otherwise
    # check keywords, otherwise append to a string 
    # and move to the next char
    tokens = []
    working_str = ''
    for s in file_string:
        s = s.strip()
        # try to match our tokens directly
        for c in s:
            # check all regexes to see if
            # the string 
            if c in lexer_matches.keys():
                for r in lexer_regexes:
                    match = re.search(r, working_str.lower())
                    if match is not None:
                        tokens.append(working_str)
                        working_str = ''
                        break
                tokens.append(c)
            # otherwise add to a working
            # string 
            else:
                working_str += c
                # if the working string is a keyword
                # add it to tokens
                if working_str.lower() in lexer_keywords.keys():
                    tokens.append(working_str)
                    working_str = ''
    print(tokens)
    return tokens

class ast_node_exp(object):
    def __init__(self, node, parent):
        self.node = node
        self.parent = parent

class ast_node_statement(object):
    def __init__(self, node, parent):
        self.node = node
        self.parent = parent

class ast_func_decl(object):
    def __init__(self, node, parent):
        self.node = node
        self.parent = parent

class ast_prog(object):
    def __init__(self, node, parent):
        self.node = node
        self.parent = parent

def ast(tokens):
    '''
    take tokens and create an abstract syntax tree
    '''
    # iterate through tokens til
    # we hit a 'return', keep 
    # parsing until we reach a terminal
    # symbole
    root_node = ast_prog('prog', None)
    for t in tokens:
        print(t)
        # first search for an exp
      
	
# read in the assembly file name compiled by gcc
source_file = sys.argv[1]

assembly_file = os.path.splitext(source_file)[0] + ".s"

with open(source_file, 'r') as infile, open(assembly_file, 'w') as outfile:
    source = infile.read().strip()
    tokens = lex(source)
    ast = ast(tokens)
    # plug our return value into the assembly and write it out
    #outfile.write(assembly_format.format(retval))
