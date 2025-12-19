# Project Instructions & Coding Standards 

## Introduzione
Questa è un'applicazione web per la configurazione di prodotti complessi. Le macro aree di riferimento dei prodotti sono tre:
- **placche elettriche**, con tutti i sotto-prodotti da poter abbinare, detti "frutti", come ad esempio una presa schuko o un deviatore. 
- **accessori** come ad esempio reggivaligia o trolley. 
- **segnaletiche** varie: scritte, numerate, etc.
  
Ognuno di queste macro aree ha delle proprie particolarità.  
Tutti i prodotti sono costituiti da una categoria, una linea, un modello, una finitura.  
Ogni prodotto ad un proprio "albero" delle opzioni organizzate per chiave (**attribute**)  e valore (**attributeValue**); le opzioni sono ricorsive e possono avere opzioni figlie. 

## JavaScript formatting
*   **Spaces in Parentheses**: ALWAYS use spaces inside parentheses for function calls, definitions, and control structures.
    *   *Correct*: `if ( condition ) { ... }`
    *   *Correct*: `function( arg1, arg2 ) { ... }`
    *   *Incorrect*: `if(condition) { ... }`
*   **Indentation**: Use 4 spaces (or tabs converted to 4 spaces, based on EditorConfig).

## Architecture & namespaces
*   **Namespace Creation**: Use `AP.namespace("path.to.module")` to create namespaces. This function supports dot notation and preserves existing objects.
    *   Example: `AP.namespace("plate.grid")` ensures `AP.plate` covers `AP.plate.grid` without overwriting `AP.plate`.
*   **Safety Checks**: When initializing namespaces manually (if not using the helper), always use the `|| {}` pattern: `AP.module = AP.module || {};`.

## Libraries & Frameworks
*   **jQuery**: The project uses jQuery (`$`). Prefer jQuery for DOM manipulation.
*   **Kendo UI**: Used for UI components (Grids, DataSources, Observables).
*   **Backend**: Lucee (`.cfc`, `.cfm`). Frontend assets are typically in `apps/manager/assets/js/`.

## Backend
*   **Lucee**: The project uses Lucee (`.cfc`, `.cfm`).
*   **Backend Assets**: Backend assets are typically in `apps/manager/controllers/`.

## Project Structure
*   **Frontend**: `apps/manager/assets/js/`
*   **Controllers**: `apps/manager/controllers/`
*   **Data access**: `core/apirone/` (data access)
*   **Models**: `core/apirone/` (models)
*   


# Altre note

## 1

