<cffunction name="getPrintHeader">
    <!--- TODO: move website to variable --->
    <cfreturn "<img src='https://test.apirone.cc/assets/main/img/logo.png' alt='Apir' style='width: 100%; height: 40px;'>">
</cffunction>

<cffunction name="getPrintFullHeader">
	<cfoutput>
		<div style="width: 8cm">
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
                        <td style='border: 0; padding-top:5px'>#cfdocument.currentpagenumber#/#cfdocument.totalpagecount#</td>
                        <td style='border: 0; padding-top:5px' align='right'>Apir Srl - #LsDateFormat( now(), 'dd/mm/yyyy' )#</td>
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



<cffunction name="getFinalForm">
	<cfoutput>
			<div class="top-note">L'ordine si intende confermato solo dopo il ricevimento dello stesso timbrato e firmato per accettazione, dell'eventuale conferma bozze e del pagamento anticipato ove previsto</div>

			<div class="bank" aria-label="Coordinate bancarie">
				<table role="table" summary="Coordinate bancarie">
				<thead><tr><th colspan="2">Coordinate Bancarie</th></tr></thead>
				<tbody>
					<tr><td class="label">Banca</td><td class="value">INTESA SANPAOLO SPA<br/><small>filiale di Rimini Via della Fiera</small></td></tr>
					<tr><td class="label">IBAN</td><td class="value">IT43 S030 6924 2321 0000 0001 234</td></tr>
					<tr><td class="label">BIC</td><td class="value">BCITITMM</td></tr>
				</tbody>
				</table>
			</div>

			<h2 class="section-title">Leggere e compilare</h2>

			<div class="important-box" role="region" aria-label="Importante">
				<div class="important-header">IMPORTANTE</div>
				<div class="important-content" style="padding: 0 0 0.1in 0.1in;">
					<p style="font-size: 9px;">Per confermare l'ordine si prega di compilare i seguenti campi:</p>
					<div>
						<table style="width: 95%">
							<tr>
								<td style="width: 35%; border: 0;">Indirizzo di fatturazione :</td>
								<td style="width: 65%; border: 0; border-bottom: 1px dotted black;">&nbsp;</td>
							</tr>
						</table>
					</div>
					<div>
						<table style="width: 95%">
							<tr>
								<td style="width: 35%; border: 0;">N° P.IVA :</td>
								<td style="width: 65%; border: 0; border-bottom: 1px dotted black;">&nbsp;</td>
							</tr>
						</table>
					</div>
					<div>
						<table class="field-row" style="width: 95%">
							<tr>
								<td style="width: 35%; border: 0;">N° SDI :</td>
								<td style="width: 65%; border: 0; border-bottom: 1px dotted black;">&nbsp;</td>
							</tr>
						</table>
					</div>
					<div>
						<table class="field-row" style="width: 95%">
							<tr>
								<td style="width: 35%; border: 0;">Indirizzo di consegna :</td>
								<td style="width: 65%; border: 0; border-bottom: 1px dotted black;">&nbsp;</td>
							</tr>
						</table>
					</div>
					<div>
						<table class="field-row" style="width: 95%">
							<tr>
								<td style="width: 35%; border: 0; line-height: 14px;">Nome e Numero di telefono <br> della persona incaricata del <br> ricevimento merce :</td>
								<td style="width: 65%; border: 0; border-bottom: 1px dotted black;">&nbsp;</td>
							</tr>
						</table>
					</div>
				</div>
			</div>

			<div class="small-print">
				<strong>CONDIZIONI GENERALI DI VENDITA</strong>
				<ol style="padding-left:14px; margin:6px 0 0 0;">
				<li style="margin-bottom:6px;">CONFERMA D'ORDINE: il presente modulo costituisce una conferma delle condizioni definitive per l'evasione dell'ordine e le parti riconoscono la sua efficacia anche se l'invio ad APIR SRL viene effettuato a mezzo telefax oppure a mezzo e-mail.(*) L'ordine si intende confermato solo dopo il ricevimento dello stesso timbrato e firmato per accettazione, dell'eventuale conferma bozze e del pagamento anticipato ove previsto.</li>
				<li style="margin-bottom:6px;">VARIAZIONE DELL'ORDINE: ogni eventuale richiesta di modifica dell'ordine, deve avvenire immediatamente dopo la ricezione della presente conferma. APIR SRL si riserva la facoltà di rifiutarla a suo insindacabile giudizio.</li>
				<li style="margin-bottom:6px;">CONSEGNA: L'eventuale data di consegna indicata da APIR SRL è solo una data stimata ed approssimativa, non vincolante per APIR SRL...</li>
				<li style="margin-bottom:6px;">RECLAMI: il cliente dovrà controllare la merce al momento della presa in consegna e le eventuali contestazioni per difetti o mancanze di materiali dovranno essere formalizzate esclusivamente per iscritto e dovranno pervenire ad APIR SRL entro 8 (otto) giorni dalla data di consegna della merce...</li>
				<li style="margin-bottom:6px;">RITARDO PAGAMENTO: in applicazione del D.L. n° 231 del 09/10/2002 attuante la direttiva 2000/35/CE, in caso di ritardo pagamento saranno automaticamente addebitati gli interessi di mora che decorreranno dal giorno successivo alla scadenza del termine di pagamento...</li>
				<li style="margin-bottom:6px;">FORO COMPETENTE: per qualsiasi controversia relativa alla esecuzione ed in generale a tutto ciò che comporta l'applicazione ed interpretazione del presente accordo è sempre competente il Foro di Rimini.</li>
				</ol>
			</div>

			<div class="sign-rows">
				<table class="sign-rows-table">
					<tr>
						<td style="width: 50%; text-align: center">
							<p style="margin-top:6px; font-size: 9px;">Ad ogni effetto di legge dichiaro di approvare in modo espresso la clausola relativa al Foro competente e quella relativa ai reclami.</p>
						</td>
						<td style="width: 10%">
							&nbsp;
						</td>
						<td style="width: 10%;">
							&nbsp;
						</td>
						<td style="width: 10%; text-align: right">
							Data
						</td>
						<td style="width: 20%; text-align: center">Firma e Timbro</td>
					</tr>
					<tr>
						<td style="width: 50%; border-bottom: 1px solid black !important;"></td>
						<td style="width: 10%; text-align: center;">
							<img src="http://apirone.local:8080/assets/main/img/quotation-arrow-left.png" style="height: 0.5in; width: 0.5in;">
						</td>
						<td style="width: 10%; text-align: center;">
							<img src="http://apirone.local:8080/assets/main/img/quotation-arrow-right.png" style="height: 0.5in; width: 0.5in;">
						</td>
						<td style="width: 10%; border-bottom: 1px solid black !important;">
							&nbsp;
						</td>
						<td style="width: 20%; border-bottom: 1px solid black !important;"></td>
					</tr>
				</table>
			</div>
	</cfoutput>
</cffunction>

<cffunction name="printStyle">
	<style>
		<cfif #args.data.quotation.getStatus().getOrderBy() < 40#>
			@page {
				background-image: url('http://apirone.local:8080/assets/main/img/quotation-watermark-2.jpg');
				background-repeat: repeat;
				background-size: 1920px;
				z-index: -1;
				background-color:rgba(0, 0, 0, 0.1);
			}
		</cfif>
		body, td, th, span, div, p { font-family: 'Poppins'; font-size: 13px }
		td {
			border: 1px solid black;
		}
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
			margin-top: 1.5in;
			font-size: 10px;
			page-break-before: always;
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