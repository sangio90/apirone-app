<cfoutput>
<div class="row" id="report-item">
    <div class="col-12">
        <form id="report-detail-form">
            <section class="card card-featured card-featured-primary mb-4">

                <header class="card-header">
                    <h2 class="card-title">#prc.title#</h2>
                </header>
                
                <div class="card-body">
                    <div class="row pb-3">

                        <div class="form-group pb-2">
                            <label class="col-form-label" for="report-desc">Nome del file</label>
                            <p class="field-value">
                                #prc.report.getFileName()#
                            </p>
                        </div>

                        <div class="form-group pb-2">
                            <label class="col-form-label" for="report-desc">File di esempio</label>
                            <p class="field-value">
                                <a href="/assets/main/examples/pdf/#prc.report.getExampleFile()#" target="_blank">#prc.report.getExampleFile()#</a>
                            </p>
                        </div>

                        <div class="form-group pb-2">
                            <label class="col-form-label" for="report-desc">JSON di esempio</label>
                            <p class="field-value">
                                <textarea cols="10" rows="20" style="width: 100%" class="form-control">
                                    #prc.report.getExampleData()#
                                </textarea>
                            </p>
                        </div>

                    </div>
                </div>
                <!----
                <footer class="card-footer text-end">
                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:save">
                        <i class="fas fa-save"></i> Salva
                    </button>

                </footer>
                ---->
                <div id="example"></div>
            </section>
        </form>
    </div>
</div>  

<script>
    //var obj = #prc.report.getExampleData()#;
    //document.getElementById('example').innerHTML = JSON.stringify(obj, null, 3);
</script>

</cfoutput>