module Main where

import           Data.Int                  (Int16, Int32, Int64, Int8)
import           Data.Word                 (Word16, Word32, Word64, Word8)
import           Foreign.C.String          (CString, withCString)
import           Foreign.C.Types           (CInt (..), CSize (..))
import           Foreign.Ptr               (FunPtr, Ptr)

-- |  \page av Public audio/video API for Tox clients.
-- 
-- This API can handle multiple calls. Each call has its state, in very rare
-- occasions the library can change the state of the call without apps knowledge.
-- -- |  \subsection events Events and callbacks
--
-- As in Core API, events are handled by callbacks. One callback can be 
-- registered per event. All events have a callback function type named 
-- `toxav_{event}_cb` and a function to register it named `tox_callback_{event}`. 
-- Passing a NULL callback will result in no callback being registered for that 
-- event. Only one callback per event can be registered, so if a client needs 
-- multiple event listeners, it needs to implement the dispatch functionality 
-- itself. Unlike Core API, lack of some event handlers will cause the the 
-- library to drop calls before they are started. Hanging up call from a 
-- callback causes undefined behaviour.
-- -- |  \subsection threading Threading implications
--
-- Unlike the Core API, this API is fully thread-safe. The library will ensure
-- the proper synchronisation of parallel calls. 
-- 
-- A common way to run ToxAV (multiple or single instance) is to have a thread,
-- separate from tox instance thread, running a simple ${toxav_iterate} loop, 
-- sleeping for ${toxav_iteration_interval} * milliseconds on each iteration.
---- | 
-- External Tox type.
--struct Tox
-- | 
-- ToxAV.-- | 
-- The ToxAV instance type. Each ToxAV instance can be bound to only one Tox
-- instance, and Tox instance can have only one ToxAV instance. One must make
-- sure to close ToxAV instance prior closing Tox instance otherwise undefined
-- behaviour occurs. Upon closing of ToxAV instance, all active calls will be 
-- forcibly terminated without notifying peers.
-- 
--struct ToxAV


--------------------------------------------------------------------------------
--
-- :: API version
--
--------------------------------------------------------------------------------


-- | 
-- The major version number. Incremented when the API or ABI changes in an
-- incompatible way.
#define TOXAV_VERSION_MAJOR               0u
-- | 
-- The minor version number. Incremented when functionality is added without
-- breaking the API or ABI. Set to 0 when the major version number is
-- incremented.
#define TOXAV_VERSION_MINOR               0u
-- | 
-- The patch or revision number. Incremented when bugfixes are applied without
-- changing any functionality or API or ABI.
#define TOXAV_VERSION_PATCH               0u
-- | 
-- A macro to check at preprocessing time whether the client code is compatible
-- with the installed version of ToxAV.
#define TOXAV_VERSION_IS_API_COMPATIBLE(MAJOR, MINOR, PATCH)        \
  (TOXAV_VERSION_MAJOR == MAJOR &&                                \
   (TOXAV_VERSION_MINOR > MINOR ||                                \
    (TOXAV_VERSION_MINOR == MINOR &&                              \
     TOXAV_VERSION_PATCH >= PATCH)))
-- | 
-- A macro to make compilation fail if the client code is not compatible with
-- the installed version of ToxAV.
#define TOXAV_VERSION_REQUIRE(MAJOR, MINOR, PATCH)                \
  typedef char toxav_required_version[TOXAV_IS_COMPATIBLE(MAJOR, MINOR, PATCH) ? 1 : -1]
-- | 
-- A convenience macro to call ${toxav_version_is_compatible} with the currently
-- compiling API version.
#define TOXAV_VERSION_IS_ABI_COMPATIBLE()                         \
  toxav_version_is_compatible(TOXAV_VERSION_MAJOR, TOXAV_VERSION_MINOR, TOXAV_VERSION_PATCH)
-- | 
-- Return the major version number of the library. Can be used to display the
-- ToxAV library version or to check whether the client is compatible with the
-- dynamically linked version of ToxAV.
--foreign import ccall toxav_version_major :: {- result :: -} Word32
-- | 
-- Return the minor version number of the library.
--foreign import ccall toxav_version_minor :: {- result :: -} Word32
-- | 
-- Return the patch number of the library.
--foreign import ccall toxav_version_patch :: {- result :: -} Word32
-- | 
-- Return whether the compiled library version is compatible with the passed
-- version numbers.
--foreign import ccall toxav_version_is_compatible :: {- major :: -} Word32 -> {- minor :: -} Word32 -> {- patch :: -} Word32 -> {- result :: -} Bool


