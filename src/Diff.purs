module Diff
  ( Modification(Removed, Unchanged, Added, Meta)
  , Diff(Diff)
  , DiffOptions(DiffOptions)
  , Hunk(Hunk)
  , Patch(Patch)
  , PatchOptions(PatchOptions)
  , diffChars
  , diffWords
  , diffWordsWithSpace
  , diffLines
  , diffTrimmedLines
  , diffSentences
  , diffCSS
  , diffJSON
  , diffArrays
  , createTwoFilesPatch
  , createPatch
  , structuredPatch
  , applyPatch
  , parsePatch
  , convertChangesToXML
  ) where

import Prelude

import Data.Either (Either(Left, Right))
import Data.Eq.Generic (genericEq)
import Data.Function.Uncurried (Fn2, Fn3, Fn5, Fn6, Fn7, runFn2, runFn3, runFn5, runFn6, runFn7)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe, maybe)
import Data.Ord.Generic (genericCompare)
import Data.Show.Generic (genericShow)
import Effect.Exception (Error)
import Foreign (Foreign, unsafeToForeign)
import Partial.Unsafe (unsafeCrashWith)

foreign import processDiffsImpl :: Fn5 Modification Modification Modification ({ value :: String, modification :: Modification, count :: Int } -> Diff) (Array Foreign) (Array Diff)
foreign import processPatchImpl :: Fn3 ({ oldStart :: Int, oldLines :: Int, newStart :: Int, newLines :: Int, lines :: Array String } -> Hunk) ({ oldFileName :: String, newFileName :: String, oldHeader :: String, newHeader :: String, hunks :: Array Hunk } -> Patch) Foreign Patch
foreign import convertCompareLineImpl :: Fn2 (String -> Modification) (Int -> String -> Modification -> String -> Boolean) Foreign

foreign import diffCharsImpl :: Fn3 String String Foreign (Array Foreign)
foreign import diffWordsImpl :: Fn3 String String Foreign (Array Foreign)
foreign import diffWordsWithSpaceImpl :: Fn3 String String Foreign (Array Foreign)
foreign import diffLinesImpl :: Fn3 String String Foreign (Array Foreign)
foreign import diffTrimmedLinesImpl :: Fn3 String String Foreign (Array Foreign)
foreign import diffSentencesImpl :: Fn3 String String Foreign (Array Foreign)
foreign import diffCSSImpl :: Fn3 String String Foreign (Array Foreign)
foreign import diffJSONImpl :: Fn3 Foreign Foreign Foreign (Array Foreign)
foreign import diffArraysImpl :: Fn3 (Array Foreign) (Array Foreign) Foreign (Array Foreign)
foreign import createTwoFilesPatchImpl :: Fn7 String String String String String String Foreign String
foreign import createPatchImpl :: Fn6 String String String String String Foreign String
foreign import structuredPatchImpl :: Fn7 String String String String String String Foreign Foreign
foreign import applyPatchImpl :: Fn3 String Foreign Foreign String
foreign import parsePatchImpl :: forall a b. Fn3 (a -> Either a b) (b -> Either a b) String (Either Error Foreign)
foreign import convertChangesToXMLImpl :: Array Diff -> String

-- XXX Document types.

-- I have no idea if `Meta` is actually what it's called, or if it's even a
-- part of the Unified Diff format, but jsdiff uses it, so we use it; we'll
-- just call it 'Meta' for now. It's used for displaying stuff like:
-- "\\ No newline at end of file".
data Modification = Removed | Unchanged | Added | Meta

derive instance genericModification :: Generic Modification

instance showModification :: Show Modification where
  show Removed = "(Removed)"
  show Unchanged = "(Unchanged)"
  show Added = "(Added)"
  show Meta = "(Meta)"

instance eqModification :: Eq Modification where
  eq Removed Removed = true
  eq Unchanged Unchanged = true
  eq Added Added = true
  eq Meta Meta = true
  eq _ _ = false

instance ordModification :: Ord Modification where
  compare Removed Removed = EQ
  compare Unchanged Unchanged = EQ
  compare Added Added = EQ
  compare Meta Meta = EQ
  compare Removed _ = LT
  compare Unchanged Removed = GT
  compare Unchanged _ = LT
  compare Added Meta = LT
  compare Added _ = GT
  compare Meta _ = GT

newtype Diff = Diff
  { value :: String
  , modification :: Modification
  , count :: Int
  }

derive instance genericDiff :: Generic Diff

instance showDiff :: Show Diff where
  show = genericShow

instance eqDiff :: Eq Diff where
  eq = genericEq

instance ordDiff :: Ord Diff where
  compare = genericCompare

newtype DiffOptions = DiffOptions
  { ignoreWhiteSpace :: Boolean
  , newlineIsToken :: Boolean
  }

derive instance genericDiffOptions :: Generic DiffOptions

