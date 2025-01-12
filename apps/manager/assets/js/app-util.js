AP.util = AP.util || {};

AP.util.getMainText = function (texts, langId="it") {

	for(var thisText of texts) {

		if (thisText.lang.id == langId.toUpperCase()) {
			return thisText;
		}

	}

	return undefined;

};

/**
 *
 * @param {Object} params { array, rowRange, colRange, isInclusiveEnd = false }
 * @returns sliced 2D array
 */
AP.util.slice2DArray = function (params) {
	if (!Array.isArray(params.array) || !params.array.length) {
		throw new Error("Input array must be a non-empty 2D array.");
	}

	if (!params.hasOwnProperty("isInclusiveEnd")) {
		params.isInclusiveEnd = false;
	}

	const startRow = params.rowRange.start;
	const endRow = params.isInclusiveEnd ? params.rowRange.end + 1 : params.rowRange.end;

	// Slice the rows
	const slicedRows = params.array.slice(startRow, endRow);

	const startCol = params.colRange.start;
	const endCol = params.isInclusiveEnd ? params.colRange.end + 1 : params.colRange.end;

	// Slice the columns for each row
	const slicedArray = slicedRows.map(row => row.slice(startCol, endCol));

	return slicedArray;
};

AP.util.splice2DArray = function (params) {
	if (!Array.isArray(params.array) || !params.array.length) {
		throw new Error("Input array must be a non-empty 2D array.");
	}

	if (!params.hasOwnProperty("isInclusiveEnd")) {
		params.isInclusiveEnd = false;
	}

	if (!params.hasOwnProperty("replaceItem")) {
		params.replaceItem = null;
	}

	const startRow = params.rowRange.start;
	const endRow = params.isInclusiveEnd ? params.rowRange.end + 1 : params.rowRange.end;

	// Slice the rows
	const slicedRows = params.array.slice(startRow, endRow);

	const startCol = params.colRange.start;
	const endCol = params.isInclusiveEnd ? params.colRange.end + 1 : params.colRange.end;
	const colsDeleteCount = Math.abs(startCol - endCol);
	const replaceArray = new Array(colsDeleteCount).fill(params.replaceItem);

	// Splice the columns for each row
	const slicedArray = slicedRows.map(row => row.splice(startCol, colsDeleteCount, ...replaceArray));

	return slicedArray;
};

AP.util.areTwoArraysOfSameDimensions = function (arr1, arr2) {
	// Check if both are arrays
	if (!Array.isArray(arr1) || !Array.isArray(arr2)) {
		return false;
	}

	// Check if the outer arrays have the same length
	if (arr1.length !== arr2.length) {
		return false;
	}

	// Check if each inner array has the same length
	for (let i = 0; i < arr1.length; i++) {
		if (!Array.isArray(arr1[i]) || !Array.isArray(arr2[i])) {
			return false; // Ensure both are inner arrays
		}

		if (arr1[i].length !== arr2[i].length) {
			return false;
		}
	}

	return true; // Dimensions match
};

AP.util.swapElementsOfTwoArrays = function (arr1, arr2) {
	for (let row = 0; row < arr1.length; row++) {
		for (let col = 0; col < arr1[row].length; col++) {
			const tmp = arr1[row][col];
			arr1[row][col] = arr2[row][col];
			arr2[row][col] = tmp;
		}
	}
};

AP.util.fireCallback = function (func, callbacks) {

	var callbackList = callbacks;

	console.log("callbackList", callbackList);


	var exists = callbackList?.hasOwnProperty(func);

	console.log("callbackList:func", exists, func);

	if(exists) {

		var thisCallback = callbackList[ func ];

		if(typeof thisCallback == "function") {

			console.log("callbackList:exec", func);

			thisCallback();
		}
	}

};

AP.util.removeQueryString = function() {

    var uri = window.location.href.toString();
    
	if (uri.indexOf("?") > 0) {
        var clean_uri = uri.substring(0, uri.indexOf("?"));
        window.history.replaceState({}, document.title, clean_uri);
    }
 
}
