--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           Text.Regex.Posix ((=~), getAllTextMatches, getAllSubmatches)
import           Data.List (groupBy)
import           System.FilePath.Posix (takeBaseName)


--------------------------------------------------------------------------------
-- Setup config to generate site into docs folder
config :: Configuration
config = defaultConfiguration { destinationDirectory = "docs" }

main :: IO ()
main = hakyllWith config $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "contact.md" $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    -- create ["archive.html"] $ do
    --     route idRoute -- identity route, no need to change its format
    --     compile $ do
    --         posts <- fmap groupArticles $ recentFirst =<< loadAll "posts/*"
    --         let archiveCtx =
    --                 listField "years"
    --                 (
    --                     field "year" (return . fst . itemBody) <>
    --                     listFieldWith "posts" postCtx (return . snd . itemBody)
    --                 )
    --                 (sequence $ fmap (\(y, is) -> makeItem (show y, is)) posts) <>
    --                 -- listField "posts" postCtx (return posts) `mappend`
    --                 constField "title" "Blog" <>
    --                 defaultContext

    --         makeItem ""
    --             >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
    --             >>= loadAndApplyTemplate "templates/default.html" archiveCtx
    --             >>= relativizeUrls

    create ["blog.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let blogCtx =
                    listField "posts" postCtx (return posts) <>
                    constField "title" "Blog"                <>
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/blog.html" blogCtx
                >>= loadAndApplyTemplate "templates/default.html" blogCtx
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            let indexCtx =
                    constField "title" "Hello, World" `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

-- Extracts year from article file name.
articleYear :: FilePath -> Maybe Int
articleYear s = read <$> head <$> pure regexResult
    where
        postRegex = "^([0-9]{4})\\-([0-9]{2})\\-([0-9]{2})\\-(.+)$" :: String
        filePath = show s :: String
        regexResult = getAllTextMatches (filePath =~ postRegex) :: [String]

-- Groups article items by year (reverse order).
groupArticles :: [Item String] -> [(Int, [Item String])]
groupArticles = fmap merge . group . fmap tupelise
    where
        merge :: [(Int, [Item String])] -> (Int, [Item String])
        merge gs   = let conv (year, acc) (_, toAcc) = (year, toAcc ++ acc)
                     in  foldr conv (head gs) (tail gs)

        group ts   = groupBy (\(y, _) (y', _) -> y == y') ts
        tupelise i = let path = (toFilePath . itemIdentifier) i
                     in  case (articleYear . takeBaseName) path of
                             Just year -> (year, [i])
                             Nothing   -> error $
                                              "[ERROR] wrong format: " ++ path
