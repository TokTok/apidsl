module Main where

import           Data.Int                  (Int16, Int32, Int64, Int8)
import           Data.Word                 (Word16, Word32, Word64, Word8)
import           Foreign.C.String          (CString, withCString)
import           Foreign.C.Types           (CInt (..), CSize (..))
import           Foreign.Ptr               (FunPtr, Ptr)

-- | 
-- Something.
--foreign import ccall get :: {-  :: -} Ptr this -> {- result :: -} Word8
-- | 
-- Something.
--foreign import ccall set :: {-  :: -} Ptr this -> {- this :: -} Word8 -> {- result :: -} ()
-- | 
-- Something.
--foreign import ccall get_size :: {-  :: -} Ptr this -> {- result :: -} CSize
