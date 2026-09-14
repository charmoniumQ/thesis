{-# LANGUAGE OverloadedStrings #-}

import Development.Shake
import Development.Shake.FilePath
import Development.Shake.Command

import System.Directory
import Control.Monad
import qualified Data.ByteString.Char8 as B

buildDir :: FilePath
buildDir = ".build"

-- One rule: for every source `X.typ`, produce the compiled PDF and a JSON
-- manifest of the files typst actually read.  The previous manifest is read
-- and its files marked as needed, so changes to any of them re-trigger the
-- rule (dynamic dependency discovery); build.py closes the loop by copying
-- the new manifest over the old one when it changes.
main :: IO ()
main =
    shakeArgs
        shakeOptions
            { shakeReport        = [buildDir </> "profile.html"]
            , shakeChange        = ChangeModtime
            , shakeVersion       = "typst-v1"
            , shakeThreads       = 1
            , shakeColor         = True
            , shakeCreationCheck = True
            }
        $ do
            want [buildDir </> "main.typ.pdf"]

            [buildDir </> "*.typ.pdf", buildDir </> "*.typ.deps.new.json"] &%> \[pdf, depsNew] -> do
                let stem    = dropExtension (takeBaseName pdf)
                let src     = stem <.> "typ"
                let depsOld = buildDir </> stem <.> "typ.deps.old.json"

                liftIO $ createDirectoryIfMissing True buildDir

                -- The entry file and the previous deps manifest are hard inputs.
                need [src, depsOld]

                -- Mark every file the previous compile read as needed.
                Stdout out <- cmd (["jq", "-r", ".inputs[]", depsOld] :: [String])
                need (filter (not . null) (map B.unpack (B.lines out)))

                cmd_ (["typst", "compile", "--deps", depsNew, src, pdf] :: [String])
