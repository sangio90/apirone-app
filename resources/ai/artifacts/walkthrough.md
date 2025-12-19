# Fix Double Call of pub.edit - Walkthrough

## Changes
I have prevented the double invocation of `pub.edit` by stopping event propagation in the action buttons within the quotation item lists.

### Manager App
#### [app-quotation-detail.js](file:///s:/workspace/users/roberto/projects/apir/apps/apirone-app/code/apps/manager/assets/js/app-quotation-detail.js)
- **Fixed `clonePlate`**: Added `event.stopPropagation()` to prevent the click from bubbling up to the item container, which would trigger `editPlate` (and thus `pub.edit`) a second time.
- **Fixed `delete`**: Added `event.stopPropagation()` to prevent the click from bubbling up to the item container. This ensures that deleting an item does not also attempt to open its edit modal.

## Verification Results
### Manual Verification
- **Double Call Issue**: The "Clone" button now triggers only the cloning action. The parent container's edit action is ignored.
- **Delete Side Effect**: The "Delete" button now opens only the confirmation dialog. The background edit modal is no longer triggered.
