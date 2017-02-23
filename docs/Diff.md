## Module Diff

#### `Modification`

``` purescript
data Modification
  = Removed
  | Unchanged
  | Added
  | Meta
```

##### Instances
``` purescript
Generic Modification
Show Modification
Eq Modification
Ord Modification
```

#### `Diff`

``` purescript
newtype Diff
  = Diff { "value" :: String, "modification" :: Modification, "count" :: Int }
```

##### Instances
``` purescript
Generic Diff
Show Diff
Eq Diff
Ord Diff
```

#### `DiffOptions`

``` purescript
newtype DiffOptions
  = DiffOptions { "ignoreWhiteSpace" :: Boolean, "newlineIsToken" :: Boolean }
```

##### Instances
``` purescript
Generic DiffOptions
Show DiffOptions
```

#### `Hunk`

``` purescript
newtype Hunk
  = Hunk { "oldStart" :: Int, "oldLines" :: Int, "newStart" :: Int, "newLines" :: Int, "lines" :: Array String }
```

##### Instances
``` purescript
Generic Hunk
Show Hunk
Eq Hunk
Ord Hunk
AsForeign Hunk
```

#### `Patch`

``` purescript
newtype Patch
  = Patch { "oldFileName" :: String, "newFileName" :: String, "oldHeader" :: String, "newHeader" :: String, "hunks" :: Array Hunk }
```

##### Instances
``` purescript
Generic Patch
Show Patch
Eq Patch
Ord Patch
AsForeign Patch
```

#### `PatchOptions`

``` purescript
newtype PatchOptions
  = PatchOptions { "context" :: Int }
```

##### Instances
``` purescript
Generic PatchOptions
Show PatchOptions
```

#### `diffChars`

``` purescript
diffChars :: Maybe DiffOptions -> String -> String -> Array Diff
```

Diffs two blocks of text, comparing character by character.

#### `diffWords`

``` purescript
diffWords :: Maybe DiffOptions -> String -> String -> Array Diff
```

Diffs two blocks of text, comparing word by word, ignoring whitespace.

#### `diffWordsWithSpace`

``` purescript
diffWordsWithSpace :: Maybe DiffOptions -> String -> String -> Array Diff
```

Diffs two blocks of text, comparing word by word, treating whitespace as
significant.

#### `diffLines`

``` purescript
diffLines :: Maybe DiffOptions -> String -> String -> Array Diff
```

Diffs two blocks of text, comparing line by line.

#### `diffTrimmedLines`

``` purescript
diffTrimmedLines :: Maybe DiffOptions -> String -> String -> Array Diff
```

Diffs two blocks of text, comparing line by line, ignoring leading and
trailing whitespace.

#### `diffSentences`

``` purescript
diffSentences :: Maybe DiffOptions -> String -> String -> Array Diff
```

Diffs two blocks of text, comparing sentence by sentence.

#### `diffCSS`

``` purescript
diffCSS :: Maybe DiffOptions -> String -> String -> Array Diff
```

Diffs two blocks of text, comparing CSS tokens.

#### `diffJSON`

``` purescript
diffJSON :: Maybe DiffOptions -> Foreign -> Foreign -> Array Diff
```

Diffs two JSON objects, comparing the fields defined on each. The order of
fields, etc does not matter in this comparison.

#### `diffArrays`

``` purescript
diffArrays :: Maybe DiffOptions -> Array Foreign -> Array Foreign -> Array Diff
```

Diffs two arrays, comparing each item for strict equality (`===`).

#### `createTwoFilesPatch`

``` purescript
createTwoFilesPatch :: Maybe PatchOptions -> String -> String -> String -> String -> String -> String -> String
```

Creates a unified diff patch string.

Parameters:
- `options`: An object with options. Currently, only context is supported and describes how many lines of context should be included.
- `oldFileName`: String to be output in the filename section of the patch for the removals.
- `newFileName`: String to be output in the filename section of the patch for the additions.
- `oldStr`: Original string value.
- `newStr`: New string value.
- `oldHeader`: Additional information to include in the old file header.
- `newHeader`: Additional information to include in the new file header.

#### `createPatch`

``` purescript
createPatch :: Maybe PatchOptions -> String -> String -> String -> String -> String -> String
```

Creates a unified diff patch string.

Parameters:
- `options`: An object with options. Currently, only context is supported and describes how many lines of context should be included.
- `fileName`: String to be output in the filename section of the patch for the removals and additions.
- `oldStr`: Original string value.
- `newStr`: New string value.
- `oldHeader`: Additional information to include in the old file header.
- `newHeader`: Additional information to include in the new file header.

#### `structuredPatch`

``` purescript
structuredPatch :: Maybe PatchOptions -> String -> String -> String -> String -> String -> String -> Patch
```

Returns a raw Patch.

Parameters:
- `options`: An object with options. Currently, only context is supported and describes how many lines of context should be included.
- `oldFileName`: String to be output in the filename section of the patch for the removals.
- `newFileName`: String to be output in the filename section of the patch for the additions.
- `oldStr`: Original string value.
- `newStr`: New string value.
- `oldHeader`: Additional information to include in the old file header.
- `newHeader`: Additional information to include in the new file header.

#### `applyPatch`

``` purescript
applyPatch :: Maybe ApplyOptions -> String -> Either String Patch -> String
```

Applies a unified diff patch.

Returns a string containing new version of provided data. Patch may be a
string diff or the output from the parsePatch or structuredPatch methods.

The optional options object may have the following keys:
- `fuzzFactor`: Number of lines that are allowed to differ before rejecting a patch. Defaults to 0.
- `compareLine(lineNumber, line, operation, patchContent)`: Callback used to compare to given lines to determine if they should be considered equal when patching. Defaults to strict equality but may be overriden to provide fuzzier comparison. Should return false if the lines should be rejected.

#### `parsePatch`

``` purescript
parsePatch :: String -> Either Error Patch
```

Parses a diff string into `Patch`.

#### `convertChangesToXML`

``` purescript
convertChangesToXML :: Array Diff -> String
```

Converts a list of changes to a serialized XML format.