instance showDiffOptions :: Show DiffOptions where
  show = genericShow

newtype Hunk = Hunk
  { oldStart :: Int
  , oldLines :: Int
  , newStart :: Int
  , newLines :: Int
  , lines :: Array String
  }

derive instance genericHunk :: Generic Hunk

instance showHunk :: Show Hunk where
  show = genericShow

instance eqHunk :: Eq Hunk where
  eq = genericEq

instance ordHunk :: Ord Hunk where
  compare = genericCompare

instance asForeignHunk :: AsForeign Hunk where
  write (Hunk h) = writeObject
    [ "oldStart" .= h.oldStart
    , "oldLines" .= h.oldLines
    , "newStart" .= h.newStart
    , "newLines" .= h.newLines
    , "lines" .= h.lines
    ]

newtype Patch = Patch
  { oldFileName :: String
  , newFileName :: String
  , oldHeader :: String
  , newHeader :: String
  , hunks :: Array Hunk
  }

derive instance genericPatch :: Generic Patch

instance showPatch :: Show Patch where
  show = genericShow

instance eqPatch :: Eq Patch where
  eq = genericEq

instance ordPatch :: Ord Patch where
  compare = genericCompare

instance asForeignPatch :: AsForeign Patch where
  write (Patch p) = writeObject
    [ "oldFileName" .= p.oldFileName
    , "newFileName" .= p.newFileName
    , "oldHeader" .= p.oldHeader
    , "newHeader" .= p.newHeader
    , "hunks" .= p.hunks
    ]

newtype PatchOptions = PatchOptions
  { context :: Int
  }

derive instance genericPatchOptions :: Generic PatchOptions

instance showPatchOptions :: Show PatchOptions where
  show = genericShow

newtype ApplyOptions = ApplyOptions
  { fuzzFactor :: Int
  , compareLine :: (Int -> String -> Modification -> String -> Boolean)
  }

instance showApplyOptions :: Show ApplyOptions where
  show (ApplyOptions o) = "(ApplyOptions "
    <> "{ fuzzFactor: "
    <> show o.fuzzFactor
    <> ", compareLine: "
    <> "(Int -> String -> Modification -> String -> Boolean)"
    <> " })"

operationToModification :: Partial => String -> Modification
operationToModification "-" = Removed
operationToModification " " = Unchanged
operationToModification "+" = Added
operationToModification "\\" = Meta

processDiffs :: Array Foreign -> Array Diff
processDiffs diffs = runFn5 processDiffsImpl Removed Unchanged Added Diff diffs

diffOptionsToForeign :: Maybe DiffOptions -> Foreign
diffOptionsToForeign = maybe writeUndefined (\(DiffOptions o) -> unsafeToForeign o)

processPatch :: Foreign -> Patch
processPatch patch = runFn3 processPatchImpl Hunk Patch patch

patchOptionsToForeign :: Maybe PatchOptions -> Foreign
patchOptionsToForeign = maybe writeUndefined (\(PatchOptions o) -> unsafeToForeign o)

applyOptionsToForeign :: Maybe ApplyOptions -> Foreign
applyOptionsToForeign o =
  maybe writeUndefined (\(ApplyOptions o) -> unsafeToForeign $ o { compareLine = convertCompareLine o.compareLine }) o
  where
  convertCompareLine compareLine = runFn2 convertCompareLineImpl (unsafeCrashWith "Encountered an unexpected operator while applying patch (was expecting one of: ['-', ' ', '+', '\\'])" operationToModification) compareLine

diff
  :: Fn3 String String Foreign (Array Foreign)
  -> Maybe DiffOptions
  -> String
  -> String
  -> Array Diff
diff fn options oldStr newStr =
  processDiffs $ runFn3 fn oldStr newStr $ diffOptionsToForeign options

-- | Diffs two blocks of text, comparing character by character.
diffChars :: Maybe DiffOptions -> String -> String -> Array Diff
diffChars = diff diffCharsImpl

-- | Diffs two blocks of text, comparing word by word, ignoring whitespace.
diffWords :: Maybe DiffOptions -> String -> String -> Array Diff
diffWords = diff diffWordsImpl

-- | Diffs two blocks of text, comparing word by word, treating whitespace as
-- | significant.
diffWordsWithSpace :: Maybe DiffOptions -> String -> String -> Array Diff
diffWordsWithSpace = diff diffWordsWithSpaceImpl

-- | Diffs two blocks of text, comparing line by line.
diffLines :: Maybe DiffOptions -> String -> String -> Array Diff
diffLines = diff diffLinesImpl

-- | Diffs two blocks of text, comparing line by line, ignoring leading and
-- | trailing whitespace.
diffTrimmedLines :: Maybe DiffOptions -> String -> String -> Array Diff
diffTrimmedLines = diff diffTrimmedLinesImpl

