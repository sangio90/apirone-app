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
					<div class="item" style="page-break-inside: avoid;">
						<cfif groupItemIndex EQ 1 AND Len( sectionTitle ) AND groupPlantsCount EQ 0><div class="category-section">#sectionTitle#</div></cfif>
						<table style="border-collapse: collapse; width: 100%;">
							<tr>
								<td style="margin: 0 !important; padding: 3px; align-items: center; border-right: 0; width: 11cm !important;">
									<cfif IsNull( oggetto.getImage() )>
										<img src="#expandPath('/assets/main/img/img-not-found.png')#" style="object-fit: contain; width: 11cm !important;">
									<cfelse>
										<img src="#expandPath('/assets/main/img/fototesthorizontal.png')#" style="object-fit: contain; width: 11cm !important;">
										<!--- Queste sono quelle che dovrebbero funionare --->
											<img src="#oggetto.getImage().getRelativePath()#" style="object-fit: contain; width: 11cm !important;">
											<img src="#oggetto.getImage().getUri()#" style="object-fit: contain; width: 11cm !important;">
										<!--- Fine  --->
									</cfif>
								</td>
								<td style="padding-right: 0; border-left: 0; line-height: 12px; width: <cfif args.params.images> 5cm <cfelse> 10.99cm </cfif> !important;">
									<span style="font-size: 7pt; text-transform: lowecase">#oggetto.getProduct().getDescription()#</span><br>
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
									<cfif structCount(zones) gt 0>
										<div style="font-size: 7pt; line-height: 15px; margin-top: 3px;">
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
