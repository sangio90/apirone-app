<cfoutput>
	<cfdocument attributeCollection="#args.pdfArgs#" marginTop="1" marginLeft="0.1" marginRight="0.1">
		#printStyle()#
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
										<td style="width: 6cm; border-right: 0; text-align: left; padding-left: 0.1in"><strong>Articolo</strong></td>
										<td style="width: 5cm; border-left: 0; border-right: 0;"></td>
										<td style="width: 9cm; border-left: 0; text-align: right;"></td>
									<cfelse>
										<td style="width: 0.01cm; border-right: 0;"></td>
										<td style="width: 10.99cm; border-left: 0; border-right: 0; padding-left: 0.1in;"><strong>Articolo</strong></td>
										<td style="width: 9cm; border-left: 0; text-align: right;"></td>
									</cfif>
								</tr>
								<tr>
									<cfif args.params.images>
										<td style="margin: 0 !important; padding: 3px; align-items: center; border-right: 0; width: 6cm !important;">
											<cfif IsNull( oggetto.getImage() )>
												<img src="#expandPath('/assets/main/img/img-not-found.png')#" style="object-fit: contain; width: 6cm !important;">
											<cfelse>
												<!--- <img src="#oggetto.getImage().getUri()#" style="object-fit: contain; width: 6cm !important;"> --->
											<img src="#expandPath('/assets/main/img/fototesthorizontal.png')#" style="object-fit: contain; width: 6cm !important;">
											</cfif>
										</td>
									<cfelse>
										<td style="padding: 0; margin: 0; border-right: 0; width: 0.01cm !important;"></td>
									</cfif>
									<td style="padding-right: 0; border-left: 0; border-right: 0; line-height: 12px; width: <cfif args.params.images> 5cm <cfelse> 10.99cm </cfif> !important;">
										<span style="font-size: 8pt; text-transform: lowecase">#oggetto.getProduct().getDescription()#</span><br>
										<cfif !isNull(oggetto.getPosition())>
											<div style="font-size: 8pt; margin-top: 3px; text-transform: lowecase">Posizione: #oggetto.getPosition()#</div>
										</cfif>
										<cfif !isNull(oggetto.getItems()) && oggetto.getItems().len() GT 0>
											<cfset itemsCount = ArrayLen( oggetto.getItems() )>
											<cfloop from="1"  to="#itemsCount#" index="item">
												<cfset item = oggetto.getItems()[item]>
												<span style="font-size: 8pt; text-transform: lowecase">#item.getProductItem().getAttribute().getName()#: #item.getProductItem().getAttributeValue().getRawValue().getName()#</span><br>
											</cfloop>
											<cfif !isNull(oggetto.getQuantity())>
												<span style="font-size: 8pt; text-transform: lowecase">Qty: #oggetto.getQuantity()#</span>
											</cfif>
											<cfif !isNull(oggetto.getNotes()) && args.params.notes>
												<span style="font-size: 8pt; text-transform: lowecase">Note: #oggetto.getNotes()#</span>
											</cfif>
										</cfif>
									</td>
									<td style="vertical-align: top; padding: 5pt; border-left: 0; width: 9cm !important;">
										<cfif IsInstanceOf(oggetto, "com.apirone.core.model.bean.QuotationItemPlate") && oggetto.getFruits().len() GT 0>
											<div style="font-size: 8pt; line-height: 15px;">
												<b>Lista Frutti: </b>
												<cfif NOT isNull(oggetto.getFruits())>
													<cfset fruitsCount = ArrayLen( oggetto.getFruits() )>
													<ul style="padding: 0 0 0 14px;">
														<cfloop from="1" to="#fruitsCount#" index="fi">
															<cfset fruit = oggetto.getFruits()[fi]>
															<li style="padding: 0">
																<b>P.#fruit.getPosition()#</b> : Cod. 
																<span style="text-transform: lowercase; font-size: 8pt;">
																	#fruit.getFruit().getCode()#
																	<cfloop array="#fruit.getFruit().getItems()#" index="fruitItem">
																		<span style="font-size: 8pt; text-transform: lowecase">
																			#fruitItem.getAttribute().getName()#: #fruitItem.getAttributeValue().getRawValue().getName()#</span>
																	</cfloop>
																	<cfif !isNull(fruit.getNotes()) && args.params.notes>
																		<span style="font-size: 8pt; margin-top: 4pt;">
																			<i>( Note: #fruit.getNotes()# )</i>
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
