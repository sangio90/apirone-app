<cfoutput>
	<cfdocument attributeCollection="#args.pdfArgs#" marginTop="2.6" marginLeft="0.1" marginRight="0.1">
		#printStyle()#
		<div>
			<cfdocumentitem type="header">
				<table style="border: 0; width: 100%; margin-left: 0.1in; margin-right: 0.1in;">
					<tbody>
						<tr style="border: 0; width: 100%;">
							<td style="border: 0; width: 50%;">
								#getPrintFullHeader()#
							</td>
							<td style="border: 0; width: 50%">
								<h2>Preventivo N. #args.data.quotation.getQuotationNumber()#/#args.data.quotation.getVersionNumber()#</h2>
								<table style="width: 95%; border: 0;">
									<tr>
										<td style="width: 40%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">Data</td>
										<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black; padding-left: 0.05in;">#DateFormat( args.data.quotation.getQuotationDate(), "dd/mm/yyyy" )#</td>
									</tr>
									<tr>
										<td style="width: 40%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">Validità offerta</td>
										<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black; padding-left: 0.05in;">#DateFormat( args.data.quotation.getValidityDate(), "dd/mm/yyyy" )#</td>
									</tr>
									<tr>
										<td style="width: 40%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">Tipo Pagamento</td>
										<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black; padding-left: 0.05in;">#args.data.quotation.getDecodedPaymentMethod()#</td>
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
										<td style="border: 0; padding-left: 0.05in;">#args.data.quotation.getCustomer().getPhoneCell()#</td>
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
											#args.data.quotation.getCustomer().getCountry()#
										</td>
									</tr>
								</table>
							</td>
							<td>
								<cfif structKeyExists(args.data, "customerShippingAddress")>
									<table style="width: 100%; padding: 0; border: 0; border-collapse: collapse;">
										<tr style="border: 0">
											<td style="border: 0; font-weight: bold; padding-left: 0.05in;">Nome: </td>
											<td style="border: 0; width: 75%">#args.data.quotation.getCustomer().getCompany()#</td>
										</tr>
										<tr style="border: 0">
											<td style="border: 0; vertical-align: top; font-weight: bold; padding-left: 0.05in;">Indirizzo: </td>
											<td style="border: 0">
												#args.data.customerShippingAddress['name']#<br>
												#args.data.customerShippingAddress['via']# #args.data.customerShippingAddress['cap']#<br>
												#args.data.customerShippingAddress['provincia']#<br>
												#args.data.customerShippingAddress['paese']#<br>
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
				<cfloop array="#itemsArray#" index="oggetto">
					<cfset zones = oggetto.zones>
					<cfset quantity = oggetto.quantity>
					<cfset oggetto = oggetto.item>
					<div class="item" style="page-break-inside: avoid;">
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
											<img src="#expandPath('/assets/main/img/fototesthorizontal.png')#" style="object-fit: contain; width: 6cm !important;">
											<!--- <img src="#oggetto.getImage().getUri()#" style="object-fit: contain; width: 6cm !important;"> --->
										</cfif>
									</td>
								<cfelse>
									<td style="padding: 0; margin: 0; border-right: 0; width: 0.01cm !important;"></td>
								</cfif>
								<td style="padding-right: 0; border-left: 0; border-right: 0; line-height: 12px; width: <cfif args.params.images> 5cm <cfelse> 10.99cm </cfif> !important;">
									<span style="font-size: 8pt; text-transform: lowecase">#oggetto.getProduct().getDescription()#</span><br>
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
									<div style="font-size: 8pt; line-height: 15px; margin-top: 3px;">
										Qty: #quantity#
									</div>
								</td>
								<td style="vertical-align: top; padding-top: 5pt; border-left: 0; padding-bottom: 5pt; padding-left: 5pt; width: 9cm !important;">
									<cfif IsInstanceOf(oggetto, "com.apirone.core.model.bean.QuotationItemPlate") && oggetto.getFruits().len() GT 0>
										<div style="font-size: 8pt; line-height: 15px;">
											<b>Lista Frutti: </b>
											<cfif NOT isNull(oggetto.getFruits())>
												<cfset fruitsCount = ArrayLen( oggetto.getFruits() )>
												<ul style="padding: 0 0 0 14px;">
													<cfloop from="1" to="#fruitsCount#" index="fi">
														<cfset fruit = oggetto.getFruits()[fi]>
														<li style="padding: 0">
															Cod. 
															<span style="text-transform: lowercase; font-size: 8pt;">
																#fruit.getFruit().getCode()#
																<cfloop array="#fruit.getFruit().getItems()#" index="fruitItem">
																	<span style="font-size: 8pt; text-transform: lowecase">
																		#fruitItem.getAttribute().getName()#: #fruitItem.getAttributeValue().getRawValue().getName()# 
																		&nbsp;</span>
																</cfloop>
																<cfif fi LT fruitsCount>, </cfif>
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
									<cfif structCount(zones) gt 0>
										<div style="font-size: 8pt; line-height: 15px">
											Posizioni: 
											<cfloop collection="#zones#" item="zoneName">
												<div style="font-size: 8pt; line-height: 15px">
													#zoneName#: 
													#arrayToList(zones[zoneName], ", ")#
												</div>
											</cfloop>
										</div>
									</cfif>
								</td>
							</tr>
						</table>
					</div>
				</cfloop>
			</cfoutput>
		</div>
    </cfdocument>

</cfoutput>