--------------------------------------------------------------------------------
-- 
-- :: Creation and destruction
--
--------------------------------------------------------------------------------



data TOXAV_ERR_NEW 

  = TOXAV_ERR_NEW_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOXAV_ERR_NEW_NULL
    -- ^ 
    -- One of the arguments to the function was NULL when it was not expected.
  
  | TOXAV_ERR_NEW_MALLOC
    -- ^ 
    -- Memory allocation failure while trying to allocate structures required for
    -- the A/V session.
  
  | TOXAV_ERR_NEW_MULTIPLE
    -- ^ 
    -- Attempted to create a second session for the same Tox instance.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Start new A/V session. There can only be only one session per Tox instance.
--foreign import ccall toxav_new :: {- tox :: -} Ptr Tox -> {- error :: -} Ptr TOXAV_ERR_NEW -> {- result :: -} Ptr ToxAV
-- | 
-- Releases all resources associated with the A/V session.
--
-- If any calls were ongoing, these will be forcibly terminated without
-- notifying peers. After calling this function, no other functions may be
-- called and the av pointer becomes invalid.
--foreign import ccall toxav_kill :: {- av :: -} Ptr ToxAV -> {- result :: -} ()
-- | 
-- Returns the Tox instance the A/V object was created for.
--foreign import ccall toxav_get_tox :: {- av :: -} Ptr ToxAV -> {- result :: -} Ptr Tox


--------------------------------------------------------------------------------
-- 
-- :: A/V event loop
--
--------------------------------------------------------------------------------


-- | 
-- Returns the interval in milliseconds when the next toxav_iterate call should
-- be. If no call is active at the moment, this function returns 200.
--foreign import ccall toxav_iteration_interval :: {- av :: -} Ptr ToxAV -> {- result :: -} Word32
-- | 
-- Main loop for the session. This function needs to be called in intervals of
-- toxav_iteration_interval() milliseconds. It is best called in the separate 
-- thread from tox_iterate.
--foreign import ccall toxav_iterate :: {- av :: -} Ptr ToxAV -> {- result :: -} ()


--------------------------------------------------------------------------------
-- 
-- :: Call setup
--
--------------------------------------------------------------------------------



data TOXAV_ERR_CALL 

  = TOXAV_ERR_CALL_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOXAV_ERR_CALL_MALLOC
    -- ^ 
    -- A resource allocation error occurred while trying to create the structures
    -- required for the call.
  
  | TOXAV_ERR_CALL_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend number did not designate a valid friend.
  
  | TOXAV_ERR_CALL_FRIEND_NOT_CONNECTED
    -- ^ 
    -- The friend was valid, but not currently connected.
  
  | TOXAV_ERR_CALL_FRIEND_ALREADY_IN_CALL
    -- ^ 
    -- Attempted to call a friend while already in an audio or video call with
    -- them.
  
  | TOXAV_ERR_CALL_INVALID_BIT_RATE
    -- ^ 
    -- Audio or video bit rate is invalid.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Call a friend. This will start ringing the friend.
