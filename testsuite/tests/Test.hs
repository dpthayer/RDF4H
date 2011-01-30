module Main where

import Test.Framework (defaultMain, testGroup)
import Test.Framework.Providers.HUnit
import Test.Framework.Providers.QuickCheck (testProperty)

import Test.QuickCheck
import Test.HUnit

import Data.RDF.MGraph_Test
import Data.RDF.TriplesGraph_Test
import Text.RDF.RDF4H.TurtleParser_ConformanceTest
import qualified Text.RDF.RDF4H.XmlParser_Test as XmlParser

main :: IO () 
main = defaultMain ( XmlParser.tests )
