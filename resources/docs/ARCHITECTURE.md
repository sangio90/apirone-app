# ApirOne - Architecture Diagrams

Questo file contiene diagrammi Mermaid per visualizzare l'architettura del progetto.

## Architettura a 3 Livelli

```mermaid
graph TB
    subgraph Frontend["Frontend Layer"]
        Views[CFML Views]
        KendoUI[KendoUI Components]
        JS[JavaScript App Modules]
    end
    
    subgraph Modules["Module Layer"]
        Manager[Manager Module<br>/manager]
        API[API Module<br>/api]
    end
    
    subgraph Core["Core Layer"]
        Controllers[Controllers]
        Services[Services]
        DAOs[DAOs]
        Beans[Beans/Models]
    end
    
    subgraph External["External"]
        DB[(PostgreSQL)]
        DataMapper[DataMapper]
        AccessMgr[AccessManager]
    end
    
    Views --> Manager
    KendoUI --> Manager
    JS --> Manager
    Views --> API
    
    Manager --> Controllers
    API --> Controllers
    
    Controllers --> Services
    Services --> DAOs
    Services --> Beans
    
    DAOs --> DataMapper
    DataMapper --> DB
    Controllers --> AccessMgr
```

## Flusso Richiesta HTTP (Manager Module)

```mermaid
sequenceDiagram
    participant Browser
    participant ColdBox
    participant Controller
    participant Service
    participant DAO
    participant DB
    
    Browser->>ColdBox: GET /manager/accounts
    ColdBox->>Controller: list(event, rc, prc)
    Controller->>Controller: Check permissions
    Controller->>Service: accountService.list()
    Service->>DAO: accountDao.getAll()
    DAO->>DB: SELECT * FROM accounts
    DB-->>DAO: ResultSet
    DAO-->>Service: Array of Beans
    Service-->>Controller: Result object
    Controller->>Controller: prc.data = result
    Controller->>ColdBox: setView("account/list")
    ColdBox-->>Browser: Rendered HTML + KendoUI
```

## Dependency Injection (WireBox)

```mermaid
graph LR
    subgraph WireBox["WireBox Container"]
        Config[WireBox.cfc]
    end
    
    subgraph Services["Auto-mapped Services"]
        AccountSvc[AccountService]
        ProductSvc[ProductService]
        AttrSvc[AttributeService]
    end
    
    subgraph DAOs["Auto-mapped DAOs"]
        AccountDao[AccountDao]
        ProductDao[ProductDao]
    end
    
    subgraph Decorators["Decorated Services"]
        FontSvc[FontService]
        FontDec[LoggerServiceDecorator]
    end
    
    subgraph Controllers["Controllers"]
        AccCtrl[AccountController]
    end
    
    Config -->|mapDirectory| Services
    Config -->|mapDirectory| DAOs
    Config -->|map/decorator| Decorators
    
    FontDec -->|wraps| FontSvc
    
    AccCtrl -->|inject| AccountSvc
    AccountSvc -->|inject| AccountDao
```

## Pattern Service Layer

```mermaid
classDiagram
    class AbsService {
        +getResult() Result
        +getError() Error
        +bean(type, values) Bean
        +getDataMapper() DataMapper
    }
    
    class AccountService {
        -accountDao AccountDao
        +list(filters) Result
        +getById(id) Result
        +save(data) Result
        +delete(id) Result
    }
    
    class ProductService {
        -productDao ProductDao
        -componentService ComponentService
        +list(filters) Result
        +getById(id) Result
        +save(data) Result
    }
    
    class Result {
        -status String
        -data Any
        -message String
        +setData(data)
        +getData()
        +setStatus(status)
    }
    
    AbsService <|-- AccountService
    AbsService <|-- ProductService
    AccountService --> Result
    ProductService --> Result
```

## Frontend Architecture (JavaScript)