--
-- It is the client's responsibility to stop ringing after a certain timeout,
-- if such behaviour is desired. If the client does not stop ringing, the
-- library will not stop until the friend is disconnected.
--
-- @param friend_number The friend number of the friend that should be called.
-- @param audio_bit_rate Audio bit rate in Kb/sec. Set this to 0 to disable
-- audio sending.
-- @param video_bit_rate Video bit rate in Kb/sec. Set this to 0 to disable
-- video sending.
--foreign import ccall toxav_call :: {- av :: -} Ptr ToxAV -> {- friend_number :: -} Word32 -> {- audio_bit_rate :: -} Word32 -> {- video_bit_rate :: -} Word32 -> {- error :: -} Ptr TOXAV_ERR_CALL -> {- result :: -} Bool
-- | 
-- The function type for the ${call} callback.
-- 
-- @param friend_number The friend number from which the call is incoming.
-- @param audio_enabled True if friend is sending audio.
-- @param video_enabled True if friend is sending video.
--typedef toxav_call_cb = {- av :: -} Ptr ToxAV -> {- friend_number :: -} Word32 -> {- audio_enabled :: -} Bool -> {- video_enabled :: -} Bool -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${call}` event. Pass NULL to unset.
--
--foreign import ccall toxav_callback_call :: {- av :: -} Ptr ToxAV -> {- callback :: -} Ptr toxav_call_cb -> {- user_data :: -} Ptr () -> {- result :: -} ()

data TOXAV_ERR_ANSWER 

  = TOXAV_ERR_ANSWER_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOXAV_ERR_ANSWER_CODEC_INITIALIZATION
    -- ^ 
    -- Failed to initialize codecs for call session. Note that codec initiation
    -- will fail if there is no receive callback registered for either audio or
    -- video.
  
  | TOXAV_ERR_ANSWER_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend number did not designate a valid friend.
  
  | TOXAV_ERR_ANSWER_FRIEND_NOT_CALLING
    -- ^ 
    -- The friend was valid, but they are not currently trying to initiate a call.
    -- This is also returned if this client is already in a call with the friend.
  
  | TOXAV_ERR_ANSWER_INVALID_BIT_RATE
    -- ^ 
    -- Audio or video bit rate is invalid.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Accept an incoming call.
--
-- If answering fails for any reason, the call will still be pending and it is
-- possible to try and answer it later.
--
-- @param friend_number The friend number of the friend that is calling.
-- @param audio_bit_rate Audio bit rate in Kb/sec. Set this to 0 to disable
-- audio sending.
-- @param video_bit_rate Video bit rate in Kb/sec. Set this to 0 to disable
-- video sending.
--foreign import ccall toxav_answer :: {- av :: -} Ptr ToxAV -> {- friend_number :: -} Word32 -> {- audio_bit_rate :: -} Word32 -> {- video_bit_rate :: -} Word32 -> {- error :: -} Ptr TOXAV_ERR_ANSWER -> {- result :: -} Bool


--------------------------------------------------------------------------------
-- 
-- :: Call state graph
--
--------------------------------------------------------------------------------



data TOXAV_CALL_STATE 

  = TOXAV_CALL_STATE_ERROR = 1
    -- ^ 
    -- Set by the AV core if an error occurred on the remote end or if friend 
    -- timed out. This is the final state after which no more state
    -- transitions can occur for the call. This call state will never be triggered
    -- in combination with other call states.
  
  | TOXAV_CALL_STATE_FINISHED = 2
    -- ^ 
    -- The call has finished. This is the final state after which no more state
    -- transitions can occur for the call. This call state will never be 
    -- triggered in combination with other call states.
  
  | TOXAV_CALL_STATE_SENDING_A = 4
    -- ^ 
    -- The flag that marks that friend is sending audio.
  
  | TOXAV_CALL_STATE_SENDING_V = 8
    -- ^ 
    -- The flag that marks that friend is sending video.
  
  | TOXAV_CALL_STATE_RECEIVING_A = 16
    -- ^ 
    -- The flag that marks that friend is receiving audio.
  
  | TOXAV_CALL_STATE_RECEIVING_V = 32
    -- ^ 
    -- The flag that marks that friend is receiving video.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- The function type for the ${call_state} callback.
--
-- @param friend_number The friend number for which the call state changed.
-- @param state The new call state which is guaranteed to be different than 
-- the previous state. The state is set to 0 when the call is paused.
--typedef toxav_call_state_cb = {- av :: -} Ptr ToxAV -> {- friend_number :: -} Word32 -> {- state :: -} Word32 -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${call_state}` event. Pass NULL to unset.
--
--foreign import ccall toxav_callback_call_state :: {- av :: -} Ptr ToxAV -> {- callback :: -} Ptr toxav_call_state_cb -> {- user_data :: -} Ptr () -> {- result :: -} ()


--------------------------------------------------------------------------------
-- 
-- :: Call control
--
--------------------------------------------------------------------------------



