import System.Environment
import TurtleParser
import RDF
import AvlGraph

main :: IO ()
main = 
  getArgs >>= \t -> (parseFile Nothing "" $ head t) >>= \res ->
    case (res) of
      Left err -> print $ show err
      Right gr -> mapM_ (putStrLn . show) (triplesOf (gr :: AvlGraph))

