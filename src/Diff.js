'use strict';

var jsdiff = require('../../bower_components/jsdiff');

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
