<cfoutput>
	<cfdocument attributeCollection="#args.pdfArgs#" marginTop="2.6" marginLeft="0.1" marginRight="0.1">
		#printStyle()#
		<div>
			<cfdocumentitem type="header">
				<table style="border: 0; width: 19cm; margin-left: 0.1in;">
					<tbody>
						<tr style="border: 0;">
							<td style="border: 0;">
								#getPrintFullHeader()#
							</td>
							<td style="border: 0; width: 9cm; padding-top: .4in;">
								<h2 style="text-align: right">Preventivo N. #args.data.quotation.getQuotationNumber()#/#args.data.quotation.getVersionNumber()#</h2>
								<table style="width: 100%; border: 0;">
									<tr>
										<td style="width: 40%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">Data</td>
										<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black; padding-left: 5px;">#DateFormat( args.data.quotation.getQuotationDate(), "dd/mm/yyyy" )#</td>
									</tr>
									<tr>
										<td style="width: 40%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">Validità offerta</td>
										<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black; padding-left: 5px;">#DateFormat( args.data.quotation.getValidityDate(), "dd/mm/yyyy" )#</td>
									</tr>
									<tr>
										<td style="width: 40%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">Tipo Pagamento</td>
										<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black; padding-left: 5px;">#args.data.quotation.getPaymentMethodName()#</td>
									</tr>
									<tr>
										<td style="width: 40%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">Commerciale di Riferimento</td>
										<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black; padding-left: 5px;">Mario Rossi</td>
									</tr>
								</table>
							</td>
						</tr>
					</tbody>
				</table>

			</cfdocumentitem>

			<cfdocumentitem type="footer">
				#getPrintFooter()#
			</cfdocumentitem>

			<cfoutput>
				<div>
					<table class="cstmtable" style="margin-top: .1in; width: 100%;">
						<tr>
							<td style="width: 50%;"></td>
							<td style="width: 50%; padding-left: 0.05in;"><strong>Indirizzo Spedizione</strong></td>
						</tr>
						<tr>
							<td>
								<table style="width: 100%; padding: 0; border: 0; border-collapse: collapse;">
									<tr style="border: 0">
										<td style="border: 0; font-weight: bold; padding-left: 0.05in;">Ragione Sociale: </td>
										<td style="border: 0; padding-left: 0.05in; width: 65%;">#args.data.quotation.getCustomer().getCompany()#</td>
									</tr>
									<tr style="border: 0">
										<td style="border: 0; font-weight: bold; padding-left: 0.05in;">Telefono: </td>
										<td style="border: 0; padding-left: 0.05in;">#args.data.quotation.getCustomer().getPhone()#</td>
									</tr>
									<tr style="border: 0">
										<td style="border: 0; font-weight: bold; padding-left: 0.05in;">Email: </td>
										<td style="border: 0; padding-left: 0.05in;">#args.data.quotation.getCustomer().getContactPersonEmail()#</td>
									</tr>
									<tr style="border: 0">
										<td style="border: 0; font-weight: bold; padding-left: 0.05in;">Partita IVA: </td>
										<td style="border: 0; padding-left: 0.05in;">#args.data.quotation.getCustomer().getVatNumber()#</td>
									</tr>
									<tr style="border: 0">
										<td style="border: 0; vertical-align: top; font-weight: bold; padding-left: 0.05in;">Indirizzo: </td>
										<td style="border: 0">
											#args.data.quotation.getCustomer().getStreet()# #args.data.quotation.getCustomer().getPostalCode()#<br>
											#args.data.quotation.getCustomer().getCity()#<br>
											#args.data.quotation.getCustomer().getState()#<br>
											#args.data.quotation.getCustomer().getCountry().getIsoCode()#
										</td>
									</tr>
								</table>
							</td>
							<td>
								<cfif structKeyExists(args.data, "customerShippingProfile")>
									<table style="width: 100%; padding: 0; border: 0; border-collapse: collapse;">
										<tr style="border: 0">
											<td style="border: 0; font-weight: bold; padding-left: 0.05in;">Nome: </td>
											<td style="border: 0; width: 75%">#args.data.quotation.getCustomer().getCompany()#</td>
										</tr>
										<tr style="border: 0">
											<td style="border: 0; vertical-align: top; font-weight: bold; padding-left: 0.05in;">Indirizzo: </td>
											<td style="border: 0">
												#args.data.customerShippingProfile['name']#<br>
												#args.data.customerShippingProfile['via']# #args.data.customerShippingProfile['cap']#<br>
												#args.data.customerShippingProfile['provincia']#<br>
												#args.data.customerShippingProfile['paese']#<br>
											</td>
										</tr>
									</table>
								</cfif>
							</td>
						</tr>
					</table>

					<cfset blundlesPrinted = {}>
				</div>
			</cfoutput>

			<cfoutput>
				<cfloop array="#args.data.zones#" index="stanza">
					<cfif stanza.zoneItems.len() EQ 0>
						<cfcontinue>
					</cfif>
					<cfset zoneItemsCount = ArrayLen( stanza.zoneItems )>
					<cfloop from="1" to="#zoneItemsCount#" index="zoneItem">
						<div class="item" style="page-break-inside: avoid !important;">
							<cfif zoneItem == 1>
								<div style="border: 0; margin: 0; margin-top: .1in; padding: .2em; width: fit-content; font-size: 14pt; font-weight: bold;">
									#stanza.getName()#
								</div>
							</cfif>
							<cfset oggetto = stanza.zoneItems[zoneItem]>
							<table style="border-collapse: collapse; width: 100%;">
								<tr>
									<td style="width: 12cm; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; border-right: 0; padding-left: 0.1in;">Articolo</td>
									<td style="width: 2cm; border-left: 0; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; text-align: right; padding-right: 0.1in;">Qty.</td>
									<td style="width: 3cm; border-left: 0; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; text-align: right; padding-right: 0.1in;">Prezzo</td>
									<td style="width: 3cm; border-left: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black; text-align: right; padding-right: 0.1in;">Totale</td>
								</tr>
								<tr>
									<td style="margin: 0 !important; padding: 3px; align-items: center; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; border-right: 0; width: 12cm !important;">
										<table class="hiddenTable">
											<tr>
												<cfif args.params.images>
													<td style="vertical-align: middle; width: 6cm;" rowspan="2">
														<cfif IsNull( oggetto.getImage() )>
															<img src="#expandPath('/assets/main/img/img-not-found.png')#" style="object-fit: contain; width: 6cm !important; max-height: 6cm !important;">
														<cfelse>
															<img src="#expandPath('/assets/main/img/fototesthorizontal.png')#" style="object-fit: contain; width: 6cm !important; max-height: 6cm !important;">
															<!--- <img src="#oggetto.getImage().getUri()#" style="object-fit: contain; width: 6cm !important;"> --->
														</cfif>
													</td>
												</cfif>
												<td>
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
														<cfif !isNull(oggetto.getNotes()) && args.params.notes>
															<span style="font-size: 8pt; text-transform: lowecase">Note: #oggetto.getNotes()#</span>
														</cfif>
													</cfif>
												</td>
											</tr>
											<tr>
												<td style="vertical-align: bottom; padding: 3pt;">
													<cfif IsInstanceOf(oggetto, "com.apirone.core.model.bean.QuotationItemPlate") && oggetto.getFruits().len() GT 0>
														<div style="font-size: 8pt; line-height: 15px; margin-top: 0.1in;">
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
																				<cfif IsArray( fruit.getFruit().getItems() )>
																					<cfloop array="#fruit.getFruit().getItems()#" index="fruitItem">
																						<span style="font-size: 8pt; text-transform: lowecase">
																							#fruitItem.getAttribute().getName()#: #fruitItem.getAttributeValue().getRawValue().getName()#
																						</span>
																					</cfloop>
																					<cfif !isNull(fruit.getNotes()) && args.params.notes>
																						<span style="font-size: 8pt; margin-top: 4pt;">
																							<i>( Note: #fruit.getNotes()# )</i>
																						</span>
																					</cfif>
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
									</td>
									<td style="padding-right: 0; border-left: 0; border-right: 0; border-bottom: 1px solid black; line-height: 12px; width: 2cm !important; text-align: right; padding-right: 0.1in;">
										#oggetto.getQuantity()#
									</td>
									<td style="padding-right: 0; border-left: 0; border-right: 0; border-bottom: 1px solid black; line-height: 12px; width: 3cm !important; text-align: right; padding-right: 0.1in;">
										#LSNumberFormat( oggetto.getPrice().getTotal(), ".99", "it_IT" )# €
									</td>
									<td style="padding-right: 0; border-left: 0; border-bottom: 1px solid black; border-top: 1px solid black; border-right: 1px solid black; line-height: 12px; width: 3cm !important; text-align: right; padding-right: 0.1in;">
										#LSNumberFormat( oggetto.getQuantity() * oggetto.getPrice().getTotal(), ".99", "it_IT" )# €
									</td>
								</tr>
							</table>
						</div>
					</cfloop>
				</cfloop>

				<div style="width: 100%; text-align: right; position: relative;">
					<table style="width: 4in; border-collapse: collapse; position: absolute; right: 0; top: .1in;">
						<tr>
							<td><strong>Totale merce</strong></td>
							<td>#LSNumberFormat( args.data.quotation.getCalculatedAmount(), ".99", "it_IT" )# €</td>
						</tr>
						<tr>
							<td>IVA 20%</td>
							<td>Ancora da definire</td>
						</tr>
						<tr>
							<td>Sconto 50%</td>
							<td>Ancora da definire</td>
						</tr>
						<tr>
							<td><strong>Totale fattura</strong></td>
							<td>#LSNumberFormat( args.data.quotation.getCalculatedAmount(), ".99", "it_IT" )# €</td>
						</tr>
					</table>
				</div>

				#getFinalForm()#
			</cfoutput>
		</div>
    </cfdocument>

</cfoutput>
