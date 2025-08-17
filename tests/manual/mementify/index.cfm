<cfscript>

	mm = new com.apirone.core.util.Mementify();
	mm.init();

	line = new bean.Line();

	data = {
		id: 99,
		name: "Line name",
		code: "98aew",
		createdAt: now(),
		gone: true,
		book: {
			id: "IT",
			name: "Italiano"
		},
		status: {
			id: "ACT",
			name: "ATTIVO"
		},
		categories: [
			{
				id: "C1",
				name: "Team Cfml"
			},
			{
				id: "C2",
				name: "Team PHP"
			}
		]
	}

	line.setRawMemento( data );

	/*
	echo("<table border=1>
			<tr>
				<td>#dump( DESerializeJSON( SerializeJSON( data ) ) )#</td>
				<td>#dump( DESerializeJSON( SerializeJSON( line ) ) )#</td>
			</tr>
		</table>")
	*/

	dump(line.getBook())

	raw = mm.convert( obj=line, profile="list", 
		mappers = {
			"book.name" = function( item, memento ){ return item.ucase(); },
			"createdAt" = function( item, memento ){ return dateTimeFormat( item, "full" ); }
		}
	);

	dump(raw);

</cfscript>


