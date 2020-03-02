module Main where

import           Data.Int                  (Int16, Int32, Int64, Int8)
import           Data.Word                 (Word16, Word32, Word64, Word8)
import           Foreign.C.String          (CString, withCString)
import           Foreign.C.Types           (CInt (..), CSize (..))
import           Foreign.Ptr               (FunPtr, Ptr)

-- | 
-- Heyo.
--
-- @param ${thing} Blerp blap.
-- @param ${barf} Oh noes!
--foreign import ccall club :: {- thing :: -} Word8 -> {- barf :: -} CString -> {- result :: -} Int32
