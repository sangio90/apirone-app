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
				<!--- il cambio zona e' una rottura: ogni zona parte da pagina nuova.
				      Si conta solo quello che si stampa davvero, le zone vuote sono
				      saltate e non devono lasciare una pagina bianca dietro di se'.
				      Il salto sta sul wrapper della prima voce perche' il titolo zona
				      e' dentro quel blocco. --->
				<cfset zoneStampate = 0>
				<cfloop array="#args.data.zones#" index="stanza">
					<cfif stanza.zoneItems.len() EQ 0>
						<cfcontinue>
					</cfif>
					<cfset zoneItemsCount = ArrayLen( stanza.zoneItems )>
					<cfset zoneStampate = zoneStampate + 1>
					<cfloop from="1" to="#zoneItemsCount#" index="zoneItem">
						<div class="item" style="page-break-inside: avoid;<cfif zoneItem EQ 1 AND zoneStampate GT 1> page-break-before: always;</cfif>">
							<cfif zoneItem == 1>
								<div style="border: 0; margin: 0; margin-top: .1in; padding: .2em; width: fit-content; font-size: 14pt; font-weight: bold;">
									#stanza.getName()#
								</div>
							</cfif>
							<cfset oggetto = stanza.zoneItems[zoneItem]>
							<table style="border-collapse: collapse; width: 100%;">
								<tr>
									<td style="margin: 0 !important; padding: 3px; align-items: center; border-right: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-left: 1px solid black; width: 11cm !important;">
										<cfif IsNull( oggetto.getImage() )>
											<img src="#expandPath('/assets/main/img/img-not-found.png')#" style="object-fit: contain; width: 11cm !important;">
										<cfelse>
											<!---
												getPath() e non getUri(): cfdocument legge l'immagine dal
												file system, non via HTTP. getUri() punta al repository
												pubblico (altro host) e getRelativePath() è solo un
												frammento, quindi nessuno dei due si risolve nel PDF.
											--->
											<img src="#oggetto.getImage().getPath()#" style="object-fit: contain; width: 11cm !important;">
										</cfif>
									</td>
									<td style="padding-right: 0; border-left: 0; border-top: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black; line-height: 12px; width: 9cm !important;">
										<span style="font-size: 7pt; text-transform: lowecase">#oggetto.getProduct().getDescription()#</span><br>
										<cfif !isNull(oggetto.getPosition())>
											<div style="font-size: 7pt; margin-top: 3px; text-transform: lowecase">#printLabel('position', langId)#: #oggetto.getPosition().getCode()#</div>
										</cfif>
										<cfif !isNull(oggetto.getItems()) && oggetto.getItems().len() GT 0>
											<cfset itemsCount = ArrayLen( oggetto.getItems() )>
											<cfloop from="1"  to="#itemsCount#" index="item">
												<cfset item = oggetto.getItems()[item]>
												<span style="font-size: 7pt; text-transform: lowecase">#item.getProductItem().getAttribute().getName()#: #item.getProductItem().getAttributeValue().getRawValue().getName()#</span><br>
											</cfloop>
											<cfif !isNull(oggetto.getQuantity())>
												<cfset zoneQuantity = stanza.getQuantity()>
												<cfset parentZoneQuantity = !isNull(stanza.getOrigin()) ? stanza.getOrigin().getQuantity() : 1>
												<cfset oggettoQuantity = oggetto.getQuantity() * zoneQuantity * parentZoneQuantity>
												<span style="font-size: 7pt; text-transform: lowecase">#printLabel('qty', langId)#: #oggettoQuantity#</span>
											</cfif>
											<cfif IsInstanceOf(oggetto, "com.apirone.core.model.bean.QuotationItemPlate") && oggetto.getFruits().len() GT 0>
												<br><br>
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
											</cfif>
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
