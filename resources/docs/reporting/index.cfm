<html class="theme-dark">
	<head>
		<title>Reporting</title>
		<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.0/css/bulma.min.css">
	</head>
	<body>

		<div class="container is-fluid mt-3 mb-3">

			<h1 class="title">Reporting for Apir</h1>

			<h2 class="title is-3">Lista dei report</h2>

			<h4 class="title is-4 bd-anchor-title">1. Stampa classica</h4>

            <p class="py-4">
                - File: 001 - Stampa CLASSICA_Offerta_644.pdf
            </p>

            Dati in entrata:
            <br>
            <p>
                <pre>
                    {
                        meta: {
                            file: "nome_del_file.jr",
                            fileName: "",
                            title: "Titolo del report",
                            owner: "Apir Srl",
                            date: "20/05/2024"
                        }, 
                        document: {
                            header: {
                                currency: "EUR",
                                date: "2024-05-20",
                                validUntil: "2024-06-20",
                                number: "P.644/4",
                                customer: {
                                    name: "BORGHI VALERIA",
                                    phone: "393477107657",
                                    email: "valeriaborghi@acqstudio.com",
                                    vat: "077000001",
                                    address: "Via Andrea Del Castagno, 34",
                                    city: "Firenze",
                                    county: "FM",
                                    country: {
                                        code: "ID"
                                    },
                                    shipment: {
                                        name: "BORGHI VALERIA",
                                        phone: "393477107657",
                                        address: "Via Andrea Del Castagno 34",
                                        city: "Firenze",
                                        county: "FM",
                                        country: {
                                            code: "ID"
                                        },
                                    }
                                }
                            },
                            rows: [
                                {
                                    product: {
                                        name: "Finitura:Ottone Industriale",
                                        description: "Profilo:Taglio Diritto, Fissaggio:Calamite, Incisione Logo:No, Forma:Rotonda, Orientamento:Orizzontale",
                                        images: {
                                            url: "https://media.jesse.it/wp-content/uploads/2023/01/casa-tipica-in-legno-1024x682.jpg"
                                        }
                                        quantity: 1,
                                        price: 10.5,
                                        total: 10.5
                                    },
                                    fruits: [ 
                                        {
                                            id: "4.0-2",
                                            name: "Deviatore a levetta - 1p 10ax",
                                            description: "Finitura:Ottone satinato - Incisione Frutto:No - Forma Levetta:AVIO -",
                                            position: "CUCINA/1"
                                        },
                                        {
                                            id: "4.0-2",
                                            name: "VerniciatoColore:Nero",
                                            description: "Profilo:Taglio Diritto - Fissaggio:Calamite - Incisione Logo:No - Forma:Rettangolare - Orientamento:Orizzontale
                                            note: "PRESA NASCOSTE IN",
                                            position: "CUCINA/2"
                                        }
                                    ]
                                },
                                {
                                    product: {
                                        name: "Finitura:Ottone Industriale",
                                        description: "Profilo:Taglio Diritto, Fissaggio:Calamite, Incisione Logo:No, Forma:Rotonda, Orientamento:Orizzontale"
                                        quantity: 1,
                                        price: 10.5,
                                        total: 10.5
                                    },
                                    fruits: [ 
                                        {
                                            id: "4.0-2",
                                            name: "Deviatore a levetta - 1p 10ax",
                                            description: "Finitura:Ottone satinato - Incisione Frutto:No - Forma Levetta:AVIO -",
                                            position: "CUCINA/1"
                                        },
                                        {
                                            id: "4.0-2",
                                            name: "VerniciatoColore:Nero",
                                            description: "Profilo:Taglio Diritto - Fissaggio:Calamite - Incisione Logo:No - Forma:Rettangolare - Orientamento:Orizzontale
                                            note: "PRESA NASCOSTE IN",
                                            position: "CUCINA/2"
                                        }
                                    ]

                                }
                            ],
                            footer: {
                                totalGoods: 100,
                                vat: {
                                    name: "Imposta 20%",
                                    value: 30
                                },
                                total:  120,
                                discount: {
                                    name: "Sconto 10%",
                                    value: "3%"
                                },
                                shipment: {
                                    name: "Spedizione 6/8 Settimane" 
                                },
                                payment: {
                                    name: "30% anticipo-saldo da definire" 
                                }
                            },                            

                        }
                    }
                </pre>
            </p>

            <hr class="my-6 py-1">

            <h2 class="title is-3 pt-6">API Rest</h2>

            <h4 class="title is-4 pt-5">Reportistca</h4>

            <b>Generate report</b>:<br>
            <code>
                &nbsp;POST $HOST/report/generate?id=$IdReport<br>
                &nbsp; BODY: { json_sopra }
            </code>

            <h4 class="title is-4 pt-5">ApirOne</h4>

            <b>Get report</b>:<br>
            <code>
                &nbsp;GET $HOST/report/?id=$IdReport<br>
            </code>

        </div>

    </body>

</html>

<!---
    1. hai un ip fisso?
    2. tabella / api anche per Apir
--->