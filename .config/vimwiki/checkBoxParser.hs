#!/usr/bin/env runhaskell
-- This simple filter that replaces the default checkboxes with cool ones from the
-- utf-8 charset, the checklist displayed still contains the marker, which can 
-- avoided by adding the task-list class to the div containing the checklist in
-- the markdown. ex:
--
-- Example.md
-- :::{.task-list}
-- - [x] item1
-- - [ ] item2
-- - [ ] item3
-- - [ ] item4
-- :::
--
-- This list will be rendered without the marker 

import Text.Pandoc.JSON
import Data.Text (pack, unpack)
import qualified Data.Text as T

main = toJSONFilter checkBoxParser

checkBoxParser :: Inline -> Inline
-- checkBoxParser (Str T.pack "\9746") = Str (pack "pippo")
checkBoxParser (Str text) | T.unpack text == "\9746" = Str (T.pack "\9989")
checkBoxParser (Str text) | T.unpack text == "\9744" = Str (T.pack "\11036\65039")
checkBoxParser x              = x
