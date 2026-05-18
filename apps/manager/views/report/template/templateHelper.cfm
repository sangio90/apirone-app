<cffunction name="getPrintHeader">
    <!--- TODO: move website to variable --->
    <cfreturn "<img src='https://test.apirone.cc/assets/main/img/logo.png' alt='Apir' style='width: 100%; height: 40px;'>">
</cffunction>

<cffunction name="getPrintFullHeader">
	<cfoutput>
		<div style="width: 10cm">
			<br>
			<img src='https://apir.co.uk/wp-content/uploads/2024/10/APIR_since1918.png' alt='Apir' style='6cm; height: 40px;'>
			<br>
			<strong style="font-size: 11pt;">APIR s.r.l. a socio unico</strong>
			<div style="line-height: 8pt;">
				<strong style="line-height: 10pt;">
					Via prato delle Valli, 58
					<br>
					47892 Acquaviva Repubblica di San Marino
				</strong>
				<br>
				<span style="font-size: 7pt; line-height: 8pt;">
					Cap.Soc. EURO 25.800,00 - Ric.Giur. del 06/05/99 Reg. Soc. N.1930
					<br>
					FROM ITALY: Tel.0549/962211 * Fax.0549/904636
					<br>
					FROM OTHER COUNTRIES: Tel(+)378/962211 * Fax.(+)378/904636
					<br>
					Cod. Oper. Econ. SM 07240
					<br>
					<div style="font-size: 8pt"><strong>E-Mail: <span class="blue" style="font-size: 8pt;">info@apir.com</span> - Web: <span class="blue" style="font-size: 8pt;">https://www.apir.com</span></strong></div>
				</span>
			</div>
		</div>

	</cfoutput>
</cffunction>

<cffunction name="getPrintFooter">
    <cfsavecontent variable="local.html">
        <cfoutput>
            <div>
                <table style='width: 100%; border-collapse:collapse'>
                    <tr>
                        <td style='border: 0; padding-left:25px;'>#cfdocument.currentpagenumber#/#cfdocument.totalpagecount#</td>
                        <td style='border: 0; padding-right:25px;' align='right'>Apir Srl - #LsDateFormat( now(), 'dd/mm/yyyy' )#</td>
                    </tr>
                </table>
            </div>
        </cfoutput>
    </cfsavecontent>

    <cfreturn local.html>

</cffunction>

<cffunction name="printComponents">
    <!--- print components by a struct --->
    <cfargument name="components" required=true>
    <cfloop array="#components#" item="component">
        <cfoutput>
        - #component.shortId# - <b>#component.quantity#

            <cfif component?.typeId == "base">
                + #component.override.quantity# = #component.totalQuantity#
            </cfif>

            #component.rawProduct.measurementUnit.id#</b> x #component.rawProduct.name# (<i>#component.rawProduct.id#</i>)
            - #component.variant.name# (<i>#component.variant.id#</i>)
            - #component.color.name# (<i>#component.color.id#</i>)<br/>
        </cfoutput>
    </cfloop>
</cffunction>