data TOXAV_CALL_CONTROL 

  = TOXAV_CALL_CONTROL_RESUME
    -- ^ 
    -- Resume a previously paused call. Only valid if the pause was caused by this
    -- client, if not, this control is ignored. Not valid before the call is accepted.
  
  | TOXAV_CALL_CONTROL_PAUSE
    -- ^ 
    -- Put a call on hold. Not valid before the call is accepted.
  
  | TOXAV_CALL_CONTROL_CANCEL
    -- ^ 
    -- Reject a call if it was not answered, yet. Cancel a call after it was
    -- answered.
  
  | TOXAV_CALL_CONTROL_MUTE_AUDIO
    -- ^ 
    -- Request that the friend stops sending audio. Regardless of the friend's
    -- compliance, this will cause the ${audio_receive_frame} event to stop being
    -- triggered on receiving an audio frame from the friend.
  
  | TOXAV_CALL_CONTROL_UNMUTE_AUDIO
    -- ^ 
    -- Calling this control will notify client to start sending audio again.
  
  | TOXAV_CALL_CONTROL_HIDE_VIDEO
    -- ^ 
    -- Request that the friend stops sending video. Regardless of the friend's
    -- compliance, this will cause the ${video_receive_frame} event to stop being
    -- triggered on receiving an video frame from the friend.
  
  | TOXAV_CALL_CONTROL_SHOW_VIDEO
    -- ^ 
    -- Calling this control will notify client to start sending video again.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)

data TOXAV_ERR_CALL_CONTROL 

  = TOXAV_ERR_CALL_CONTROL_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOXAV_ERR_CALL_CONTROL_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend_number passed did not designate a valid friend.
  
  | TOXAV_ERR_CALL_CONTROL_FRIEND_NOT_IN_CALL
    -- ^ 
    -- This client is currently not in a call with the friend. Before the call is
    -- answered, only CANCEL is a valid control.
  
  | TOXAV_ERR_CALL_CONTROL_INVALID_TRANSITION
    -- ^ 
    -- Happens if user tried to pause an already paused call or if trying to
    -- resume a call that is not paused.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Sends a call control command to a friend.
--
-- @param friend_number The friend number of the friend this client is in a call
-- with.
-- @param control The control command to send.
--
-- @return true on success.
--foreign import ccall toxav_call_control :: {- av :: -} Ptr ToxAV -> {- friend_number :: -} Word32 -> {- control :: -} TOXAV_CALL_CONTROL -> {- error :: -} Ptr TOXAV_ERR_CALL_CONTROL -> {- result :: -} Bool


--------------------------------------------------------------------------------
-- 
-- :: Controlling bit rates
--
--------------------------------------------------------------------------------



data TOXAV_ERR_SET_BIT_RATE 

  = TOXAV_ERR_SET_BIT_RATE_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOXAV_ERR_SET_BIT_RATE_INVALID
    -- ^ 
    -- The bit rate passed was not one of the supported values.
  
  | TOXAV_ERR_SET_BIT_RATE_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend_number passed did not designate a valid friend.
  
  | TOXAV_ERR_SET_BIT_RATE_FRIEND_NOT_IN_CALL
    -- ^ 
    -- This client is currently not in a call with the friend.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- The function type for the ${audio_bit_rate_status} callback.
