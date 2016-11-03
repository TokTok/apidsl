module Main where

import           Data.Int                  (Int16, Int32, Int64, Int8)
import           Data.Word                 (Word16, Word32, Word64, Word8)
import           Foreign.C.String          (CString, withCString)
import           Foreign.C.Types           (CInt (..), CSize (..))
import           Foreign.Ptr               (FunPtr, Ptr)

-- | 
-- The call state is a set of operations that are currently being performed.
-- A value of 0 means we are neither sending nor receiving anything, meaning,
-- one of the sides requested pause. The call will be resumed once the side
-- that initiated pause resumes it.
data TOXAV_CALL_STATE 

  = TOXAV_CALL_STATE_SENDING_A = 1
    -- ^ 
    -- The friend is sending audio (we are receiving).
  
  | TOXAV_CALL_STATE_SENDING_V = 2
    -- ^ 
    -- The friend is sending video (we are receiving).
  
  | TOXAV_CALL_STATE_RECEIVING_A = 4
    -- ^ 
    -- The friend is receiving audio (we are sending).
  
  | TOXAV_CALL_STATE_RECEIVING_V = 8
    -- ^ 
    -- The friend is receiving video (we are sending).
  
  | TOXAV_CALL_STATE_END = 16
    -- ^ 
    -- The call has finished. This is the final state after which no more state
    -- transitions can occur for the call.
  
  | TOXAV_CALL_STATE_ERROR = 32
    -- ^ 
    -- Set by the AV core if an error occurred on the remote end. This call
    -- state will never be triggered in combination with other call states.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
