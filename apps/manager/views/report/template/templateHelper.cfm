<cffunction name="getPrintHeader">
    <!--- TODO: move website to variable --->
    <cfreturn "<img src='https://test.apirone.cc/assets/main/img/logo.png' alt='Apir' style='width: 100%; height: 40px;'>">
</cffunction>

<cffunction name="getPrintFullHeader">
	<style>
		.blue {
			color: #007bff;
			text-decoration: none;
		}
	</style>
	<cfoutput>
		<div style="width: 8cm">
			<br>
			<img src='https://test.apirone.cc/assets/main/img/logo.png' alt='Apir' style='6cm; height: 40px;'>
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



<cffunction name="importPrintStyle">
    <cfreturn "<style>body, td, th, span, div, p { font-family: 'Poppins'; font-size: 13px };</style>">
</cffunction>

<cffunction name="getPrintFooter">
    <cfsavecontent variable="local.html">
        <cfoutput>
            <div style='border-top: 1px solid ##EAEAEA;'>
                <table width='100%' border=0 style='border-collapse:collapse'>
                    <tr>
                        <td style='padding-top:5px'>#cfdocument.currentpagenumber#/#cfdocument.totalpagecount#</td>
                        <td style='padding-top:5px' align='right'>Apir Srl - #LsDateFormat( now(), 'dd/mm/yyyy' )#</td>
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