<cffunction name="printLabel">
	<cfargument name="key" required="true">
	<cfargument name="langId" default="IT">
	<cfset local.lang = UCase(arguments.langId)>
	<cfset local.labels = {
		"IT": {
			"quotation":      "Preventivo",
			"date":           "Data",
			"offerValidity":  "Validità offerta",
			"paymentMethod":  "Tipo Pagamento",
			"salesAgent":     "Commerciale di Riferimento",
			"shippingAddress":"Indirizzo Spedizione",
			"company":        "Ragione Sociale",
			"phone":          "Telefono",
			"email":          "Email",
			"vatNumber":      "Partita IVA",
			"address":        "Indirizzo",
			"lead":           "Lead",
			"opportunity":    "Opportunità",
			"shippingName":   "Nome",
			"article":        "Articolo",
			"qty":            "Qty.",
			"price":          "Prezzo",
			"total":          "Totale",
			"service":        "Servizio",
			"goodsTotal":     "Totale merce",
			"discounts":      "Sconti",
			"vat":            "Iva",
			"shipping":       "Spedizione",
			"invoiceTotal":   "Totale fattura",
			"position":       "Posizione",
			"positions":      "Posizioni",
			"fruitList":      "Lista Frutti",
			"offer":          "Offerta",
			"technicalPrint": "Stampa Tecnica",
			"photoPrint":     "Stampa Foto"
		},
		"EN": {
			"quotation":      "Quotation",
			"date":           "Date",
			"offerValidity":  "Offer validity",
			"paymentMethod":  "Payment method",
			"salesAgent":     "Sales agent",
			"shippingAddress":"Shipping address",
			"company":        "Company",
			"phone":          "Phone",
			"email":          "Email",
			"vatNumber":      "VAT number",
			"address":        "Address",
			"lead":           "Lead",
			"opportunity":    "Opportunity",
			"shippingName":   "Name",
			"article":        "Article",
			"qty":            "Qty.",
			"price":          "Price",
			"total":          "Total",
			"service":        "Service",
			"goodsTotal":     "Goods total",
			"discounts":      "Discounts",
			"vat":            "VAT",
			"shipping":       "Shipping",
			"invoiceTotal":   "Invoice total",
			"position":       "Position",
			"positions":      "Positions",
			"fruitList":      "Fruit list",
			"offer":          "Offer",
			"technicalPrint": "Technical Print",
			"photoPrint":     "Photo Print"
		},
		"FR": {
			"quotation":      "Devis",
			"date":           "Date",
			"offerValidity":  "Validité de l'offre",
			"paymentMethod":  "Mode de paiement",
			"salesAgent":     "Commercial référent",
			"shippingAddress":"Adresse de livraison",
			"company":        "Raison sociale",
			"phone":          "Téléphone",
			"email":          "Email",
			"vatNumber":      "N° TVA",
			"address":        "Adresse",
			"lead":           "Lead",
			"opportunity":    "Opportunité",
			"shippingName":   "Nom",
			"article":        "Article",
			"qty":            "Qté.",
			"price":          "Prix",
			"total":          "Total",
			"service":        "Service",
			"goodsTotal":     "Total marchandises",
			"discounts":      "Remises",
			"vat":            "TVA",
			"shipping":       "Livraison",
			"invoiceTotal":   "Total facture",
			"position":       "Position",
			"positions":      "Positions",
			"fruitList":      "Liste des fruits",
			"offer":          "Offre",
			"technicalPrint": "Impression Technique",
			"photoPrint":     "Impression Photo"
		},
		"ES": {
			"quotation":      "Presupuesto",
			"date":           "Fecha",
			"offerValidity":  "Validez de la oferta",
			"paymentMethod":  "Método de pago",
			"salesAgent":     "Agente comercial",
			"shippingAddress":"Dirección de envío",
			"company":        "Razón social",
			"phone":          "Teléfono",
			"email":          "Email",
			"vatNumber":      "N° de IVA",
			"address":        "Dirección",
			"lead":           "Lead",
			"opportunity":    "Oportunidad",
			"shippingName":   "Nombre",
			"article":        "Artículo",
			"qty":            "Cant.",
			"price":          "Precio",
			"total":          "Total",
			"service":        "Servicio",
			"goodsTotal":     "Total mercancías",
			"discounts":      "Descuentos",
			"vat":            "IVA",
			"shipping":       "Envío",
			"invoiceTotal":   "Total factura",
			"position":       "Posición",
			"positions":      "Posiciones",
			"fruitList":      "Lista de frutos",
			"offer":          "Oferta",
			"technicalPrint": "Impresión Técnica",
			"photoPrint":     "Impresión Fotográfica"
		},
		"DE": {
			"quotation":      "Angebot",
			"date":           "Datum",
			"offerValidity":  "Angebotsgültigkeit",
			"paymentMethod":  "Zahlungsmethode",
			"salesAgent":     "Vertriebsmitarbeiter",
			"shippingAddress":"Lieferadresse",
			"company":        "Firma",
			"phone":          "Telefon",
			"email":          "E-Mail",
			"vatNumber":      "USt-IdNr.",
			"address":        "Adresse",
			"lead":           "Lead",
			"opportunity":    "Chance",
			"shippingName":   "Name",
			"article":        "Artikel",
			"qty":            "Menge",
			"price":          "Preis",
			"total":          "Gesamt",
			"service":        "Service",
			"goodsTotal":     "Warengesamt",
			"discounts":      "Rabatte",
			"vat":            "MwSt.",
			"shipping":       "Versand",
			"invoiceTotal":   "Rechnungsgesamt",
			"position":       "Position",
			"positions":      "Positionen",
			"fruitList":      "Fruchtliste",
			"offer":          "Angebot",
			"technicalPrint": "Technischer Druck",
			"photoPrint":     "Fotodruck"
		}
	}>
	<cfif !structKeyExists(local.labels, local.lang)>
		<cfset local.lang = "IT">
	</cfif>
	<cfif structKeyExists(local.labels[local.lang], arguments.key)>
		<cfreturn local.labels[local.lang][arguments.key]>
	</cfif>
	<cfreturn local.labels["IT"][arguments.key]>
