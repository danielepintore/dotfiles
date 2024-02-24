#!/usr/bin/env runhaskell
-- This simple filter checks if the link contained is a valid url, if it isn't
-- it adds a .html extenstion to the link (it's supposed to be a page in the wiki)

import Text.Pandoc.JSON
import Text.Regex.TDFA ((=~))
import Data.Text (pack, unpack)

main = toJSONFilter linkParser

linkParser :: Inline -> Inline
linkParser (Link attr txt (url, title)) = Link attr txt (newUrl, title)
  where
    newUrl = if isValidURL (unpack url) then url else pack (unpack url ++ ".html")
linkParser x              = x

isValidURL :: String -> Bool
isValidURL url = url =~ ("(^(https?|ftp)://[a-zA-Z0-9]+(\\.[a-zA-Z0-9]+)+([/?].*)?$)|^(#)" :: String)
