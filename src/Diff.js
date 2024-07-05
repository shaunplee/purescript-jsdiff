'use strict';

import { diffChars, diffWords, diffWordsWithSpace, diffLines, diffTrimmedLines, diffSentences, diffCss, diffJson, diffArrays, createTwoFilesPatch, createPatch, structuredPatch, applyPatch, parsePatch, convertChangesToXML } from '../node_modules/diff/dist/diff.js';

export function processPatchImpl(Hunk, Patch, patch) {
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
}

export function processDiffsImpl(Removed, Unchanged, Added, Diff, diffs) {
  return diffs.map(function(diff) {
	if (diff.removed) {
	  return Diff({count: diff.count, value: diff.value, modification: Removed});
	} else if (diff.added) {
	  return Diff({count: diff.count, value: diff.value, modification: Added});
	} else {
	  return Diff({count: diff.count, value: diff.value, modification: Unchanged});
	}
  });
}

export function convertCompareLineImpl(operationToModification, compareLine) {
	return function(lineNumber, line, operation, patchContent) {
		return compareLine(lineNumber)(line)(operationToModification(operation))(patchContent);
	};
}

export function diffCharsImpl(oldStr, newStr, options) {
	return diffChars(oldStr, newStr, options);
}

export function diffWordsImpl(oldStr, newStr, options) {
	return diffWords(oldStr, newStr, options);
}

export function diffWordsWithSpaceImpl(oldStr, newStr, options) {
	return diffWordsWithSpace(oldStr, newStr, options);
}

export function diffLinesImpl(oldStr, newStr, options) {
	return diffLines(oldStr, newStr, options);
}

export function diffTrimmedLinesImpl(oldStr, newStr, options) {
	return diffTrimmedLines(oldStr, newStr, options);
}

export function diffSentencesImpl(oldStr, newStr, options) {
	return diffSentences(oldStr, newStr, options);
}

export function diffCSSImpl(oldStr, newStr, options) {
	return diffCss(oldStr, newStr, options);
}

export function diffJSONImpl(oldObj, newObj, options) {
	return diffJson(oldObj, newObj, options);
}

export function diffArraysImpl(oldArr, newArr, options) {
	return diffArrays(oldArr, newArr, options);
}

export function createTwoFilesPatchImpl(oldFileName, newFileName, oldStr, newStr, oldHeader, newHeader, options) {
	return createTwoFilesPath(oldFileName, newFileName, oldStr, newStr, oldHeader, newHeader, options);
}

export function createPatchImpl(fileName, oldStr, newStr, oldHeader, newHeader, options) {
	return createPatch(fileName, oldStr, newStr, oldHeader, newHeader, options);
}

export function structuredPatchImpl(oldFileName, newFileName, oldStr, newStr, oldHeader, newHeader, options) {
	return structuredPatch(oldFileName, newFileName, oldStr, newStr, oldHeader, newHeader, options);
}

export function applyPatchImpl(source, patch, options) {
  return applyPatch(source, patch, options);
}

export function parsePatchImpl(Left, Right, diffString) {
	try {
		return Right(parsePatch(diffString));
	} catch (err) {
		return Left(err);
	}
}

export function convertChangesToXMLImpl(diffs) {
	return convertChangesToXML(diffs);
}