</cffunction>

<cffunction name="getFinalForm">
	<cfargument name="langId" default="IT">
	<cfset local.lang = UCase(arguments.langId)>
	<cfset local.tx = {
		"IT": {
			"topNote":        "L'ordine si intende confermato solo dopo il ricevimento dello stesso timbrato e firmato per accettazione, dell'eventuale conferma bozze e del pagamento anticipato ove previsto",
			"bankTitle":      "Coordinate Bancarie",
			"bank":           "Banca",
			"readAndFill":    "Leggere e compilare",
			"important":      "IMPORTANTE",
			"importantIntro": "Per confermare l'ordine si prega di compilare i seguenti campi:",
			"billingAddress": "Indirizzo di fatturazione :",
			"vatNo":          "N° P.IVA :",
			"sdi":            "N° SDI :",
			"deliveryAddress":"Indirizzo di consegna :",
			"receiverContact":"Nome e Numero di telefono della persona incaricata del ricevimento merce :",
			"termsTitle":     "CONDIZIONI GENERALI DI VENDITA",
			"art1":           "CONFERMA D'ORDINE: il presente modulo costituisce una conferma delle condizioni definitive per l'evasione dell'ordine e le parti riconoscono la sua efficacia anche se l'invio ad APIR SRL viene effettuato a mezzo telefax oppure a mezzo e-mail. (*) L'ordine si intende confermato solo dopo il ricevimento dello stesso timbrato e firmato per accettazione, dell'eventuale conferma bozze e del pagamento anticipato ove previsto.",
			"art2":           "VARIAZIONE DELL'ORDINE: ogni eventuale richiesta di modifica dell'ordine deve avvenire immediatamente dopo la ricezione della presente conferma. APIR SRL si riserva la facoltà di rifiutarla a suo insindacabile giudizio.",
			"art3":           "CONSEGNA: L'eventuale data di consegna indicata da APIR SRL è solo una data stimata ed approssimativa, non vincolante per APIR SRL.",
			"art4":           "RECLAMI: il cliente dovrà controllare la merce al momento della presa in consegna e le eventuali contestazioni per difetti o mancanze di materiali dovranno essere formalizzate esclusivamente per iscritto e dovranno pervenire ad APIR SRL entro 8 (otto) giorni dalla data di consegna della merce.",
			"art5":           "RITARDO PAGAMENTO: in applicazione del D.L. n° 231 del 09/10/2002 attuante la direttiva 2000/35/CE, in caso di ritardo pagamento saranno automaticamente addebitati gli interessi di mora che decorreranno dal giorno successivo alla scadenza del termine di pagamento.",
			"art6":           "FORO COMPETENTE: per qualsiasi controversia relativa alla esecuzione ed in generale a tutto ciò che comporta l'applicazione ed interpretazione del presente accordo è sempre competente il Foro di Rimini.",
			"signNote":       "Ad ogni effetto di legge dichiaro di approvare in modo espresso la clausola relativa al Foro competente e quella relativa ai reclami.",
			"date":           "Data",
			"signStamp":      "Firma e Timbro"
		},
		"EN": {
			"topNote":        "The order is confirmed only upon receipt of the same duly signed and stamped for acceptance, any proof approval, and advance payment where applicable.",
			"bankTitle":      "Bank Details",
			"bank":           "Bank",
			"readAndFill":    "Please read and fill in",
			"important":      "IMPORTANT",
			"importantIntro": "To confirm the order, please fill in the following fields:",
			"billingAddress": "Billing address:",
			"vatNo":          "VAT No.:",
			"sdi":            "SDI No.:",
			"deliveryAddress":"Delivery address:",
			"receiverContact":"Name and phone number of the person in charge of receiving the goods:",
			"termsTitle":     "GENERAL TERMS AND CONDITIONS OF SALE",
			"art1":           "ORDER CONFIRMATION: This form constitutes a confirmation of the final conditions for fulfilling the order, and the parties acknowledge its validity even if sent to APIR SRL by fax or e-mail. (*) The order is confirmed only upon receipt of the same duly signed and stamped for acceptance, any proof approval, and advance payment where applicable.",
			"art2":           "ORDER MODIFICATION: Any request to modify the order must be made immediately after receiving this confirmation. APIR SRL reserves the right to refuse it at its sole discretion.",
			"art3":           "DELIVERY: Any delivery date indicated by APIR SRL is only an estimated and approximate date, not binding for APIR SRL.",
			"art4":           "CLAIMS: The customer must inspect the goods upon delivery; any objections regarding defects or missing materials must be formalized exclusively in writing and must reach APIR SRL within 8 (eight) days from the delivery date.",
			"art5":           "LATE PAYMENT: Pursuant to Legislative Decree no. 231 of 09/10/2002 implementing Directive 2000/35/EC, in case of late payment, default interest will be automatically charged from the day following the expiry of the payment deadline.",
			"art6":           "JURISDICTION: For any dispute relating to the execution and, in general, to everything involving the application and interpretation of this agreement, the Court of Rimini shall have exclusive jurisdiction.",
			"signNote":       "For all legal purposes, I declare to expressly approve the clause relating to the competent court and the one relating to complaints.",
			"date":           "Date",
			"signStamp":      "Signature and Stamp"
		},
		"FR": {
			"topNote":        "La commande n'est confirmée qu'à la réception du bon de commande tamponné et signé pour acceptation, de toute approbation de maquette éventuelle et du paiement anticipé si prévu.",
			"bankTitle":      "Coordonnées Bancaires",
			"bank":           "Banque",
			"readAndFill":    "Lire et remplir",
			"important":      "IMPORTANT",
			"importantIntro": "Pour confirmer la commande, veuillez remplir les champs suivants :",
			"billingAddress": "Adresse de facturation :",
			"vatNo":          "N° TVA :",
			"sdi":            "N° SDI :",
			"deliveryAddress":"Adresse de livraison :",
			"receiverContact":"Nom et numéro de téléphone de la personne chargée de la réception des marchandises :",
			"termsTitle":     "CONDITIONS GÉNÉRALES DE VENTE",
			"art1":           "CONFIRMATION DE COMMANDE : le présent formulaire constitue une confirmation des conditions définitives pour l'exécution de la commande, et les parties reconnaissent sa validité même si l'envoi à APIR SRL est effectué par télécopieur ou par e-mail. (*) La commande n'est confirmée qu'à la réception du bon de commande tamponné et signé pour acceptation, de toute approbation de maquette et du paiement anticipé si prévu.",
			"art2":           "MODIFICATION DE COMMANDE : toute demande de modification de la commande doit être effectuée immédiatement après réception de la présente confirmation. APIR SRL se réserve le droit de la refuser à sa seule discrétion.",
			"art3":           "LIVRAISON : toute date de livraison indiquée par APIR SRL est uniquement une date estimée et approximative, non contraignante pour APIR SRL.",
			"art4":           "RÉCLAMATIONS : le client doit vérifier la marchandise au moment de la prise en charge ; toute contestation relative à des défauts ou des manques de matériaux doit être formalisée exclusivement par écrit et doit parvenir à APIR SRL dans les 8 (huit) jours suivant la date de livraison.",
			"art5":           "RETARD DE PAIEMENT : en application du décret législatif n° 231 du 09/10/2002 transposant la directive 2000/35/CE, en cas de retard de paiement, des intérêts de retard seront automatiquement facturés à compter du lendemain de l'échéance.",
			"art6":           "JURIDICTION COMPÉTENTE : pour tout litige relatif à l'exécution et, en général, à tout ce qui implique l'application et l'interprétation du présent accord, le Tribunal de Rimini est seul compétent.",
			"signNote":       "À tous effets de droit, je déclare approuver expressément la clause relative au tribunal compétent et celle relative aux réclamations.",
			"date":           "Date",
			"signStamp":      "Signature et Cachet"
		},
		"ES": {
			"topNote":        "El pedido se considera confirmado únicamente tras la recepción del mismo sellado y firmado como aceptación, de cualquier aprobación de prueba y del pago anticipado cuando sea necesario.",
			"bankTitle":      "Datos Bancarios",
			"bank":           "Banco",
			"readAndFill":    "Leer y completar",
			"important":      "IMPORTANTE",
			"importantIntro": "Para confirmar el pedido, por favor complete los siguientes campos:",
			"billingAddress": "Dirección de facturación:",
			"vatNo":          "N° IVA:",
			"sdi":            "N° SDI:",
			"deliveryAddress":"Dirección de entrega:",
			"receiverContact":"Nombre y número de teléfono de la persona encargada de recibir la mercancía:",
			"termsTitle":     "CONDICIONES GENERALES DE VENTA",
			"art1":           "CONFIRMACIÓN DE PEDIDO: el presente formulario constituye una confirmación de las condiciones definitivas para la ejecución del pedido, y las partes reconocen su validez aunque el envío a APIR SRL se realice por fax o correo electrónico. (*) El pedido se considera confirmado únicamente tras la recepción del mismo sellado y firmado como aceptación, de cualquier aprobación de prueba y del pago anticipado cuando sea necesario.",
			"art2":           "MODIFICACIÓN DEL PEDIDO: cualquier solicitud de modificación del pedido debe realizarse inmediatamente después de recibir la presente confirmación. APIR SRL se reserva el derecho a rechazarla a su entera discreción.",
			"art3":           "ENTREGA: cualquier fecha de entrega indicada por APIR SRL es únicamente una fecha estimada y aproximada, no vinculante para APIR SRL.",
			"art4":           "RECLAMACIONES: el cliente deberá verificar la mercancía en el momento de la recepción; cualquier objeción por defectos o falta de materiales deberá formalizarse exclusivamente por escrito y deberá llegar a APIR SRL en un plazo de 8 (ocho) días a partir de la fecha de entrega.",
			"art5":           "RETRASO EN EL PAGO: en aplicación del Decreto Legislativo n° 231 de 09/10/2002 que implementa la Directiva 2000/35/CE, en caso de retraso en el pago, se cargarán automáticamente intereses de mora a partir del día siguiente al vencimiento del plazo de pago.",
			"art6":           "JURISDICCIÓN COMPETENTE: para cualquier controversia relativa a la ejecución y, en general, a todo lo que conlleva la aplicación e interpretación del presente acuerdo, el Tribunal de Rímini tendrá jurisdicción exclusiva.",
			"signNote":       "A todos los efectos legales, declaro aprobar expresamente la cláusula relativa al tribunal competente y la relativa a las reclamaciones.",
			"date":           "Fecha",
			"signStamp":      "Firma y Sello"
		},
		"DE": {
			"topNote":        "Der Auftrag gilt als bestätigt erst nach Eingang desselben, gestempelt und unterschrieben zur Annahme, einer etwaigen Druckfreigabe und der Vorauszahlung, sofern vorgesehen.",
			"bankTitle":      "Bankverbindung",
			"bank":           "Bank",
			"readAndFill":    "Bitte lesen und ausfüllen",
			"important":      "WICHTIG",
			"importantIntro": "Um die Bestellung zu bestätigen, füllen Sie bitte die folgenden Felder aus:",
			"billingAddress": "Rechnungsadresse:",
			"vatNo":          "USt-IdNr.:",
			"sdi":            "SDI-Nr.:",
			"deliveryAddress":"Lieferadresse:",
			"receiverContact":"Name und Telefonnummer der für den Warenempfang zuständigen Person:",
			"termsTitle":     "ALLGEMEINE GESCHÄFTSBEDINGUNGEN",
			"art1":           "AUFTRAGSBESTÄTIGUNG: Dieses Formular stellt eine Bestätigung der endgültigen Bedingungen für die Auftragsabwicklung dar; die Parteien erkennen seine Gültigkeit an, auch wenn die Übermittlung an APIR SRL per Telefax oder E-Mail erfolgt. (*) Der Auftrag gilt erst nach Eingang desselben, gestempelt und unterschrieben zur Annahme, einer etwaigen Druckfreigabe und der Vorauszahlung, sofern vorgesehen, als bestätigt.",
			"art2":           "AUFTRAGSÄNDERUNG: Jede etwaige Änderungsanfrage muss unmittelbar nach Erhalt dieser Bestätigung erfolgen. APIR SRL behält sich das Recht vor, diese nach eigenem Ermessen abzulehnen.",
			"art3":           "LIEFERUNG: Ein etwaig von APIR SRL angegebenes Lieferdatum ist lediglich ein geschätztes und ungefähres Datum, das für APIR SRL nicht verbindlich ist.",
			"art4":           "REKLAMATIONEN: Der Kunde muss die Ware bei der Übernahme prüfen; etwaige Beanstandungen wegen Mängeln oder fehlenden Materialien müssen ausschließlich schriftlich erfolgen und müssen APIR SRL innerhalb von 8 (acht) Tagen ab dem Lieferdatum zugehen.",
			"art5":           "ZAHLUNGSVERZUG: In Anwendung des Gesetzesdekrets Nr. 231 vom 09.10.2002 zur Umsetzung der Richtlinie 2000/35/EG werden im Falle eines Zahlungsverzugs automatisch Verzugszinsen ab dem auf den Fälligkeitstag folgenden Tag berechnet.",
			"art6":           "GERICHTSSTAND: Für etwaige Streitigkeiten im Zusammenhang mit der Ausführung und im Allgemeinen mit allem, was die Anwendung und Auslegung dieser Vereinbarung betrifft, ist ausschließlich das Gericht Rimini zuständig.",
			"signNote":       "Zu allen rechtlichen Zwecken erkläre ich, die Klausel bezüglich des zuständigen Gerichts und die Klausel bezüglich der Reklamationen ausdrücklich zu genehmigen.",
			"date":           "Datum",
			"signStamp":      "Unterschrift und Stempel"
		}
	}>
	<cfif !structKeyExists(local.tx, local.lang)>
		<cfset local.lang = "IT">
	</cfif>
	<cfset local.t = local.tx[local.lang]>
	<cfoutput>
		<div style="page-break-inside: avoid !important;">
			<div class="top-note">#local.t.topNote#</div>

			<div class="bank" aria-label="#local.t.bankTitle#">
				<table role="table" summary="#local.t.bankTitle#">
				<thead><tr><th colspan="2">#local.t.bankTitle#</th></tr></thead>
				<tbody>
					<tr><td class="label">#local.t.bank#</td><td class="value">INTESA SANPAOLO SPA<br/><small>filiale di Rimini Via della Fiera</small></td></tr>
					<tr><td class="label">IBAN</td><td class="value">IT43 S030 6924 2321 0000 0001 234</td></tr>
					<tr><td class="label">BIC</td><td class="value">BCITITMM</td></tr>
				</tbody>
				</table>
			</div>

			<h2 class="section-title">#local.t.readAndFill#</h2>

			<div class="important-box" role="region" aria-label="#local.t.important#">
				<div class="important-header">#local.t.important#</div>
				<div class="important-content" style="padding: 0 0 0.1in 0.1in;">
					<p style="font-size: 9px;">#local.t.importantIntro#</p>
					<div>
						<table style="width: 95%">
							<tr>
								<td style="width: 35%; border: 0;">#local.t.billingAddress#</td>
								<td style="width: 65%; border: 0; border-bottom: 1px dotted black;">&nbsp;</td>
							</tr>
						</table>
					</div>
					<div>
						<table style="width: 95%">
							<tr>
								<td style="width: 35%; border: 0;">#local.t.vatNo#</td>
								<td style="width: 65%; border: 0; border-bottom: 1px dotted black;">&nbsp;</td>
							</tr>
						</table>
					</div>
					<div>
						<table class="field-row" style="width: 95%">
							<tr>
								<td style="width: 35%; border: 0;">#local.t.sdi#</td>
								<td style="width: 65%; border: 0; border-bottom: 1px dotted black;">&nbsp;</td>
							</tr>
						</table>
					</div>
					<div>
						<table class="field-row" style="width: 95%">
							<tr>
								<td style="width: 35%; border: 0;">#local.t.deliveryAddress#</td>
								<td style="width: 65%; border: 0; border-bottom: 1px dotted black;">&nbsp;</td>
							</tr>
						</table>
					</div>
					<div>
						<table class="field-row" style="width: 95%">
							<tr>
								<td style="width: 35%; border: 0; line-height: 14px;">#local.t.receiverContact#</td>
								<td style="width: 65%; border: 0; border-bottom: 1px dotted black;">&nbsp;</td>
							</tr>
						</table>
					</div>
				</div>
			</div>

			<div class="small-print">
				<strong>#local.t.termsTitle#</strong>
				<ol style="padding-left:14px; margin:6px 0 0 0;">
				<li style="margin-bottom:6px;">#local.t.art1#</li>
				<li style="margin-bottom:6px;">#local.t.art2#</li>
				<li style="margin-bottom:6px;">#local.t.art3#</li>
				<li style="margin-bottom:6px;">#local.t.art4#</li>
				<li style="margin-bottom:6px;">#local.t.art5#</li>
				<li style="margin-bottom:6px;">#local.t.art6#</li>
				</ol>
			</div>

			<div class="sign-rows">
				<table class="sign-rows-table">
					<tr>
						<td style="width: 50%; text-align: center">
							<p style="margin-top:6px; font-size: 9px;">#local.t.signNote#</p>
						</td>
						<td style="width: 10%">
							&nbsp;
						</td>
						<td style="width: 10%;">
							&nbsp;
						</td>
						<td style="width: 10%; text-align: right">
							#local.t.date#
						</td>
						<td style="width: 20%; text-align: center">#local.t.signStamp#</td>
					</tr>
					<tr>
						<td style="width: 50%; border-bottom: 1px solid black !important;"></td>
						<td style="width: 10%; text-align: center;">
							<img src="/assets/main/img/quotation-arrow-left.png" style="height: 0.5in; width: 0.5in;">
						</td>
						<td style="width: 10%; text-align: center;">
							<img src="/assets/main/img/quotation-arrow-right.png" style="height: 0.5in; width: 0.5in;">
						</td>
						<td style="width: 10%; border-bottom: 1px solid black !important;">
							&nbsp;
						</td>
						<td style="width: 20%; border-bottom: 1px solid black !important;"></td>
					</tr>
				</table>
			</div>
		</div>
	</cfoutput>
