<cfoutput>
	<cfdocument attributeCollection="#args.pdfArgs#"  marginLeft=".2" marginRight=".2">
		#printStyle()#
		<div>
			<cfdocumentitem type="header">
				<table style="border: 0; width: 19cm;">
					<tbody>
						<tr style="border: 0;">
							<td style="border: 0; width: 7cm;">
								#getPrintFullHeader()#
							</td>
							<td style="border: 0; width: 12cm; padding-left: 1in; padding-top: .4in">
								<h2>Preventivo N. #args.data.quotation.getQuotationNumber()#/#args.data.quotation.getVersionNumber()#</h2>
								<table style="width: 100%; border: 0;">
									<tr>
										<td style="width: 40%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">Data</td>
										<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">#DateFormat( args.data.quotation.getQuotationDate(), "dd/mm/yyyy" )#</td>
									</tr>
									<tr>
										<td style="width: 40%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">Validità offerta</td>
										<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">#DateFormat( args.data.quotation.getValidityDate(), "dd/mm/yyyy" )#</td>
									</tr>
									<tr>
										<td style="width: 40%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">Tipo Pagamento</td>
										<td style="width: 60%;border: 0; border-bottom: 1px solid black; border-right: 1px solid black;">#args.data.quotation.getDecodedPaymentMethod()#</td>
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
				<div style="padding-top: 1.2in;">
					<!-- Nota, l'unica UM supportata per i margini sono gli inches, quindi per coerenza
					li uso dappertutto, per allineare body a header uso un -.08in ---->
					<table class="cstmtable" style="margin-top: .1in; width: 100%;">
						<tr>
							<td style="width: 50%;"></td>
							<td style="width: 50%;"><strong>Indirizzo Spedizione</strong></td>
						</tr>
						<tr>
							<td>
								<table style="width: 100%; padding: 0; border: 0; border-collapse: collapse;">
									<tr style="border: 0">
										<td style="border: 0; font-weight: bold;">Ragione Sociale: </td>
										<td style="border: 0">#args.data.quotation.getCustomer().getCompany()#</td>
									</tr>
									<tr style="border: 0">
										<td style="border: 0; font-weight: bold;">Telefono: </td>
										<td style="border: 0">#args.data.quotation.getCustomer().getPhoneCell()#</td>
									</tr>
									<tr style="border: 0">
										<td style="border: 0; font-weight: bold;">Email: </td>
										<td style="border: 0">#args.data.quotation.getCustomer().getContactPersonEmail()#</td>
									</tr>
									<tr style="border: 0">
										<td style="border: 0; font-weight: bold;">Partita IVA: </td>
										<td style="border: 0">#args.data.quotation.getCustomer().getVatNumber()#</td>
									</tr>
									<tr style="border: 0">
										<td style="border: 0; vertical-align: top; font-weight: bold;">Indirizzo: </td>
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
											<td style="border: 0; font-weight: bold;">Nome: </td>
											<td style="border: 0">#args.data.quotation.getCustomer().getCompany()#</td>
										</tr>
										<tr style="border: 0">
											<td style="border: 0; vertical-align: top; font-weight: bold;"">Indirizzo: </td>
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
				<cfset i = 1>
				<!--- LOOP sulle stanze --->
				<cfloop array="#args.data.items#" index="oggetto">
					<cfif i == 1>
						<div style="margin-top: 0.2in">&nbsp;</div>
					<cfelseif ( i MOD 2 EQ 1 )>
						<div style="page-break-before: always;"></div>
						<div style="margin-top: 1.3in">&nbsp;</div>
					</cfif>

					<!--- wrapper per evitare che venga spezzato su due pagine --->
					<div class="item" style="page-break-inside: avoid;">
						<table style="border-collapse: collapse; width: 100%;">
							<tr>
								<td style="width: 10cm; border-right: 0;"><strong>Articolo</strong></td>
								<td style="width: 1cm; text-align: right;"><strong>Qtà.</strong></td>
								<td style="width: 3cm; text-align: right;"><strong>Prezzo</strong></td>
								<td style="width: 3cm; text-align: right;"><strong>Totale</strong></td>
							</tr>
							<tr>
								<td style="width: 10cm; padding-top: 5pt; padding-left: 0; padding-bottom: 5pt;">
									<table class="hiddenTable">
										<tr>
											<td style="width: 3.5cm;">
												<cfif IsNull( oggetto.getImage() )>
													<img src="https://test.apirone.cc/assets/main/img/img-not-found.png" style="text-align: left; width: 100%; object-fit: contain; min-width: 3.5cm; min-height: 4cm;">
												<cfelse>
													<img src="#oggetto.getImage().getUri()#" style="text-align: left; width: 100%; object-fit: contain; min-width: 3.5cm; min-height: 4cm;">
												</cfif>
											</td>
											<td style="width: 5.5cm; padding-left: 2pt; padding-right: 0">
												<span style="word-break: break-all; font-size: 8pt; overflow: hidden; text-transform: lowecase">#oggetto.getProduct().getDescription()#</span><br>
												<cfif !isNull(oggetto.getItems()) && oggetto.getItems().len() GT 0>
													<cfset itemsCount = ArrayLen( oggetto.getItems() ) GTE 9 ? 9 : ArrayLen( oggetto.getItems() )>
													<cfloop from="1"  to="#itemsCount#" index="item">
														<cfset item = oggetto.getItems()[item]>
														<span style="word-break: break-all; font-size: 8pt; overflow: hidden; text-transform: lowecase">#item.getProductItem().getAttribute().getName()#: #item.getProductItem().getAttributeValue().getRawValue().getName()#</span><br>
													</cfloop>
													<cfif !isNull(oggetto.getNotes()) && args.params.notes>
														<span style="word-break: break-all; font-size: 8pt; overflow: hidden; text-transform: lowecase">Note: #oggetto.getNotes()#</span>
													</cfif>
												</cfif>
											</td>
										</tr>
										<tr>
											<cfif IsInstanceOf(oggetto, "com.apirone.core.model.bean.QuotationItemPlate") && oggetto.getFruits().len() GT 0>
												<td colspan="2" style="padding-left: 5pt; font-size: 8pt; line-height: 20px;">
													<b>Lista Frutti: </b>
													<cfif NOT isNull(oggetto.getFruits())>
														<cfset fruitsCount = ArrayLen( oggetto.getFruits() )>
														<cfloop from="1" to="#fruitsCount#" index="fi">
															<cfset fruit = oggetto.getFruits()[fi]>
															Cod. <span style="text-transform: lowercase; font-size: 8pt;">
																#fruit.getFruit().getCode()#<cfif fi LT fruitsCount>, </cfif>
																<cfif !isNull(fruit.getNotes()) && args.params.notes>
																	<span style="font-size: 8pt; margin-top: 4pt;">
																		<i>(Note: #fruit.getNotes()#)</i>
																	</span>
																</cfif>
															</span>
														</cfloop>
													</cfif>
												</td>
											</cfif>
										</tr>
										<tr>
											<td colspan="2" style="padding-left: 5pt; font-size: 8pt; line-height: 20px;">
												<b>Posizioni: </b> [01_CUCINA]: 02, [01_BAGNO]: 04
											</td>
										</tr>
									</table>
								</td>
								<td style="width: 1cm; text-align: right; font-size: 8pt;">#oggetto.getQuantity()#</td>
								<td style="width: 3cm; text-align: right; font-size: 8pt;">#LSNumberFormat( oggetto.getPrice(), ".99", "it_IT" )# €</td>
								<td style="width: 3cm; text-align: right; font-size: 8pt;">#LSNumberFormat( oggetto.getQuantity() * oggetto.getPrice(), ".99", "it_IT" )# €</td>
							</tr>
						</table>
					</div>
					<cfset i = i + 1>
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
