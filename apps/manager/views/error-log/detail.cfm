<cfoutput>

    <div id="error-log-detail-root">

        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
            <div class="col-4 text-end">
                <a href="/manager/error-logs" class="btn btn-default btn-sm"><i class="fas fa-arrow-left"></i> Torna al log</a>
            </div>
        </div>

        <cfset row = prc.row>

        <section class="card">
            <div class="card-body">
                <table class="table table-sm mb-0">
                    <tbody>
                        <tr><th style="width: 180px;">Data</th><td>#DateTimeFormat( row.created_at, "dd/mm/yyyy HH:nn:ss" )#</td></tr>
                        <tr><th>Codice</th><td><code>#EncodeForHTML( row.code )#</code></td></tr>
                        <tr><th>Tipo</th><td>#EncodeForHTML( row.error_type )#</td></tr>
                        <tr><th>Messaggio</th><td style="white-space: pre-wrap;">#EncodeForHTML( row.message )#</td></tr>
                        <cfif Len( row.detail )>
                            <tr><th>Dettaglio</th><td style="white-space: pre-wrap;">#EncodeForHTML( row.detail )#</td></tr>
                        </cfif>
                        <tr><th>Template</th><td>#EncodeForHTML( row.template )#<cfif Len( row.line )> : #row.line#</cfif></td></tr>
                        <tr><th>Evento</th><td>#EncodeForHTML( row.event )#</td></tr>
                        <tr><th>URL</th><td>#EncodeForHTML( row.http_method )# #EncodeForHTML( row.routed_url )#</td></tr>
                        <tr><th>Utente</th><td>#EncodeForHTML( row.user_name )#</td></tr>
                        <tr><th>IP</th><td>#EncodeForHTML( row.ip_address )#</td></tr>
                        <tr><th>User agent</th><td>#EncodeForHTML( row.user_agent )#</td></tr>
                    </tbody>
                </table>
            </div>
        </section>

        <!--- report completo ( tag context, form, sessione, cookie ) in un iframe: ha il suo CSS --->
        <section class="card">
            <div class="card-body">
                <h5>Report completo</h5>
                <iframe sandbox src="/manager/error-logs/#row.error_log_id#/report" style="width: 100%; height: 75vh; border: 1px solid ##ddd; border-radius: 4px; background: ##fff;"></iframe>
            </div>
        </section>

    </div>

</cfoutput>
