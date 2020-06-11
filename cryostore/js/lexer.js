/* - capital 'I' stands for the use of an internal 
   - function, previous way of parsing comments 
   - would break for anyone using /* or /* multi
   - line comment.
   - */

module.exports = lexer

function lexer(){

	'use strict'

	this.position = 0
	this.buflength = 0
	this.buf = null

	this.operandtable = {
		'+':  'PLUS',
    	'-':  'MINUS',
    	'*':  'MULTIPLY',
    	'/':  'DIVIDE',
    	'.':  'PERIOD',
    	'\\': 'BACKSLASH',
    	':':  'COLON',
    	'%':  'PERCENT',
    	'|':  'PIPE',
    	'!':  'EXCLAMATION',
    	'?':  'QUESTION',
	    '#':  'POUND',
	    '&':  'AMPERSAND',
	    ';':  'SEMI',
	    ',':  'COMMA',
	    '(':  'L_PAREN',
	    ')':  'R_PAREN',
	    '<':  'L_ANG',
	    '>':  'R_ANG',
	    '{':  'L_BRACE',
	    '}':  'R_BRACE',
	    '[':  'L_BRACKET',
	    ']':  'R_BRACKET',
	    '=':  'EQUALS'
	}
}

lexer.prototype = {

	nextToken: function() {

		this.skipTokensI()
		if (this.buflength <= this.pos){
			return null
		}

		var c = this.buf.charAt(this.pos)
		var option = this.operandtable[c]

		if(this.testCommentI(c)){
			return this.iterateOverCommentI()
		}else{
			if(option !== undefined){ //if we're in the option table
				return {name: option, value: c, pos:this.pos++}
			}else{ //if we're not in the option table
				if(this.testAlphaI(c)){
					return this.iterateOverIdentifierI()
				}else if(this.testDigitI(c)){
					return this.iterateOverDigitI()
				}else if (this.testQuoteI(c)){
					return this.iterateOverQuoteI(c)
				}else if(this.testSpaceI(c)){
					return this.iterateOverWhitespaceI()
				}else if(this.testNewlineI(c)){
					return this.iterateOverNewlineI()
				}else if(this.testSemiColonI(c)){
					return this.iterateOverSemiColonI()
				}else{
					throw Error('Error at '+ this.pos)
				}
			}
		}
	},

	/* - input for preprocessed data or
	   - raw data into the lexer
	   */
	datain: function(buf){

		this.pos = 0
		this.buf = buf
		this.buflength = buf.length
	},

	/* - skips tokens that aren't code
	   - like whitespace, newlines, etc
	   */
	skipTokensI: function(){

		while (this.buflength > this.pos){
			var c = this.buf.charAt(this.pos)
			if(c === '\t' || c === '\r'){
				this.pos++
			}else{
				break;
			}
		}
	},

	iterateOverSemiColonI: function(){
		var token = {name:"SEMICOLON", value:';', pos:this.pos}
		this.pos++
		return token
	},

	iterateOverNewlineI: function(){
		var token = {name:"NEWLINE", value:'\n', pos:this.pos}
		this.pos++
		return token
	},
	iterateOverWhitespaceI: function(){

		var token = {name:'WHITESPACE', value:' ', pos:this.pos}
		this.pos++
		return token
	},

	iterateOverCommentI: function(){

		var end = this.pos+2
		var c = this.buf.charAt(end) 

		if(this.buf.charAt(this.pos+1) === '/'){
			while(end < this.buflength  && !this.testNewlineI(this.buf.charAt(end))){
				end++
			}
		}else if(this.buf.charAt(this.pos+1) === '*'){
			while(end < this.buflength  && !this.testEndCommentStarI(this.buf.charAt(end-1), this.buf.charAt(end-2))){
				end++
			}
		}
		
		var token = {
			name: 'COMMENT',
			value: this.buf.substring(this.pos, end),
			pos: this.pos
		}
		this.pos = end+1
		return token
	},

	iterateOverIdentifierI: function(){
		var end = this.pos+1
		while(end < this.buflength && this.testAlphaNumI(this.buf.charAt(end))){
			end++
		}
		var token = {
			name: 'IDENTIFIER',
			value: this.buf.substring(this.pos, end),
			pos: this.pos
		}
		this.pos = end
		return token
	},

	iterateOverDigitI: function(){
		var end = this.pos+1
		while(end < this.buflength && this.testDigitI(this.buf.charAt(end))){
			end++
		}
		var token = {
			name: 'NUMBER',
			value: this.buf.substring(this.pos, end),
			pos: this.pos
		}
		this.pos = end
		return token
	},

	iterateOverQuoteI: function(c){
		var end
		if (c === "'"){ //if quote starts with ' look for closing '
			end = this.buf.indexOf("'", this.pos+1) 

		}else{//if quote starts with " look for closing "
			end = this.buf.indexOf('"', this.pos+1) 
		}
		if (end === -1){
			throw Error('You didn\'t close the quote, see '+this.pos)
		}else{
			var token = {
				name: 'QUOTE',
				value: this.buf.substring(this.pos, end+1),
				pos: this.pos
			}
			this.pos = end+1
			return token
		}
	},

	testCommentI: function(c){
		var newchar = this.buf.charAt(this.pos+1)
		return c === '/' && (newchar === '/' || newchar === '*')
	},

	testEndCommentStarI: function(end, endless){
		return end === '/' && endless === '*'
	},

	testNewlineI: function(c){
		return c === '\n'
	},

	testDigitI: function(c){
		return '0' <= c && c <= '9'
	},

	testAlphaI: function(c){
		return ('a'<= c && c <= 'z') ||
	           ('A'<= c && c <= 'Z') ||
	           (c === '_') || (c === '$')
	},

	testAlphaNumI: function(c){
		return ('a'<= c && c <= 'z') ||
	           ('A'<= c && c <= 'Z') ||
	           ('0'<= c && c <= '9') ||
	           (c === '_') || (c === '$')
	},

	testQuoteI: function(c){
		return c === '"' || c === "'"
	},

	testSpaceI: function(c){
		return c === ' '
	},

	testSemiColonI: function(c){
		return c === ';'
	}
}
