#!/usr/bin/env runhaskell
-- This haskell filter removes links from the document

import Text.Pandoc.JSON

main = toJSONFilter delink

delink :: Inline -> [Inline]
delink (Link _ txt _) = txt
delink x              = [x]