```mermaid
graph TB
    subgraph Namespaces["Global Namespaces"]
        AP[AP namespace<br>Application logic]
        NM[NM namespace<br>Utilities]
    end
    
    subgraph AppModules["AP.{entity} Modules"]
        AcctList[AP.account.list]
        AcctDetail[AP.account.detail]
        ProdList[AP.product.list]
    end
    
    subgraph Utilities["NM Utilities"]
        KendoUtils[NM.kendo.*<br>dataSource, formatDate]
        FormUtils[NM.form.*<br>validation, messages]
        UtilFuncs[NM.util.*<br>modal, ajax]
    end
    
    subgraph KendoUI["KendoUI MVVM"]
        ViewModel[kendo.observable]
        DataSource[DataSource]
        Binding[data-bind attributes]
    end
    
    AP --> AppModules
    NM --> Utilities
    
    AcctList --> ViewModel
    AcctList --> KendoUtils
    AcctDetail --> FormUtils
    
    ViewModel --> DataSource
    ViewModel --> Binding
    KendoUtils --> DataSource
```

## Database Schema (Esempio Entità Principali)

```mermaid
erDiagram
    PRODUCTS ||--o{ COMPONENTS : contains
    PRODUCTS ||--o{ COMBINATIONS : has
    PRODUCTS ||--o{ PRODUCT_ITEMS : generates
    
    ATTRIBUTES ||--o{ ATTRIBUTE_VALUES : has
    ATTRIBUTES ||--o{ RAW_VALUES : has
    
    COMPONENTS ||--o{ COMPONENT_OVERRIDES : can_override
    
    COMBINATIONS ||--o{ COMBINATION_PRODUCT_ITEMS : links
    COMBINATION_PRODUCT_ITEMS }o--|| PRODUCT_ITEMS : references
    
    ACCOUNTS ||--o{ AUDIT_ENTRIES : creates
    
    PRODUCTS {
        int id PK
        string code
        string name
        string status
        timestamp created_at
    }
    
    COMPONENTS {
        int id PK
        int product_id FK
        string code
        string name
    }
    
    ATTRIBUTES {
        int id PK
        string code
        string name
        string type
    }
```

## Flusso AJAX (KendoUI DataSource)

```mermaid
sequenceDiagram
    participant Grid as KendoUI Grid
    participant DS as DataSource
    participant Ajax as AJAX Call
    participant Ctrl as AjaxController
    participant Svc as Service
    
    Grid->>DS: read()
    DS->>Ajax: GET /manager/ajax/accounts
    Ajax->>Ctrl: list(event, rc, prc)
    Ctrl->>Svc: accountService.list(filters)
    Svc-->>Ctrl: Result object
    Ctrl->>Ctrl: event.getResponse().setData()
    Ctrl-->>Ajax: JSON response
    Ajax-->>DS: data array
    DS-->>Grid: populate rows
    Grid->>Grid: render with template
```

## Workflow Aggiunta Nuova Entità

```mermaid
graph TD
    Start[Nuova Entità] --> Bean[Crea Bean.cfc]
    Bean --> DAO[Crea EntityDao.cfc]
    DAO --> Service[Crea EntityService.cfc]
    Service --> Memento[Crea EntityMemento.json.cfm]
    
    Memento --> Controllers{Tipo modulo?}
    Controllers -->|Manager| MgrCtrl[EntityController.cfc<br>EntityAjaxController.cfc]
    Controllers -->|API| ApiCtrl[API Controller]
    
    MgrCtrl --> Views[Views: list.cfm<br>detail-modal.cfm]
    Views --> JS[app-entity.js]
    JS --> Perms[Update permissions.json.cfm]
    Perms --> Menu[Update menu.json.cfm]
    Menu --> End[Done!]
```

---

**Nota:** VS Code renderizza automaticamente i diagrammi Mermaid. Se non li vedi, assicurati di avere l'anteprima Markdown attiva (Ctrl+Shift+V o click sull'icona preview).
