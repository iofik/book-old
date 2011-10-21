{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Arrow ((>>>), arr)
import Data.Monoid (mempty)
import Text.Pandoc (WriterOptions(..), defaultParserState, defaultWriterOptions)

import Hakyll

main :: IO ()
main = hakyll $ do
  -- Compress CSS
  match "css/*.css" $ do
    route   idRoute
    compile compressCssCompiler
  
  -- Copy images
  match "images/**.png" $ do
    route   idRoute
    compile copyFileCompiler

  -- Read templates
  match "templates/*" $ compile templateCompiler

  -- Web pages
  match "**.md" $ do
    route   $ setExtension ".html"
    compile $ pageCompilerWith defaultParserState chapterOptions
      >>> applyTemplateCompiler "templates/book.html"
      >>> relativizeUrlsCompiler

chapterOptions = defaultWriterOptions {
                   writerNumberSections  = True,
                   writerSectionDivs     = True,
                   writerStandalone      = True,
                   writerTableOfContents = True,
                   writerTemplate        = "<b>Table of contents</b>\n$toc$\n$body$"
                 }