<cfoutput>
	<cfset langId = (!isNull(args.data.quotation.getLang()) ? UCase(args.data.quotation.getLang().getId()) : "IT")>
	<cfdocument attributeCollection="#args.pdfArgs#" marginTop="2.6" marginLeft="0.1" marginRight="0.1">
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
				<table style="border: 0; width: 20cm; margin-left: 0.1in;">
					<tbody>
						<tr style="border: 0;">
							<td style="border: 0;">
								#getPrintFullHeader()#
							</td>
							<td style="border: 0; width: 9cm; padding-top: .4in;">
								<h2 style="text-align: right; margin-right: .1in;">#printLabel('quotation', langId)# N. #args.data.quotation.getQuotationNumber()#/#args.data.quotation.getVersionNumber()#</h2>
								<table style="width: 100%; border: 0;">
									<tr>
										<td style="width: 40%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">#printLabel('date', langId)#</td>
										<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black; padding-left: 5px;">#DateFormat( args.data.quotation.getQuotationDate(), "dd/mm/yyyy" )#</td>
									</tr>
									<tr>
										<td style="width: 40%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">#printLabel('offerValidity', langId)#</td>
										<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black; padding-left: 5px;">#DateFormat( args.data.quotation.getValidityDate(), "dd/mm/yyyy" )#</td>
									</tr>
									<tr>
										<td style="width: 40%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">#printLabel('paymentMethod', langId)#</td>
										<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black; padding-left: 5px;">#args.data.quotation.getPaymentMethodName()#</td>
									</tr>
									<tr>
										<td style="width: 40%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">#printLabel('salesAgent', langId)#</td>
										<cfif !isNull(args.data.quotation.getSalesAgent())>
											<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black; padding-left: 5px;">#args.data.quotation.getSalesAgent().getAccount().getName()#</td>
										<cfelse>
											<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black; padding-left: 5px;"></td>
										</cfif>
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
							<cfif !isNull(args.data.quotation.getShippingProfile())>
								<td style="width: 50%; padding-left: 0.05in;"><strong>#printLabel('shippingAddress', langId)#</strong></td>
							<cfelse>
								<td style="width: 50%;"></td>
							</cfif>
						</tr>
						<tr>
							<td>
								<cfif !isNull(args.data.quotation.getCustomer())>
									<table style="width: 100%; padding: 0; border: 0; border-collapse: collapse;">
										<tr style="border: 0">
											<td style="border: 0; font-weight: bold; padding-left: 0.05in;">#printLabel('company', langId)#: </td>
											<td style="border: 0; padding-left: 0.05in; width: 65%;">#args.data.quotation.getCustomer().getCompany()#</td>
										</tr>
										<tr style="border: 0">
											<td style="border: 0; font-weight: bold; padding-left: 0.05in;">#printLabel('phone', langId)#: </td>
											<td style="border: 0; padding-left: 0.05in;">#args.data.quotation.getCustomer().getPhone()#</td>
										</tr>
										<tr style="border: 0">
											<td style="border: 0; font-weight: bold; padding-left: 0.05in;">#printLabel('email', langId)#: </td>
											<td style="border: 0; padding-left: 0.05in;">#args.data.quotation.getCustomer().getContactPersonEmail()#</td>
										</tr>
										<tr style="border: 0">
											<td style="border: 0; font-weight: bold; padding-left: 0.05in;">#printLabel('vatNumber', langId)#: </td>
											<td style="border: 0; padding-left: 0.05in;">#args.data.quotation.getCustomer().getVatNumber()#</td>
										</tr>
										<tr style="border: 0">
											<td style="border: 0; vertical-align: top; font-weight: bold; padding-left: 0.05in;">#printLabel('address', langId)#: </td>
											<td style="border: 0">
												#args.data.quotation.getCustomer().getStreet()# #args.data.quotation.getCustomer().getPostalCode()#<br>
												#args.data.quotation.getCustomer().getCity()# #args.data.quotation.getCustomer().getState()#
											</td>
										</tr>
									</table>
								<cfelseif !isNull(args.data.quotation.getLead())>
									<table style="width: 100%; padding: 0; border: 0; border-collapse: collapse;">
										<tr style="border: 0">
											<td style="border: 0; font-weight: bold; padding-left: 0.05in;">#printLabel('lead', langId)#: </td>
											<td style="border: 0; padding-left: 0.05in; width: 65%;">#args.data.quotation.getLead().getName()#</td>
										</tr>
									</table>
								<cfelseif !isNull(args.data.quotation.getOpportunity())>
									<table style="width: 100%; padding: 0; border: 0; border-collapse: collapse;">
										<tr style="border: 0">
											<td style="border: 0; font-weight: bold; padding-left: 0.05in;">#printLabel('opportunity', langId)#: </td>
											<td style="border: 0; padding-left: 0.05in; width: 65%;">#args.data.quotation.getOpportunity().getName()#</td>
										</tr>
									</table>
								</cfif>
							</td>
							<td>
								<cfif !isNull(args.data.quotation.getShippingProfile())>
									<table style="width: 100%; padding: 0; border: 0; border-collapse: collapse;">
										<tr style="border: 0">
											<td style="border: 0; font-weight: bold; padding-left: 0.05in;">#printLabel('shippingName', langId)#: </td>
											<td style="border: 0; width: 75%">#args.data.quotation.getShippingProfile().getCompany()#</td>
										</tr>
										<tr style="border: 0">
											<td style="border: 0; vertical-align: top; font-weight: bold; padding-left: 0.05in;">#printLabel('address', langId)#: </td>
											<td style="border: 0">
												#args.data.quotation.getShippingProfile().getCity()# #args.data.quotation.getShippingProfile().getState()#<br>
												#args.data.quotation.getShippingProfile().getStreet()# #args.data.quotation.getShippingProfile().getPostalCode()#
												#args.data.quotation.getShippingProfile().getCountry().getIsoCode()#<br>
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
								<td style="width: 12cm; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; border-right: 0; padding-left: 0.1in;">#printLabel('article', langId)#</td>
								<td style="width: 2cm; border-left: 0; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; text-align: right; padding-right: 0.1in;">#printLabel('qty', langId)#</td>
								<td style="width: 3cm; border-left: 0; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; text-align: right; padding-right: 0.1in;">#printLabel('price', langId)#</td>
								<td style="width: 3cm; border-left: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black; text-align: right; padding-right: 0.1in;">#printLabel('total', langId)#</td>
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
														<!--- Queste sono quelle che dovrebbero funionare --->
															<img src="#oggetto.getImage().getRelativePath()#" style="object-fit: contain; width: 6cm !important; max-height: 6cm !important;">
															<img src="#oggetto.getImage().getUri()#" style="object-fit: contain; width: 6cm !important; max-height: 6cm !important;">
														<!--- Fine  --->
													</cfif>
												</td>
											</cfif>
											<td>
												<span style="font-size: 8pt; text-transform: lowecase">#!isNull(oggetto.getArticle()) ? oggetto.getArticle().getName() : oggetto.getProduct().getDescription()#</span><br>
												<cfif isNull(oggetto.getArticle())>
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
												<cfif structCount(zones) gt 0>
													<div style="font-size: 8pt; line-height: 15px;">
														Posizioni:
														<cfloop collection="#zones#" item="zoneName">
															<div style="font-size: 8pt; line-height: 15px; padding-left: 3px;">
																<cfif zoneName != 'Non assegnato'>
																	#zoneName#:
																</cfif>
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
									<cfset prezzoFinale = oggetto.getPrice().getTotal()>
									<cfif args.params.discounts>
										<cfset sconto1 = oggetto.getPrice().getDiscount1()>
										<cfset sconto2 = oggetto.getPrice().getDiscount2()>
										<cfset moltiplicatore = (1 - (sconto1 / 100)) * (1 - (sconto2 / 100))>
										<cfif moltiplicatore EQ 0>
											<cfset prezzoIniziale = 0>
										<cfelse>
											<cfset prezzoIniziale = prezzoFinale / moltiplicatore>
										</cfif>
										<cfif sconto1 GT 0 OR sconto2 GT 0>
											<del>#LSNumberFormat( prezzoIniziale, "9,999.99", "it_IT" )# €</del> <br><br>
										</cfif>
									</cfif>
									#LSNumberFormat( prezzoFinale, "9,999.99", "it_IT" )# €
								</td>
								<td style="padding-right: 0; border-left: 0; border-bottom: 1px solid black; border-top: 1px solid black; border-right: 1px solid black; line-height: 12px; width: 3cm !important; text-align: right; padding-right: 0.1in;">
									#LSNumberFormat( quantity * oggetto.getPrice().getTotal(), "9,999.99", "it_IT" )# €
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
								<td style="width: 12cm; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; border-right: 0; padding-left: 0.1in;">#printLabel('service', langId)#</td>
								<td style="width: 2cm; border-left: 0; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; text-align: right; padding-right: 0.1in;">#printLabel('qty', langId)#</td>
								<td style="width: 3cm; border-left: 0; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; text-align: right; padding-right: 0.1in;">#printLabel('price', langId)#</td>
								<td style="width: 3cm; border-left: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black; text-align: right; padding-right: 0.1in;">#printLabel('total', langId)#</td>
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
									#LSNumberFormat( servizio.getPrice().getTotal(), "9,999.99", "it_IT" )# €
								</td>
								<td style="padding-right: 0; border-left: 0; border-bottom: 1px solid black; border-top: 1px solid black; border-right: 1px solid black; line-height: 12px; width: 3cm !important; text-align: right; padding-right: 0.1in;">
									#LSNumberFormat( quantity * servizio.getPrice().getTotal(), "9,999.99", "it_IT" )# €
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
										<td><strong>#printLabel('goodsTotal', langId)#</strong></td>
										<td>
											<cfif args.params.discounts && ( args.data.quotationPrice.getCalculatedTotals()['discount1'] GT 0 OR args.data.quotationPrice.getCalculatedTotals()['discount2'] GT 0 )>
												#LSNumberFormat( args.data.quotationPrice.getCalculatedTotals()['totalGoods'], "9,999.99", "it_IT" )# €
											<cfelse>
												#LSNumberFormat(
													args.data.quotationPrice.getCalculatedTotals()['totalGoods'] *
													( 1 - args.data.quotationPrice.getCalculatedTotals()['discount1'] / 100 ) *
													( 1 - args.data.quotationPrice.getCalculatedTotals()['discount2'] / 100 )
												, "9,999.99", "it_IT" ) # €
											</cfif>
										</td>
									</tr>
									<cfif args.params.discounts && ( args.data.quotationPrice.getCalculatedTotals()['discount1'] GT 0 OR args.data.quotationPrice.getCalculatedTotals()['discount2'] GT 0 )>
										<tr>
											<td><strong>#printLabel('discounts', langId)#</strong></td>
											<td>
												- #LSNumberFormat(
													args.data.quotationPrice.getCalculatedTotals()['totalGoods'] - (args.data.quotationPrice.getCalculatedTotals()['totalGoods'] - ( args.data.quotationPrice.getCalculatedTotals()['totalGoods'] * args.data.quotationPrice.getCalculatedTotals()['discount1'] / 100 ))
													, "9,999.99", "it_IT" )
												# €
											</td>
										</tr>
										<tr>
											<td><strong></strong></td>
											<td>
												- #LSNumberFormat(
													(args.data.quotationPrice.getCalculatedTotals()['totalGoods'] - ( args.data.quotationPrice.getCalculatedTotals()['totalGoods'] * args.data.quotationPrice.getCalculatedTotals()['discount1'] / 100 )) * args.data.quotationPrice.getCalculatedTotals()['discount2'] / 100
													, "9,999.99", "it_IT" )
												# €
											</td>
										</tr>
									</cfif>
									<tr>
										<cfif #!isNull( args.data.quotation.getVatCode())#>
											<td>#args.data.quotation.getVatCode().getName()#</td>
										<cfelse>
											<td>#printLabel('vat', langId)#</td>
										</cfif>
										<td>#LSNumberFormat( args.data.quotationPrice.getCalculatedTotals()['vatAmount'], "9,999.99", "it_IT" )# €</td>
									</tr>
									<cfif #!isNull( args.data.quotationPrice.getShippingCost())#>
										<tr>
											<td>#printLabel('shipping', langId)#</td>
											<td>#LSNumberFormat( args.data.quotationPrice.getShippingCost(), "9,999.99", "it_IT" )# €</td>
										</tr>
									</cfif>
									<tr>
										<td><strong>#printLabel('invoiceTotal', langId)#</strong></td>
										<td>#LSNumberFormat( args.data.quotationPrice.getCalculatedTotals()['total'], "9,999.99", "it_IT" )# €</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
				</div>
				#getFinalForm(langId)#
			</cfoutput>
		</div>
    </cfdocument>

</cfoutput>
