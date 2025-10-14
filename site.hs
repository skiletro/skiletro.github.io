--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

import           Control.Exception     (SomeException, catch)
import           Data.List             (isInfixOf, sortBy)
import           Data.Monoid           (mappend)
import           Hakyll
import           Hakyll.Web.Sass       (sassCompiler)
import           System.Environment
import           System.FilePath.Posix (splitFileName, takeBaseName,
                                        takeDirectory, (</>))
import           System.Process

--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
  match "images/*" $ do
    route idRoute
    compile copyFileCompiler

  match "css/*.css" $ do
    route idRoute
    compile compressCssCompiler

  match "css/*.scss" $ do
    route $ setExtension "css"
    let compressCssItem = fmap compressCss
    compile (compressCssItem <$> sassCompiler)

  match "404.html" $ do
    route idRoute
    compile $
      pandocCompiler
        >>= loadAndApplyTemplate "templates/default.html" defaultCtx
        >>= relativizeUrls
        >>= removeIndexHtml

  match "pages/*.html" $ do
    route prettyRoute
    compile $
      pandocCompiler
        >>= loadAndApplyTemplate "templates/default.html" defaultCtx
        >>= relativizeUrls
        >>= removeIndexHtml

  match "posts/*" $ do
    route prettyRoute
    compile $
      pandocCompiler
        >>= loadAndApplyTemplate "templates/post.html" postCtx
        >>= saveSnapshot "content"
        >>= loadAndApplyTemplate "templates/default.html" postCtx
        >>= relativizeUrls
        >>= removeIndexHtml

  create ["archive.html"] $ do
    route prettyRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let archiveCtx =
            listField "posts" postCtx (return posts)
              `mappend` constField "title" "Archives"
              `mappend` defaultCtx

      makeItem ""
        >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
        >>= loadAndApplyTemplate "templates/default.html" archiveCtx
        >>= relativizeUrls
        >>= removeIndexHtml

  create ["atom.xml"] $ do
    route idRoute
    compile $ do
      let feedCtx = postCtx `mappend` bodyField "description"
      posts <-
        fmap (take 10) . recentFirst
          =<< loadAllSnapshots "posts/*" "content"
      renderAtom feedConfiguration feedCtx posts

  create ["rss.xml"] $ do
    route idRoute
    compile $ do
      let feedCtx = postCtx `mappend` bodyField "description"
      posts <-
        fmap (take 10) . recentFirst
          =<< loadAllSnapshots "posts/*" "content"
      renderRss feedConfiguration feedCtx posts

  match "index.html" $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let indexCtx =
            listField "posts" postCtx (return posts)
              `mappend` defaultCtx

      getResourceBody
        >>= applyAsTemplate indexCtx
        >>= loadAndApplyTemplate "templates/default.html" indexCtx
        >>= relativizeUrls
        >>= removeIndexHtml

  match "templates/*" $ compile templateBodyCompiler

--------------------------------------------------------------------------------
feedConfiguration :: FeedConfiguration
feedConfiguration =
  FeedConfiguration
    { feedTitle = "Posts on Skiletro.com",
      feedDescription = "Recent posts from Skiletro.com",
      feedAuthorName = "Skiletro",
      feedAuthorEmail = "19377854+skiletro@users.noreply.github.com", -- you're not getting my email that easily
      feedRoot = "https://skiletro.com"
    }

--------------------------------------------------------------------------------

prettyRoute :: Routes
prettyRoute = customRoute createIndexRoute
  where
    createIndexRoute ident =
      takeDirectory p </> takeBaseName p </> "index.html"
      where
        p = toFilePath ident

removeIndexHtml :: Item String -> Compiler (Item String)
removeIndexHtml item = return $ fmap (withUrls removeIndexStr) item
  where
    removeIndexStr :: String -> String
    removeIndexStr url = case splitFileName url of
      (dir, "index.html") | isLocal dir -> dir
      _                                 -> url
      where
        isLocal uri = not (isInfixOf "://" uri)

--------------------------------------------------------------------------------

defaultCtx :: Context String
defaultCtx = gitRevisionCtx <> defaultContext

postCtx :: Context String
postCtx = hDateCtx <> cDateCtx <> defaultCtx

hDateCtx :: Context String
hDateCtx = dateField "hdate" "%B %e, %Y"

cDateCtx :: Context String
cDateCtx = dateField "cdate" "%Y-%m-%d"

gitRevisionField :: String -> Context String
gitRevisionField = flip field (const gitRevision)

-- Compiler which attempts to find the current git revision. This is done by
-- first checking the "REVISION" environment variable and, if this fails,
-- running the command "git rev-parse HEAD".
gitRevision :: Compiler String
gitRevision = do
  rev <- unsafeCompiler (getEnv "REVISION" `catch` (\e -> return (e :: SomeException) >> return ""))
  if rev == ""
    then unixFilter "git" ["rev-parse", "--short=7", "HEAD"] ""
    else return rev

gitRevisionCtx :: Context String
gitRevisionCtx = gitRevisionField "revision"

--------------------------------------------------------------------------------
