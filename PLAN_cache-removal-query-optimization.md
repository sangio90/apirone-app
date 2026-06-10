# PLAN: Cache Removal & Query Optimization

## Progress Tracking

| Label | Meaning |
| --- | --- |
| `❌ TO DO` | Not started |
| `⏳ IN PROGRESS` | Being worked on |
| `✅ DONE` | Completed & verified |

---

## Overview

Two interventions, applied **simultaneously, entity by entity**:

1. **Remove bean caching** (`CacheManager.get/put/remove`) — the primary cause of stale data
2. **Merge the N+1 query pattern** — DAO `find()` returns only IDs, then the service `search()` calls `get(id)` for each record, and `build()` fires 5–50+ sub-queries per bean

**Strategy per entity:**

- Add batch methods (`readByIds`, `getMany`, `listByEntityIds`) to optionally preload sub-entities
- Rewrite `search()` to build beans from a single batch fetch instead of N individual `get()` calls
- Remove the cache from `get()` once `search()` is verified
- Each entity is independently testable — no need to finish everything before testing

**View caching** (sidebar menu, search template in `layouts/manager.cfm`) — kept as-is.

---

## Scope Boundaries

### NOT touched (excluded from all changes)

| Reason | Entities |
| --- | --- |
| **MS SQL ERP (verticale)** | RawProduct, VatCode, PaymentMethod, PaymentType, Currency, Country, Variant, RawProductType, Color, Cost (and their DAOs) |
| **Read-only lookups** | Status, Lang, Lookup, SystemColor, Thickness, Orientation, MeasurementUnit, Entity, DataType, FileKind, FileType, ArticleType, CompanyType, TextKind, PriceLine, PriceMethod, ProcessingType, ProfileType, RoleType, SearchTerm |
| **Config-only (no DB)** | BillingProfile, Lead |
| **View caching** | `layouts/manager.cfm` — menu by role and search template fragment |

### TOUCHED (cache removed + query optimized)

**~49 services + ~49 DAOs**, organized into 3 tiers by build() complexity:

| Tier | Build cost | Count | Entities |
| --- | --- | --- | --- |
| T1 – Light | ≤3 DB queries | ~20 | Pricelist, Font, Profile, Permission, PictogramDimension, ProductionTime, Search, FontFamilySize, SignageConfigItem, QuotationItemFruitPosition, QuotationItemPosition, QuotationItemPriceLine, QuotationPriceLine, QuotationItemProduct, QuotationZonePosition, RolePermission, Role, QuotationItemSignageRow, ExportCode, etc. |
| T2 – Medium | 4–15 DB queries | ~22 | Account, Article, Attribute, AuditEntry, CatalogBundle, Combination, Company, ComponentOverride, File, Finish, FontFamily, Frame, FrameCell, Line, LineCost, Location, Metadata, MetadataType, Model, Pictogram, Price, PriceType, ProductCategory, ProductCategoryLine, ProductCategoryType, ProductHash, ProductItem, QuotationDocument, QuotationExported, QuotationItemExported, QuotationItemFruit, QuotationItemProductItem, QuotationPrice, QuotationStatusHistory, QuotationZone, RawValue, Report, SignageConfig, Text, User |
| T3 – Heavy | 16–80+ DB queries | ~7 | Product, Quotation, QuotationItem, Component, SignageConfig, Combination, QuotationZone |

T1 entities are worked on first (no dependencies), then T2, then T3 (depends on T1+T2 sub-entities).

---

## Phase 1: Foundation — Batch Infrastructure &nbsp;&nbsp;`✅ DONE`

> **Goal:** Add shared batch-query methods to `AbsDAO` and `AbsService` that all entities can reuse. No existing behavior is changed.

### 1.1 AbsDAO — `readByIds(idArray)` &nbsp;&nbsp;`✅ DONE`

**File:** `com/apirone/core/model/dao/AbsDAO.cfc`

Add a method that returns all rows for a list of IDs. Since each table has a different PK column name, the method takes the column name as a parameter:

```cfscript
public Query function readByIds(
    required String table,
    required String pkColumn,
    required Array  idArray
){
    // SELECT * FROM {table} WHERE {pkColumn} = ANY(:idArray)
}
```

**Note:** CFML `<cfqueryparam list="true">` can handle arrays for `= ANY()`. Each DAO will override with its own PK column, or we can add a convenience method per DAO. The actual implementation pattern is:

```cfml
<cffunction name="readByIds" returntype="Query">
    <cfargument name="ids" type="Array" required="true">

    <cfquery name="local.q" datasource="apirone">
        SELECT *
        FROM {table}
        WHERE {pk_column} IN (
            <cfqueryparam value="#ArrayToList(arguments.ids)#" list="true" cfsqltype="varchar">
        )
    </cfquery>

    <cfreturn local.q>
</cffunction>
```

### 1.2 AbsService — `getMany(idArray)` and batch helpers &nbsp;&nbsp;`✅ DONE`

**File:** `com/apirone/core/model/service/AbsService.cfc`

Add:

1. `buildFromQuery(record)` — builds a bean from a single query row (used by batch methods)
2. `getMany(dao, idArray, buildFunction)` — generic batch getter (each service will call with its own DAO and build function)

For the `buildFromQuery` approach: add a lightweight version of `build()` that takes a query row instead of doing a new DB read. This is straightforward for T1 entities (few sub-queries) and becomes complex for T3. The T3 approach uses preloaded maps (see Phase 4).

