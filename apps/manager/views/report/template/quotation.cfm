<cfoutput>
	<cfdocument attributeCollection="#args.pdfArgs#"  marginLeft=".2" marginRight=".2">
		<style>
			td {
				border: 1px solid black;
				padding-left: .3em;
				padding-right: .3em;
			}
			table {
				border-collapse: collapse;
			}
		</style>
		<div>
			<cfdocumentitem type="header">
				<table style="border: 0; width: 19cm;">
					<tbody>
						<tr style="border: 0;">
							<td style="border: 0; width: 7cm;">
								#getPrintFullHeader()#
							</td>
							<td style="border: 0; width: 12cm; padding-left: 1in; padding-top: .4in">
								<h2>Preventivo N. #args.data.quotation.getQuotationNumber()#</h2>
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

			#importPrintStyle()#

			<cfoutput>
				<div style="padding-top: 1.2in;">
					<!-- Nota, l'unica UM supportata per i margini sono gli inches, quindi per coerenza
					li uso dappertutto, per allineare body a header uso un -.08in ---->
					<table class="cstmtable" style="margin-top: 1em;width: 100%;">
						<tr>
							<td style="width: 50%;"></td>
							<td style="width: 50%;"><strong>Referente</strong></td>
						</tr>
						<tr>
							<td>
								#args.data.quotation.getCustomer().getName()#<br>
								#args.data.quotation.getCustomer().getStreet()#<br>
								#args.data.quotation.getCustomer().getPostalCode()#<br>
								#args.data.quotation.getCustomer().getCity()#<br>
								#args.data.quotation.getCustomer().getState()#<br>
								#args.data.quotation.getCustomer().getCountry()#<br>
							</td>
							<td rowspan="2">
								Nome: #args.data.quotation.getCustomer().getContactPersonName()# <br>
								Email: #args.data.quotation.getCustomer().getContactPersonEmail()# <br>
							</td>
						</tr>
						<tr>
							<td>
								<strong>Luogo di consegna</strong><br>
								#args.data.customerShippingAddress['name']#<br>
								#args.data.customerShippingAddress['via']#<br>
								#args.data.customerShippingAddress['cap']#<br>
								#args.data.customerShippingAddress['citta']#<br>
								#args.data.customerShippingAddress['provincia']#<br>
								#args.data.customerShippingAddress['paese']#<br>
							</td>
						</tr>
					</table>

					<cfset blundlesPrinted = {}>

					<div style="border-bottom:1px solid ##EAEAEA; padding: 15px 0"></div>
				</div>
			</cfoutput>

			<cfoutput>
				<cfset i = 1>
				<!--- LOOP sulle stanze --->
				<cfloop array="#args.data.zones#" index="stanza">
					<cfif stanza.zoneItems.len() EQ 0>
						<cfcontinue>
					</cfif>
					<cfif i GT 1>
						<!--- Ogni stanza comincia su nuova pagina --->
						<div style="page-break-before: always; margin-top: 1.5in; border: 1px solid black; padding: .2em; font-size: 14pt; font-weight: bold;">#stanza.getName()#</div>
					<cfelse>
						<div style="border: 1px solid black; margin: 0; padding: .2em; width: fit-content; font-size: 14pt; font-weight: bold;">
							#stanza.getName()#
						</div>
					</cfif>
					<!--- Loop sugli oggetti della stanza --->
					<cfset j = 1>
					<cfloop array="#stanza.zoneItems#" index="oggetto">
						<cfif (i EQ 1 and j EQ 3) or (i EQ 1 AND j EQ 7)>
							<div style="page-break-before: always;"></div>
							<div style="margin-top: 1.3in">&nbsp;</div>
						<cfelseif i GT 1 and J GT 1 AND J MOD 4 EQ 1>
							<div style="margin-top: 1.9in">&nbsp;</div>
						</cfif>

						<!--- wrapper per evitare che venga spezzato su due pagine --->
						<div class="item" style="page-break-inside: avoid;">
							<table style="border-collapse: collapse; width: 100%;">
							<tr style="border-collapse: collapse;">
									<td style="width: 3.6cm; border-right: 0;"><strong>Articolo</strong></td>
									<td style="border-left: 0;"></td>
									<td style="width: 2cm; text-align: right;"><strong>Qtà.</strong></td>
									<td style="width: 2cm; text-align: right;"><strong>Prezzo</strong></td>
									<td style="width: 2cm; text-align: right;"><strong>Totale</strong></td>
								</tr>
								<tr style="border-collapse: collapse;">
									<td style="padding-top: .1in; text-align: center; border-right: 0;">
										<cfif IsNull( oggetto.getImage() )>
											<img src="/assets/main/img/img-not-found.png" style="text-align: left; width: 3.6cm; max-width: 100%; object-fit: contain;">
										<cfelse>
											<img src="#oggetto.getImage().getUri()#" style="text-align: left; width: 3.6cm; max-width: 100%; object-fit: contain;">
										</cfif>
									</td>
									<td style="vertical-align: top; padding-top: .2in; border-left: 0; font-size: 11pt;">#oggetto.getProduct().getDescription()#</td>
									<td style="text-align: right;">#oggetto.getQuantity()#</td>
									<td style="text-align: right;">#oggetto.getPrice()# €</td>
									<td style="text-align: right;">#oggetto.getQuantity() * oggetto.getPrice()# €</td>
								</tr>
							</table>
						</div>
						<cfset j = j + 1>
					</cfloop>
					<cfset i = i + 1>
				</cfloop>
				<div style="width: 100%; text-align: right; position: relative;">
					<table style="width: 4in; border-collapse: collapse; position: absolute; right: 0; top: .1in;">
						<tr>
							<td><strong>Totale merce</strong></td>
							<td>#args.data.quotation.getCalculatedAmount()# €</td>
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
							<td>#args.data.quotation.getCalculatedAmount()# €</td>
						</tr>
					</table>
				</div>
			</cfoutput>
		</div>
    </cfdocument>

</cfoutput>
