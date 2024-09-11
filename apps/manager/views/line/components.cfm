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

                <ul class="nav nav-tabs" id="size-tabs" role="tablist">
                    
                    <cfloop array="#prc.sizes#" item="item">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="home-tab" data-bs-toggle="tab" type="button" role="tab" aria-selected="true"
                                data-bs-target="##size_#item.getId()#" aria-controls="size_#item.getId()#">#item.getName()#</button>
                        </li>
                    </cfloop>
                </ul>
                  
                <div class="tab-content"  id="size-tabs-content">

                    <div class="col-lg-12 text-end mt-3 mb-5">
                        <button class="btn btn-primary btn-sm" data-bind="click:showComponentsList">Carica attributo &raquo;</button>
                    </div>

                    <table width="100%" class="table">
                        
                        <cfloop array="#finishes#" index="finish">
                        <tr>
                            <td colspan="2"><br><b>Finitura: #finish.name#</b></td>
                        </tr>
                            <cfloop array="#finish.works#" index="work">
                            <tr>
                                <td>#work.id# #work.name#</td>
                                <td width="50"><a href="">Cancella</a></td>
                            </tr>

                                <cfif work.keyExists("variants")>

                                    <cfloop array="#work.variants#" index="variant">
                                        <tr>
                                            <td>-- #variant.id# #variant.name#</td>
                                            <td width="50"><a href="">Cancella</a></td>
                                        </tr>

                                        <cfif variant.keyExists("colors")>
                                            
                                            <cfloop array="#variant.colors#" index="color">
                                            <tr>
                                                <td>---- #color.id# #color.name#</td>
                                                <td width="50"><a href="">Cancella</a></td>
                                            </tr>
                                            </cfloop>

                                        </cfif>

                                    </cfloop>

                                </cfif>

                                <cfif work.keyExists("colors")>

                                    <cfloop array="#work.colors#" index="color">
                                        <tr>
                                            <td>-- #color.id# #color.name#</td>
                                            <td width="50"><a href="">Cancella</a></td>
                                        </tr>

                                    </cfloop>

                                </cfif>

                            
                            </cfloop>
                        </cfloop>
                    
                    </table>

                </div>
            
            </div>

        </div>

        #view("line/components-list-modal")#

    </div>

    <script>
        var components = #SerializeJSON( prc.components )#;
    </script>

</cfoutput>