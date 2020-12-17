module Lib
    ( someFunc,
      dayOne,
      dayTwo
    ) where

import Data.List.Split

someFunc :: IO ()
someFunc = putStrLn "somefunc"

dayOne :: IO ()
dayOne = do
  ls <- fmap lines $ readFile "1.txt"
  let lsint = fmap (read::String->Integer) ls
  let res = take 1 [x * y | x <- lsint, y <- lsint, 2020 == (x + y)]
  print res
  let res2 = take 1 [x * y * z | x <- lsint, y <- lsint, z <- lsint, 2020 == (x + y + z)]
  print res2

dayTwo :: IO ()
dayTwo = do
  ls <- fmap lines $ readFile "2.test.txt"
  let lsw = fmap words ls
  let minmax = splitOn "-" (lsw!!0)
  
  print lsw
  print ls
  
