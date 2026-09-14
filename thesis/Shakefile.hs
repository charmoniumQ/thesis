{-# LANGUAGE OverloadedStrings #-}

import Development.Shake
import Development.Shake.FilePath
import Development.Shake.Command
import Development.Shake.Util

import System.Directory
import Control.Monad
import Data.List
import Data.Hashable (hash)
import qualified Data.ByteString as BS

buildDir :: FilePath
buildDir = ".build"

texEngine :: String
texEngine = "lualatex"

biber :: String
biber = "biber"

-- Stamp files storing the content hash of each .bib; the PDF rule depends
-- on the stamp rather than the .bib so mod-time rewritten bibliographies
-- (Zotero) only rebuild the thesis when the content actually changes.
bibStampOut :: FilePattern
bibStampOut = buildDir </> "*.bib.sha"

main :: IO ()
main =
    shakeArgs
        shakeOptions
            { shakeReport = [buildDir </> "profile.html"]
            , shakeChange   = ChangeModtime
            , shakeLiveFiles = [buildDir </> "live.txt"]
            , shakeVersion  = "lualatex-biber-v1"
            , shakeThreads  = 1
            , shakeColor    = True
            , shakeCreationCheck = True
            }
        $ do

        want [buildDir </> "thesis.pdf"]

        buildDir </> "*.pdf" %> \out -> do
            let stem = takeBaseName out

            -- All sources are globbed up front -- no dynamic deps.mk parsing.
            texFiles <- getDirectoryFiles "" ["//*.tex", "//*.bib"]
            let projectTex =
                    [ f | f <- texFiles
                        , not ("." `isPrefixOf` f)
                        , not ("buck-out" `isPrefixOf` f)
                    ]

            need (projectTex ++ [buildDir </> stem <.> "bib.sha"])

            cmd_ (["latexmk"
                  , "-bibtex"
                  , "-dir-report"
                  , "-output-directory=" ++ buildDir
                  , "-pdflua"
                  , "-rc-report-"
                  , "-silent"
                  , "-time"
                  , "-Werror"
                  , stem
                  ] :: [String])