-- 
-- @param friend_number The friend number of the friend for which to set the
-- audio bit rate.
-- @param stable Is the stream stable enough to keep the bit rate. 
-- Upon successful, non forceful, bit rate change, this is set to 
-- true and 'bit_rate' is set to new bit rate.
-- The stable is set to false with bit_rate set to the unstable
-- bit rate when either current stream is unstable with said bit rate
-- or the non forceful change failed.
-- @param bit_rate The bit rate in Kb/sec.
--typedef toxav_audio_bit_rate_status_cb = {- av :: -} Ptr ToxAV -> {- friend_number :: -} Word32 -> {- stable :: -} Bool -> {- bit_rate :: -} Word32 -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${audio_bit_rate_status}` event. Pass NULL to unset.
--
--foreign import ccall toxav_callback_audio_bit_rate_status :: {- av :: -} Ptr ToxAV -> {- callback :: -} Ptr toxav_audio_bit_rate_status_cb -> {- user_data :: -} Ptr () -> {- result :: -} ()
-- | 
-- Set the audio bit rate to be used in subsequent audio frames. If the passed 
-- bit rate is the same as the current bit rate this function will return true 
-- without calling a callback. If there is an active non forceful setup with the
-- passed audio bit rate and the new set request is forceful, the bit rate is 
-- forcefully set and the previous non forceful request is cancelled. The active
-- non forceful setup will be canceled in favour of new non forceful setup.
--
-- @param friend_number The friend number of the friend for which to set the
-- audio bit rate.
-- @param audio_bit_rate The new audio bit rate in Kb/sec. Set to 0 to disable
-- audio sending.
-- @param force True if the bit rate change is forceful.
-- 
--foreign import ccall toxav_audio_bit_rate_set :: {- av :: -} Ptr ToxAV -> {- friend_number :: -} Word32 -> {- audio_bit_rate :: -} Word32 -> {- force :: -} Bool -> {- error :: -} Ptr TOXAV_ERR_SET_BIT_RATE -> {- result :: -} Bool
-- | 
-- The function type for the ${video_bit_rate_status} callback.
-- 
-- @param friend_number The friend number of the friend for which to set the
-- video bit rate.
-- @param stable Is the stream stable enough to keep the bit rate. 
-- Upon successful, non forceful, bit rate change, this is set to 
-- true and 'bit_rate' is set to new bit rate.
-- The stable is set to false with bit_rate set to the unstable
-- bit rate when either current stream is unstable with said bit rate
-- or the non forceful change failed.
-- @param bit_rate The bit rate in Kb/sec.
--typedef toxav_video_bit_rate_status_cb = {- av :: -} Ptr ToxAV -> {- friend_number :: -} Word32 -> {- stable :: -} Bool -> {- bit_rate :: -} Word32 -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${video_bit_rate_status}` event. Pass NULL to unset.
--
--foreign import ccall toxav_callback_video_bit_rate_status :: {- av :: -} Ptr ToxAV -> {- callback :: -} Ptr toxav_video_bit_rate_status_cb -> {- user_data :: -} Ptr () -> {- result :: -} ()
-- | 
-- Set the video bit rate to be used in subsequent video frames. If the passed 
-- bit rate is the same as the current bit rate this function will return true 
-- without calling a callback. If there is an active non forceful setup with the
-- passed video bit rate and the new set request is forceful, the bit rate is 
-- forcefully set and the previous non forceful request is cancelled. The active
-- non forceful setup will be canceled in favour of new non forceful setup.
--
-- @param friend_number The friend number of the friend for which to set the
-- video bit rate.
-- @param audio_bit_rate The new video bit rate in Kb/sec. Set to 0 to disable
-- video sending.
-- @param force True if the bit rate change is forceful.
-- 
--foreign import ccall toxav_video_bit_rate_set :: {- av :: -} Ptr ToxAV -> {- friend_number :: -} Word32 -> {- audio_bit_rate :: -} Word32 -> {- force :: -} Bool -> {- error :: -} Ptr TOXAV_ERR_SET_BIT_RATE -> {- result :: -} Bool


--------------------------------------------------------------------------------
-- 
-- :: A/V sending
--
--------------------------------------------------------------------------------



data TOXAV_ERR_SEND_FRAME 

  = TOXAV_ERR_SEND_FRAME_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOXAV_ERR_SEND_FRAME_NULL
    -- ^ 
    -- In case of video, one of Y, U, or V was NULL. In case of audio, the samples
    -- data pointer was NULL.
  
  | TOXAV_ERR_SEND_FRAME_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend_number passed did not designate a valid friend.
  
  | TOXAV_ERR_SEND_FRAME_FRIEND_NOT_IN_CALL
    -- ^ 
    -- This client is currently not in a call with the friend.
  
  | TOXAV_ERR_SEND_FRAME_INVALID
    -- ^ 
    -- One of the frame parameters was invalid. E.g. the resolution may be too
    -- small or too large, or the audio sampling rate may be unsupported.
  
  | TOXAV_ERR_SEND_FRAME_RTP_FAILED
    -- ^ 
    -- Failed to push frame through rtp interface.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Send an audio frame to a friend.
