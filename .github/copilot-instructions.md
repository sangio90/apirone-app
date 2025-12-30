# ApirOne - AI Coding Assistant Instructions

## Quick Start
```bash
box install                    # Install dependencies
box run-script setup:devel     # Setup dev environment (.env file)
box server start               # Start Lucee server
# Visit: http://localhost:{port}/manager
# Tests: http://localhost:{port}/tests/runner-all.cfm
```

**Key reload commands:**
- `?reinit=1` - Reload ColdBox framework
- `?reset=1` - Clear cache and restart application

## Project Overview
ApirOne is a product configurator for Apir Srl built on **ColdBox Framework** (CFML) with **Lucee 5.4.8.2**, using **PostgreSQL** for data and **KendoUI** for the frontend. It's a modular application managing products, attributes, combinations, and pricing for custom manufacturing.

**Tech Stack:**
- Backend: ColdBox 7.4.2 (CFML framework) on Lucee 5.4.8.2
- Database: PostgreSQL 16 (no ORM - uses custom DataMapper)
- Frontend: KendoUI + jQuery with server-rendered CFML views
- DI: WireBox (auto-wiring services/DAOs)
- Testing: TestBox with cbMockData fixtures

## Architecture

### Three-Layer Structure
1. **Core Layer** (`com/apirone/core/`): Business logic, services, DAOs, and models
2. **Module Layer** (`apps/`): Two ColdBox modules
   - `manager`: Admin interface (entry point `/manager`)
   - `api`: REST API (entry point `/api`)
3. **Frontend Layer**: Server-rendered CFML views + KendoUI/jQuery SPA-like interactions

### Key Directories
- `com/apirone/core/model/service/`: Business services extending `AbsService`
- `com/apirone/core/model/dao/`: Data access objects
- `com/apirone/core/controller/`: Base controllers
- `config/`: ColdBox, WireBox, settings, and JSON data files (roles, permissions, entities)
- `config/data/*.json.cfm`: Static data definitions (permissions, roles, menu structure)
- `apps/manager/controllers/`: Admin module controllers
- `apps/manager/views/`: CFML templates
- `apps/manager/assets/js/`: Frontend JavaScript (pattern: `app-{entity}.js`)
- `resources/db/ddl/`: Database migration SQL files

## Development Workflow

### Environment Setup
```bash
# Install dependencies via CommandBox
box install

# Setup environment (creates .env from properties file)
box run-script setup:devel   # Local development
box run-script setup:prod    # Production
box run-script setup:test    # Testing
box run-script setup:stage   # Staging

# Start server (uses server.json config)
box server start
```

Environment-specific properties are in `tasks/envs/{env}.properties`.

### Running Tests
```bash
# Run all tests via TestBox
http://localhost:{port}/tests/runner-all.cfm

# Run specific test bundles
http://localhost:{port}/tests/runner.cfm?directory=tests.specs.com.apirone
```

Tests use `cbMockData` for fixtures. TestBox framework is in `modules/testbox/`.

### Code Formatting
```bash
box run-script format        # Format all code
box run-script format:watch  # Watch mode for auto-formatting
box run-script format:check  # Check formatting without changes
```

Formatting enforced by `cfformat` (config: `.cfformat.json`) and EditorConfig:
* **Spaces in Parentheses**: ALWAYS use spaces inside parentheses for function calls, definitions, and control structures.
    *   *Correct*: `if ( condition ) { ... }`
    *   *Correct*: `function( arg1, arg2 ) { ... }`
    *   *Incorrect*: `if(condition) { ... }`
*   **Indentation**: Use tabs (4 spaces wide) as defined in `.editorconfig`
*   **Function Casing**: Built-in functions in PascalCase, user-defined in camelCase
*   **Max line length**: 120 characters

### Database
- Uses PostgreSQL 16
- Manual migrations in `resources/db/ddl/` (date-prefixed SQL files)
- No ORM - raw queries via DataMapper (`modules/external/dataMapper/`)
- Connection configured via `.env` file

