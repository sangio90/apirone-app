# Fix Double Call of pub.edit

## Goal Description
The user reported that `pub.edit` is called twice. The issue is identified as event bubbling in `apps/manager/assets/js/app-quotation-detail.js`. The "Clone" button (calling `clonePlate`) and "Delete" button (calling `delete`) are nested within a container that has a `click` listener for `editPlate`. Clicking the buttons triggers both the button's action and the container's action.

I will update `clonePlate` and `delete` handlers to stop event propagation.

## Proposed Changes
### Manager App
#### [MODIFY] [app-quotation-detail.js](file:///s:/workspace/users/roberto/projects/apir/apps/apirone-app/code/apps/manager/assets/js/app-quotation-detail.js)
- In `clonePlate(event)`: add `event.stopPropagation()` to prevent bubbling to `editPlate`.
- In `delete(event)`: add `event.stopPropagation()` to prevent bubbling to `editPlate` (which would open the modal while the confirmation dialog is showing).

## Verification Plan
### Manual Verification
1. Open the user's view (since I cannot do it, the user will).
2. Click on the "Clone" (Duplicate) button on a plate item.
3. Verify that the "Duplica placca" (Duplicate plate) modal opens ONCE and the network request to `pub.edit` is made ONCE (or appropriately for cloning).
4. Verify that the console does not show double invocation logs if any.
5. Click on the "Delete" (Trash) button.
6. Verify that ONLY the confirmation dialog appears, and the edit modal does NOT open behind it.
