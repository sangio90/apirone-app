<cfoutput>
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
								<h2>Stampa Tecnica: Offerta N° #args.data.quotation.getQuotationNumber()#/#args.data.quotation.getVersionNumber()#</h2>
							</td>
						</tr>
					</tbody>
				</table>

			</cfdocumentitem>

			<cfdocumentitem type="footer">
				#getPrintFooter()#
			</cfdocumentitem>

			<cfoutput>
				<cfloop array="#args.data.zones#" index="stanza">
					<cfif stanza.zoneItems.len() EQ 0>
						<cfcontinue>
					</cfif>
					<cfset zoneItemsCount = ArrayLen( stanza.zoneItems )>
					<cfloop from="1" to="#zoneItemsCount#" index="zoneItem">
						<div class="item" style="page-break-inside: avoid;">
							<cfif zoneItem == 1>
								<div style="border: 0; margin: 0; margin-top: .1in; padding: .2em; width: fit-content; font-size: 14pt; font-weight: bold;">
									#stanza.getName()#
								</div>
							</cfif>
							<cfset oggetto = stanza.zoneItems[zoneItem]>
							<table style="border-collapse: collapse; width: 100%;">
								<tr>
									<cfif args.params.images>
										<td style="width: 6cm; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; text-align: left; padding-left: 0.1in"><strong>Articolo</strong></td>
										<td style="width: 5cm; border-left: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 0;"></td>
										<td style="width: 9cm; border-left: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;"></td>
									<cfelse>
										<td style="width: 0.1cm; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black;"></td>
										<td style="width: 10.90cm; border-left: 0; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; padding-left: 0.1in;"><strong>Articolo</strong></td>
										<td style="width: 9cm; border-left: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black; text-align: right;"></td>
									</cfif>
								</tr>
								<tr>
									<cfif args.params.images>
										<td style="margin: 0 !important; padding: 3px; align-items: center; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; width: 6cm !important;">
											<cfif IsNull( oggetto.getImage() )>
												<img src="#expandPath('/assets/main/img/img-not-found.png')#" style="object-fit: contain; width: 6cm !important;">
											<cfelse>
												<!--- <img src="#oggetto.getImage().getUri()#" style="object-fit: contain; width: 6cm !important;"> --->
											<img src="#expandPath('/assets/main/img/fototesthorizontal.png')#" style="object-fit: contain; width: 6cm !important;">
											</cfif>
										</td>
									<cfelse>
										<td style="padding: 0; margin: 0; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; width: 0.1cm !important;"></td>
									</cfif>
									<td style="padding-right: 0; border-left: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 0; line-height: 12px; width: <cfif args.params.images> 5cm <cfelse> 10.9cm </cfif> !important;">
										<span style="font-size: 8pt; text-transform: lowecase">#oggetto.getProduct().getDescription()#</span><br>
										<cfif !isNull(oggetto.getPosition())>
											<div style="font-size: 8pt; margin-top: 3px; text-transform: lowecase">Posizione: #oggetto.getPosition().getCode()#</div>
										</cfif>
										<cfif !isNull(oggetto.getItems()) && oggetto.getItems().len() GT 0>
											<cfset itemsCount = ArrayLen( oggetto.getItems() )>
											<cfloop from="1"  to="#itemsCount#" index="item">
												<cfset item = oggetto.getItems()[item]>
												<span style="font-size: 8pt; text-transform: lowecase">#item.getProductItem().getAttribute().getName()#: #item.getProductItem().getAttributeValue().getRawValue().getName()#</span><br>
											</cfloop>
											<cfif !isNull(oggetto.getQuantity())>
												<cfset zoneQuantity = stanza.getQuantity()>
												<cfset parentZoneQuantity = !isNull(stanza.getOrigin()) ? stanza.getOrigin().getQuantity() : 1>
												<cfset oggettoQuantity = oggetto.getQuantity() * zoneQuantity * parentZoneQuantity>
												<span style="font-size: 8pt; text-transform: lowecase">Qty: #oggettoQuantity#</span>
											</cfif>
											<cfif !isNull(oggetto.getNote()) && args.params.note>
												<span style="font-size: 8pt; text-transform: lowecase">Note: #oggetto.getNote()#</span>
											</cfif>
										</cfif>
									</td>
									<td style="vertical-align: top; padding: 5pt; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black; border-left: 0; width: 9cm !important;">
										<cfif IsInstanceOf(oggetto, "com.apirone.core.model.bean.QuotationItemPlate") && oggetto.getFruits().len() GT 0>
											<div style="font-size: 8pt; line-height: 15px;">
												Lista Frutti:
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
																<span style="text-transform: lowercase; font-size: 8pt;">
																	#fruit.getFruit().getCode()#<br>
																	<cfif IsArray( fruit.getItems() )>
																		<cfloop array="#fruit.getItems()#" index="fruitItem">
																			<span style="font-size: 8pt; text-transform: lowecase">
																				#fruitItem.getProductItem().getAttribute().getName()#: #fruitItem.getProductItem().getAttributeValue().getRawValue().getName()#
																			</span><br>
																		</cfloop>
																	</cfif>
																	<cfif !isNull(fruit.getNote()) && args.params.note>
																		<span style="font-size: 8pt; margin-top: 4pt;">
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
