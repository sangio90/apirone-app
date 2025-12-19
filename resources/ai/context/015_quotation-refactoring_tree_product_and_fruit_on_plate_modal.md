# Preventivi. Refactoring dell'albero degli attributi e dei frutti delle placche

Agisci come un esperto Senior Developer specializzato in javascript, KendoUI e Kendo Mvvm.

## Stato dell'arte - Problemi attuali.

Nell'attuale implementazione, quando si seleziona un prodotto, viene aperto una modal tutti i dati della riga/prodotto. A sinistra c'è l'albero delle opzioni (una serie di select a cascata) che viene caricato (condelle chiamate ajax) ricorsivamente. Se gli attributi sono molti, l'interfaccia diventa un po' lenta. 

Il prodotto contiene degli attributi e delle opzioni in modo ricorsivo.


## Obiettivi del refactoring:

- Pattern architetturale: Riorganizza il codice seguendo il pattern MVC (Model-View-Controller) o una struttura a Moduli ES6.
- Performance: ottimizza le chiamate ajax per caricare l'albero delle opzioni.
- Semplicità: semplifica il codice per renderlo più facile da mantenere e modificare.


## API 

```
POST /api/register 
```

(Successo - 201): { "status": "success", "data": { "id": 123, "createdAt": "2025-12-19" } } 

