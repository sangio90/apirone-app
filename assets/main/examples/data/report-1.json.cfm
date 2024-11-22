{
    header: {
        currency: "EUR",
        date: "2024-05-20",
        validUntil: "2024-06-20",
        number: "P.644/4",
        payment: {
            name: "30% anticipo-saldo da definire" 
        },
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
                image: {
                    url: "https://placehold.co/500x500.jpg"
                },
                quantity: 1,
                price: 10.5,
                total: 10.5,
                position: "Lista di posizinio on una stringa"
            },
            fruits: [ 
                {
                    id: "4.0-2",
                    name: "Deviatore a levetta - 1p 10ax",
                    description: "Finitura:Ottone satinato - Incisione Frutto:No - Forma Levetta:AVIO -",
                },
                {
                    id: "4.0-2",
                    name: "VerniciatoColore:Nero",
                    description: "Profilo:Taglio Diritto - Fissaggio:Calamite - Incisione Logo:No - Forma:Rettangolare - Orientamento:Orizzontale",
                    note: "PRESA NASCOSTE IN",
                }
            ]
        },
        {
            product: {
                name: "Finitura:Ottone Industriale",
                description: "Profilo:Taglio Diritto, Fissaggio:Calamite, Incisione Logo:No, Forma:Rotonda, Orientamento:Orizzontale",
                image: {
                    url: "https://placehold.co/500x500.jpg"
                },
                quantity: 1,
                price: 10.5,
                total: 10.5,
                position: "CUCINA/1"

            },
            fruits: [ 
                {
                    id: "4.0-2",
                    name: "Deviatore a levetta - 1p 10ax",
                    description: "Finitura:Ottone satinato - Incisione Frutto:No - Forma Levetta:AVIO",
                    note: "PRESA NASCOSTE IN"
                },
                {
                    id: "4.0-2",
                    name: "VerniciatoColore:Nero",
                    description: "Profilo:Taglio Diritto - Fissaggio:Calamite - Incisione Logo:No - Forma:Rettangolare - Orientamento:Orizzontale",
                    note: "PRESA NASCOSTE IN"
                }
            ]

        }
    ],
    footer: {
        totals: [
            {
                "Totale merce": 10000
            },
            {
                "IVA 20%": 1200
            },
            {
                "Sconto 50%": 2200
            },
            {
                "Totale fattura": 2400
            }
        ],
        description: "text in html"
    }
}