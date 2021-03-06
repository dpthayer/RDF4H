{-# LANGUAGE RankNTypes #-}

module Text.RDF.RDF4H.ParserUtils(
  ParseFailure(..),
  parseFile', parseURL'
) where

import Network.URI
import Network.HTTP

import Data.Char(intToDigit)
import Data.ByteString.Lazy.Char8(ByteString)
import qualified Data.ByteString.Lazy.Char8 as B

-- |Represents a failure in parsing an N-Triples document, including
-- an error message with information about the cause for the failure.
newtype ParseFailure = ParseFailure String
  deriving (Eq, Show)

-- A convenience function for terminating a parse with a parse failure, using
-- the given error message as the message for the failure.
errResult :: forall rdf. String -> Either ParseFailure rdf
errResult msg = Left (ParseFailure msg)

parseFile' :: forall rdf.
           (ByteString -> Either ParseFailure rdf)
           -> FilePath
           -> IO (Either ParseFailure rdf)
parseFile' parser file = do str <- B.readFile file
                            return (parser str)

-- |Parse the document at the given location URL with the given parser function.
parseURL' :: forall rdf.
          (ByteString -> Either ParseFailure rdf) -- ^ Function to parse the document (should include this URL as a BaseUrl if it is appropriate)
          -> String                                  -- ^ URL of the document to parse
          -> IO (Either ParseFailure rdf)            -- ^ either a @ParseFailure@ or a new graph containing the parsed triples.
parseURL' parseFunc url =
  maybe
    (return (Left (ParseFailure $ "Unable to parse URL: " ++ url)))
    p
    (parseURI url)
  where
    showRspCode (a, b, c) = map intToDigit [a, b, c]
    httpError resp = showRspCode (rspCode resp) ++ " " ++ rspReason resp
    p url =
      simpleHTTP (request url) >>= \resp ->
        case resp of
          (Left e)    -> return (errResult $ "couldn't retrieve from URL: " ++ show url ++ " [" ++ show e ++ "]")
          (Right res) -> case rspCode res of
                           (2, 0, 0) -> return $ parseFunc (rspBody res)
                           _         -> return (errResult $ "couldn't retrieve from URL: " ++ httpError res)

request :: URI -> HTTPRequest ByteString
request uri = Request { rqURI = uri,
                        rqMethod = GET,
                        rqHeaders = [Header HdrConnection "close"],
                        rqBody = B.empty }
