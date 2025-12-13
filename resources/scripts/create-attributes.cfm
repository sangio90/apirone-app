<cfscript>



    model = server["wirebox-apirone"];

    svc = model.getInstance("AccountService");

    attributeList = [
        {
            from = "67981aef-88d8-40e9-8db5-29b08cf88020",
            to = [
                { code = "WH11X", desc = "PERICOLO 11X11" },
                { code = "WH15X", desc = "PERICOLO 15X15" },
                { code = "WH20O", desc = "PERICOLO 20X15" },
                { code = "WH22X", desc = "PERICOLO 22X22" },
                { code = "WH25X", desc = "PERICOLO 25X25" },
            ]
        },
        {
            from = "6b9d4649-214b-486d-a675-e11be0ebfdcb",
            to = [
                { code = "PA11X", desc = "DIVIETO 11X11" },
                { code = "PA15X", desc = "DIVIETO 15X15" },
                { code = "PA20O", desc = "DIVIETO 20X15" },
                { code = "PA22X", desc = "DIVIETO 22X22" },
                { code = "PA25X", desc = "DIVIETO 25X25" },
            ]
        },        
        {
            from = "9c043b12-0050-4949-ae91-7e075d03b4ba",
            to = [
                { code = "EM11X", desc = "EMERGENZA 11X11" },
                { code = "EM15X", desc = "EMERGENZA 15X15" },
                { code = "EM20O", desc = "EMERGENZA 20X15" },
                { code = "EM22X", desc = "EMERGENZA 22X22" },
                { code = "EM25X", desc = "EMERGENZA 25X25" },
            ]
        },
        {
            from = "a8995636-1f1e-4869-8b49-976daedaf73b",
            to = [
                { code = "FP11X", desc = "ANTINCENDIO 11X11" },
                { code = "FP15X", desc = "ANTINCENDIO 15X15" },
                { code = "FP20O", desc = "ANTINCENDIO 20X15" },
                { code = "FP22X", desc = "ANTINCENDIO 22X22" },
                { code = "FP25X", desc = "ANTINCENDIO 25X25" },
            ]
        }
    ]

    attrSvc = model.getInstance("AttributeService");
    attrValueSvc = model.getInstance("AttributeValueService");

    for( attrib in attributeList ) {
    	obj = attrSvc.get( attrib.from ); 

        for( attrValue in attrib.to ) {

            text = new com.apirone.core.model.bean.Text();
            lang = new com.apirone.core.model.bean.Lang();
            kind = new com.apirone.core.model.bean.TextKind();
            
            text.setName( attrValue.desc );
            text.setLang( lang.setId("IT") );
            text.setkind( kind.setId("NAME") );

            newAttr = duplicate( obj );

            newAttr.setCode( attrValue.code )
            newAttr.setTexts( [ text ] )

            newAttrId = attrSvc.create( newAttr ); 

            for( thisValue in obj.getValues() ) {
                //var newVAlue = new com.apirone.core.model.bean.AttributeValue();
                newValue = duplicate( thisValue );
                newValue.setAttributeId( newAttrId );
                newValue.setAffectToImage( true );
                attrValueSvc.create( newValue );
            }

        }

    }

</cfscript>