**Convention for triggers/functions:**

1. **Functions**: `fn_<table>_<action>_<field>`
    *   Ex.: `fn_attribute_raw_value_u_component_count`

2. **Triggers**: `tgr_<table>_<action>_<target_table>_<description>`
    *   Ex.: `tgr_components_aiu_attributes_raw_values_component_count`
    *   Ex.: `tgr_components_ad_attributes_raw_values_component_count`

**Action/event codes:**
- `u` = update
- `i` = insert
- `d` = delete
- `a` = after
- `b` = before

Ex. `aiu` = after insert update

## Code Patterns

### Result/Error Bean Pattern
Service methods that return **paginated lists**, return a `Result` bean containing status, count, total and data:

```cfml
public function doSomething() {
    var result = getResult();  // Helper method from AbsService
    
    try {
        var data = // ... business logic
        result.setData(data);
        result.setStatus("SUCCESS");
    } catch (any e) {
        var error = getError();  // Helper method from AbsService
        error.setType("apirone.error.service.OperationFailed");
        error.setMessage("Failed to complete operation: [#e.message#]");
        result.addError(error);
        result.setStatus("ERROR");
    }
    
    return result;
}
```

### Service Layer Pattern
All services extend `AbsService` and are auto-wired as singletons:

```cfml
component extends="com.apirone.core.model.service.AbsService" accessors="true" {
    
    property name="someOtherService" inject="SomeOtherService";
    
    public function doSomething() {
        var result = getResult();
        // Business logic
        result.setData(data);
        return result;
    }
}
```

Services registered in `config/WireBox.cfc` via `mapDirectory()`. Some use decorator pattern (e.g., `LoggerServiceDecorator` wrapping `FontService`).

### Controller Pattern (Manager Module)
Controllers extend `com.apirone.core.controller.AbsController`:

```cfml
component extends="com.apirone.core.controller.AbsController" {
    
    property name="accountService" inject="AccountService";
    
    function list(event, rc, prc) {
        // rc = Request Collection (URL/form params - public scope)
        // prc = Private Request Collection (view data - private scope)
        
        prc.title = "Entity List";
        prc.accounts = accountService.getAll().getData();
        
        event.setView("entity/list");
    }
    
    function save(event, rc, prc) {
        var result = accountService.save(rc);
        
        event.getResponse()
            .setData(result)
            .setError(!result.getStatus() == "SUCCESS");
    }
}
```

**Request Collection (`rc`) vs Private Request Collection (`prc`):**
- `rc`: Contains URL parameters, form data - automatically populated by ColdBox, accessible in views
- `prc`: Controller-set data for views only - more secure, not exposed to URL manipulation
- AJAX controllers return JSON via `event.getResponse().setData()`
- Validation uses `cbvalidation` with constraints in `apps/api/constraints/`

### Frontend Architecture (Manager Module)
JavaScript follows a namespaced pattern with KendoUI MVVM:

```javascript
// Pattern: AP.{entity}.{action}
AP.namespace("account");

AP.account.list = (function() {
    var pub = {};
    var fields = AP.account.fields;
    
    var viewModel = kendo.observable({
        items: NM.kendo.dataSource({ url: "/manager/ajax/accounts" }),
        // ... observables
    });
    
    pub.init = function() {
        kendo.bind(fields.listRoot, viewModel);
    };
    
    return pub;
})();
```

**Custom Utilities:**
- `NM.kendo.*`: KendoUI helpers (dataSource, formatDate, formatCurrency)
- `NM.util.*`: Modal handling, AJAX, form utilities
- `NM.form.*`: Form validation and message display

### View Patterns
Views use data-binding with KendoUI:

```cfml
<div id="entity-list-root">
    <div data-bind="source: items" data-template="entity-row-template"></div>
</div>

<script id="entity-row-template" type="text/x-kendo-template">
    <div>#: name #</div>
</script>
```

