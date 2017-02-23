'use strict';

var jsdiff = require('../../bower_components/jsdiff/diff.js');

exports.processPatchImpl = function processPatchImpl(Hunk, Patch, patch) {
	return Patch({
		oldFileName: patch.oldFileName,
		newFileName: patch.newFileName,
		oldHeader: patch.oldHeader,
		newHeader: patch.newHeader,
		hunks: patch.hunks.map(function(hunk) {
			return Hunk({
				oldStart: hunk.oldStart,
				oldLines: hunk.oldLines,
				newStart: hunk.newStart,
				newLines: hunk.newLines,
				lines: hunk.lines
			});
		})
	});
};

exports.processDiffsImpl = function processDiffsImpl(Removed, Unchanged, Added, Diff, diffs) {
	return diffs.map(function(diff) {
		if (diff.removed) {
			return Diff({count: diff.count, value: diff.value, modification: Removed});
		} else if (diffs.added) {
			return Diff({count: diff.count, value: diff.value, modification: Added});
		} else {
			return Diff({count: diff.count, value: diff.value, modification: Unchanged});
		}
	});
};

exports.convertCompareLineImpl = function convertCompareLineImpl(operationToModification, compareLine) {
	return function(lineNumber, line, operation, patchContent) {
		return compareLine(lineNumber)(line)(operationToModification(operation))(patchContent);
	};
};

exports.diffCharsImpl = function diffCharsImpl(oldStr, newStr, options) {
	return jsdiff.diffChar(oldStr, newStr, options);
};

exports.diffWordsImpl = function diffWordsImpl(oldStr, newStr, options) {
	return jsdiff.diffWords(oldStr, newStr, options);
};

exports.diffWordsWithSpaceImpl = function diffWordsWithSpaceImpl(oldStr, newStr, options) {
	return jsdiff.diffWordswithSpace(oldStr, newStr, options);
};

exports.diffLinesImpl = function diffLinesImpl(oldStr, newStr, options) {
	return jsdiff.diffLines(oldStr, newStr, options);
};

exports.diffTrimmedLinesImpl = function diffTrimmedLinesImpl(oldStr, newStr, options) {
	return jsdiff.diffTrimmedLines(oldStr, newStr, options);
};

exports.diffSentencesImpl = function diffSentencesImpl(oldStr, newStr, options) {
	return jsdiff.diffSentences(oldStr, newStr, options);
};

exports.diffCSSImpl = function diffCSSImpl(oldStr, newStr, options) {
	return jsdiff.diffCss(oldStr, newStr, options);
};

exports.diffJSONImpl = function diffJSONImpl(oldObj, newObj, options) {
	return jsdiff.diffJson(oldObj, newObj, options);
};

exports.diffArraysImpl = function diffArraysImpl(oldArr, newArr, options) {
	return jsdiff.diffArrays(oldArr, newArr, options);
};

exports.createTwoFilesPatchImpl = function createTwoFilesPatchImpl(oldFileName, newFileName, oldStr, newStr, oldHeader, newHeader, options) {
	return jsdiff.createTwoFilesPath(oldFileName, newFileName, oldStr, newStr, oldHeader, newHeader, options);
};

exports.createPatchImpl = function createPatchImpl(fileName, oldStr, newStr, oldHeader, newHeader, options) {
	return jsdiff.createPatch(fileName, oldStr, newStr, oldHeader, newheader, options);
};

exports.structuredPatchImpl = function structuredPatchImpl(oldFileName, newFileName, oldStr, newStr, oldHeader, newHeader, options) {
	return jsdiff.structuredPatch(oldFileName, newFileName, oldStr, newStr, oldHeader, newHeader, options);
};

exports.applyPatchImpl = function applyPatchImpl(source, patch, options) {
	return jsdiff.applyPatch(source, patch);
};

exports.parsePatchImpl = function parsePatchImpl(Left, Right, diffString) {
	try {
		return Right(jsdiff.parsePatch(diffString));
	} catch (err) {
		return Left(err);
	}
};

exports.convertChangesToXMLImpl = function convertChangesToXMLImpl(diffs) {
	return jsdiff.convertChangesToXML(diffs);
};
