<cfoutput>
<h2>Dashboard</h2>

<div class="row" style="margin-bottom:50px">
    <div class="col-md-12">

        #session.user.getAccount().getRole().getId()#
        <cfabort>


        <cfif session.user.getAccount().getRole().getId() IS "ADM"></cfif>

        <section class="card">
            <header class="card-header">
                <div class="card-actions">
                    <a href="##" class="card-action card-action-toggle" data-card-toggle></a>
                    <a href="##" class="card-action card-action-dismiss" data-card-dismiss></a>
                </div>

                <h2 class="card-title">Vendite per mese</h2>
                <p class="card-subtitle">Vendite negli ultimi dodici mesi.</p>
            </header>
            <div class="card-body">

                <!-- Morris: Bar -->
                <div class="chart chart-md" id="morrisBar"></div>
                <script type="text/javascript">

                    var morrisBarData = [{
                        y: 'Gennaio 2022',
                        a: 10,
                    }, {
                        y: 'Febbraio 2022',
                        a: 100,
                    }, {
                        y: 'Marzo 2022',
                        a: 60,
                    }, {
                        y: 'Aprile 2022',
                        a: 75,
                    }, {
                        y: 'Maggio 2022',
                        a: 90,
                    }, {
                        y: 'Giugno 2022',
                        a: 75,
                    }, {
                        y: 'Luglio 2022',
                        a: 50,
                    }, {
                        y: 'Agosto 2022',
                        a: 75,
                    }, {
                        y: 'Settembre 2022',
                        a: 30,
                    }, {
                        y: 'Ottobre 2022',
                        a: 75,
                    }, {
                        y: 'Novembre 2022',
                        a: 60,
                    }];

                    // See: js/examples/examples.charts.js for more settings.

                </script>

            </div>
        </section>
    </div>
</div>

<div class="row">
    <div class="col-lg-6">
        <section class="card">
            <header class="card-header">
                <div class="card-actions">
                    <a href="##" class="card-action card-action-toggle" data-card-toggle></a>
                    <a href="##" class="card-action card-action-dismiss" data-card-dismiss></a>
                </div>

                <h2 class="card-title">Vendite per azienda</h2>
                <p class="card-subtitle">Negli ultimi 12 mesi.</p>
            </header>
            <div class="card-body">

                <!-- Morris: Line -->
                <div class="chart chart-md" id="morrisLine"></div>
                <script type="text/javascript">

                    var morrisLineData = [{
                        y: 'Gennaio',
                        a: 100,
                        b: 90
                    }, {
                        y: 'Febbraio',
                        a: 75,
                        b: 65
                    }, {
                        y: 'Marzo',
                        a: 50,
                        b: 40
                    }, {
                        y: 'Aprile',
                        a: 75,
                        b: 65
                    }, {
                        y: 'Maggio',
                        a: 50,
                        b: 40
                    }, {
                        y: 'Giugno',
                        a: 75,
                        b: 65
                    }, {
                        y: 'Luglio',
                        a: 100,
                        b: 90
                    }, {
                        y: 'Agosto',
                        a: 75,
                        b: 65
                    }, {
                        y: 'Settembre',
                        a: 100,
                        b: 90
                    }];

                    // See: js/examples/examples.charts.js for more settings.

                </script>

            </div>
        </section>
    </div>
    <div class="col-lg-6">
        <section class="card">
            <header class="card-header">
                <div class="card-actions">
                    <a href="##" class="card-action card-action-toggle" data-card-toggle></a>
                    <a href="##" class="card-action card-action-dismiss" data-card-dismiss></a>
                </div>

                <h2 class="card-title">Vendite per partner</h2>
                <p class="card-subtitle">Negli ultimi 12 mesi.</p>
            </header>
            <div class="card-body">

                <!-- Morris: Donut -->
                <div class="chart chart-md" id="morrisDonut"></div>
                <script type="text/javascript">

                    var morrisDonutData = [{
                        label: "Partner A",
                        value: 32
                    }, {
                        label: "Partner B",
                        value: 18
                    }, {
                        label: "Partner C",
                        value: 20
                    }];

                    // See: js/examples/examples.charts.js for more settings.

                </script>

            </div>
        </section>
    </div>
</div>

</cfoutput>