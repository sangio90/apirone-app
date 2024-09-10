<cfoutput>

    <cfset finishes = [
        {
            id = "C1",
            name = "Acciaio lucido" ,
            works = [
                {
                    id = "L2",
                    name = "Incisione simboli",
                },
                {
                    id = "L3",
                    name = "Taglio moduli",
                    variants = [
                        {
                            id = "PL-2MODULI",
                            name = "INCISIONE 2 MODULI"
                        },
                        {
                            id = "PL-LEVETTA",
                            name = "INCISIONE LEVETTA"
                        }
                    ]

                },
                {
                    id = "L4",
                    name = "Taglio forma placca",
                    variants = [
                        {
                            id = "PL-SQUARE",
                            name = "PLACCA MODELLO SQUARE",
                            colors = [
                                {
                                    id: "PL-503",
                                    name: "FORMATO PLACCA 503",
                                }
                            ]
                        }
                    ]
                },
                {
                    id = "L9",
                    name = "Pulitura placche post incisione",
                    colors = [
                        {
                            id: "PL-503",
                            name: "FORMATO PLACCA 503",
                        }
                    ]
                },
                {
                    id = "L10",
                    name = "Satinatura placca",
                    colors = [
                        {
                            id: "PL-503",
                            name: "FORMATO PLACCA 503",
                        }
                    ]
                },
        
            ]
        },
        {
            id = "C2",
            name = "Ottone lucido",
            works = [
                {
                    id = "L5",
                    name = "Pulitura placche",
                },
                {
                    id = "L6",
                    name = "Satinatura placca",
                },
                {
                    id = "L7",
                    name = "Assemblaggio",
                },
            ]
        }
    ]>

    <div id="line-components-root">

        <div class="row mb-3">
            <div class="col-lg-8">
                <h2>#prc.title#</h2>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">

                <div class="tab-content"  id="size-tabs-content">

                    <div class="col-lg-12 text-end mt-3 mb-5">
                        <button class="btn btn-primary btn-sm" data-bind="click:showComponentsList">Carica attributo &raquo;</button>
                    </div>

                </div>
            
            </div>

        </div>

        #view("product/components-list-modal")#

    </div>

    <script>
        var components = #SerializeJSON( prc.components )#;
    </script>

</cfoutput>