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
								<h2>#printLabel('technicalPrint', langId)#: #printLabel('offer', langId)# N° #args.data.quotation.getQuotationNumber()#/#args.data.quotation.getVersionNumber()#</h2>
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
				<cfloop array="#args.data.itemGroups#" index="categoryGroup">
					<cfset groupItemsCount = ArrayLen( categoryGroup.items )>
					<cfset groupPlantsCount = ArrayLen( categoryGroup.plants )>
					<cfset sectionTitle = Len( categoryGroup.id ) ? printCategoryType(categoryGroup.id, categoryGroup.name, langId) : "">
					<cfloop from="1" to="#groupPlantsCount#" index="plantIndex">
						#printPlant(plant = categoryGroup.plants[plantIndex], langId = langId, sectionTitle = plantIndex EQ 1 ? sectionTitle : "")#
					</cfloop>
					<cfloop from="1" to="#groupItemsCount#" index="groupItemIndex">
					<cfset oggetto = categoryGroup.items[groupItemIndex]>
					<cfset zones = oggetto.zones>
					<cfset quantity = oggetto.quantity>
					<cfset oggetto = oggetto.item>
					<cfset hasDim = StructKeyExists(args.data, "modelConfigMap") && StructKeyExists(args.data.modelConfigMap, oggetto.getProduct().getId())>
					<cfif hasDim><cfset thisDimMC = args.data.modelConfigMap[oggetto.getProduct().getId()]></cfif>
					<cfset thisDimType = hasDim && !isNull(oggetto.getProduct().getCategory()) && !isNull(oggetto.getProduct().getCategory().getType()) ? oggetto.getProduct().getCategory().getType().getId() : "">
					<div class="item" style="page-break-inside: avoid;">
						<cfif groupItemIndex EQ 1 AND Len( sectionTitle ) AND groupPlantsCount EQ 0><div class="category-section">#sectionTitle#</div></cfif>
						<table style="border-collapse: collapse; width: 100%;">
							<tr>
								<cfif args.params.images>
									<td style="width: 6cm; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; text-align: left; padding-left: 0.1in"><strong>#printLabel('article', langId)#</strong></td>
									<td style="width: 5cm; border-left: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 0;"></td>
									<td style="width: 9cm; border-left: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;"></td>
								<cfelse>
									<td style="width: 0.1cm; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black;"></td>
									<td style="width: 10.90cm; border-left: 0; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; padding-left: 0.1in;"><strong>#printLabel('article', langId)#</strong></td>
									<td style="width: 9cm; border-left: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;"></td>
								</cfif>
							</tr>
							<tr>
								<cfif args.params.images>
									<td style="margin: 0 !important; padding: 3px; align-items: center; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; width: 6cm !important;">
										<cfif IsNull( oggetto.getImage() )>
											<img src="#expandPath('/assets/main/img/img-not-found.png')#" style="object-fit: contain; width: 6cm !important;">
										<cfelse>
											<!---
												getPath() e non getUri(): cfdocument legge l'immagine dal
												file system, non via HTTP. getUri() punta al repository
												pubblico (altro host) e getRelativePath() è solo un
												frammento, quindi nessuno dei due si risolve nel PDF.
											--->
											<img src="#oggetto.getImage().getPath()#" style="object-fit: contain; width: 6cm !important;">
										</cfif>
									</td>
								<cfelse>
									<td style="padding: 0; margin: 0; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; width: 0.01cm !important;"></td>
								</cfif>
								<td style="padding-right: 0; border-left: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 0; line-height: 12px; width: <cfif args.params.images> 5cm <cfelse> 10.99cm </cfif> !important;">
									<!---
										Codice export della voce, sopra la descrizione. Arriva già
										risolto dal controller (mappa hash -> codice) per non fare una
										lettura per riga. Se la voce non ne ha uno non si stampa nulla,
										senza etichetta a vuoto.
									--->
									<cfset thisHash = oggetto.getHash()>
									<cfset thisExportCode = "">
									<cfif !IsNull( thisHash ) AND StructKeyExists( args.data.exportCodes, thisHash )>
										<cfset thisExportCode = args.data.exportCodes[ thisHash ]>
									</cfif>
									<cfif Len( thisExportCode )>
										<span style="font-size: 7pt; font-weight: bold;">#thisExportCode#</span><br>
									</cfif>
									<span style="font-size: 7pt; text-transform: lowecase">#oggetto.getProduct().getDescription()#</span><br>
									<cfif hasDim && thisDimType NEQ "PLA" && thisDimType NEQ "SEG">
										<div style="font-size: 7pt; margin-top: 2px;">
											<cfif !isNull(thisDimMC.getLength())>
												<span style="white-space: nowrap;">#printLabel('dimLegend3', langId)#:</span>
												<span style="white-space: nowrap;">#thisDimMC.getLength()# x #thisDimMC.getWidth()# x #thisDimMC.getHeight()# cm</span>
											<cfelse>
												<span style="white-space: nowrap;">#printLabel('dimLegend2', langId)#:</span>
												<span style="white-space: nowrap;">#thisDimMC.getWidth()# x #thisDimMC.getHeight()# cm</span>
											</cfif>
										</div>
									</cfif>
									<cfif !isNull(oggetto.getItems()) && oggetto.getItems().len() GT 0>
										<cfset itemsCount = ArrayLen( oggetto.getItems() )>
										<cfloop from="1"  to="#itemsCount#" index="item">
											<cfset item = oggetto.getItems()[item]>
											<span style="font-size: 7pt; text-transform: lowecase">#item.getProductItem().getAttribute().getName()#: #item.getProductItem().getAttributeValue().getRawValue().getName()#</span><br>
										</cfloop>
										<cfif !isNull(oggetto.getNote()) && args.params.note>
											<span style="font-size: 7pt; text-transform: lowecase">Note: #oggetto.getNote()#</span>
										</cfif>
									</cfif>
									<div style="font-size: 7pt; line-height: 15px; margin-top: 3px;">
										#printLabel('qty', langId)#: #quantity#
									</div>
								</td>
								<td style="vertical-align: top; padding-top: 5pt; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black; border-left: 0; padding-left: 5pt; width: 9cm !important;">
									<cfif hasDim && thisDimType EQ "PLA">
										<div style="font-size: 7pt; margin-bottom: 4px;">
											<span style="white-space: nowrap;">#printLabel('dimLegend2', langId)#:</span>
											<span style="white-space: nowrap;">#thisDimMC.getWidth()# x #thisDimMC.getHeight()# mm</span>
										</div>
									</cfif>
									<cfif IsInstanceOf(oggetto, "com.apirone.core.model.bean.QuotationItemPlate") && oggetto.getFruits().len() GT 0>
										<div style="font-size: 7pt; line-height: 15px;">
											#printLabel('fruitList', langId)#:
											<cfif NOT isNull(oggetto.getFruits())>
												<cfset fruitsCount = ArrayLen( oggetto.getFruits() )>
												<ul style="padding: 0 0 0 24px;">
													<cfloop from="1" to="#fruitsCount#" index="fi">
														<cfset fruit = oggetto.getFruits()[fi]>
														<li style="padding: 0">
															<b>P.
																<cfset fruitPositionsCount = ArrayLen( fruit.getPositions() )>
																<cfloop from="1" to="#fruitPositionsCount#" index="fpi">
																	<cfset fruitPosition = fruit.getPositions()[fpi]>
																	#fruitPosition.order + 1#<cfif fpi < fruitPositionsCount > - </cfif>
																</cfloop>
															</b> : Cod.
															<span style="text-transform: lowercase; font-size: 7pt;">
																#fruit.getFruit().getCode()#<br>
																<cfif IsArray( fruit.getItems() )>
																	<cfloop array="#fruit.getItems()#" index="fruitItem">
																		<span style="font-size: 7pt; text-transform: lowecase">
																			#fruitItem.getProductItem().getAttribute().getName()#: #fruitItem.getProductItem().getAttributeValue().getRawValue().getName()#
																		</span><br>
																	</cfloop>
																</cfif>
																<cfif !isNull(fruit.getNote()) && args.params.note>
																	<span style="font-size: 7pt; margin-top: 4pt;">
																		<i>( Note: #fruit.getNote()# )</i>
																	</span>
																</cfif>
															</span>
														</li>
													</cfloop>
												</ul>
											</cfif>
										</div>
									</cfif>
									<cfif hasDim && thisDimType EQ "SEG">
										<div style="font-size: 7pt; margin-bottom: 4px;">
											<span style="white-space: nowrap;">#printLabel('dimLegend2', langId)#:</span>
											<span style="white-space: nowrap;">#thisDimMC.getWidth()# x #thisDimMC.getHeight()# mm</span>
										</div>
									</cfif>
									<cfif structCount(zones) gt 0>
										<div style="font-size: 7pt; line-height: 15px">
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
