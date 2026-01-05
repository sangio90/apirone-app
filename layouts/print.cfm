<cfparam name="prc.printParams.title" default="">

<cfdocument format="pdf" orientation="landscape" saveasname="#LCase(REReplace(prc.printParams.title, '[^a-zA-Z\s\d:]', '', 'ALL'))#.pdf" pageType="A4">

    <cfoutput>

        <cfdocumentitem type="header">
            #getPrintHeader( prc.printParams.title )#
        </cfdocumentitem>

        <style type="text/css">
            #importPrintStyle()#
        </style>

        <h2 style="font-family: Poppins Light">#prc.printParams.title#</h2>

        #view()#

        <cfdocumentitem type="footer">
            #getPrintFooter()#
        </cfdocumentitem>    

    </cfoutput>

</cfdocument>