### 1.3 Sub-service batch list methods (Phase 4 pre-requisite) &nbsp;&nbsp;`✅ DONE`

These methods enable batch preloading for T3 entities. They can be added early since they don't change existing behavior:

**TextService** — `listByEntityIds(entityKey, idArray)`

```cfml
-- SELECT * FROM texts WHERE entity_key = :entityKey AND entity_value = ANY(:idArray)
```

**PriceService** — `listByProductIds(productIdArray)`

```cfml
-- SELECT * FROM prices WHERE product_id = ANY(:idArray)
```

**FileService** — `listByEntityIds(entityKey, idArray)`

```cfml
-- SELECT * FROM files WHERE entity_key = :entityKey AND entity_value = ANY(:idArray)
```

**ProductItemService** — `listByProductIds(productIdArray)`

```cfml
-- SELECT * FROM product_items WHERE product_id = ANY(:idArray)
```

> **Verification:** Test each new DAO method directly via the test runner (`/tests/runner-all.cfm`) or manual HTTP tests. No existing code paths are altered yet.

---

## Phase 2: T1 — Light Entities (≤3 DB queries in build) &nbsp;&nbsp;`✅ DONE` (20/20 done)

> **Each entity below is fully independent.** Complete and test one at a time.

The pattern for each T1 entity:

```
Before:  search() → find() [1 query, IDs only] → for each → get(id) → build(id) [N × (1–3 queries)]
After:   search() → find_with_data() [1 query, all cols] → for each → build_from_row(row) [0 extra queries]
```

### Steps per entity

1. **DAO:** Modify `find()` to SELECT all needed columns (not just PK + COUNT)
   - The `COUNT(*) OVER() AS total` stays for pagination
   - Add the real columns from the main table

2. **Service:**
   - Add private `buildFromQueryRow(record)` that sets bean fields from the find() result row
   - Rewrite `search()`: iterate records → call `buildFromQueryRow()` instead of `get()`
   - Remove `property name="cacheScope"` from the component declaration
   - Remove the cache check from `get()` — just call `build()` directly
   - Remove calls to `getCacheManager()` from `update()`, `delete()`, `removeCache()`, etc.

3. **AJAX Controller:** No changes needed — they call `search()` which now works without cache.

### T1 Entity List (estimated 20 entities)

Each can be tested by navigating to its manager grid (which triggers the AJAX `search()` call).

| # | Service File | DAO File | PK Column | Special Notes |
| --- | --- | --- | --- | --- |
| 1 | `PricelistService.cfc` | `PricelistDAO.cfc` | `pricelist_id` | Only 1 query in build, simplest case |
| 2 | `FontService.cfc` | `FontDAO.cfc` | `font_id` | Has LoggerServiceDecorator |
| 3 | `ProfileService.cfc` | `ProfileDAO.cfc` | `profile_id` |  |
| 4 | `PermissionService.cfc` | `PermissionDAO.cfc` | `permission_id` |  |
| 5 | `PictogramDimensionService.cfc` | `PictogramDimensionDAO.cfc` | `pictogram_dimension_id` |  |
| 6 | `ProductionTimeService.cfc` | `ProductionTimeDAO.cfc` | `production_time_id` |  |
| 7 | `SearchService.cfc` | `SearchDAO.cfc` | `search_id` |  |
| 8 | `FontFamilySizeService.cfc` | `FontFamilySizeDAO.cfc` | `font_family_size_id` |  |
| 9 | `SignageConfigItemService.cfc` | `SignageConfigItemDAO.cfc` | `signage_config_item_id` |  |
| 10 | `QuotationItemFruitPositionService.cfc` | `QuotationItemFruitPositionDAO.cfc` | `quotation_item_fruit_position_id` |  |
| 11 | `QuotationItemPositionService.cfc` | `QuotationItemPositionDAO.cfc` | `quotation_item_position_id` |  |
| 12 | `QuotationItemPriceLineService.cfc` | `QuotationItemPriceLineDAO.cfc` | `quotation_item_price_line_id` |  |
| 13 | `QuotationPriceLineService.cfc` | `QuotationPriceLineDAO.cfc` | `quotation_price_line_id` |  |
| 14 | `QuotationItemProductService.cfc` | `QuotationItemProductDAO.cfc` | `quotation_item_product_id` |  |
| 15 | `QuotationZonePositionService.cfc` | `QuotationZonePositionDAO.cfc` | `quotation_zone_position_id` |  |
| 16 | `RolePermissionService.cfc` | `RolePermissionDAO.cfc` | `role_permission_id` |  |
| 17 | `RoleService.cfc` | `RoleDAO.cfc` | `role_id` |  |
| 18 | `QuotationItemSignageRowService.cfc` | `QuotationItemSignageRowDAO.cfc` | `quotation_item_signage_row_id` | Cross-scope cache invalidation (removes from QuotationItem.bean too!) |
| 19 | `ExportCodeService.cfc` | `ExportCodeDAO.cfc` | `export_code_id` |  |
| 20 | `ReportService.cfc` | `ReportDAO.cfc` | `report_id` |  |

> **Test checkpoint A:** After completing 2–3 T1 entities, run the full test suite. Verify the manager AJAX grids still work correctly for each entity.

