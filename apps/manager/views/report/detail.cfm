<cfoutput>
<div class="row" id="report-item">
    <div class="col-12">
        <form id="report-detail-form">
            <section class="card">

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
                                <pre id="formatted-example" style="border: 1px solid ##CCCCCC; color: Black; padding: 10px;"></pre>
                            </p>
                        </div>

                    </div>
                </div>
            </section>
        </form>
    </div>
</div>  

<script>
    var obj = #prc.report.getExampleData()#;
    document.getElementById('formatted-example').innerHTML = JSON.stringify(obj, null, '\t');
</script>

</cfoutput>