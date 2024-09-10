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



                    <!-----
                    <cfset n = 1>
                    <cfloop array="#prc.sizes#" item="item">
                        <div class="tab-pane fade #(n EQ 1 ? 'show active' : '')#" role="tabpanel" tabindex="0"
                            id="size_#item.getId()#" 
                            aria-labelledby="size_#item.getId()#">
                                <form action="/manager/lines/save" class="form-horizontal" method="post" id="lines-detail-form_#item.getId()#">
                                
                                <section class="card">
                                    
                                    <div class="card-body">

                                        <div>

                                            <h2>Configurazione finiture per < #item.getId()# > </h2>

                                            <label>
                                                Finitura
                                            </label>

                                            <select class="form-control">
                                                <cfloop array="#groups[1].items#" item="comp">
                                                    <option>#comp.name#</option>
                                                </cfloop>
                                            </select>

                                            <label class="mt-3">
                                                Cerca lavorazioni
                                            </label>

                                            <input value="" class="form-control">

                                            <table width="100%">
                                                <tr>
                                                    <td colspan="2"><b>LAVORAZIONI</b></td>
                                                </tr>
                                                <cfloop array="#works#" index="work">
                                                <tr>
                                                    <td>#work.id# - #work.name#</td>
                                                    <td width=50><input type="checkbox"></td>
                                                </tr>
                                                </cfloop>
                                            </table>                                            

                                            <input class="btn btn-primary mt-3" style="width: 250px;" onclick="showWorks()" value="Aggiungi lavorazioni per finitura">
                                                
                                        </div>

                                        <hr>

                                        <div style="display: none;" id="table-works">

                                            <table width="100%">
                                                <cfloop array="#worksForColors#" index="color">
                                                <tr>
                                                    <td colspan="2"><b>LAVORAZIONE: #color.name#</b></td>
                                                </tr>
                                                    <cfloop array="#color.works#" index="lav">
                                                    <tr>
                                                        <td>#lav.id# #lav.name#</td>
                                                        <td width="50"><a href="">Cancella</a></td>
                                                    </tr>
                                                    </cfloop>
                                                </cfloop>
                                            </table>
                                        
                                        </div>                              


                                        <hr>

                                        <div>
                                        
                                            <a href="##" data-bind="click:showComponentsList">+ Aggiungi materia prima</a>
                                            |
                                            <a href="javascript:addComponents()">+ Aggiungi lavorazione</a>
                                            |
                                            <a href="##" data-bind="click:showConfig" data-size="#item.getId()#">Mostra</a>
                                            <br>

                                            <div style="display:none" id="comp-config_#item.getId()#">

                                                <h2>Configurazione materie prime per < #item.getId()# > </h2>

                                                <table width="100%">
                                                    <tr>
                                                        <td colspan="2"><b>MATERIALI</b></td>
                                                        <td colspan="1"><b>VARIANTI</b></td>
                                                        <td colspan="1"><b>COLORI</b></td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="99"><img src="/assets/main/img/pixel.png" height="3" width="100%" vspace="10"></td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            MATACCINOLAMAPP<br>
                                                            <b style="background: ##F0ED85; padding:5px;">LAMIERA DI FISSAGGIO INOX X APPLIQU</b>
                                                        </td>
                                                        <td></td>
                                                        <td></td>
                                                        <td></td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                        <td></td>
                                                        <td>
                                                            ARMATURA VERTICALE X PLACCHE 502	
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                        <td></td>
                                                        <td></td>
                                                        <td>
                                                            NERO<br>
                                                            <hr>
                                                            TRASPARENTE<br>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                        <td></td>
                                                        <td colspan="99"><img src="/assets/main/img/pixel.png" height="1" width="100%" vspace="10"></td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                        <td></td>
                                                        <td>
                                                            ARMATURA ORIZZONTALE X PLACCHE 502
                                                        </td>
                                                    </tr>
                                                        <td></td>
                                                        <td></td>
                                                        <td></td>
                                                        <td>
                                                            BIANCO<br>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="99"><img src="/assets/main/img/pixel.png" height="1" width="100%" vspace="10"></td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            MATACCOTTLEVETT<br>
                                                            <b style="background: ##F0ED85; padding:5px;">LEVETTA IN OTTONE GREZZO	</b>
                                                        <td></td>
                                                        <td></td>
                                                        <td></td>
                                                    </tr>

                                                    <tr>
                                                        <td></td>
                                                        <td></td>
                                                        <td>
                                                            LEVETTA FORMA AVIO
                                                        </td>
                                                    </tr>
                                                        <td></td>
                                                        <td></td>
                                                        <td></td>
                                                        <td>
                                                            OTTONE ANTICATO SCURO
                                                            <hr>
                                                            OTTONE BRONZATO CHIARO
                                                            <hr>
                                                            OTTONE BRONZATO SCURO
                                                        </td>
                                                        <td>
                                                            <i class="fas fa-image"></i>
                                                            <hr>
                                                            <i class="fas fa-image"></i>
                                                            <hr>
                                                            <i class="fas fa-image"></i>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                        <td></td>
                                                        <td colspan="99"><img src="/assets/main/img/pixel.png" height="1" width="100%" vspace="10"></td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                        <td></td>
                                                        <td>
                                                            LEVETTA FORMA CILINDRICA	
                                                        </td>
                                                    </tr>
                                                        <td></td>
                                                        <td></td>
                                                        <td></td>
                                                        <td>
                                                            OTTONE BRONZATO CHIARO
                                                            <hr>
                                                            OTTONE BRONZATO SCURO
                                                        </td>
                                                        <td>
                                                            <i class="fas fa-image"></i>
                                                            <hr>
                                                            <i class="fas fa-image"></i>
                                                            <hr>
                                                            <i class="fas fa-image"></i>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="99"><img src="/assets/main/img/pixel.png" height="2" width="100%" vspace="10"></td>
                                                    </tr>
                                                    <tr>
                                                        <td>MATACC000LED000</td>
                                                        <td><b style="background: ##F0ED85; padding:5px;">LED X PLACCA	</b></td>
                                                    </tr>
                                                    <tr>
                                                        <td></td>
                                                        <td></td>
                                                        <td>
                                                            12 O 24 VOLT
                                                            <hr>
                                                            230 VOLT
                                                        </td>
                                                        <td>
                                                            BIANCO
                                                            <hr>
                                                            NERO
                                                            <hr>
                                                            TRASPARENTE
                                                        </td>

                                                    </tr>
                                                </table>

                                            </div>

                                        </div>
                                        
                                        <!----
                                        <cfloop array="#prc.components#" item="item">
                                            <div class="form-group row pb-3 ">
                                                <div class="col-sm-12">
                                                    <b>#item.name#</b>
                                                    
                                                    <cfloop array="#item.values#" item="value">
                                                        #value.name# <a href="javascript:addProducts()">+ Aggiungi prodotto</a> | <a href="javascript:addComponents()">+ Aggiungi componente</a><br>
                                                    </cfloop>

                                                </div>
                                            </div>

                                        </cfloop>
                                        ---->
                                    
                                    </div>

                                    <footer class="card-footer">
                                        <div class="row justify-content-end">
                                            <div class="col-sm-9">
                                                <button class="btn btn-primary">Salva &raquo;</button>
                                                <input type="hidden" name="id" value="" />
                                            </div>
                                        </div>
                                    </footer>
                                
                                </section>
                            
                                </form>
                        </div>
                        <cfset n++>
                    </cfloop>
                    ---->
                </div>
            
            </div>

        </div>

        #view("product/components-list-modal")#

    </div>

    <script>
        var components = #SerializeJSON( prc.components )#;
    </script>

</cfoutput>