</cffunction>

<cffunction name="printStyle">
	<style>	
		body, td, th, span, div, p { font-family: 'Poppins'; font-size: 13px }
		
		table {
			border-collapse: collapse;
		}

		.blue {
			color: #007bff;
			text-decoration: none;
		}
		/* tabella dentro td articolo */
		.hiddenTable {
			border-collapse: collapse;
			border: 0;
			width: 100%;        /* usa tutta la larghezza della cella contenitore */
			table-layout: fixed;/* evita ricalcoli dinamici delle colonne */
			box-sizing: border-box;
		}
		.hiddenTable td,
		.hiddenTable th {
			border: 0 !important;
			padding: 0;         /* rimuovi padding interni, gestiscilo a livello della cella esterna se serve */
			vertical-align: top;
			box-sizing: border-box;
			line-height: 10px;
		}
		.hiddenTable td img {
			max-width: 100%;   /* mai oltre la larghezza della cella */
			height: auto;      /* mantiene il rapporto */
			display: block;    /* evita spazi extra dai baseline */
		}
		/* fine */

		/* form finale con iban banca e firme */
		.top-note {
			font-size: 10px;
		}
		.bank {
			width: 4.5in;
			float: right;
			margin-right: 20px;
			text-align: left;
		}
		.bank table {
			width:100%;
			border:1px solid #000;
			border-collapse: collapse;
			text-align:left;
		}
		.bank th {
			background:#f0f0f0;
			text-align:center;
			font-size: 11px;
			border-bottom:1px solid #000;
		}
		.bank td { padding:6px 8px; border-top:1px solid #000; vertical-align: middle; }
		.bank .label { width:120px; font-weight:600; border-right:1px solid #000; text-align:left; padding-left:8px; }
		.bank .value { padding-left:10px; }
		.section-title {
			clear: both;
			margin-top:0.2in;
			font-size:12px;
			font-weight: 700;
		}
		.important-box {
			border:1px solid #000;
			margin-top:0.1in;
			padding:0;
		}
		.important-header {
			background:#f3f3f3;
			border-bottom:1px solid #000;
			text-align:center;
			font-weight:800;
			padding:8px 6px;
			font-size:12px;
		}
		.important-content {
			padding:3px 10px;
			line-height:1.4;
		}
		.small-print {
			clear: both;
			margin-top:0.2in;
			font-size:8px;
			line-height:1.05;
		}
		.sign-rows {
			margin-top: 0.4in;
		}
		.sign-rows-table {
			border-collapse: collapse;
			border: 0;
		}
		.sign-rows-table td,
		.sign-rows-table tr {
			border: 0 !important;
		}
		/* fine */
	</style>
</cffunction>