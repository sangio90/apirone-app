<cfscript>
    model = server["wirebox-apirone"];

    attributeList = [
        {
            from = "346b4a14-4528-4244-9a17-e72babcc73dc", //G4
            to = [
                { code = "Y4", desc = "GRAFICA SURETEN A4 NEGATIVO" },
            ]
        },
        {
            from = "36fa89dc-54c7-477f-8cc2-6a65b505e95d", //GR
            to = [
                { code = "YR", desc = "GRAFICA SURETEN REG NEGATIVO" },
            ]
        },        
        {
            from = "5d90602b-a344-49e6-b476-e9ffe35651ce", //GS
            to = [
                { code = "YS", desc = "GRAFICA SURETEN 15X NEGATIVO" },
            ]
        },
        {
            from = "65f6404b-1e44-460c-abd5-c64ebf452b5d", //G2
            to = [
                { code = "Y2", desc = "GRAFICA SURETEN A2 NEGATIVO" },
            ]
        },
        {
            from = "a06c075d-1876-43e6-8038-569acfde16b8", //GZ
            to = [
                { code = "YZ", desc = "GRAFICA SURETEN 22X NEGATIVO" },
            ]
        },
        {
            from = "b3a65b36-6141-4670-bfa5-ffedf842806b", //GE
            to = [
                { code = "YE", desc = "GRAFICA SURETEN 32V NEGATIVO" },
            ]
        },
        {
            from = "b5d80e0b-dce6-44e5-a2ce-51738425c121", //G3
            to = [
                { code = "Y3", desc = "GRAFICA SURETEN A3 NEGATIVO" },
            ]
        }
    ]

    svc = model.getInstance("AccountService");
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
                newValue = duplicate( thisValue );
                newValue.setAttributeId( newAttrId );
                newValue.setAffectToImage( true );
                attrValueSvc.create( newValue );
            }

        }

    }

</cfscript>