--
-- The expected format of the PCM data is: [s1c1][s1c2][...][s2c1][s2c2][...]...
-- Meaning: sample 1 for channel 1, sample 1 for channel 2, ...
-- For mono audio, this has no meaning, every sample is subsequent. For stereo,
-- this means the expected format is LRLRLR... with samples for left and right
-- alternating.
--
-- @param friend_number The friend number of the friend to which to send an
-- audio frame.
-- @param pcm An array of audio samples. The size of this array must be
-- sample_count * channels.
-- @param sample_count Number of samples in this frame. Valid numbers here are
-- ((sample rate) * (audio length) / 1000), where audio length can be
-- 2.5, 5, 10, 20, 40 or 60 millseconds.
-- @param channels Number of audio channels. Supported values are 1 and 2.
-- @param sampling_rate Audio sampling rate used in this frame. Valid sampling
-- rates are 8000, 12000, 16000, 24000, or 48000.
--foreign import ccall toxav_audio_send_frame :: {- av :: -} Ptr ToxAV -> {- friend_number :: -} Word32 -> {- pcm :: -} Ptr Int16 -> {- sample_count :: -} CSize -> {- channels :: -} Word8 -> {- sampling_rate :: -} Word32 -> {- error :: -} Ptr TOXAV_ERR_SEND_FRAME -> {- result :: -} Bool
-- | 
-- Send a video frame to a friend.
--
-- Y - plane should be of size: height * width
-- U - plane should be of size: (height/2) * (width/2)
-- V - plane should be of size: (height/2) * (width/2)
--
-- @param friend_number The friend number of the friend to which to send a video
-- frame.
-- @param width Width of the frame in pixels.
-- @param height Height of the frame in pixels.
-- @param y Y (Luminance) plane data.
-- @param u U (Chroma) plane data.
-- @param v V (Chroma) plane data.
-- @param a A (Alpha) plane data.
--foreign import ccall toxav_video_send_frame :: {- av :: -} Ptr ToxAV -> {- friend_number :: -} Word32 -> {- width :: -} Word16 -> {- height :: -} Word16 -> {- y :: -} Ptr Word8 -> {- u :: -} Ptr Word8 -> {- v :: -} Ptr Word8 -> {- a :: -} Ptr Word8 -> {- error :: -} Ptr TOXAV_ERR_SEND_FRAME -> {- result :: -} Bool


--------------------------------------------------------------------------------
-- 
-- :: A/V receiving
--
--------------------------------------------------------------------------------


-- | 
-- The function type for the ${audio_receive_frame} callback.
--
-- @param friend_number The friend number of the friend who sent an audio frame.
-- @param pcm An array of audio samples (sample_count * channels elements).
-- @param sample_count The number of audio samples per channel in the PCM array.
-- @param channels Number of audio channels.
-- @param sampling_rate Sampling rate used in this frame.
--
--typedef toxav_audio_receive_frame_cb = {- av :: -} Ptr ToxAV -> {- friend_number :: -} Word32 -> {- pcm :: -} Ptr Int16 -> {- sample_count :: -} CSize -> {- channels :: -} Word8 -> {- sampling_rate :: -} Word32 -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${audio_receive_frame}` event. Pass NULL to unset.
--
--foreign import ccall toxav_callback_audio_receive_frame :: {- av :: -} Ptr ToxAV -> {- callback :: -} Ptr toxav_audio_receive_frame_cb -> {- user_data :: -} Ptr () -> {- result :: -} ()
-- | 
-- The function type for the ${video_receive_frame} callback.
--
-- @param friend_number The friend number of the friend who sent a video frame.
-- @param width Width of the frame in pixels.
-- @param height Height of the frame in pixels.
-- @param y 
-- @param u 
-- @param v Plane data.
--          The size of plane data is derived from width and height where
--          Y = MAX(width, abs(ystride)) * height, 
--          U = MAX(width/2, abs(ustride)) * (height/2) and 
--          V = MAX(width/2, abs(vstride)) * (height/2).
--          A = MAX(width, abs(astride)) * height.
-- @param ystride
-- @param ustride
-- @param vstride
-- @param astride Strides data. Strides represent padding for each plane
--                that may or may not be present. You must handle strides in
--                your image processing code. Strides are negative if the 
--                image is bottom-up hence why you MUST abs() it when
--                calculating plane buffer size.
--typedef toxav_video_receive_frame_cb = {- av :: -} Ptr ToxAV -> {- friend_number :: -} Word32 -> {- width :: -} Word16 -> {- height :: -} Word16 -> {- y :: -} Ptr Word8 -> {- u :: -} Ptr Word8 -> {- v :: -} Ptr Word8 -> {- a :: -} Ptr Word8 -> {- ystride :: -} Int32 -> {- ustride :: -} Int32 -> {- vstride :: -} Int32 -> {- astride :: -} Int32 -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${video_receive_frame}` event. Pass NULL to unset.
--
--foreign import ccall toxav_callback_video_receive_frame :: {- av :: -} Ptr ToxAV -> {- callback :: -} Ptr toxav_video_receive_frame_cb -> {- user_data :: -} Ptr () -> {- result :: -} ()