Helper functions in `apps/manager/helpers/viewHelpers.cfm` provide `pageTitle()`, `includeJSFiles()`, etc.

### Configuration Pattern
Static data lives in `config/data/*.json.cfm` files:
- `permissions.json.cfm`: Permission definitions (e.g., `RAW_VALUE.VIEW`)
- `roles.json.cfm`: User roles
- `entities.json.cfm`: Entity metadata
- `menu.json.cfm`: Admin menu structure with role-based access

These are JSON arrays wrapped in CFML to prevent direct access.

### Memento Pattern
Entity serialization configured via `config/mementos/{Entity}Memento.json.cfm`:
```json
{
    "default": {
        "properties": ["id", "name", "code", "status"],
        "includes": {
            "status": { "memento": "default" }
        }
    },
    "detail": {
        "properties": ["id", "name", "code", "description", "status", "createdAt"],
        "includes": {
            "status": { "memento": "default" },
            "variants": { "memento": "list" }
        }
    }
}
```

Used to control API response structure and avoid circular references. Access via `bean.getMemento("profile")`.

### Validation
Using `cbvalidation`:

```cfml
// In controller
var constraints = getConstraints("EntityName", "profile");
var validationResult = validate(target=rc, constraints=constraints);

if (validationResult.hasErrors()) {
    setErrorResult(event, validationResult.getAllErrors());
}
```

Constraints defined in `apps/api/constraints/{Entity}.json`.

## Important Conventions

### Naming
- Services: `{Entity}Service.cfc` (e.g., `AccountService.cfc`)
- Controllers: `{Entity}Controller.cfc` and `{Entity}AjaxController.cfc`
- Views: `apps/manager/views/{entity}/{action}.cfm`
- JS files: `app-{entity}.js` or `app-{entity}-{action}.js`
- DAOs: `{Entity}Dao.cfc`

### URL Structure
- Manager module: `/manager/{handler}/{action}`
- API module: `/api/{handler}/{action}`
- AJAX endpoints: `/manager/ajax/{entity}` or `/api/{entity}`
- Static assets use cache-busting via `prc.staticVersion`

### Asset Management
Assets loaded via URL rewrite rules in `config/urlrewrite.xml`:
- `/assets/{version}/manager/js/file.js` → `/apps/manager/assets/js/file.js`
- `/assets/{version}/main/css/file.css` → `/assets/main/css/file.css`

CSS/JS file lists in `config/assets/{cssFiles|jsFiles}.json.cfm`.

### Error Handling
- Production: Custom error template at `/apps/utils/errorReport.cfm`
- Development: ColdBox debug mode with `?reinit` to reload
- Invalid events handled by `UtilController.notFound`

**Error naming convention:**

_Type Structure:_ `<project>.error.<scope>.<errorType>`

Examples:
- `apirone.error.metadata.NotFound`
- `apirone.error.product.InvalidSaveType`
- `apirone.error.common.Unauthorized`

_Messages (message):_
- Complete, clear, developer-friendly sentences.
- Always specify the entity, action, and ID/value if possible.
- Dynamic values ​​in square brackets.
- If the error is expected (e.g., validation), make it explicit.

Examples:
```
message = "Failed to save metadata: Invalid type [width]."
message = "Product with ID [42] not found."
message = "Unauthorized attempt to access resource [metadata]."
```

_Reusable message errors (generic):_

| **Type** | **Name** | **When to use it** |
| ---| ---| --- |
| Missing parameter | MissingParameter | Missing required parameters |
| Invalid type | InvalidType | Invalid enum, switch, routing |
| Access denied | Unauthorized | Missing role/permission |
| Not Found | NotFound | Missing resource |
| Validation failed | ValidationError | Invalid input |

## Module System

### Manager Module (`apps/manager/`)
Admin interface with authentication and role-based permissions.

