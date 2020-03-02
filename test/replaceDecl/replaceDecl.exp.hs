module Main where

import           Data.Int                  (Int16, Int32, Int64, Int8)
import           Data.Word                 (Word16, Word32, Word64, Word8)
import           Foreign.C.String          (CString, withCString)
import           Foreign.C.Types           (CInt (..), CSize (..))
import           Foreign.Ptr               (FunPtr, Ptr)


--foreign import ccall foo_bar :: {- foo :: -} Ptr Foo -> {- result :: -} Word8
-- | 
-- Moop.
data Foo = Foo
  
  { order :: Word8}

--foreign import ccall foo_get_order :: {- foo :: -} Ptr Foo -> {- result :: -} Word8

--foreign import ccall foo_set_order :: {- foo :: -} Ptr Foo -> {- order :: -} Word8 -> {- result :: -} ()

--foreign import ccall foo_cow :: {- foo :: -} Ptr Foo -> {- result :: -} Word8
