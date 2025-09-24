<cffunction name="getPrintHeader">
    <!--- TODO: move website to variable --->
    <cfreturn "<img src='https://test.apirone.cc/assets/main/img/logo.png' alt='Apir' style='width: 100%; height: 40px;'>">
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