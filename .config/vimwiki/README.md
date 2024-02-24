# How to compile the filter

In order to compile the filter you must type: `ghc -static --make filter.hs`. Keep in mind that you don't need to compile anything, because you can just make the `filter.hs` file executable via `chmod +x filter.hs` and then run it via: 
`pandoc -f markdown -t html --filter ./filter.hs -o index.html index.md`.

To do that remember also to add the shebang: `#!/usr/bin/env runhaskell`
