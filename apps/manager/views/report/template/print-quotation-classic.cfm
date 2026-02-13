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
											<!---- TODO: set country
											<cfif len( args.data.quotation?.getCustomer()?.getCountry() )>
												#args.data.quotation.getCustomer().getCountry()#
											</cfif>
											---->
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
												#args.data.customerShippingProfile.getCompany()#<br>
												#args.data.customerShippingProfile.getAddress()# #args.data.customerShippingProfile.getPostalCode()#<br>
												#args.data.customerShippingProfile.getState()#<br>
												#args.data.customerShippingProfile.getCountry().getIsoCode()#<br>
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

				<cfset itemsArray = []>
				<cfloop collection="#args.data.items#" item="hashKey">
					<cfset arrayAppend(itemsArray, args.data.items[hashKey])>
				</cfloop>
				<cfset arraySort(itemsArray, function(a,b) {
					return a.item.getHash() LT b.item.getHash() ? -1 : 1;
				})>
				<cfloop array="#itemsArray#" index="oggetto">
					<div class="item" style="page-break-inside: avoid !important;">
						<cfset zones = oggetto.zones>
						<cfset quantity = oggetto.quantity>
						<cfset oggetto = oggetto.item>
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
														<img src="#expandPath('/assets/main/img/fototestvertical.png')#" style="object-fit: contain; width: 6cm !important; max-height: 6cm !important;">
													<cfelse>
														<img src="#expandPath('/assets/main/img/fototestvertical.png')#" style="object-fit: contain; width: 6cm !important; max-height: 6cm !important;">
														<!--- <img src="#oggetto.getImage().getUri()#" style="object-fit: contain; width: 6cm !important;"> --->
													</cfif>
												</td>
											</cfif>
											<td>
												<span style="font-size: 8pt; text-transform: lowecase">#!isNull(oggetto.getArticle()) ? oggetto.getArticle().getName() : oggetto.getProduct().getDescription()#</span><br>
												<cfif !isNull(oggetto.getArticle())>
													<span style="font-size: 8pt; text-transform: lowecase">#oggetto.getNote()#</span><br>
												</cfif>
												<cfif !isNull(oggetto.getItems()) && oggetto.getItems().len() GT 0>
													<cfset itemsCount = ArrayLen( oggetto.getItems() )>
													<cfloop from="1"  to="#itemsCount#" index="item">
														<cfset item = oggetto.getItems()[item]>
														<span style="font-size: 8pt; text-transform: lowecase">#item.getProductItem().getAttribute().getName()#: #item.getProductItem().getAttributeValue().getRawValue().getName()#</span><br>
													</cfloop>
													<cfif !isNull(oggetto.getNote()) && args.params.note>
														<span style="font-size: 8pt; text-transform: lowecase">Note: #oggetto.getNote()#</span>
													</cfif>
												</cfif>
											</td>
										</tr>
										<tr>
											<td style="vertical-align: bottom; padding: 3pt 0 3px 0;">
												<cfif IsInstanceOf(oggetto, "com.apirone.core.model.bean.QuotationItemPlate") && oggetto.getFruits().len() GT 0>
													<div style="font-size: 8pt; line-height: 15px;">
														Lista Frutti: 
														<cfif NOT isNull(oggetto.getFruits())>
															<cfset fruitsCount = ArrayLen( oggetto.getFruits() )>
															<ul style="padding: 0 0 0 24px;">
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
												<cfif structCount(zones) gt 0>
													<div style="font-size: 8pt; line-height: 15px;">
														Posizioni:
														<cfloop collection="#zones#" item="zoneName">
															<div style="font-size: 8pt; line-height: 15px; padding-left: 3px;">
																#zoneName#: 
																#arrayToList(zones[zoneName], ", ")#
															</div>
														</cfloop>
													</div>
												</cfif>
											</td>
										</tr>
									</table>
								</td>
								<td style="padding-right: 0; border-left: 0; border-right: 0; border-bottom: 1px solid black; line-height: 12px; width: 3cm !important; text-align: right; padding-right: 0.1in;">
									#quantity#
								</td>
								<td style="padding-right: 0; border-left: 0; border-right: 0; border-bottom: 1px solid black; line-height: 12px; width: 3cm !important; text-align: right; padding-right: 0.1in;">
									#LSNumberFormat( oggetto.getPrice().getTotal(), ".99", "it_IT" )# €
								</td>
								<td style="padding-right: 0; border-left: 0; border-bottom: 1px solid black; border-top: 1px solid black; border-right: 1px solid black; line-height: 12px; width: 3cm !important; text-align: right; padding-right: 0.1in;">
									#LSNumberFormat( quantity * oggetto.getPrice().getTotal(), ".99", "it_IT" )# €
								</td>
							</tr>
						</table>
					</div>
				</cfloop>
				<div style="width: 100%; height: 5mm;"></div>
				<cfloop array="#args.data.articleItems#" index="servizio">
					<div class="item" style="page-break-inside: avoid !important;">
						<cfset quantity = servizio.getQuantity()>
						<table style="border-collapse: collapse; width: 100%;">
							<tr>
								<td style="width: 12cm; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; border-right: 0; padding-left: 0.1in;">Servizio</td>
								<td style="width: 2cm; border-left: 0; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; text-align: right; padding-right: 0.1in;">Qty.</td>
								<td style="width: 3cm; border-left: 0; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; text-align: right; padding-right: 0.1in;">Prezzo</td>
								<td style="width: 3cm; border-left: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black; text-align: right; padding-right: 0.1in;">Totale</td>
							</tr>
							<tr>
								<td style="padding: 2mm 2mm 4mm 2mm; align-items: center; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; border-right: 0; width: 12cm !important;">
									<table class="hiddenTable">
										<tr>
											<td>
												<span style="font-size: 8pt; text-transform: lowecase">#servizio.getArticle().getName()#</span><br>
												<span style="font-size: 8pt; text-transform: lowecase">#servizio.getNote()#</span><br>
											</td>
										</tr>
									</table>
								</td>
								<td style="padding-right: 0; border-left: 0; border-right: 0; border-bottom: 1px solid black; line-height: 12px; width: 3cm !important; text-align: right; padding-right: 0.1in;">
									#quantity#
								</td>
								<td style="padding-right: 0; border-left: 0; border-right: 0; border-bottom: 1px solid black; line-height: 12px; width: 3cm !important; text-align: right; padding-right: 0.1in;">
									#LSNumberFormat( oggetto.getPrice().getTotal(), ".99", "it_IT" )# €
								</td>
								<td style="padding-right: 0; border-left: 0; border-bottom: 1px solid black; border-top: 1px solid black; border-right: 1px solid black; line-height: 12px; width: 3cm !important; text-align: right; padding-right: 0.1in;">
									#LSNumberFormat( quantity * oggetto.getPrice().getTotal(), ".99", "it_IT" )# €
								</td>
							</tr>
						</table>
					</div>
				</cfloop>

				<div style="width: 100%; text-align: right; page-break-inside: avoid; margin-top: 0.2in;">
					<table style="border: 0">
						<tr style="border: 0">
							<td style="width: 70%; border: 0"></td>
							<td style="width: 30%; border: 0">
								<table style="width: 4in; border-collapse: collapse;">
									<tr>
										<td><strong>Totale merce</strong></td>
										<td>#LSNumberFormat( args.data.quotationPrice.getCalculatedTotals()['totalGoods'], ".99", "it_IT" )# €</td>
									</tr>
									<tr>
										<td>IVA 20%</td>
										<td>#LSNumberFormat( args.data.quotationPrice.getCalculatedTotals()['vatAmount'], ".99", "it_IT" )# €</td>
									</tr>
									<tr>
										<td><strong>Totale fattura</strong></td>
										<td>#LSNumberFormat( args.data.quotationPrice.getCalculatedTotals()['total'], ".99", "it_IT" )# €</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
				</div>
				#getFinalForm()#
			</cfoutput>
		</div>
    </cfdocument>

</cfoutput>