-- | Diffs two blocks of text, comparing sentence by sentence.
diffSentences :: Maybe DiffOptions -> String -> String -> Array Diff
diffSentences = diff diffSentencesImpl

-- | Diffs two blocks of text, comparing CSS tokens.
diffCSS :: Maybe DiffOptions -> String -> String -> Array Diff
diffCSS = diff diffCSSImpl

-- | Diffs two JSON objects, comparing the fields defined on each. The order of
-- | fields, etc does not matter in this comparison.
diffJSON :: Maybe DiffOptions -> Foreign -> Foreign -> Array Diff
diffJSON options oldObj newObj = processDiffs
  $ runFn3 diffJSONImpl oldObj newObj
  $ diffOptionsToForeign options

-- | Diffs two arrays, comparing each item for strict equality (`===`).
diffArrays :: Maybe DiffOptions -> Array Foreign -> Array Foreign -> Array Diff
diffArrays options oldArr newArr = processDiffs
  $ runFn3 diffArraysImpl oldArr newArr
  $ diffOptionsToForeign options

-- | Creates a unified diff patch string.
-- |
-- | Parameters:
-- | - `options`: An object with options. Currently, only context is supported and describes how many lines of context should be included.
-- | - `oldFileName`: String to be output in the filename section of the patch for the removals.
-- | - `newFileName`: String to be output in the filename section of the patch for the additions.
-- | - `oldStr`: Original string value.
-- | - `newStr`: New string value.
-- | - `oldHeader`: Additional information to include in the old file header.
-- | - `newHeader`: Additional information to include in the new file header.
createTwoFilesPatch
  :: Maybe PatchOptions
  -> String
  -> String
  -> String
  -> String
  -> String
  -> String
  -> String
createTwoFilesPatch options oldFileName newFileName oldStr newStr oldHeader newHeader =
  runFn7 createTwoFilesPatchImpl oldFileName newFileName oldStr newStr oldHeader newHeader $ patchOptionsToForeign options

-- | Creates a unified diff patch string.
-- |
-- | Parameters:
-- | - `options`: An object with options. Currently, only context is supported and describes how many lines of context should be included.
-- | - `fileName`: String to be output in the filename section of the patch for the removals and additions.
-- | - `oldStr`: Original string value.
-- | - `newStr`: New string value.
-- | - `oldHeader`: Additional information to include in the old file header.
-- | - `newHeader`: Additional information to include in the new file header.
createPatch
  :: Maybe PatchOptions
  -> String
  -> String
  -> String
  -> String
  -> String
  -> String
createPatch options fileName oldStr newStr oldHeader newHeader =
  runFn6 createPatchImpl fileName oldStr newStr oldHeader newHeader $ patchOptionsToForeign options

-- | Returns a raw Patch.
-- |
-- | Parameters:
-- | - `options`: An object with options. Currently, only context is supported and describes how many lines of context should be included.
-- | - `oldFileName`: String to be output in the filename section of the patch for the removals.
-- | - `newFileName`: String to be output in the filename section of the patch for the additions.
-- | - `oldStr`: Original string value.
-- | - `newStr`: New string value.
-- | - `oldHeader`: Additional information to include in the old file header.
-- | - `newHeader`: Additional information to include in the new file header.
structuredPatch :: Maybe PatchOptions -> String -> String -> String -> String -> String -> String -> Patch
structuredPatch options oldFileName newFileName oldStr newStr oldHeader newHeader = processPatch
  $ runFn7 structuredPatchImpl oldFileName newFileName oldStr newStr oldHeader newHeader
  $ patchOptionsToForeign options

-- | Applies a unified diff patch.
-- |
-- | Returns a string containing new version of provided data. Patch may be a
-- | string diff or the output from the parsePatch or structuredPatch methods.
-- |
-- | The optional options object may have the following keys:
-- | - `fuzzFactor`: Number of lines that are allowed to differ before rejecting a patch. Defaults to 0.
-- | - `compareLine(lineNumber, line, operation, patchContent)`: Callback used to compare to given lines to determine if they should be considered equal when patching. Defaults to strict equality but may be overriden to provide fuzzier comparison. Should return false if the lines should be rejected.
applyPatch :: Maybe ApplyOptions -> String -> Either String Patch -> String
applyPatch options source (Left diffString) =
  runFn3 applyPatchImpl source (unsafeToForeign diff) (applyOptionsToForeign options)
applyPatch options source (Right patch) =
  runFn3 applyPatchImpl source (write patch) (applyOptionsToForeign options)

-- XXX applyPatches

-- | Parses a diff string into `Patch`.
parsePatch :: String -> Either Error Patch
parsePatch diffString = map processPatch $ runFn3 parsePatchImpl Left Right diffString

-- | Converts a list of changes to a serialized XML format.
convertChangesToXML :: Array Diff -> String
convertChangesToXML = convertChangesToXMLImpl

-- XXX Implement option.callback a.k.a. async mode.
