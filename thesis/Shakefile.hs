{-# LANGUAGE OverloadedStrings #-}

import Development.Shake
import Development.Shake.FilePath
import Development.Shake.Command
import Development.Shake.Util

import System.Directory
import Control.Monad
import Data.List
import System.Environment
import System.Exit

buildDir :: FilePath
buildDir = ".build"

texEngine :: String
texEngine = "lualatex"

biber :: String
biber = "biber"

stem :: String
stem = "thesis"

-- Make the build environment deterministic.
--
-- In particular, SOURCE_DATE_EPOCH prevents timestamps from entering
-- PDFs/logs and makes TeX's reproducible-build mode effective.
deterministicEnv :: [(String, String)]
deterministicEnv =
    [ ("SOURCE_DATE_EPOCH", "1")
    , ("TZ", "UTC")
    , ("LC_ALL", "C")
    , ("LANG", "C")
    ]

main :: IO ()
main =
    shakeArgs
        shakeOptions
            { shakeFiles = buildDir
            , shakeReport = [buildDir </> "profile.html"]
            , shakeChange   = ChangeDigest
            , shakeLiveFiles = [buildDir </> "live.txt"]
            , shakeVersion  = "lualatex-biber-v1"
            , shakeThreads  = 1
            , shakeColor    = True
            , shakeCreationCheck = True
            }
        $ do

        want ["check"]

        let texOutputs =
                [ buildDir </> stem <.> "pdf"
                , buildDir </> stem <.> "aux"
                , buildDir </> stem <.> "log"
                ]

        texOutputs &%> \_ -> do
            liftIO $ createDirectoryIfMissing True buildDir
            let stemPath = buildDir </> stem
                pdf      = buildDir </> stem <.> "pdf"
            -- The TeX source and any .bib files are explicit dependencies.
            -- Other TeX inputs are discovered from main.fls below.
            bibs <- getDirectoryFiles ("." :: FilePath) (["*.bib"] :: [FilePattern])
            need (bibs ++ [stem <.> "tex"])
            runLuaLaTeX deterministicEnv stemPath
            discoverFlInputs stemPath

            -- readFile' would register the log as a tracked dependency, but
            -- the log changes on every pass (memory stats etc.), forcing a
            -- rebuild each run.  Read it untracked: we only inspect it.
            log1 <- liftIO $ readFile (stemPath <.> "log")

            -- A .bib edit never makes LuaLaTeX request Biber, so run Biber
            -- whenever any .bib file is newer than the .bbl as well.
            bibChanged <- or <$> mapM (newerThanBbl stemPath) bibs

            if wantsBiber log1 || bibChanged
                then do
                    runBiber deterministicEnv stemPath
                    -- Biber changed the bibliography data, so LuaLaTeX
                    -- must process the resulting .bbl.
                    runLuaLaTeX deterministicEnv stemPath
                    discoverFlInputs stemPath
                    log2 <- liftIO $ readFile (stemPath <.> "log")
                    when (wantsRerunLatex log2) $ do
                        runLuaLaTeX deterministicEnv stemPath
                        discoverFlInputs stemPath
                else when (wantsRerunLatex log1) $ do
                    runLuaLaTeX deterministicEnv stemPath
                    discoverFlInputs stemPath

        -- Print warnings from the final log (see check.py).
        phony "check" $ do
            let logPath = buildDir </> stem <.> "log"
            need [logPath]
            cmd_ (["python3", "check.py", logPath] :: [String])


-- Suppress command output on success; on failure Shake includes both
-- streams in the raised error.
quietCmd :: [CmdOption]
quietCmd =
    [ EchoStdout False
    , EchoStderr False
    , WithStdout True
    , WithStderr True
    ]

runLuaLaTeX :: [(String, String)] -> FilePath -> Action ()
runLuaLaTeX env stem = do
    let tex = replaceExtension (takeFileName stem) "tex"
        dir = takeDirectory stem

        args =
            [ "-interaction=nonstopmode"
            , "-halt-on-error"
            , "-file-line-error"
            , "-recorder"
            , "-output-directory=" ++ dir
            , tex
            ]

    -- -interaction=nonstopmode prevents TeX from asking questions.
    -- -halt-on-error makes failures propagate.
    --
    -- -recorder causes LuaLaTeX to create main.fls, which records files
    -- actually read.  This is how we discover \input, \include, packages,
    -- etc. without trying to reproduce TeX's dependency resolution.
    putInfo $ unwords (texEngine : args)

    cmd_ (quietCmd ++ map (uncurry AddEnv) env) texEngine args

runBiber :: [(String, String)] -> FilePath -> Action ()
runBiber env stem = do
    putInfo $ unwords [biber, "--quiet", stem]

    cmd_ (quietCmd ++ map (uncurry AddEnv) env) biber ["--quiet", stem]

-- True if the file is newer than the current .bbl (or no .bbl exists).
newerThanBbl :: FilePath -> FilePath -> Action Bool
newerThanBbl stem f = do
    bblExists <- liftIO $ System.Directory.doesFileExist bblPath
    if not bblExists
        then return True
        else do
            bblTime <- liftIO $ System.Directory.getModificationTime bblPath
            fTime   <- liftIO $ System.Directory.getModificationTime f
            return $ fTime > bblTime
  where
    bblPath = stem <.> "bbl"

-- LuaLaTeX's -recorder option produces:
--
--   INPUT ./main.tex
--   INPUT /some/path/foo.sty
--   INPUT ./chapter1.tex
--
-- We tell Shake about every input that actually exists.
discoverFlInputs :: FilePath -> Action ()
discoverFlInputs stem = do
    let fls = stem <.> "fls"

    exists <- liftIO $ System.Directory.doesFileExist fls

    when exists $ do
        contents <- readFile' fls

        let inputs =
                nub
                . map (normalise . dropPrefix)
                . filter (isPrefixOf "INPUT ")
                . lines
                $ contents

            dropPrefix = drop 6

        -- Ignore files outside the project/build tree which are merely
        -- implementation details of TeX's installation.
        let projectInputs =
                filter isInteresting inputs

        unless (null projectInputs) $
            needed projectInputs

  where
    isInteresting p =
        not (null p)
        && not (isAbsolute p || "/texlive/" `isInfixOf` p)
        && takeExtension p `elem`
            [ ".tex"
            , ".bib"
            , ".sty"
            , ".cls"
            , ".bst"
            , ".bbx"
            , ".cbx"
            , ".def"
            , ".fd"
            , ".lua"
            ]

-- Biber usually leaves one of these messages in the LaTeX log when
-- biblatex has generated/updated a .bcf requiring Biber.
wantsBiber :: String -> Bool
wantsBiber log =
       "Please (re)run Biber on the file:" `isInfixOf` log
    || "Please (re)run Biber" `isInfixOf` log
    || "Package biblatex Warning: Please (re)run Biber" `isInfixOf` log

-- These are the common signals emitted by LaTeX that another pass is
-- required.  This intentionally does not blindly run three passes.
wantsRerunLatex :: String -> Bool
wantsRerunLatex log =
       "Rerun to get cross-references right" `isInfixOf` log
    || "Label(s) may have changed" `isInfixOf` log
    || "There were undefined references" `isInfixOf` log
    || "There were undefined citations" `isInfixOf` log
    || "Please rerun LaTeX" `isInfixOf` log
    || "Please (re)run LaTeX" `isInfixOf` log