La riga rossa indica che sei in dev
![](https://t2599594.p.clickup-attachments.com/t2599594/582ff88c-ffb3-4815-9baa-7bf9dd740df7/image.png)

## 2
L'asterisco nel titolo indica che sei in dev
![](https://t2599594.p.clickup-attachments.com/t2599594/aa7f0738-f1b8-4ce8-998a-6b669684c1b2/image.png)

## 3
I template js sono nella cartella jstemplate suddivisi per vista, il nome finisce per -tmpl e l'id è lo stesso del nome del file.

## 4
Nei servizi, tutte le search() tornato un oggetto paginato Result con total (record totali) e count (numero di record correnti)

## 5
Nei servizi, le list() chiamano sempre la search() ma senza limit/offset e restituiscono direttamente un array. Il trucco è mettere il limit -1

## 6
Da box, per formattare il testo installa (una volta soltanto):

```plain
install commandbox-cfformat
```

poi:

```plain
run-script format:watch
```

che rimate in ascolto e formatta i .cfc, dentro la cartella "model" e "controllers", ogni volta che salvi.

Sostituisci il file che ti allego in

[Delimited.cfc](https://t2599594.p.clickup-attachments.com/t2599594/4e1a3d0e-06ef-44b4-9ac6-3727207fe4a1/Delimited.cfc)

.CommandBox/cfml/modules/commandbox-cfformat/models

## 7
Code guidelines:
per cfml:
[https://github.com/Ortus-Solutions/coding-standards/blob/master/guides/coldfusion.md](https://github.com/Ortus-Solutions/coding-standards/blob/master/guides/coldfusion.md)
che comunque te lo fa cfformat (con piccole modifiche)

per js:
[https://github.com/Ortus-Solutions/coding-standards/blob/master/guides/javascript.md](https://github.com/Ortus-Solutions/coding-standards/blob/master/guides/javascript.md)
sto preparando il js _.jsbeautifyrc._ Abbi pazienza.

## 7/A
Tab space = 4

## 8
per riavviare l'mvc ([Coldbox](https://coldbox.ortusbooks.com/)) devi passare

```plain
?fwreinit=1 
```

nella queryString ogni volta che modifichi il Router.cfc

per riavviare la BusinessLogic (che non dovrebbe succedere mai, in dev lo fa ad ogni request):

```plain
?reinit=1 
```

## 9
Non usiamo né ORM (💩) né Factory (anche se domani scopriremo se ci sarà utili per i prodotti). C'è un build() in tutti i servizi. 

## 10
nei controlli usiamo sempre save() mentre nei servizi create() and update()

## 11
Per i messaggi che arrivano dalle chiamate ajax in genere facciamo così:

```plain
var message = super.completeMessage( "message.id" ); 
```

con "[message.id](http://message.id)" inserito dentro config/assets/messages-it.json.cfm
Quindi lo restituito al client così, eventualmente con un un payload:

```plain
event.setValue( "result", { "message" = message, "payload" = { "id" = newId } } );
```

## 12
Tutti gli stati (attivo, disattivo, cancellato, etc) sono nella tabella:

```cpp
public.statuses
```

ogni record porta un campo "entities" in jsonb, con i "domini" per quello stato.
Si aggiorna così:

```plain
UPDATE status set entities = '["LINE", "ATTRIBUTE", "FINISH"]'
WHERE status_id IN ('ACT', 'DEA');
```

## 13

| **SERVICE** | **DAO** |
| ---| --- |
| get() | read() |
| list() → non paginato, tutti i record | find() (non direttamente) |
| search() → paginato | find() |
| create() | insert() |
| update() | update() |

## 14
In questa pagina trovi alcuni task che ti potrebbero essere utili per lo sviluppo.
Una è "svuota cache", che rimuove tutti i bean in cache:
[http://apirone.local:TUO\_IP/resources/routines.cfm](http://apirone.local:7110/resources/routines.cfm)

## 15
Ogni grid porta il nome del template di riga usato.
Basta fare doppio click nello spazio bianco in fondo a sinistra per leggerlo.
![](https://t2599594.p.clickup-attachments.com/t2599594/081020a8-647e-4762-99be-9dd14d186804/image.png)

## 16
Convenzioni per trigger/funzioni:

1. **Funzioni**: fn\_<tabella>\_<azione>\_<campo>
    *   Es: fn\_attribute\_raw\_value\_u\_component\_count

1. **Trigger**: tgr\_<tabella>\_<azione>\_<target\_target>\_<description>
    *   Esempio: tgr\_components\_aiu\_attributes\_raw\_values\_component\_count
    *   Esempio: tgr\_components\_ad\_attributes\_raw\_values\_component\_count

con, azioni/eventi:
u = update
i = insert
a = after
b = before

Es. aiu = after insert update

## 17
Stiamo usando l'auto inject di Wirebox direttamente mappando le cartelle:
model.dao e model.service
Ogni file in queste cartelle è un singleton attingibile dal proprio nome.
Quindi nelle property dei servizi basta scrivere:

```plain
property name="statusService" inject="StatusService";
property name="textService" inject="TextService";
```

senza dover configurare WireBoxService.cfc, dove invece ho lasciato alcune classi di utility e meno standard.

**Occhio** a non scrivere :

```plain
property name="cacheScope" inject="String" default="Size.bean";
```

(inject="string" = Errore)

## 18
Convenzione errori

_Type_
Struttura: <progetto>.error.<ambito>.<tipoErrore>

\- apirone.error.metadata.NotFound
\- apirone.error.product.InvalidSaveType
\- apirone.error.common.Unauthorized

_Messaggi (message)_
\- Frasi complete, chiare, orientate all’utente sviluppatore.
\- Specifica sempre l’entità, l’azione e l’ID/valore se possibile.
\- Valori dinamici fra parentesi quadre.
\- Se l’errore è atteso (es. validazione), rendilo esplicito.

message = "Impossibile salvare i metadati: tipo \[larghezza\] non valido."
message = "Prodotto con ID \[42\] non trovato."
message = "Tentativo non autorizzato di accedere alla risorsa \[metadata\]."

_Errori riusabili (generici_)

| **Tipo** | **Nome** | **Quando usarlo** |
| ---| ---| --- |
| Parametro mancante | MissingParameter | Parametri obbligatori mancanti |
| Tipo non valido | InvalidType | Enum, switch, routing errato |
| Accesso negato | Unauthorized | Ruolo/permesso mancante |
| Non trovato | NotFound | Risorsa assente |
| Validazione fallita | ValidationError | Input non valido |

## 19 util/Mementify
Usa il Mementify per le serializzazione dei dati (per quanto si può).

## 20 - Core
- DAO,service, Mvc...