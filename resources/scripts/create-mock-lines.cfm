<cfscript>
model = server["wirebox-apirone"];
svc = model.getInstance("LineService");

function create( count ) {
	var json = {
		code: "#Right( CreateUUID(), 5)#",
		name: "name #count#",
		status: { id: "ACT" },
		selectedCategories: [
			{ id: 11 },
			{ id: 12 },
			{ id: 13 }
		],
		thickness: { id: "4MM" },
		texts: [
			text: {
				name: "Traduzione 1 #count#",
				lang: { id: "IT" },
				kind: { id: "NAME" },
			},
			text: {
				name: "Traduzione lunga descrizione 1 #count#",
				lang: { id: "IT" },
				kind: { id: "DESC" },
			},
			text: {
				name: "Translation 2 #count#",
				lang: { id: "EN" },
				kind: { id: "NAME" },
			},
			text: {
				name: "Translation long description 2 #count#",
				lang: { id: "EN" },
				kind: { id: "DESC" },
			},
		]
	};

	var line      = new com.apirone.core.model.bean.Line();
	var status    = new com.apirone.core.model.bean.Status();
	var thickness = new com.apirone.core.model.bean.Thickness();
	var lang      = new com.apirone.core.model.bean.Lang();

	var categories = [];
	for ( var thisCategory in json.selectedCategories ) {
		var category = new com.apirone.core.model.bean.ProductCategory();

		category.setId( thisCategory.id )
		categories.add( category );
	}

	line.setCode( json.code );
	line.setName( json.name );

	line.setStatus( status.setId( json.status.id ) );
	line.setCategories( categories );
	line.setThickness( thickness.setId( json?.thickness?.id ) );

	var texts = [];
	for( var thisText in json.texts ) {
		var textItem = new com.apirone.core.model.bean.Text();

		textItem.setLang( lang.setId( json.texts[thisText].lang.id ) );
		//textItem.setId( json.texts[thisText].id );
		textItem.setName( json.texts[thisText].name );
		texts.add( textItem );
	}

	line.setTexts( texts );

	var thisId = svc.create( line );
	
	return thisId;

}

for ( count=1 ; count < 10000 ; count++ ) {
	thisId = create( count )
	dump(thisId);
}

</cfscript>