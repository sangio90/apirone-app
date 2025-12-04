<cfoutput>
<cfdocument format="pdf" marginTop="2">

	<style>
		body, td, th, span, div, p { font-family: 'Poppins'; font-size: 13px }
		td {
			border: 1px solid black;
			padding-left: .3em;
			padding-right: .3em;
		}
		table {
			border-collapse: collapse;
		}

		.blue {
			color: Red;
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
			border:1px solid Black
			border-collapse: collapse;
			text-align:left;
		}
		.bank th {
			background: White;
			text-align:center;
			font-size: 11px;
			border-bottom:1px solid Black;
		}
		.bank td { padding:6px 8px; border-top:1px solid Black; vertical-align: middle; }
		.bank .label { width:120px; font-weight:600; border-right:1px solid Black; text-align:left; padding-left:8px; }
		.bank .value { padding-left:10px; }
		.section-title {
			clear: both;
			margin-top:0.2in;
			font-size:12px;
			font-weight: 700;
		}
		.important-box {
			border:1px solid Black;
			margin-top:0.1in;
			padding:0;
		}
		.important-header {
			background: White;
			border-bottom:1px solid Black;
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

	<div>
		<cfdocumentitem type="header">
			<h2><i>Example section-1 Header - Example section-1 Header - Example section-1 Header- Example section-1 Header - Example section-1 Header- Example section-1 Header - Example section-1 Header</i></h2>
		</cfdocumentitem>

		<table style="border: 1px solid Red;">
			<cfloop from="1" to="50" index="i">
				<tr>
					<td>
						<div style="border: 1px solid black; margin: 10px; padding: 10px;">
							<h1>Welcome to Lucee</h1>
							<p>Example for <b>#RepeatString( "CfdocumentSection cfml ", RandRange(19, 50) )#</b></p>
							<h2><i>Example section-1 body</i></h2>
						</div>
				</td>
			</tr>
		</cfloop>
		</table>
		
		<cfdocumentitem type="footer">
			<h2><i>Example section-1 footer</i></h2>
		</cfdocumentitem>
	</div>
</cfdocument>
</cfoutput>