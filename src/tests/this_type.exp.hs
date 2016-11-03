module Main where

import           Data.Int                  (Int16, Int32, Int64, Int8)
import           Data.Word                 (Word16, Word32, Word64, Word8)
import           Foreign.C.String          (CString, withCString)
import           Foreign.C.Types           (CInt (..), CSize (..))
import           Foreign.Ptr               (FunPtr, Ptr)


--struct Tox

--struct ToxAV

--foreign import ccall toxav_new :: {- tox :: -} Ptr Tox -> {- result :: -} Ptr ToxAV

--foreign import ccall toxav_get_tox :: {- av :: -} Ptr ToxAV -> {- result :: -} Ptr Tox
