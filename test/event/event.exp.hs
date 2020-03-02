module Main where

import           Data.Int                  (Int16, Int32, Int64, Int8)
import           Data.Word                 (Word16, Word32, Word64, Word8)
import           Foreign.C.String          (CString, withCString)
import           Foreign.C.Types           (CInt (..), CSize (..))
import           Foreign.Ptr               (FunPtr, Ptr)


--struct FooBar
-- | 
-- yoy
--typedef foobar_thing_cb = {- bar :: -} Ptr FooBar -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${thing}` event. Pass NULL to unset.
--
--foreign import ccall foobar_callback_thing :: {- bar :: -} Ptr FooBar -> {- callback :: -} Ptr foobar_thing_cb -> {- user_data :: -} Ptr () -> {- result :: -} ()
-- | 
-- yoy
--typedef foobar_bleh_thing_cb = {- bar :: -} Ptr FooBar -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${bleh_thing}` event. Pass NULL to unset.
--
--foreign import ccall foobar_callback_bleh_thing :: {- bar :: -} Ptr FooBar -> {- callback :: -} Ptr foobar_bleh_thing_cb -> {- user_data :: -} Ptr () -> {- result :: -} ()
-- | 
-- Heyo haha.
--typedef foobar_bleh_otherthing_cb = {- bar :: -} Ptr FooBar -> {- fluff :: -} Word32 -> {- user_data :: -} Ptr () -> <unresolved>

-- | 
-- Set the callback for the `${bleh_otherthing}` event. Pass NULL to unset.
--
--foreign import ccall foobar_callback_bleh_otherthing :: {- bar :: -} Ptr FooBar -> {- callback :: -} Ptr foobar_bleh_otherthing_cb -> {- result :: -} ()

--foreign import ccall foobar_iterate :: {- bar :: -} Ptr FooBar -> {- user_data :: -} <unresolved> -> {- result :: -} <unresolved>

--foreign import ccall foobar_iterate2 :: {- bar :: -} Ptr FooBar -> {- user_data :: -} <unresolved> -> {- result :: -} <unresolved>
