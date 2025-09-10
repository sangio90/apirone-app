<cffunction name="getPrintHeader">
    <cfreturn "<div><img src='/assets/main/img/logo.png' alt='Apir' style='width: 100%; height: 60px;'><div>">
</cffunction>

<cffunction name="importPrintStyle">
    <cfreturn "<style>body, td, th, span, div { font-family: 'Poppins'; font-size: 13px };</style>">
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