**Key Features:**
- Session-based auth (`session.user`)
- Permission checks via `AccessManager` (injected utility)
- KendoUI grids for CRUD operations
- Modal-based detail views

### API Module (`apps/api/`)
RESTful API for external integrations.

**Key Features:**
- JSON payloads auto-converted to `rc`
- Layout: `api.cfm` (minimal wrapper)
- Separate constraint validation

## Dependency Injection (WireBox)

Configure in `config/WireBox.cfc`:

```cfml
// Auto-map directories
mapDirectory(packagePath="com.apirone.core.model.service").asSingleton();

// Explicit mappings
map("ServiceName").to("full.path.ServiceName")
    .asSingleton()
    .initArg(name="argName", value="argValue");

// Request-scoped services
map("PriceCalculatorService").to("...").into(this.SCOPES.REQUEST);
```

Access via `inject` property or `getInstance()`.

## External Dependencies

### Custom Modules (Private Repository)
Installed from `http+cached://www.coridalia.cc/repository/`:
- `dataMapper`: Custom ORM/query builder
- `accessManager`: Role/permission management
- `porto-admin-template`: Admin UI theme
- `kendoui`: Licensed KendoUI framework

### Framework Dependencies
- `coldbox`: 7.4.2+24
- `cbvalidation`: 4.4.0
- `testbox`: 5.1.0+2 (dev only)

## Deployment

### Build Process
```bash
# Create deployment ZIP
box run-script createZip
```

Creates versioned ZIP in `../zips/{slug}_{date}_{version}/` with excluded patterns from `tasks/config.json.cfm`.

### Docker Setup
Uses `docker-compose-dist.yml`:
- CommandBox container (port 8080)
- PostgreSQL 16 container
- Nginx for static file serving (port 7112)

Configure ports/credentials by copying `docker-compose-dist.yml` to `docker-compose.yml`.

## Common Tasks

### Adding a New Entity
1. Create service: `com/apirone/core/model/service/{Entity}Service.cfc`
2. Create DAO: `com/apirone/core/model/dao/{Entity}Dao.cfc`
3. Create bean: `com/apirone/core/model/bean/{Entity}.cfc`
4. Add memento config: `config/mementos/{Entity}Memento.json.cfm`
5. Create controllers: `apps/manager/controllers/{Entity}Controller.cfc` + `{Entity}AjaxController.cfc`
6. Create views: `apps/manager/views/{entity}/list.cfm` + `detail-modal.cfm`
7. Create JS: `apps/manager/assets/js/app-{entity}.js`
8. Add permissions: Update `config/data/permissions.json.cfm`
9. Add to menu: Update `config/data/menu.json.cfm`

### Debugging
- Use `dump()` and `abort` for quick debugging
- Check `prc.isDev` for development-only code
- Add `?reinit=1` to URL to reload ColdBox
- Set breakpoints in Lucee admin: `http://localhost:{port}/lucee/admin/server.cfm`

### Working with KendoUI
- DataSources created via `NM.kendo.dataSource({ url: "..." })`
- Grids use row templates (see `apps/manager/views/{entity}/{entity}-grid-row-tmpl.cfm`)
- Date formatting: `NM.kendo.formatISODate(date)` or `NM.kendo.formatDate(date)`
- Currency: `NM.kendo.formatCurrency(amount)`

## Security Notes
- Authentication managed in `Application.cfc` via `session.user`
- Permissions checked via `AccessManager` utility
- Role-based menu filtering in views
- CSRF protection via ColdBox (if enabled)
- SQL injection prevention via `<cfqueryparam>` in DAOs

## Resources
- ColdBox Docs: https://coldbox.ortusbooks.com/
- Lucee Docs: https://docs.lucee.org/
- KendoUI Docs: https://docs.telerik.com/kendo-ui/
- TestBox Docs: https://testbox.ortusbooks.com/
