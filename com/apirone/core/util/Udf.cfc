<cfcomponent>
	<cffunction
		name      ="prettyString"
		access    ="public"
		returntype="string"
		hint      ="Replaces all evil characters from a string with pretty ones. Usefull for SEO Url."
		output    ="No"
	>
		<cfargument name="str" type="string" required="yes">

		<cfset arguments.str = ReReplaceNoCase( arguments.str, "<[^>]*>", "", "ALL" )>

		<cfset arguments.str = LCase( arguments.str )>
		<cfset arguments.str = RTrim( arguments.str )>
		<cfset arguments.str = ReplaceList(
			arguments.str,
			"#Chr( 224 )#,#Chr( 225 )#,#Chr( 226 )#,#Chr( 227 )#,#Chr( 228 )#,#Chr( 229 )#,#Chr( 193 )#,#Chr( 194 )#,#Chr( 195 )#,#Chr( 196 )#,#Chr( 197 )#,#Chr( 192 )#",
			"a,a,a,a,a,a,a,a,a,a,a,a"
		)>
		<cfset arguments.str = ReplaceList(
			arguments.str,
			"#Chr( 128 )#,#Chr( 200 )#,#Chr( 201 )#,#Chr( 202 )#,#Chr( 203 )#,#Chr( 232 )#,#Chr( 233 )#,#Chr( 234 )#,#Chr( 235 )#",
			"e,e,e,e,e,e,e,e,e"
		)>
		<cfset arguments.str = ReplaceList(
			arguments.str,
			"#Chr( 204 )#,#Chr( 205 )#,#Chr( 206 )#,#Chr( 207 )#,#Chr( 236 )#,#Chr( 237 )#,#Chr( 238 )#,#Chr( 239 )#",
			"i,i,i,i,i,i,i,i"
		)>
		<cfset arguments.str = ReplaceList(
			arguments.str,
			"#Chr( 210 )#,#Chr( 211 )#,#Chr( 212 )#,#Chr( 213 )#,#Chr( 214 )#,#Chr( 215 )#,#Chr( 216 )#,#Chr( 240 )#,#Chr( 241 )#,#Chr( 242 )#,#Chr( 243 )#,#Chr( 244 )#,#Chr( 245 )#,#Chr( 246 )#",
			"o,o,o,o,o,o,o,o,o,o,o,o,o"
		)>
		<cfset arguments.str = ReplaceList(
			arguments.str,
			"#Chr( 181 )#,#Chr( 217 )#,#Chr( 218 )#,#Chr( 219 )#,#Chr( 220 )#,#Chr( 249 )#,#Chr( 250 )#,#Chr( 251 )#,#Chr( 252 )#",
			"u,u,u,u,u,u,u,u,u"
		)>
		<cfset arguments.str = ReplaceList( arguments.str, "#Chr( 131 )#", "f" )>
		<cfset arguments.str = ReplaceList(
			arguments.str,
			"#Chr( 138 )#,#Chr( 154 )#",
			"s,s"
		)>
		<cfset arguments.str = ReplaceList(
			arguments.str,
			"#Chr( 142 )#,#Chr( 158 )#",
			"z,z"
		)>
		<cfset arguments.str = ReplaceList(
			arguments.str,
			"#Chr( 159 )#,#Chr( 165 )#,#Chr( 153 )#,#Chr( 155 )#,#Chr( 221 )#,#Chr( 253 )#,#Chr( 255 )#",
			"y,y,y,y,y,y,y"
		)>
		<cfset arguments.str = ReplaceList(
			arguments.str,
			"#Chr( 162 )#,#Chr( 199 )#,#Chr( 231 )#",
			"c,c,c"
		)>
		<cfset arguments.str = ReplaceList(
			arguments.str,
			"#Chr( 209 )#,#Chr( 241 )#",
			"n,n"
		)>
		<cfset arguments.str = ReReplace( arguments.str, "[^A-Za-z0-9_\-\s]", "", "ALL" )><!---
			tolgo l'underscore
		--->
		<cfset arguments.str = Trim( arguments.str )>
		<cfset arguments.str = ReReplace( arguments.str, "\s+", " ", "ALL" )>
		<cfset arguments.str = Replace( arguments.str, " ", "-", "ALL" )>
		<cfset arguments.str = ReReplace( arguments.str, "-{1,4}", "-", "ALL" )>

		<cfreturn arguments.str>
	</cffunction>

	<cfscript>
	String function pad( string, count, char ){
		var strLen = Len( arguments.string );
		var padLen = arguments.count - strLen;

		if ( padLen LTE 0 ) {
			return arguments.string;
		} else {
			return RepeatString( arguments.char, padLen ) & arguments.string;
		}
	}
	</cfscript>

	<cffunction name="getUniqueID" returntype="numeric">
		<cfquery name="q" datasource="apirone">
			SELECT nextval('uniqueid_seq') AS unique_id
		</cfquery>

		<cfreturn q.unique_id>
	</cffunction>

	<cfscript>
	/**
	 * Elabora un array usando array.each() in parallelo, mantenendo l'ordine iniziale.
	 * Rispettando la struttura della callback: function(item, index) { return result; }
	 * * @param sourceArray L'array di input.
	 * @param callbackFunction La funzione da applicare a ogni elemento, deve restituire il risultato.
	 * @return Un nuovo array con i risultati elaborati e nell'ordine corretto.
	 */
	public Array function eachParallelAndReorder(
		required Array sourceArray,
		required Function callbackFunction,
		required Numeric maxThreads = 4
	) {

		// 1. Array di preparazione: crea una struttura {index: N, item: X} per ogni elemento.
		// Questo è l'array su cui eseguiremo l'iterazione parallela.

		var callback = arguments.callbackFunction; // Per evitare problemi di ambito nelle closure.

		var indexedItems = arguments.sourceArray.map(function(item, index) {
			return {
				index: arguments.index, // L'indice di posizione (1, 2, 3...)
				item: arguments.item    // Il valore/oggetto originale
			};
		});
		
		// 2. Esegui l'elaborazione in parallelo usando array.each() sull'array indicizzato.
		// L'ordine di completamento è casuale.
		indexedItems.each(
			function(indexedStruct) {
				// Qui adattiamo la chiamata per la tua callback esterna (arguments.callbackFunction).
				// La tua callback riceve (item, index) e restituisce il risultato elaborato.
				var processedResult = callback(
					indexedStruct.item, // item
					indexedStruct.index // index
				);
				
				// Salviamo il risultato elaborato all'interno della struttura indicizzata.
				indexedStruct.result = processedResult;
			}, 
			true, // parallel=true
			arguments.maxThreads
		);
		
		// 3. Riordina l'array di struct in base all'indice di posizione ('index').
		// Questo garantisce che l'ordine originale sia ripristinato.
		indexedItems.sort(function(a, b){
			if (a.index < b.index) {
				return -1;
			} else if (a.index > b.index) {
				return 1;
			}
			return 0;
		});
		
		// 4. Estrai i soli risultati elaborati nell'ordine corretto.
		var resultArray = indexedItems.map(function(item) {
			return item.result;
		});
		
		return resultArray;
	}			
	</cfscript>


</cfcomponent>
