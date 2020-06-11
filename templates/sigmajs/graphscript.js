sigma.parsers.gexf(
	'miserable.gexf',
	{// id of the document object model element that contains graph
		container:'sigma-container'
	},
	function(s){//executed when graph displayed
		console.log('graph displayed!')
	}
)