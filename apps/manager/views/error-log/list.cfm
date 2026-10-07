<cfoutput>

    <div id="error-log-list-root">

        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
        </div>

        <section class="card">
            <section class="card-body box-search">
                <form method="get" action="/manager/error-logs">
                    <div class="row">
                        <div class="col-6">
                            <div class="form-group row mb-2">
                                <label class="col-sm-3 control-label text-sm-end pt-2">Cerca</label>
                                <div class="col-sm-9">
                                    <input type="text" name="str" class="form-control" value="#EncodeForHTMLAttribute( prc.str )#" placeholder="Codice, messaggio, tipo, evento o utente">
                                </div>
                            </div>
                        </div>
                        <div class="col-6">
                            <button type="submit" class="btn btn-primary btn-sm me-2 mt-1">
                                <i class="fas fa-search"></i> Cerca
                            </button>
                            <cfif Len( prc.str )>
                                <a href="/manager/error-logs" class="btn btn-default btn-sm mt-1">Azzera</a>
                            </cfif>
                        </div>
                    </div>
                </form>
            </section>
        </section>

        <section class="card">
            <div class="card-body">

                <p class="text-muted mb-2">#prc.total# errori<cfif prc.pages GT 1> &middot; pagina #prc.page# di #prc.pages#</cfif></p>

                <table class="table table-sm table-striped table-hover mb-3">
                    <thead>
                        <tr>
                            <th style="width: 140px;">Data</th>
                            <th style="width: 230px;">Codice</th>
                            <th>Messaggio</th>
                            <th style="width: 220px;">Evento</th>
                            <th style="width: 160px;">Utente</th>
                            <th style="width: 55px;"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfloop query="prc.rows">
                            <tr>
                                <td>#DateTimeFormat( prc.rows.created_at, "dd/mm/yyyy HH:nn:ss" )#</td>
                                <td><code>#EncodeForHTML( prc.rows.code )#</code></td>
                                <td>
                                    <cfif Len( prc.rows.error_type )><span class="text-muted">#EncodeForHTML( prc.rows.error_type )#</span><br></cfif>
                                    #EncodeForHTML( prc.rows.message )#
                                </td>
                                <td>#EncodeForHTML( prc.rows.event )#</td>
                                <td>#EncodeForHTML( prc.rows.user_name )#</td>
                                <td class="text-end">
                                    <a href="/manager/error-logs/#prc.rows.error_log_id#" class="btn btn-default btn-sm" title="Dettaglio"><i class="fas fa-search"></i></a>
                                </td>
                            </tr>
                        </cfloop>
                        <cfif !prc.rows.recordCount>
                            <tr><td colspan="6" class="text-muted">Nessun errore registrato.</td></tr>
                        </cfif>
                    </tbody>
                </table>

                <cfif prc.pages GT 1>
                    <cfset pageUrl = "/manager/error-logs?str=" & EncodeForURL( prc.str ) & "&page=">
                    <nav>
                        <ul class="pagination pagination-sm mb-0">
                            <li class="page-item <cfif prc.page EQ 1>disabled</cfif>"><a class="page-link" href="#pageUrl##prc.page - 1#">&laquo;</a></li>
                            <li class="page-item disabled"><span class="page-link">#prc.page# / #prc.pages#</span></li>
                            <li class="page-item <cfif prc.page EQ prc.pages>disabled</cfif>"><a class="page-link" href="#pageUrl##prc.page + 1#">&raquo;</a></li>
                        </ul>
                    </nav>
                </cfif>

            </div>
        </section>

    </div>

</cfoutput>
