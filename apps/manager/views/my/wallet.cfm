<cfoutput>

    <div class="row mb-3">
        <div class="col-lg-12">
            <section class="card">
                <header class="card-header">
                    <h2 class="card-title">#prc.title#</h2>
                </header>
                <div class="card-body">

                    <div class="row">

                        <section class="card mb-4">

                            <div class="card-body">
                                <div class="row">
                                    <div class="col-6">
                                        <span style="font-size: 20px">Il tuo portafoglio contiene:</span>
                                    </div>
                                    <div class="col-6">
                                        <span style="font-size: 35px">150 Euro</span>
                                    </div>
                                </div>
                                <div class="row mt-5">
                                    <div class="col-12 text-center">
                                        <button class="btn btn-primary col-2">Acquista credito</button>
                                        <button class="btn btn-primary col-2">Riscuoti carta</button>
                                    </div>
                                </div>
                            </div>
                        
                        </section>

                    </div>                    

                </div>
            </section>


            <section class="card mb-4">

                <header class="card-header">
                    <h2 class="card-title">Lista delle transazioni</h2>
                </header>                                    
        
                <div class="card-body">
                    <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Descrizione</th>
                            <th>Data</th>
                            <th>Azienda</th>
                            <th>Ricaricato</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfloop array="#rc.list#" index="item">
                        <tr>
                            <td>#item.name#</td>
                            <td>#item.date#</td>
                            <td>#item.company#</td>
                            <td>#item.total#</td>
                        </tr>
                        </cfloop>
                    </tbody>
                    </table>
                </div>

            </section>

        </div>            
    </div>

</cfoutput>