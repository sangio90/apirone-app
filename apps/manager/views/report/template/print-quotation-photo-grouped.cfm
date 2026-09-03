<cfoutput>
	<cfset langId = (!isNull(args.data.quotation.getLang()) ? UCase(args.data.quotation.getLang().getId()) : "IT")>
	<cfdocument attributeCollection="#args.pdfArgs#" marginTop="1" marginLeft="0.1" marginRight="0.1">
		#printStyle()#
		<cfif args.data.quotation.getStatusHistory().getStatus().getOrderBy() < 20>
			<style>
				@page {
					background-image: url('/assets/main/img/quotation-watermark-2.jpg');
					background-repeat: repeat;
					background-size: 1920px;
					z-index: 900;
					background-color:rgba(0, 0, 0, 0.1);
				}
			</style>
		</cfif>
		<div>
			<cfdocumentitem type="header">
				<table style="border: 0; width: 100%; margin-left: 0.1in; margin-right: 0.1in;">
					<tbody>
						<tr style="border: 0; width: 100%;">
							<td style="border: 0; width: 15%;">
								<img src='https://apir.co.uk/wp-content/uploads/2024/10/APIR_since1918.png' alt='Apir' style='6cm; height: 40px;'>
							</td>
							<td style="border: 0; text-align: right; padding-right: 60px;">
								<h2>#printLabel('photoPrint', langId)#: #printLabel('offer', langId)# N° #args.data.quotation.getQuotationNumber()#/#args.data.quotation.getVersionNumber()#</h2>
							</td>
						</tr>
					</tbody>
				</table>

			</cfdocumentitem>

			<cfdocumentitem type="footer">
				#getPrintFooter()#
			</cfdocumentitem>

			<cfoutput>
				<cfloop array="#args.data.plants#" index="plant">
					#printPlant(plant = plant, langId = langId)#
				</cfloop>
				<!--- qui le voci non sono in ordine di zona ma raggruppate per categoria
				      ( ogni voce porta dentro di se' l'elenco delle sue zone ), quindi la
				      rottura e' il cambio gruppo: ogni gruppo parte da pagina nuova.
				      Si contano solo i gruppi che stampano qualcosa, altrimenti un gruppo
				      vuoto lascerebbe dietro di se' una pagina bianca. --->
				<!--- fattore unico per le placche ritagliate: la piu' grande riempie il box,
				      le altre le restano proporzionate --->
				<cfset imgScale = printImageScale( data = args.data, boxWidthCm = 12.5, boxHeightCm = 12.5 )>
				<cfset gruppiStampati = 0>
				<cfloop array="#args.data.itemGroups#" index="categoryGroup">
					<cfset groupItemsCount = ArrayLen( categoryGroup.items )>
					<cfset groupPlantsCount = ArrayLen( categoryGroup.plants )>
					<cfset sectionTitle = Len( categoryGroup.id ) ? printCategoryType(categoryGroup.id, categoryGroup.name, langId) : "">
					<cfif groupItemsCount GT 0 OR groupPlantsCount GT 0>
						<cfset gruppiStampati = gruppiStampati + 1>
						<cfif gruppiStampati GT 1>
							<div style="page-break-before: always;"></div>
						</cfif>
					</cfif>
					<cfloop from="1" to="#groupPlantsCount#" index="plantIndex">
						#printPlant(plant = categoryGroup.plants[plantIndex], langId = langId, sectionTitle = plantIndex EQ 1 ? sectionTitle : "")#
					</cfloop>
					<cfloop from="1" to="#groupItemsCount#" index="groupItemIndex">
					<cfset oggetto = categoryGroup.items[groupItemIndex]>
					<cfset zones = oggetto.zones>
					<cfset quantity = oggetto.quantity>
					<cfset oggetto = oggetto.item>
					<div class="item" style="page-break-inside: avoid;">
						<cfif groupItemIndex EQ 1 AND Len( sectionTitle ) AND groupPlantsCount EQ 0><div class="category-section">#sectionTitle#</div></cfif>
						<table style="border-collapse: collapse; width: 100%;">
							<tr>
								<!--- colonna immagine allargata con il box: senza, le foto sborderebbero dalla cella.
								     Riga di chiusura sotto ogni voce, come nelle altre stampe: qui le voci
								     non hanno cornice e senza una linea si confondono fra loro --->
								<td style="margin: 0 !important; padding: 3px 3px 6px 3px; align-items: center; border-right: 0; border-bottom: 1px solid black; width: 12.5cm !important;">
									<!--- box uguale per tutte le immagini: e' quello che rimette
									      alla stessa scala placche orizzontali e verticali --->
									#printItemImage( item = oggetto, data = args.data, boxWidthCm = 12.5, boxHeightCm = 12.5, cmPerMm = imgScale )#
								</td>
								<!--- descrizione appesa in alto: senza, con le foto alte finiva a meta' cella,
								     staccata dal titolo della voce --->
								<td style="vertical-align: top; padding-right: 0; padding-bottom: 6px; border-left: 0; border-bottom: 1px solid black; line-height: 12px; width: <cfif args.params.images> 5cm <cfelse> 10.99cm </cfif> !important;">
									<span style="font-size: 7pt; text-transform: lowecase">#oggetto.getProduct().getDescription()#</span><br>
									<cfif !isNull(oggetto.getItems()) && oggetto.getItems().len() GT 0>
										<cfset itemsCount = ArrayLen( oggetto.getItems() )>
										<cfloop from="1"  to="#itemsCount#" index="item">
											<cfset item = oggetto.getItems()[item]>
											<span style="font-size: 7pt; text-transform: lowecase">#item.getProductItem().getAttribute().getName()#: #item.getProductItem().getAttributeValue().getRawValue().getName()#</span><br>
										</cfloop>
										<cfif !isNull(oggetto.getNote()) && Len( Trim( oggetto.getNote() ) ) && args.params.note>
											<span style="font-size: 7pt; text-transform: lowecase">Note: #oggetto.getNote()#</span>
										</cfif>
									</cfif>
									<div style="font-size: 7pt; line-height: 15px; margin-top: 3px;">
										#printLabel('qty', langId)#: #quantity#
									</div>
									<cfif structCount(zones) gt 0>
										<div style="font-size: 7pt; line-height: 15px; margin-top: 3px;">
											#printLabel('positions', langId)#:
											<cfloop collection="#zones#" item="zoneName">
												<div style="font-size: 7pt; line-height: 15px; padding-left: 3px;">
													#zoneName#: 
													<cfif ArrayLen( zones[zoneName].positions )>
														#arrayToList( zones[zoneName].positions, ", " )#
													<cfelse>
														#printLabel('qty', langId)# #zones[zoneName].quantity#
													</cfif>
												</div>
											</cfloop>
										</div>
									</cfif>
								</td>
							</tr>
						</table>
					</div>
				</cfloop>
				</cfloop>
			</cfoutput>
		</div>
    </cfdocument>

</cfoutput>
