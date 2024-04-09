<cfoutput>

<div class="row">
    <div class="col-lg-12">
        
        <form id="form" action="/manager/cards/generate-do" class="form-horizontal" method="POST">
            
            <section class="card">
                
                <header class="card-header">
                    <h2 class="card-title">#prc.title#</h2>
                    
                    <p class="card-subtitle">
                        Genera le tessere di cui hai bisogno
                    </p>
                </header>
                
                <div class="card-body">

                    <div class="form-group row pb-3">

                        <label class="col-sm-3 control-label text-sm-end pt-2">
                            Azienda
                        </label>

                        <div class="col-sm-9">
                            <select class="form-control" name="companyId">
                                <option value="">-- tutti</option>
                                <cfloop array="#prc.companies.getData()#" index="index">
                                    <option value="#index.getId()#">#index.getName()#</option>
                                </cfloop>
                            </select>
                        </div>
                    
                    </div>

                    <div class="form-group row pb-3">
                        <label class="col-sm-3 control-label text-sm-end pt-2">
                            Quantità
                        </label>
                        <div class="col-sm-9">
                            <input type="number" name="quantity" class="form-control" required/>
                        </div>
                    </div>
                    
                    <div class="form-group row pb-3">
                        <label class="col-sm-3 control-label text-sm-end pt-2">
                            Importo
                        </label>
                        <div class="col-sm-9">
                            <input type="number" name="amount" class="form-control" required/>
                        </div>
                    </div>

                </div>

                <footer class="card-footer">
                    <div class="row justify-content-end">
                        <div class="col-sm-9">
                            <button class="btn btn-primary">Genera &raquo;</button>
                            <input type="hidden" name="id" value="" >
                        </div>
                    </div>
                </footer>

            </section>
        
        </form>
    
    </div>

</div>

</cfoutput>