### Special attention: `FontService` (decorator)

**File:** `config/WireBox.cfc:43-48`

FontService uses `LoggerServiceDecorator`. After modifying `FontService.cfc`, ensure the decorator still properly delegates all methods (including the new `buildFromQueryRow`).

### Special attention: `QuotationItemSignageRowService` (cross-scope invalidation)

**File:** `com/apirone/core/model/service/QuotationItemSignageRowService.cfc:78`

```cfml
cm.remove( "QuotationItem.bean", arguments.quotationItemSignageRow.getQuotationItemId() );
```

This invalidates the parent QuotationItem's cache when a signage row changes. With caches removed, this line becomes a no-op. Replace with a TODO comment to eventually remove, or just delete it.

### Special attention: `i18nService` (typo bug)

**File:** `com/apirone/core/model/service/i18nService.cfc:48,78`

Lines 48 and 78 have `getCasceScope()` (missing `h`). This is a latent bug — these cache lookups silently fail and the service falls through to re-read the JSON file every time. Remove caching entirely from this service (it reads from static JSON files, not a database, so caching is purely for avoiding file I/O — a micro-optimization that doesn't cause stale data).

---

## Phase 3: T2 — Medium Entities (4–15 DB queries in build) &nbsp;&nbsp;`❌ TO DO`

> **Each entity is independent** (except where noted). Complete and test one at a time.

The pattern for each T2 entity:

```
Before:  search() → find() [1 query, IDs only] → for each → get(id) → build(id) [N × (4–15 queries)]
After:   search() → find() [1 query, IDs] → getDao().readByIds(idArray) [1 bulk query]
         → for each record → buildFromQueryRow(record) [uses preloaded sub-entity maps]
```

### Strategy for T2

T2 entities load 4–15 sub-queries in their `build()`. The approach:

1. **DAO:** Add `readByIds(idArray)` method that SELECTs all columns
2. **Service:** Modify `search()` to:
   a. Call `find()` to get IDs (still needed for pagination)
   b. Collect all IDs into an array
   c. Call `getDao().readByIds(idArray)` for the main records
   d. **Optionally preload common sub-entities** (Status, Lang, Lookup) — these are already fast since they're cached in T1 removal
   e. Build each bean from the batch result row, calling sub-services for unique data
3. **Remove cache** from `get()`, `update()`, `delete()`

**Key optimization:** Even without batch-preloading sub-entities, replacing N individual DAO `read()` calls with a single `readByIds()` eliminates N−1 queries per search page (e.g., from 15 individual reads to 1 bulk read). The sub-service calls (Status.get, Lang.get, etc.) remain per-bean but these are cheap lookups.

### T2 Entity List (estimated 22 entities)

| # | Service File | DAO File | PK Column | Sub-services called by build() |
| --- | --- | --- | --- | --- |
| 1 | `AccountService.cfc` | `AccountDAO.cfc` | `account_id` | Status, Role, (User chain) |
| 2 | `ArticleService.cfc` | `ArticleDAO.cfc` | `article_id` | TextService.list, PriceService.list, Status |
| 3 | `AttributeService.cfc` | `AttributeDAO.cfc` | `attribute_id` | TextService.list, 2× Lookup |
| 4 | `AuditEntryService.cfc` | `AuditEntryDAO.cfc` | `audit_entry_id` | Minimal |
| 5 | `CatalogBundleService.cfc` | `CatalogBundleDAO.cfc` | `catalog_bundle_id` | Line, Model, ProductCategory |
| 6 | `CombinationService.cfc` | `CombinationDAO.cfc` | `combination_id` | Status, CombinationProductItem → ProductItem chain |
| 7 | `CompanyService.cfc` | `CompanyDAO.cfc` | `company_id` | Sub-chain |
| 8 | `ComponentOverrideService.cfc` | `ComponentOverrideDAO.cfc` | `component_override_id` | Component.get |
| 9 | `FileService.cfc` | `FileDAO.cfc` | `file_id` | FileType, Lookup |
| 10 | `FinishService.cfc` | `FinishDAO.cfc` | `finish_id` | TextService.list, Status, getCategories |
| 11 | `FontFamilyService.cfc` | `FontFamilyDAO.cfc` | `font_family_id` | TextService.list, Status |
| 12 | `FrameService.cfc` | `FrameDAO.cfc` | `frame_id` | Sub-chain |
| 13 | `FrameCellService.cfc` | `FrameCellDAO.cfc` | `frame_cell_id` | Sub-chain |
| 14 | `LineService.cfc` | `LineDAO.cfc` | `line_id` | TextService.list, Status, getCategories, Lookup |
| 15 | `LineCostService.cfc` | `LineCostDAO.cfc` | `line_cost_id` | Minimal |
| 16 | `MetadataService.cfc` | `MetadataDAO.cfc` | `metadata_id` | MetadataType, TextService.list |
| 17 | `MetadataTypeService.cfc` | `MetadataTypeDAO.cfc` | `metadata_type_id` | Minimal |
| 18 | `ModelService.cfc` | `ModelDAO.cfc` | `model_id` | TextService.list, Status, getCategories, Lookup. Has LoggerServiceDecorator |
| 19 | `PictogramService.cfc` | `PictogramDAO.cfc` | `pictogram_id` | Sub-chain |
| 20 | `PriceService.cfc` | `PriceDAO.cfc` | `price_id` | PriceType, Status, Lookup |
| 21 | `PriceTypeService.cfc` | `PriceTypeDAO.cfc` | `price_type_id` | TextService.list, Status |
| 22 | `ProductCategoryService.cfc` | `ProductCategoryDAO.cfc` | `product_category_id` | TextService.list, Status, PcType, Lookup |
| 23 | `ProductCategoryLineService.cfc` | `ProductCategoryLineDAO.cfc` | `product_category_line_id` | Minimal |
| 24 | `ProductCategoryTypeService.cfc` | `ProductCategoryTypeDAO.cfc` | `product_category_type_id` | Minimal |
| 25 | `ProductHashService.cfc` | `ProductHashDAO.cfc` | `product_hash_id` | Minimal |
| 26 | `ProductItemService.cfc` | `ProductItemDAO.cfc` | `product_item_id` | Status, AttributeValue → Attribute, PriceService.list, FileService.list |
| 27 | `QuotationDocumentService.cfc` | `QuotationDocumentDAO.cfc` | `quotation_document_id` | Minimal |
| 28 | `QuotationExportedService.cfc` | `QuotationExportedDAO.cfc` | (dual-scope) | Sub-chain. Uses `rowCacheScope` too. |
| 29 | `QuotationItemExportedService.cfc` | `QuotationItemExportedDAO.cfc` | (dual-scope) | Sub-chain. Uses `rowCacheScope` too. |
| 30 | `QuotationItemFruitService.cfc` | `QuotationItemFruitDAO.cfc` | `quotation_item_fruit_id` | Product, FruitProductItem.list, Position.list |
| 31 | `QuotationItemProductItemService.cfc` | `QuotationItemProductItemDAO.cfc` | `quotation_item_product_item_id` | ProductItem.get (cascades heavily) |
| 32 | `QuotationPriceService.cfc` | `QuotationPriceDAO.cfc` | `quotation_price_id` | Minimal |
| 33 | `QuotationStatusHistoryService.cfc` | `QuotationStatusHistoryDAO.cfc` | `quotation_status_history_id` | User.get, Status.get, Quotation.get |
| 34 | `QuotationZoneService.cfc` | `QuotationZoneDAO.cfc` | `quotation_zone_id` | QuotationService.get (recursive!), FileService.list |
| 35 | `RawValueService.cfc` | `RawValueDAO.cfc` | `raw_value_id` | Metadata, SystemColor, TextService.list |
| 36 | `TextService.cfc` | `TextDAO.cfc` | `text_id` | Lang, Status, Lookup |
| 37 | `UserService.cfc` | `UserDAO.cfc` | `user_id` | Account, Status, Role, Lang |

> **Test checkpoint B:** After each T2 batch of 5 entities, verify the AJAX grids and detail pages work correctly.

### Special attention: `ProductItemService` → `QuotationItemProductItem` chain

`QuotationItemProductItemService.build()` calls `ProductItemService.get()` per item. `ProductItemService.build()` calls `AttributeValueService.get()` → `AttributeService.get()`, plus `PriceService.list()` and `FileService.list()`. This chain should be optimized together in Phase 4.

### Special attention: `QuotationZoneService` → `QuotationService` recursion

`QuotationZoneService.build()` calls `QuotationService.get()` which calls `QuotationZoneService.list()`... potential circular dependency. With cache removal, ensure this doesn't cause infinite loops. The current cache likely prevents re-reading. Without cache, add a request-scoped "already loading" guard (`request._loadingZones` or similar).

### Special attention: `CustomerService` (CRM API, not DB)

**File:** `com/apirone/core/model/service/CustomerService.cfc`

This service is unique — it does NOT query the local database. Its `get()` and `search()` call an external CRM API (`CrmApiService`). The `CacheManager` is used to cache API responses.

Removing the cache here means every customer lookup hits the external CRM API. This is acceptable for correctness (no stale data) but could slow down quotation pages that display customer info.

**Recommendation:** Remove the cache but monitor CRM API latency. If performance degrades, consider a short-TTL cache specific to the CRM (separate from the bean `CacheManager`).

### Special attention: `QuotationExported` and `QuotationItemExported` dual-scope

These services have `cacheScope` AND `rowCacheScope`. Both cache layers must be removed.

### Special attention: `ModelService` (decorator)

**File:** `config/WireBox.cfc:72-77`

ModelService uses `LoggerServiceDecorator`. Same precautions as FontService.

### Special attention: `LocationService` + `GeoService` incomplete refactoring

**Files:**

- `com/apirone/core/model/service/LocationService.cfc` — uses raw cache keys + `getCachekey()` throws error
- `com/apirone/core/model/service/GeoService.cfc` — mixed raw/shorthand keys + `getCacheKey()` throws error

These services have dead code (`getCacheKey()` throws `"Use cache manager and scope"`). The cache removal means:

1. Remove the raw-key caching (already semi-broken)
2. Remove `getCacheKey()` dead methods
3. Remove the throwing methods entirely
4. `GeoService.cfc` line 14-23 (County), 31-41 (State) — convert to non-cached direct reads or use proper scope if they still want to call other services

---

## Phase 4: T3 — Heavy Entities (16–80+ DB queries in build) &nbsp;&nbsp;`❌ TO DO`

> **These are the performance-critical entities.** They cascade deeply into sub-entity chains.

### Pre-requisites

Before touching T3 entities, add batch-preload methods to the sub-services they depend on. These are added as **new methods** that don't change existing behavior:

#### 4.0a TextService — `listByEntityIds(entityKey, idArray)`

**File:** `com/apirone/core/model/service/TextService.cfc`
**DAO:** `TextDAO.cfc` — new method `findByEntityIds(entityKey, idArray)`

```sql
SELECT * FROM texts WHERE entity_key = :key AND entity_value = ANY(:idArray)
```

Returns a struct keyed by entity_value for O(1) lookup during bean assembly.

#### 4.0b PriceService — `listByProductIds(productIdArray)`

**File:** `com/apirone/core/model/service/PriceService.cfc`
**DAO:** `PriceDAO.cfc` — new method `findByProductIds(idArray)`

```sql
SELECT * FROM prices WHERE product_id = ANY(:idArray)
```

#### 4.0c FileService — `listByEntityIds(entityKey, idArray)`

**File:** `com/apirone/core/model/service/FileService.cfc`
**DAO:** `FileDAO.cfc` — new method `findByEntityIds(entityKey, idArray)`

#### 4.0d ProductItemService — `listByProductIds(productIdArray)`

**File:** `com/apirone/core/model/service/ProductItemService.cfc`
**DAO:** `ProductItemDAO.cfc` — new method `findByProductIds(idArray)`

#### 4.0e ProductCategoryService — `getMany(idArray)`

For batch-loading categories used in `getCategoriesBeanByIds()`.

### 4.1 ProductService (25–40 queries per bean)

**File:** `com/apirone/core/model/service/ProductService.cfc`
**DAO:** `com/apirone/core/model/dao/ProductDAO.cfc`

**Current `search()` flow:**

```
find() [1 query, IDs only]
→ for each (15 records):
    get(id) → build(id):
        getDao().read()                          [1]
        getProductCategoryService().get()        [1]
        getLinesBeanByIds() → N × LineService.get() [N × ~13]
        getStatusService().get()                 [1]
        getTextService().list()                  [1 + text builds]
        getAttributesBeanByIds() → N × AttributeService.get()
        getPriceService().list()                 [1 + price builds]
        getFileService().list()                  [1 + file builds]
        (ProductComplex:) getCatalogBundleService().get() → Line.get + Model.get + PC.get
                           getFinishService().get()
```

**New `search()` flow:**

```
find() [1 query, IDs only for pagination]
→ Collect all productIds
→ Batch 1: getDao().readByIds(allProductIds) [1 bulk query]
→ Batch 2: getTextService().listByEntityIds("product.id", allProductIds) [1 query]
→ Batch 3: getPriceService().listByProductIds(allProductIds) [1 query]
→ Batch 4: getFileService().listByEntityIds("product.id", allProductIds) [1 query]
→ For each product:
    buildFromBatch(row, textsMap, pricesMap, filesMap) — uses preloaded maps
    → Sub-calls: Category.get(), Status.get(), Lines.get(), Attributes.get()
      (these are lightweight lookups and shared across products)
```

**Changes:**

1. `ProductDAO.cfc` — add `readByIds(idArray)` method
2. `ProductService.cfc` — rewrite `search()` with batch flow
3. `ProductService.cfc` — remove `cacheScope`, cache from `get()`, cache from `delete()`, `deleteByParams()`, `deleteAllByParams()`, `update()`, `updateDetail()`, `removeCache()`
4. `ProductService.cfc` — remove `getCacheManager().removeAll()` from `deleteAllByParams()` and `cloneTree()` (was bulk-clearing ALL caches!)
5. `ProductService.cfc` — `readIds()` method: if callers only need IDs for existence checks, keep it. Otherwise convert callers to use the batch approach.

**ProductService has LoggerServiceDecorator** (`config/WireBox.cfc:63-68`). Ensure decorator delegation works with the new methods.

### 4.2 QuotationService (10–14 queries per bean)

**File:** `com/apirone/core/model/service/QuotationService.cfc`
**DAO:** `com/apirone/core/model/dao/QuotationDAO.cfc`

**Current `build()` flow:**

```
getDao().read()          [1]
getLangService().get()   [1]
getCurrencyService().get() [1]
getUserService().get()   [1 + sub-chain]
getPaymentMethodService().get() [1]
getQuotationStatusHistoryService().get() [1 + sub-chain]
getCustomerService().get() [1 + sub-chain] (conditional)
getOpportunityService().get() [1] (conditional)
getLeadService().get() [1] (conditional)
getVatCodeService().get() [1] (conditional)
getUserService().get(salesAgent) [1] (conditional)
getUserService().get(graphicTech) [1] (conditional)
getDao().getQuotationTotal() [1]
```

**Changes:**

1. `QuotationDAO.cfc` — add `readByIds(idArray)` method
2. `QuotationService.cfc` — rewrite `search()` with batch `readByIds()`
3. `QuotationService.cfc` — remove `cacheScope`, cache from `get()`
4. `QuotationService.cfc` — remove commented-out cache removal (line 180)
5. Remove cache invalidation from `clone()` (lines 991-992, 1015-1016, 1023)

**Special: `exportProducts()` and `getComponents()` (N+1 loops)**

These methods in `QuotationService.cfc` loop over quotation items calling individual `get()` methods. These do NOT use the cache-based `search()` pattern — they're direct service calls. The approach:

1. `exportProducts()` (lines 257-414): Collect all IDs across the loop, then batch-fetch:
   - `getProductService().getMany(allProductIds)`
   - `getLineService().getMany(allLineIds)`
   - `getModelService().getMany(allModelIds)`
   - `getFinishService().getMany(allFinishIds)`
   - etc.

2. `getComponents()` (lines 802-877): Accept an array of `productItemIds` and use `WHERE product_item_id = ANY(:idArray)` in ComponentDAO instead of per-item queries.

### 4.3 QuotationItemService (50–80 queries per bean — the WORST)

**File:** `com/apirone/core/model/service/QuotationItemService.cfc`
**DAO:** `com/apirone/core/model/dao/QuotationItemDAO.cfc`

**Current `build()` flow:**

```
getDao().read()                                    [1]
getQuotationItemFruitService().list()              [1 + fruit builds]
getQuotationItemPriceService().getByQuotationItemId() [1 + price line builds]
getQuotationService().get()                        [1 → ~10-14 queries]
getProductService().get()                          [1 → ~25-40 queries] ← THE BIG ONE
getStatusService().get()                           [1]
getArticleService().get()                          [1 + sub-chain]
getQuotationZoneService().get()                    [1 → QuotationService.get() recursive]
getSignageConfigItemService().get()                [1]
getQuotationItemSignageRowService().list()         [1 + row builds]
getFileService().list()                            [1 + file builds]
getQuotationItemProductItemService().list()        [1 + QIProductItem → ProductItem chain]
getQuotationZonePositionService().get()            [1]
getQuotationItemPositionService().list()           [1 + position builds]
```

**Changes:**

1. `QuotationItemDAO.cfc` — add `readByIds(idArray)` method (select all needed columns)
2. `QuotationItemService.cfc` — rewrite `search()` with full batch preloading:
   - Collect all quotationItemIds
   - Batch load: fruits, prices, quotation zones, signage rows, files, positions, product items
   - Batch load: all quotationIds → `QuotationService.getMany(allQuotaionIds)`
   - Batch load: all productIds → `ProductService.getMany(allProductIds)` ← uses batch infrastructure
   - Batch load: all statusIds, zoneIds, configItemIds, etc.
3. `QuotationItemService.cfc` — remove `cacheScope`, cache from `get()`, `delete()`, `update()`, `updateHash()`
4. Note: `get()` accepts `useCache` parameter (line 22) — remove this parameter since cache is gone

**Special: `useCache` parameter in `search()` and `get()`**

Line 22: `get( required String quotationItemId, Boolean useCache = true )`
Line 50: `search( ..., Boolean useCache = true, ... )`

These exist because `updateAllPrices()` in `QuotationItemAjaxController` was getting stale cached beans during price recalculation (comment at line 48-49). With cache removed, this parameter is no longer needed:

- Remove `useCache` parameter from both methods
- Update `QuotationItemAjaxController` to remove the `useCache=false` argument

### 4.4 ComponentService (8–45 queries per bean)

**File:** `com/apirone/core/model/service/ComponentService.cfc`
**DAO:** `com/apirone/core/model/dao/ComponentDAO.cfc`

**Changes:**

1. `ComponentDAO.cfc` — add `readByIds(idArray)` method
2. `ComponentService.cfc` — rewrite `search()` with batch approach
3. `ComponentService.cfc` — remove `cacheScope`, cache from `get()`, `delete()`, etc.

**Special:** `ComponentDAO.priceCalculatorRead()` (3 chained queries: apirone + verticale + verticale) — This is NOT touched (verticale is ERP).

### 4.5 SignageConfigService (47 queries per bean — 2nd worst)

**File:** `com/apirone/core/model/service/SignageConfigService.cfc`
**DAO:** `com/apirone/core/model/dao/SignageConfigDAO.cfc`

**Changes:**

1. `SignageConfigDAO.cfc` — add `readByIds(idArray)` method
2. `SignageConfigService.cfc` — rewrite `search()` with batch preloading:
   - Preload all Fonts, CatalogBundles, SignageConfigItems
3. `SignageConfigService.cfc` — remove `getCacheManager().removeAll()` from `delete()` and `deleteByParams()` (lines 79, 98 had "TODO: optimize cache invalidation")
4. Remove cache from all mutation methods

### 4.6 QuotationZoneService (QuotationService recursion)

See T2 entry above. The `QuotationService.get()` call inside `build()` must be batched.

### 4.7 CombinationService

Already listed in T2 but the `findByListOfProductItemIds()` method uses complex CTEs. The CTEs are fine — they're a single query. The N+1 issue is in the `search()` → `get()` → `build()` → `CombinationProductItem.get()` chain.

---

## Phase 5: CacheManager Disarm & Removal &nbsp;&nbsp;`❌ TO DO`

### 5.1 Remove CacheManager from WireBox

**File:** `config/WireBox.cfc`

Remove lines 98-103:

```cfml
map("CacheManager").to( "com.apirone.core.util.CacheManager" )...
```

Remove the `CacheManager` property injection from `QueryLoader` (line 96):

```cfml
map("QueryLoader").to( "com.apirone.core.util.QueryLoader" )
    .property( name = "CacheManager", ref = "CacheManager");  ← remove this line
```

### 5.2 Remove `getCacheManager()` from base classes

**File:** `com/apirone/core/model/service/AbsService.cfc:208-210`
Remove the method.

**File:** `com/apirone/core/controller/AbsController.cfc:384-386`
Remove the method.

**File:** `com/apirone/core/controller/AbsController.cfc:222`
Remove the commented-out line.

### 5.3 Remove CacheManager class file

**File:** `com/apirone/core/util/CacheManager.cfc`
Can be deleted entirely (or kept for reference).

### 5.4 Remove cacheScopes config

**File:** `config/cacheScopes.json.cfm`
Can be deleted (or kept for reference).

### 5.5 Update QueryLoader

**File:** `com/apirone/core/util/QueryLoader.cfc`

The QueryLoader caches MS SQL ERP query results (table `azapi_listin`). This is NOT the bean cache and doesn't cause stale data for customers — it caches ERP data that rarely changes. However, we need to decide:

**Option A:** Keep QueryLoader caching (it loads the entire `azapi_listin` table into memory). The stale data risk is low since ERP data changes infrequently.

**Option B:** Remove QueryLoader caching and re-query the ERP on every call. This could slow down cost calculations but ensures freshness.

**Recommendation:** Keep QueryLoader as-is for now. It's separate from the bean cache system. If stale ERP costs become an issue later, add a TTL-based refresh.

### 5.6 Remove all `cm.remove(...)` calls

After all services are updated, verify there are no remaining calls to:

- `getCacheManager()`
- `cm.get(`, `cm.put(`, `cm.remove(`
- `getCacheManager().removeAll()`

These should all be removed in Phases 2–4. Phase 5 is a final sweep to catch any stragglers.

---

## Phase 6: Bug Fixes & Cleanup &nbsp;&nbsp;`❌ TO DO`

### 6.1 i18nService — `getCasceScope()` typo

**File:** `com/apirone/core/model/service/i18nService.cfc:48,78`

`getCasceScope()` → should be `getCacheScope()`. Since we're removing caching from this service anyway, just remove the cache logic entirely (lines 44-53 and 76-80). The service reads from static JSON files and caching provides negligible benefit.

### 6.2 GeoService — remove dead code and fix incomplete refactoring

**File:** `com/apirone/core/model/service/GeoService.cfc`

The service has inconsistent caching patterns and dead code:

- `getCountry()` (lines 45-58) uses the proper scope system: `cm.get(getCacheScopeCountry(), id)`
- `getCounty()` (lines 11-26) uses raw key: `cm.get(getCacheKey("County_#id#"))`
- `getState()` (lines 28-43) uses raw key: `cm.get(getCacheKey("State_#id#"))`
- `getCacheKey()` (line 102) throws `"Use cache manager and scope"` — dead, incomplete refactoring

**Action:**

1. Remove `getCacheKey()` method entirely (dead code)
2. Remove raw-key caching from `getCounty()` — call `buildCounty()` directly
3. Remove raw-key caching from `getState()` — call `buildState()` directly
4. Remove scoped caching from `getCountry()` — call `buildCountry()` directly
5. Remove `cacheScopeCounty`, `cacheScopeState`, `cacheScopeCountry` properties

Note: `CountyDAO`, `StateDAO`, `CountryDAO` all use the `verticale` datasource (MS SQL). Since ERP entities are excluded from query optimization, the DAOs are left as-is. The fix here is just cache removal.

### 6.3 LocationService — remove dead code

**File:** `com/apirone/core/model/service/LocationService.cfc`

Same pattern as GeoService:

- `get()` uses raw key: `cm.get(key)` where `key = getCacheKey(id)` (custom, unscoped)
- `getCacheKey()` throws `"Use cache manager and scope"` — dead code

**Action:**

1. Remove `getCacheKey()` method
2. Remove raw-key caching from `get()` — call `build()` directly
3. Remove cache invalidation from `update()`

### 6.4 SQL injection fix — `ProductAjaxController.removeItems()`

**File:** `apps/manager/controllers/ProductAjaxController.cfc:122-128`

```cfml
DELETE FROM product_items
WHERE product_item_id IN ( #rc.items# )   ← SQL injection!
```

Replace with parameterized query using `cfqueryparam list="true"`.

### 6.5 SQL injection fix — `FruitAjaxController.removeItems()`

**File:** `apps/manager/controllers/FruitAjaxController.cfc:185-190`

Same pattern. Replace with parameterized query.

### 6.6 Remove unused `cachePut()` in `RawProductController`

**File:** `apps/api/controllers/RawProductController.cfc:52-53`

```cfml
// super.getCacheManager().remove( "RawProduct.bean", rc.rawProductId );
super.getCacheManager().removeAll()           ← bulk clears ALL caches!
```

The commented-out line + `removeAll()` is a workaround. With cache removed, this whole block becomes a no-op. Remove it entirely.

---

## Testing Strategy

### Per-entity testing

After modifying each entity:

1. **Unit:** Run the full TestBox test suite: `http://localhost:{port}/tests/runner-all.cfm`
2. **Integration (Manager AJAX):** Navigate to the entity's grid page in the manager, verify:
   - Grid loads correctly (pagination, sorting, filtering)
   - Edit form opens and loads data correctly
   - Create new record works
   - Delete record works
3. **Integration (API):** If the entity has API endpoints, test them via curl or the API test harness

### Per-batch testing

After completing each batch (~5 entities):

1. Run full test suite
2. Smoke-test the main manager flows: Quotation creation, Product listing, Line management
3. Check for any ColdBox errors in `?reinit=1`

### Final testing

After all phases:

1. Full test suite
2. Manual walkthrough of complete quotation workflow:
   - Create customer
   - Create quotation
   - Add products to quotation
   - Add signage items
   - Add plate items with fruits
   - Export quotation to ERP
3. Performance comparison: measure page load times before and after (use browser dev tools or Lucee debug)

---

## Rollback Strategy

Each change is isolated to one entity. If a change causes issues:

1. Revert the entity's service and DAO files via git
2. The entity will still work with its old cache-based code
3. Other already-migrated entities are unaffected

---

## Dependency Order Summary

```
Phase 1 (Foundation)
    ↓
Phase 2 (T1 – Light entities, ~20)  ← No dependencies on other entities
    ↓
Phase 3 (T2 – Medium entities, ~37)  ← May call T1 entities (already migrated)
    ↓
Phase 4 (T3 – Heavy entities, ~7)    ← Calls T1+T2 sub-entities (already migrated)
    ↓
Phase 5 (CacheManager removal)       ← No remaining cache consumers
    ↓
Phase 6 (Bug fixes & cleanup)
    ↓
Phase 7 (Deprecated method removal)
```

### Phase 7: Deprecated Method Removal (TBD) &nbsp;&nbsp;`❌ TO DO`

> **Note:** This phase is a placeholder. When the time comes, a proper research pass will identify:
>
> - Old per-record `get()` cache wrappers that are no longer called
> - The `CacheManager` class and `cacheScopes.json.cfm` config (if not already removed in Phase 5)
> - Legacy `build()` methods superseded by `buildFromResultRow` variants
> - `readIds()` method on `ProductDAO` / `ProductService` if no callers remain

---

## Files NOT to Touch

| File | Reason |
| --- | --- |
| `com/apirone/core/util/QueryLoader.cfc` | ERP cost cache, separate concern |
| `com/apirone/core/model/service/StatusService.cfc` | Readonly lookup |
| `com/apirone/core/model/service/LangService.cfc` | Readonly lookup |
| `com/apirone/core/model/service/LookupService.cfc` | Readonly lookup |
| `com/apirone/core/model/service/SystemColorService.cfc` | Readonly lookup |
| All `*Verticale*` / `*verticale*` files | MS SQL ERP |
| All DAOs extending `VerticaleDAO` | MS SQL ERP |
| `ColorService.cfc` / `ColorDAO.cfc` | verticale datasource |
| `CostService.cfc` / `CostDAO.cfc` | verticale Query-of-Query |
| `VariantService.cfc` / `VariantDAO.cfc` | verticale datasource |
| `CountryService.cfc` / `CountryDAO.cfc` | verticale datasource |
| `CurrencyService.cfc` / `CurrencyDAO.cfc` | verticale datasource |
| `PaymentMethodService.cfc` / `PaymentMethodDAO.cfc` | verticale datasource |
| `PaymentTypeService.cfc` / `PaymentTypeDAO.cfc` | verticale datasource |
| `RawProductService.cfc` / `RawProductDAO.cfc` | verticale datasource |
| `RawProductTypeService.cfc` / `RawProductTypeDAO.cfc` | verticale datasource |
| `VatCodeService.cfc` / `VatCodeDAO.cfc` | verticale datasource |
| `config/cacheScopes.json.cfm` | Delete in Phase 5 |
| `com/apirone/core/util/CacheManager.cfc` | Delete in Phase 5 |
| `layouts/manager.cfm` | View caching kept |
| `config/Coldbox.cfc` | View caching kept (line 48) |
| `com/apirone/core/util/Mementify.cfc` | Its internal caches are rules/metadata only, not data |
| `CountyDAO.cfc` / `StateDAO.cfc` / `CountryDAO.cfc` | verticale datasource (used by GeoService, cache removal only in GeoService) |
| `CustomerService.cfc` | External CRM API — remove cache, but monitor performance |
| `LocationService.cfc` | Remove cache + dead code, DAO stays as-is |
| `GeoService.cfc` | Remove cache + dead code + inconsistent refactoring, DAOs stay as-is |
| `OpportunityService.cfc` | External CRM API (same pattern as CustomerService) |

---

## Total File Count Estimate

| Phase | DAOs | Services | Controllers | Config | Other | Total |
| --- | --- | --- | --- | --- | --- | --- |
| 1 – Foundation | 1 | 1 | 0 | 0 | 0 | 2 |
| 2 – T1 (~20) | 20 | 20 | 0 | 0 | 0 | 40 |
| 3 – T2 (~37) | 37 | 37 | 1 | 0 | 0 | 75 |
| 4 – T3 (~7) | 7 | 7 | 1 | 0 | 0 | 15 |
| 5 – Cleanup | 0 | 2 | 2 | 2 | 1 | 7 |
| 6 – Bug fixes | 0 | 2 | 2 | 0 | 0 | 4 |
| 7 – Deprecated removal | TBD — sarà oggetto di una ricerca dedicata |
| **Total (Phase 1-6)** | **~65** | **~69** | **~6** | **~2** | **~1** | **~143** |

Note: Some entities appear in multiple phases if they also receive batch sub-methods (Phase 4.0).
