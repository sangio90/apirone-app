# Debugging Double Call of pub.edit

## Analysis
The user reported that `pub.edit` is called twice.
My analysis of `apps/manager/assets/js/app-quotation-detail.js` and `apps/manager/views/jstemplate/quotation/quotation-item-plate-preview-tmpl.cfm` reveals that:
1. The list item container has a `click` binding to `editPlate`.
2. The "Clone" button inside the container has a `click` binding to `clonePlate`.
3. `clonePlate` calls `plateApp().edit({ clone: true })` (which is `pub.edit`).
4. `clonePlate` calls `event.preventDefault()` but NOT `event.stopPropagation()`.
5. Therefore, clicking "Clone" triggers `clonePlate` (1st call), and the event bubbles to the container, triggering `editPlate` (2nd call).

## Plan
- [x] Create implementation plan <!-- id: 0 -->
- [x] Fix `clonePlate` in `apps/manager/assets/js/app-quotation-detail.js` to stop propagation. <!-- id: 1 -->
- [x] Fix `delete` in `apps/manager/assets/js/app-quotation-detail.js` to stop propagation (prevent opening modal when deleting). <!-- id: 2 -->
- [x] Verify if there are other similar buttons. <!-- id: 3 -->
- [x] Notify user. <!-- id: 4 -->
