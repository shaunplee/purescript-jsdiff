module Diff
	( Options(Options)
	, Diff
	, diffChars
	, diffWords
	, diffWordsWithSpace
	, diffLines
	, diffTrimmedLines
	, diffSentences
	, diffCSS
	, diffJSON
	, diffArrays
	) where

import Data.Foreign            (Foreign, toForeign)
import Data.Foreign.Undefined  (writeUndefined)
import Data.Function.Uncurried (Fn3, runFn3)
import Data.Maybe              (Maybe(Just))

type FnDiff = Fn3 Foreign String String (Array Diff)
type Diff'  = Maybe Options -> String -> String -> Array Diff

foreign import data Diff :: *

foreign import diffCharsImpl          :: FnDiff
foreign import diffWordsImpl          :: FnDiff
foreign import diffWordsWithSpaceImpl :: FnDiff
foreign import diffLinesImpl          :: FnDiff
foreign import diffTrimmedLinesImpl   :: FnDiff
foreign import diffSentencesImpl      :: FnDiff
foreign import diffCSSImpl            :: FnDiff
foreign import diffJSONImpl           :: Fn3 Foreign Foreign Foreign (Array Diff)
foreign import diffArraysImpl         :: Fn3 Foreign (Array Foreign) (Array Foreign) (Array Diff)

newtype Options = Options
	{ ignoreWhiteSpace :: Boolean
	, newlineIsToken   :: Boolean
	}

diff :: FnDiff -> Diff'
diff fn (Just (Options o)) oldStr newStr = runFn3 fn (toForeign o)  oldStr newStr
diff fn                  _ oldStr newStr = runFn3 fn writeUndefined oldStr newStr

-- | Diffs two blocks of text, comparing character by character.
diffChars :: Diff'
diffChars = diff diffCharsImpl

-- | Diffs two blocks of text, comparing word by word, ignoring whitespace.
diffWords :: Diff'
diffWords = diff diffWordsImpl

-- | Diffs two blocks of text, comparing word by word, treating whitespace as
-- | significant.
diffWordsWithSpace :: Diff'
diffWordsWithSpace = diff diffWordsWithSpaceImpl

-- | Diffs two blocks of text, comparing line by line.
diffLines :: Diff'
diffLines = diff diffLinesImpl

-- | Diffs two blocks of text, comparing line by line, ignoring leading and
-- | trailing whitespace.
diffTrimmedLines :: Diff'
diffTrimmedLines = diff diffTrimmedLinesImpl

-- | Diffs two blocks of text, comparing sentence by sentence.
diffSentences :: Diff'
diffSentences = diff diffSentencesImpl

-- | Diffs two blocks of text, comparing CSS tokens.
diffCSS :: Diff'
diffCSS = diff diffCSSImpl

-- | Diffs two JSON objects, comparing the fields defined on each. The order of
-- | fields, etc does not matter in this comparison.
diffJSON :: Maybe Options -> Foreign -> Foreign -> Array Diff
diffJSON (Just (Options o)) oldObj newObj = runFn3 diffJSONImpl  (toForeign o) oldObj newObj
diffJSON                  _ oldObj newObj = runFn3 diffJSONImpl writeUndefined oldObj newObj

-- | Diffs two arrays, comparing each item for strict equality (`===`).
diffArrays :: Maybe Options -> Array Foreign -> Array Foreign -> Array Diff
diffArrays (Just (Options o)) oldArr newArr = runFn3 diffArraysImpl (toForeign o)  oldArr newArr
diffArrays                  _ oldArr newArr = runFn3 diffArraysImpl writeUndefined oldArr newArr
