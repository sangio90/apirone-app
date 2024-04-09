<cfoutput>

    <div class="row">
        <div class="col-lg-12">
            <section class="card">
                <header class="card-header">
                    <h2 class="card-title">Lista degli ordini</h2>
                </header>
                <div class="card-body">
                    <table class="table table-responsive-md table-hover mb-0">
                        <thead>
                            <tr>
                                <th>##</th>
                                <th>Cliente</th>
                                <th>Totale</th>
                                <th>Data</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop array="#prc.list.getData()#" item="item">
                                <tr>
                                    <td><a href="/manager/documents/#item.getId()#">#item.getCode()#</a></td>
                                    <td>#item.getEmployee().getName()# #item.getEmployee().getSurname()#</td>
                                    <td>#item.getTotal()#</td>
                                    <td>#LsDateTimeFormat( item.getDate(), 'dd/mm/yyyy hh:nn')#</td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </div>

</cfoutput>