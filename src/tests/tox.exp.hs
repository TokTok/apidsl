module Main where

import           Data.Int                  (Int16, Int32, Int64, Int8)
import           Data.Word                 (Word16, Word32, Word64, Word8)
import           Foreign.C.String          (CString, withCString)
import           Foreign.C.Types           (CInt (..), CSize (..))
import           Foreign.Ptr               (FunPtr, Ptr)



--------------------------------------------------------------------------------
-- `tox.h` SHOULD *NOT* BE EDITED MANUALLY – any changes should be made to   *
-- `tox.api.h`, located in `toxcore/`. For instructions on how to            *
-- generate `tox.h` from `tox.api.h` please refer to `docs/apidsl.md`        *
--------------------------------------------------------------------------------


-- |  \page core Public core API for Tox clients.
--
-- Every function that can fail takes a function-specific error code pointer
-- that can be used to diagnose problems with the Tox state or the function
-- arguments. The error code pointer can be NULL, which does not influence the
-- function's behaviour, but can be done if the reason for failure is irrelevant
-- to the client.
--
-- The exception to this rule are simple allocation functions whose only failure
-- mode is allocation failure. They return NULL in that case, and do not set an
-- error code.
--
-- Every error code type has an OK value to which functions will set their error
-- code value on success. Clients can keep their error code uninitialised before
-- passing it to a function. The library guarantees that after returning, the
-- value pointed to by the error code pointer has been initialised.
--
-- Functions with pointer parameters often have a NULL error code, meaning they
-- could not perform any operation, because one of the required parameters was
-- NULL. Some functions operate correctly or are defined as effectless on NULL.
--
-- Some functions additionally return a value outside their
-- return type domain, or a bool containing true on success and false on
-- failure.
--
-- All functions that take a Tox instance pointer will cause undefined behaviour
-- when passed a NULL Tox pointer.
--
-- All integer values are expected in host byte order.
--
-- Functions with parameters with enum types cause unspecified behaviour if the
-- enumeration value is outside the valid range of the type. If possible, the
-- function will try to use a sane default, but there will be no error code,
-- and one possible action for the function to take is to have no effect.
--
-- Integer constants and the memory layout of publicly exposed structs are not
-- part of the ABI.-- |  \subsection events Events and callbacks
--
-- Events are handled by callbacks. One callback can be registered per event.
-- All events have a callback function type named `tox_{event}_cb` and a
-- function to register it named `tox_callback_{event}`. Passing a NULL
-- callback will result in no callback being registered for that event. Only
-- one callback per event can be registered, so if a client needs multiple
-- event listeners, it needs to implement the dispatch functionality itself.
--
-- The last argument to a callback is the user data pointer. It is passed from
-- ${tox_iterate} to each callback in sequence.
--
-- The user data pointer is never stored or dereferenced by any library code, so
-- can be any pointer, including NULL. Callbacks must all operate on the same
-- object type. In the apidsl code (tox.in.h), this is denoted with `any`. The
-- `any` in ${tox_iterate} must be the same `any` as in all callbacks. In C,
-- lacking parametric polymorphism, this is a pointer to void.
--
-- Old style callbacks that are registered together with a user data pointer
-- receive that pointer as argument when they are called. They can each have
-- their own user data pointer of their own type.-- |  \subsection threading Threading implications
--
-- It is possible to run multiple concurrent threads with a Tox instance for
-- each thread. It is also possible to run all Tox instances in the same thread.
-- A common way to run Tox (multiple or single instance) is to have one thread
-- running a simple ${tox_iterate} loop, sleeping for ${tox_iteration_interval}
-- milliseconds on each iteration.
--
-- If you want to access a single Tox instance from multiple threads, access
-- to the instance must be synchronised. While multiple threads can concurrently
-- access multiple different Tox instances, no more than one API function can
-- operate on a single instance at any given time.
--
-- Functions that write to variable length byte arrays will always have a size
-- function associated with them. The result of this size function is only valid
-- until another mutating function (one that takes a pointer to non-const Tox)
-- is called. Thus, clients must ensure that no other thread calls a mutating
-- function between the call to the size function and the call to the retrieval
-- function.
--
-- E.g. to get the current nickname, one would write
--
-- \code
-- size_t length = ${tox_self_get_name_size}(tox);
-- uint8_t *name = malloc(length);
-- if (!name) abort();
-- ${tox_self_get_name}(tox, name);
-- \endcode
--
-- If any other thread calls ${tox_self_set_name} while this thread is allocating
-- memory, the length may have become invalid, and the call to
-- ${tox_self_get_name} may cause undefined behaviour.-- | 
-- The Tox instance type. All the state associated with a connection is held
-- within the instance. Multiple instances can exist and operate concurrently.
-- The maximum number of Tox instances that can exist on a single network
-- device is limited. Note that this is not just a per-process limit, since the
-- limiting factor is the number of usable ports on a device.
--struct Tox


--------------------------------------------------------------------------------
--
-- :: API version
--
--------------------------------------------------------------------------------


-- | 
-- The major version number. Incremented when the API or ABI changes in an
-- incompatible way.
--
-- The function variants of these constants return the version number of the
-- library. They can be used to display the Tox library version or to check
-- whether the client is compatible with the dynamically linked version of Tox.
--const TOX_VERSION_MAJOR = 0

--foreign import ccall tox_version_major :: {- result :: -} Word32
-- | 
-- The minor version number. Incremented when functionality is added without
-- breaking the API or ABI. Set to 0 when the major version number is
-- incremented.
--const TOX_VERSION_MINOR = 0

--foreign import ccall tox_version_minor :: {- result :: -} Word32
-- | 
-- The patch or revision number. Incremented when bugfixes are applied without
-- changing any functionality or API or ABI.
--const TOX_VERSION_PATCH = 5

--foreign import ccall tox_version_patch :: {- result :: -} Word32
-- | 
-- A macro to check at preprocessing time whether the client code is compatible
-- with the installed version of Tox.
#define TOX_VERSION_IS_API_COMPATIBLE(MAJOR, MINOR, PATCH)      \
  (TOX_VERSION_MAJOR == MAJOR &&                                \
   (TOX_VERSION_MINOR > MINOR ||                                \
    (TOX_VERSION_MINOR == MINOR &&                              \
     TOX_VERSION_PATCH >= PATCH)))
-- | 
-- A macro to make compilation fail if the client code is not compatible with
-- the installed version of Tox.
#define TOX_VERSION_REQUIRE(MAJOR, MINOR, PATCH)                \
  typedef char tox_required_version[TOX_IS_COMPATIBLE(MAJOR, MINOR, PATCH) ? 1 : -1]
-- | 
-- Return whether the compiled library version is compatible with the passed
-- version numbers.
--foreign import ccall tox_version_is_compatible :: {- major :: -} Word32 -> {- minor :: -} Word32 -> {- patch :: -} Word32 -> {- result :: -} Bool
-- | 
-- A convenience macro to call tox_version_is_compatible with the currently
-- compiling API version.
#define TOX_VERSION_IS_ABI_COMPATIBLE()                         \
  tox_version_is_compatible(TOX_VERSION_MAJOR, TOX_VERSION_MINOR, TOX_VERSION_PATCH)


--------------------------------------------------------------------------------
--
-- :: Numeric constants
--
-- The values of these are not part of the ABI. Prefer to use the function
-- versions of them for code that should remain compatible with future versions
-- of toxcore.
--
--------------------------------------------------------------------------------


-- | 
-- The size of a Tox Public Key in bytes.
--const TOX_PUBLIC_KEY_SIZE = 32

--foreign import ccall tox_public_key_size :: {- result :: -} Word32
-- | 
-- The size of a Tox Secret Key in bytes.
--const TOX_SECRET_KEY_SIZE = 32

--foreign import ccall tox_secret_key_size :: {- result :: -} Word32
-- | 
-- The size of a Tox address in bytes. Tox addresses are in the format
-- [Public Key (${TOX_PUBLIC_KEY_SIZE} bytes)][nospam (4 bytes)][checksum (2 bytes)].
--
-- The checksum is computed over the Public Key and the nospam value. The first
-- byte is an XOR of all the even bytes (0, 2, 4, ...), the second byte is an
-- XOR of all the odd bytes (1, 3, 5, ...) of the Public Key and nospam.
--const TOX_ADDRESS_SIZE = (TOX_PUBLIC_KEY_SIZE + sizeof(Word32) + sizeof(Word16))

--foreign import ccall tox_address_size :: {- result :: -} Word32
-- | 
-- Maximum length of a nickname in bytes.
--const TOX_MAX_NAME_LENGTH = 128

--foreign import ccall tox_max_name_length :: {- result :: -} Word32
-- | 
-- Maximum length of a status message in bytes.
--const TOX_MAX_STATUS_MESSAGE_LENGTH = 1007

--foreign import ccall tox_max_status_message_length :: {- result :: -} Word32
-- | 
-- Maximum length of a friend request message in bytes.
--const TOX_MAX_FRIEND_REQUEST_LENGTH = 1016

--foreign import ccall tox_max_friend_request_length :: {- result :: -} Word32
-- | 
-- Maximum length of a single message after which it should be split.
--const TOX_MAX_MESSAGE_LENGTH = 1372

--foreign import ccall tox_max_message_length :: {- result :: -} Word32
-- | 
-- Maximum size of custom packets. TODO(iphydf): should be LENGTH?
--const TOX_MAX_CUSTOM_PACKET_SIZE = 1373

--foreign import ccall tox_max_custom_packet_size :: {- result :: -} Word32
-- | 
-- The number of bytes in a hash generated by ${tox_hash}.
--const TOX_HASH_LENGTH = 32

--foreign import ccall tox_hash_length :: {- result :: -} Word32
-- | 
-- The number of bytes in a file id.
--const TOX_FILE_ID_LENGTH = 32

--foreign import ccall tox_file_id_length :: {- result :: -} Word32
-- | 
-- Maximum file name length for file transfers.
--const TOX_MAX_FILENAME_LENGTH = 255

--foreign import ccall tox_max_filename_length :: {- result :: -} Word32


--------------------------------------------------------------------------------
--
-- :: Global enumerations
--
--------------------------------------------------------------------------------


-- | 
-- Represents the possible statuses a client can have.
data TOX_USER_STATUS 

  = TOX_USER_STATUS_NONE
    -- ^ 
    -- User is online and available.
  
  | TOX_USER_STATUS_AWAY
    -- ^ 
    -- User is away. Clients can set this e.g. after a user defined
    -- inactivity time.
  
  | TOX_USER_STATUS_BUSY
    -- ^ 
    -- User is busy. Signals to other clients that this client does not
    -- currently wish to communicate.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Represents message types for ${tox_friend_send_message} and conference
-- messages.
data TOX_MESSAGE_TYPE 

  = TOX_MESSAGE_TYPE_NORMAL
    -- ^ 
    -- Normal text message. Similar to PRIVMSG on IRC.
  
  | TOX_MESSAGE_TYPE_ACTION
    -- ^ 
    -- A message describing an user action. This is similar to /me (CTCP ACTION)
    -- on IRC.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)

data TOX_ERR_ALLOC 

  = TOX_ERR_ALLOC_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_ALLOC_MALLOC
    -- ^ 
    -- The function failed to allocate enough memory for the data structure.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)


--------------------------------------------------------------------------------
--
-- :: Loading/saving of internal state
--
--------------------------------------------------------------------------------


-- | 
-- Calculates the number of bytes required to store the tox instance with
-- ${tox_get_savedata}. This function cannot fail. The result is always greater than 0.
--
-- @see threading for concurrency implications.
--foreign import ccall tox_get_savedata_size :: {- tox :: -} Ptr Tox -> {- result :: -} CSize
-- | 
-- Store all information associated with the tox instance to a byte array.
--
-- @param savedata A memory region large enough to store the tox instance
--   data. Call ${tox_get_savedata_size} to find the number of bytes required. If this parameter
--   is NULL, this function has no effect.
--foreign import ccall tox_get_savedata :: {- tox :: -} Ptr Tox -> {- savedata :: -} Ptr (Word8{-[tox_get_savedata_size]-}) -> {- result :: -} ()
-- | 
-- This struct contains callbacks for the save function. You will probably
-- want to implement all callbacks to produce a useful result.
data ToxSaver = ToxSaver
  
  { u08 :: Ptr tox_saver_u08_cb, u16 :: Ptr tox_saver_u16_cb, u32 :: Ptr tox_saver_u32_cb, u64 :: Ptr tox_saver_u64_cb, arr :: Ptr tox_saver_arr_cb, map :: Ptr tox_saver_map_cb, bin :: Ptr tox_saver_bin_cb}

--foreign import ccall tox_saver_get_u08 :: {- saver :: -} Ptr ToxSaver -> {- result :: -} Ptr tox_saver_u08_cb

--foreign import ccall tox_saver_set_u08 :: {- saver :: -} Ptr ToxSaver -> {- u08 :: -} Ptr tox_saver_u08_cb -> {- result :: -} ()

--foreign import ccall tox_saver_get_u16 :: {- saver :: -} Ptr ToxSaver -> {- result :: -} Ptr tox_saver_u16_cb

--foreign import ccall tox_saver_set_u16 :: {- saver :: -} Ptr ToxSaver -> {- u16 :: -} Ptr tox_saver_u16_cb -> {- result :: -} ()

--foreign import ccall tox_saver_get_u32 :: {- saver :: -} Ptr ToxSaver -> {- result :: -} Ptr tox_saver_u32_cb

--foreign import ccall tox_saver_set_u32 :: {- saver :: -} Ptr ToxSaver -> {- u32 :: -} Ptr tox_saver_u32_cb -> {- result :: -} ()

--foreign import ccall tox_saver_get_u64 :: {- saver :: -} Ptr ToxSaver -> {- result :: -} Ptr tox_saver_u64_cb

--foreign import ccall tox_saver_set_u64 :: {- saver :: -} Ptr ToxSaver -> {- u64 :: -} Ptr tox_saver_u64_cb -> {- result :: -} ()

--foreign import ccall tox_saver_get_arr :: {- saver :: -} Ptr ToxSaver -> {- result :: -} Ptr tox_saver_arr_cb

--foreign import ccall tox_saver_set_arr :: {- saver :: -} Ptr ToxSaver -> {- arr :: -} Ptr tox_saver_arr_cb -> {- result :: -} ()

--foreign import ccall tox_saver_get_map :: {- saver :: -} Ptr ToxSaver -> {- result :: -} Ptr tox_saver_map_cb

--foreign import ccall tox_saver_set_map :: {- saver :: -} Ptr ToxSaver -> {- map :: -} Ptr tox_saver_map_cb -> {- result :: -} ()

--foreign import ccall tox_saver_get_bin :: {- saver :: -} Ptr ToxSaver -> {- result :: -} Ptr tox_saver_bin_cb

--foreign import ccall tox_saver_set_bin :: {- saver :: -} Ptr ToxSaver -> {- bin :: -} Ptr tox_saver_bin_cb -> {- result :: -} ()
-- | 
-- Write an 8 bit unsigned integer.
--typedef tox_saver_u08_cb = {- saver :: -} Ptr ToxSaver -> {- value :: -} Word8 -> {- user_data :: -} <unresolved> -> ()

-- | 
-- Write a 16 bit unsigned integer.
--typedef tox_saver_u16_cb = {- saver :: -} Ptr ToxSaver -> {- value :: -} Word16 -> {- user_data :: -} <unresolved> -> ()

-- | 
-- Write a 32 bit unsigned integer.
--typedef tox_saver_u32_cb = {- saver :: -} Ptr ToxSaver -> {- value :: -} Word32 -> {- user_data :: -} <unresolved> -> ()

-- | 
-- Write a 64 bit unsigned integer.
--typedef tox_saver_u64_cb = {- saver :: -} Ptr ToxSaver -> {- value :: -} Word64 -> {- user_data :: -} <unresolved> -> ()

-- | 
-- Write an array of the given length. This call is followed by exactly
-- `elements` calls to other functions. Arrays may be nested, so each
-- element of the array may be another call to ${tox_saver_arr_cb} with its own element
-- count and subsequent calls.
--typedef tox_saver_arr_cb = {- saver :: -} Ptr ToxSaver -> {- elements :: -} CSize -> {- user_data :: -} <unresolved> -> ()

-- | 
-- Write a list of key/value pairs. A call to this function is followed by
-- `elements * 2` calls to other functions. Every other call is either key
-- or value. Keys can be assumed to be unique.
--typedef tox_saver_map_cb = {- saver :: -} Ptr ToxSaver -> {- elements :: -} CSize -> {- user_data :: -} <unresolved> -> ()

-- | 
-- Write a byte array of a given length.
--typedef tox_saver_bin_cb = {- saver :: -} Ptr ToxSaver -> {- data :: -} Ptr (Word8{-[length]-}) -> {- length :: -} CSize -> {- user_data :: -} <unresolved> -> ()

-- | 
-- Allocates a new ${ToxSaver} object and initialises it with the default
-- handlers.
--
-- Objects returned from this function must be freed using the ${tox_saver_free}
-- function.
--
-- @return A new ${ToxSaver} object with default options or NULL on failure.
--foreign import ccall tox_saver_new :: {- error :: -} Ptr TOX_ERR_ALLOC -> {- result :: -} Ptr ToxSaver
-- | 
-- Releases all resources associated with a saver objects.
--
-- Passing a pointer that was not returned by ${tox_saver_new} results in
-- undefined behaviour.
--foreign import ccall tox_saver_free :: {- saver :: -} Ptr ToxSaver -> {- result :: -} ()

--foreign import ccall tox_save :: {- tox :: -} Ptr Tox -> {- saver :: -} Ptr ToxSaver -> {- user_data :: -} <unresolved> -> {- result :: -} ()
-- | 
-- This struct contains callbacks for the load function. You will probably
-- want to implement all callbacks to produce a useful result.
data ToxLoader = ToxLoader
  
  { u08 :: Ptr tox_loader_u08_cb, u16 :: Ptr tox_loader_u16_cb, u32 :: Ptr tox_loader_u32_cb, u64 :: Ptr tox_loader_u64_cb, arr :: Ptr tox_loader_arr_cb, map :: Ptr tox_loader_map_cb, bin :: Ptr tox_loader_bin_cb}

--foreign import ccall tox_loader_get_u08 :: {- loader :: -} Ptr ToxLoader -> {- result :: -} Ptr tox_loader_u08_cb

--foreign import ccall tox_loader_set_u08 :: {- loader :: -} Ptr ToxLoader -> {- u08 :: -} Ptr tox_loader_u08_cb -> {- result :: -} ()

--foreign import ccall tox_loader_get_u16 :: {- loader :: -} Ptr ToxLoader -> {- result :: -} Ptr tox_loader_u16_cb

--foreign import ccall tox_loader_set_u16 :: {- loader :: -} Ptr ToxLoader -> {- u16 :: -} Ptr tox_loader_u16_cb -> {- result :: -} ()

--foreign import ccall tox_loader_get_u32 :: {- loader :: -} Ptr ToxLoader -> {- result :: -} Ptr tox_loader_u32_cb

--foreign import ccall tox_loader_set_u32 :: {- loader :: -} Ptr ToxLoader -> {- u32 :: -} Ptr tox_loader_u32_cb -> {- result :: -} ()

--foreign import ccall tox_loader_get_u64 :: {- loader :: -} Ptr ToxLoader -> {- result :: -} Ptr tox_loader_u64_cb

--foreign import ccall tox_loader_set_u64 :: {- loader :: -} Ptr ToxLoader -> {- u64 :: -} Ptr tox_loader_u64_cb -> {- result :: -} ()

--foreign import ccall tox_loader_get_arr :: {- loader :: -} Ptr ToxLoader -> {- result :: -} Ptr tox_loader_arr_cb

--foreign import ccall tox_loader_set_arr :: {- loader :: -} Ptr ToxLoader -> {- arr :: -} Ptr tox_loader_arr_cb -> {- result :: -} ()

--foreign import ccall tox_loader_get_map :: {- loader :: -} Ptr ToxLoader -> {- result :: -} Ptr tox_loader_map_cb

--foreign import ccall tox_loader_set_map :: {- loader :: -} Ptr ToxLoader -> {- map :: -} Ptr tox_loader_map_cb -> {- result :: -} ()

--foreign import ccall tox_loader_get_bin :: {- loader :: -} Ptr ToxLoader -> {- result :: -} Ptr tox_loader_bin_cb

--foreign import ccall tox_loader_set_bin :: {- loader :: -} Ptr ToxLoader -> {- bin :: -} Ptr tox_loader_bin_cb -> {- result :: -} ()
-- | 
-- Read an 8 bit unsigned integer.
--typedef tox_loader_u08_cb = {- loader :: -} Ptr ToxLoader -> {- user_data :: -} <unresolved> -> Word8

-- | 
-- Read a 16 bit unsigned integer.
--typedef tox_loader_u16_cb = {- loader :: -} Ptr ToxLoader -> {- user_data :: -} <unresolved> -> Word16

-- | 
-- Read a 32 bit unsigned integer.
--typedef tox_loader_u32_cb = {- loader :: -} Ptr ToxLoader -> {- user_data :: -} <unresolved> -> Word32

-- | 
-- Read a 64 bit unsigned integer.
--typedef tox_loader_u64_cb = {- loader :: -} Ptr ToxLoader -> {- user_data :: -} <unresolved> -> Word64

-- | 
-- Read the an array length. This call is followed by exactly the returned
-- number calls to other functions.
--typedef tox_loader_arr_cb = {- loader :: -} Ptr ToxLoader -> {- user_data :: -} <unresolved> -> CSize

-- | 
-- Read the length of the list of key/value pairs. A call to this function
-- is followed by twice the returned number of calls to other functions.
-- Every other call is either key or value.
--typedef tox_loader_map_cb = {- loader :: -} Ptr ToxLoader -> {- user_data :: -} <unresolved> -> CSize

-- | 
-- Read a byte array of a given length.
--typedef tox_loader_bin_cb = {- loader :: -} Ptr ToxLoader -> {- data :: -} Ptr (Word8{-[length]-}) -> {- length :: -} CSize -> {- user_data :: -} <unresolved> -> ()

-- | 
-- Allocates a new ${ToxLoader} object and initialises it with the default
-- handlers.
--
-- Objects returned from this function must be freed using the ${tox_loader_free}
-- function.
--
-- @return A new ${ToxLoader} object with default options or NULL on failure.
--foreign import ccall tox_loader_new :: {- error :: -} Ptr TOX_ERR_ALLOC -> {- result :: -} Ptr ToxLoader
-- | 
-- Releases all resources associated with a loader objects.
--
-- Passing a pointer that was not returned by ${tox_loader_new} results in
-- undefined behaviour.
--foreign import ccall tox_loader_free :: {- loader :: -} Ptr ToxLoader -> {- result :: -} ()


--------------------------------------------------------------------------------
--
-- :: Startup options
--
--------------------------------------------------------------------------------


-- | 
-- Type of proxy used to connect to TCP relays.
data TOX_PROXY_TYPE 

  = TOX_PROXY_TYPE_NONE
    -- ^ 
    -- Don't use a proxy.
  
  | TOX_PROXY_TYPE_HTTP
    -- ^ 
    -- HTTP proxy using CONNECT.
  
  | TOX_PROXY_TYPE_SOCKS5
    -- ^ 
    -- SOCKS proxy for simple socket pipes.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Type of savedata to create the Tox instance from.
data TOX_SAVEDATA_TYPE 

  = TOX_SAVEDATA_TYPE_NONE
    -- ^ 
    -- No savedata.
  
  | TOX_SAVEDATA_TYPE_TOX_SAVE
    -- ^ 
    -- Savedata is one that was obtained from ${tox_get_savedata}.
  
  | TOX_SAVEDATA_TYPE_SECRET_KEY
    -- ^ 
    -- Savedata is a secret key of length ${TOX_SECRET_KEY_SIZE}.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Severity level of log messages.
data TOX_LOG_LEVEL 

  = TOX_LOG_LEVEL_TRACE
    -- ^ 
    -- Very detailed traces including all network activity.
  
  | TOX_LOG_LEVEL_DEBUG
    -- ^ 
    -- Debug messages such as which port we bind to.
  
  | TOX_LOG_LEVEL_INFO
    -- ^ 
    -- Informational log messages such as video call status changes.
  
  | TOX_LOG_LEVEL_WARNING
    -- ^ 
    -- Warnings about internal inconsistency or logic errors.
  
  | TOX_LOG_LEVEL_ERROR
    -- ^ 
    -- Severe unexpected errors caused by external or internal inconsistency.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- This event is triggered when the toxcore library logs an internal message.
-- This is mostly useful for debugging. This callback can be called from any
-- function, not just ${tox_iterate}. This means the user data lifetime must at
-- least extend between registering and unregistering it or ${tox_kill}.
--
-- Other toxcore modules such as toxav may concurrently call this callback at
-- any time. Thus, user code must make sure it is equipped to handle concurrent
-- execution, e.g. by employing appropriate mutex locking.
--
-- @param level The severity of the log message.
-- @param file The source file from which the message originated.
-- @param line The source line from which the message originated.
-- @param func The function from which the message originated.
-- @param message The log message.
-- @param user_data The user data pointer passed to ${tox_new} in options.
--typedef tox_log_cb = {- tox :: -} Ptr Tox -> {- level :: -} TOX_LOG_LEVEL -> {- file :: -} CString -> {- line :: -} Word32 -> {- func :: -} CString -> {- message :: -} CString -> {- user_data :: -} <unresolved> -> ()

-- | 
-- This struct contains all the startup options for Tox. You can either
-- allocate this object yourself, and pass it to ${tox_options_default}, or call ${tox_options_new} to get
-- a new default options object.
--
-- If you allocate it yourself, be aware that your binary will rely on the
-- memory layout of this struct. In particular, if additional fields are added
-- in future versions of the API, code that allocates it itself will become
-- incompatible.
--
-- @deprecated The memory layout of this struct (size, alignment, and field
-- order) is not part of the ABI. To remain compatible, prefer to use ${tox_options_new} to
-- allocate the object and accessor functions to set the members. The struct
-- will become opaque (i.e. the definition will become private) in v0.1.0.
data ToxOptions = ToxOptions
  
  { ipv6Enabled :: Bool
    -- ^ 
    -- The type of socket to create.
    --
    -- If this is set to false, an IPv4 socket is created, which subsequently
    -- only allows IPv4 communication.
    -- If it is set to true, an IPv6 socket is created, allowing both IPv4 and
    -- IPv6 communication.
  , udpEnabled :: Bool
    -- ^ 
    -- Enable the use of UDP communication when available.
    --
    -- Setting this to false will force Tox to use TCP only. Communications will
    -- need to be relayed through a TCP relay node, potentially slowing them down.
    -- Disabling UDP support is necessary when using anonymous proxies or Tor.
  , proxyType :: TOX_PROXY_TYPE
    -- ^ 
    -- Pass communications through a proxy.
  , proxyHost :: CString
    -- ^ 
    -- The IP address or DNS name of the proxy to be used.
    --
    -- If used, this must be non-NULL and be a valid DNS name. The name must not
    -- exceed 255 characters, and be in a NUL-terminated C string format
    -- (255 chars + 1 NUL byte).
    --
    -- This member is ignored (it can be NULL) if proxy_type is ${TOX_PROXY_TYPE_NONE}.
    --
    -- The data pointed at by this member is owned by the user, so must
    -- outlive the options object.
  , proxyPort :: Word16
    -- ^ 
    -- The port to use to connect to the proxy server.
    --
    -- Ports must be in the range (1, 65535). The value is ignored if
    -- proxy_type is ${TOX_PROXY_TYPE_NONE}.
  , startPort :: Word16
    -- ^ 
    -- The start port of the inclusive port range to attempt to use.
    --
    -- If both start_port and end_port are 0, the default port range will be
    -- used: [33445, 33545].
    --
    -- If either start_port or end_port is 0 while the other is non-zero, the
    -- non-zero port will be the only port in the range.
    --
    -- Having start_port > end_port will yield the same behavior as if start_port
    -- and end_port were swapped.
  , endPort :: Word16
    -- ^ 
    -- The end port of the inclusive port range to attempt to use.
  , tcpPort :: Word16
    -- ^ 
    -- The port to use for the TCP server (relay). If 0, the TCP server is
    -- disabled.
    --
    -- Enabling it is not required for Tox to function properly.
    --
    -- When enabled, your Tox instance can act as a TCP relay for other Tox
    -- instance. This leads to increased traffic, thus when writing a client
    -- it is recommended to enable TCP server only if the user has an option
    -- to disable it.
  , holePunchingEnabled :: Bool
    -- ^ 
    -- Enables or disables UDP hole-punching in toxcore. (Default: enabled).
  , savedataType :: TOX_SAVEDATA_TYPE
    -- ^ 
    -- The type of savedata to load from.
  , savedataData :: Ptr (Word8{-[savedataLength]-})
    -- ^ 
    -- The savedata.
    --
    -- The data pointed at by this member is owned by the user, so must
    -- outlive the options object.
  , savedataLength :: CSize
    -- ^ 
    -- The length of the savedata.
  , logCallback :: Ptr tox_log_cb
    -- ^ 
    -- Logging callback for the new tox instance.
  , logUserData :: <unresolved>
    -- ^ 
    -- User data pointer passed to the logging callback.
  , loadCallbacks :: Ptr ToxLoader
    -- ^ 
    -- An implementation of the loader interface specified in ${ToxLoader}.
  , loadUserData :: <unresolved>
    -- ^ 
    -- User data pointer passed to each of the loader callbacks.
  }

--foreign import ccall tox_options_get_ipv6_enabled :: {- options :: -} Ptr ToxOptions -> {- result :: -} Bool

--foreign import ccall tox_options_set_ipv6_enabled :: {- options :: -} Ptr ToxOptions -> {- ipv6_enabled :: -} Bool -> {- result :: -} ()

--foreign import ccall tox_options_get_udp_enabled :: {- options :: -} Ptr ToxOptions -> {- result :: -} Bool

--foreign import ccall tox_options_set_udp_enabled :: {- options :: -} Ptr ToxOptions -> {- udp_enabled :: -} Bool -> {- result :: -} ()

--foreign import ccall tox_options_get_proxy_type :: {- options :: -} Ptr ToxOptions -> {- result :: -} TOX_PROXY_TYPE

--foreign import ccall tox_options_set_proxy_type :: {- options :: -} Ptr ToxOptions -> {- type :: -} TOX_PROXY_TYPE -> {- result :: -} ()

--foreign import ccall tox_options_get_proxy_host :: {- options :: -} Ptr ToxOptions -> {- result :: -} CString

--foreign import ccall tox_options_set_proxy_host :: {- options :: -} Ptr ToxOptions -> {- host :: -} CString -> {- result :: -} ()

--foreign import ccall tox_options_get_proxy_port :: {- options :: -} Ptr ToxOptions -> {- result :: -} Word16

--foreign import ccall tox_options_set_proxy_port :: {- options :: -} Ptr ToxOptions -> {- port :: -} Word16 -> {- result :: -} ()

--foreign import ccall tox_options_get_start_port :: {- options :: -} Ptr ToxOptions -> {- result :: -} Word16

--foreign import ccall tox_options_set_start_port :: {- options :: -} Ptr ToxOptions -> {- start_port :: -} Word16 -> {- result :: -} ()

--foreign import ccall tox_options_get_end_port :: {- options :: -} Ptr ToxOptions -> {- result :: -} Word16

--foreign import ccall tox_options_set_end_port :: {- options :: -} Ptr ToxOptions -> {- end_port :: -} Word16 -> {- result :: -} ()

--foreign import ccall tox_options_get_tcp_port :: {- options :: -} Ptr ToxOptions -> {- result :: -} Word16

--foreign import ccall tox_options_set_tcp_port :: {- options :: -} Ptr ToxOptions -> {- tcp_port :: -} Word16 -> {- result :: -} ()

--foreign import ccall tox_options_get_hole_punching_enabled :: {- options :: -} Ptr ToxOptions -> {- result :: -} Bool

--foreign import ccall tox_options_set_hole_punching_enabled :: {- options :: -} Ptr ToxOptions -> {- hole_punching_enabled :: -} Bool -> {- result :: -} ()

--foreign import ccall tox_options_get_savedata_type :: {- options :: -} Ptr ToxOptions -> {- result :: -} TOX_SAVEDATA_TYPE

--foreign import ccall tox_options_set_savedata_type :: {- options :: -} Ptr ToxOptions -> {- type :: -} TOX_SAVEDATA_TYPE -> {- result :: -} ()

--foreign import ccall tox_options_get_savedata_data :: {- options :: -} Ptr ToxOptions -> {- result :: -} Ptr (Word8{-[<unresolved>]-})

--foreign import ccall tox_options_set_savedata_data :: {- options :: -} Ptr ToxOptions -> {- data :: -} Ptr (Word8{-[length]-}) -> {- length :: -} CSize -> {- result :: -} ()

--foreign import ccall tox_options_get_savedata_length :: {- options :: -} Ptr ToxOptions -> {- result :: -} CSize

--foreign import ccall tox_options_set_savedata_length :: {- options :: -} Ptr ToxOptions -> {- length :: -} CSize -> {- result :: -} ()

--foreign import ccall tox_options_get_log_callback :: {- options :: -} Ptr ToxOptions -> {- result :: -} Ptr tox_log_cb

--foreign import ccall tox_options_set_log_callback :: {- options :: -} Ptr ToxOptions -> {- callback :: -} Ptr tox_log_cb -> {- result :: -} ()

--foreign import ccall tox_options_get_log_user_data :: {- options :: -} Ptr ToxOptions -> {- result :: -} <unresolved>

--foreign import ccall tox_options_set_log_user_data :: {- options :: -} Ptr ToxOptions -> {- user_data :: -} <unresolved> -> {- result :: -} ()

--foreign import ccall tox_options_get_load_callbacks :: {- options :: -} Ptr ToxOptions -> {- result :: -} Ptr ToxLoader

--foreign import ccall tox_options_set_load_callbacks :: {- options :: -} Ptr ToxOptions -> {- callbacks :: -} Ptr ToxLoader -> {- result :: -} ()

--foreign import ccall tox_options_get_load_user_data :: {- options :: -} Ptr ToxOptions -> {- result :: -} <unresolved>

--foreign import ccall tox_options_set_load_user_data :: {- options :: -} Ptr ToxOptions -> {- user_data :: -} <unresolved> -> {- result :: -} ()
-- | 
-- Initialises a ${ToxOptions} object with the default options.
--
-- The result of this function is independent of the original options. All
-- values will be overwritten, no values will be read (so it is permissible
-- to pass an uninitialised object).
--
-- If options is NULL, this function has no effect.
--
-- @param options An options object to be filled with default options.
--foreign import ccall tox_options_default :: {- options :: -} Ptr ToxOptions -> {- result :: -} ()
-- | 
-- Allocates a new ${ToxOptions} object and initialises it with the default
-- options. This function can be used to preserve long term ABI compatibility by
-- giving the responsibility of allocation and deallocation to the Tox library.
--
-- Objects returned from this function must be freed using the ${tox_options_free}
-- function.
--
-- @return A new ${ToxOptions} object with default options or NULL on failure.
--foreign import ccall tox_options_new :: {- error :: -} Ptr TOX_ERR_ALLOC -> {- result :: -} Ptr ToxOptions
-- | 
-- Releases all resources associated with an options objects.
--
-- Passing a pointer that was not returned by ${tox_options_new} results in
-- undefined behaviour.
--foreign import ccall tox_options_free :: {- options :: -} Ptr ToxOptions -> {- result :: -} ()


--------------------------------------------------------------------------------
--
-- :: Creation and destruction
--
--------------------------------------------------------------------------------



data TOX_ERR_NEW 

  = TOX_ERR_NEW_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_NEW_NULL
    -- ^ 
    -- One of the arguments to the function was NULL when it was not expected.
  
  | TOX_ERR_NEW_MALLOC
    -- ^ 
    -- The function was unable to allocate enough memory to store the internal
    -- structures for the Tox object.
  
  | TOX_ERR_NEW_PORT_ALLOC
    -- ^ 
    -- The function was unable to bind to a port. This may mean that all ports
    -- have already been bound, e.g. by other Tox instances, or it may mean
    -- a permission error. You may be able to gather more information from errno.
  
  | TOX_ERR_NEW_PROXY_BAD_TYPE
    -- ^ 
    -- proxy_type was invalid.
  
  | TOX_ERR_NEW_PROXY_BAD_HOST
    -- ^ 
    -- proxy_type was valid but the proxy_host passed had an invalid format
    -- or was NULL.
  
  | TOX_ERR_NEW_PROXY_BAD_PORT
    -- ^ 
    -- proxy_type was valid, but the proxy_port was invalid.
  
  | TOX_ERR_NEW_PROXY_NOT_FOUND
    -- ^ 
    -- The proxy address passed could not be resolved.
  
  | TOX_ERR_NEW_LOAD_ENCRYPTED
    -- ^ 
    -- The byte array to be loaded contained an encrypted save.
  
  | TOX_ERR_NEW_LOAD_BAD_FORMAT
    -- ^ 
    -- The data format was invalid. This can happen when loading data that was
    -- saved by an older version of Tox, or when the data has been corrupted.
    -- When loading from badly formatted data, some data may have been loaded,
    -- and the rest is discarded. Passing an invalid length parameter also
    -- causes this error.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- @brief Creates and initialises a new Tox instance with the options passed.
--
-- This function will bring the instance into a valid state. Running the event
-- loop with a new instance will operate correctly.
--
-- If loading failed or succeeded only partially, the new or partially loaded
-- instance is returned and an error code is set.
--
-- @param options An options object as described above. If this parameter is
--   NULL, the default options are used.
--
-- @see ${tox_iterate} for the event loop.
--
-- @return A new Tox instance pointer on success or NULL on failure.
--foreign import ccall tox_new :: {- options :: -} Ptr ToxOptions -> {- error :: -} Ptr TOX_ERR_NEW -> {- result :: -} Ptr Tox
-- | 
-- Releases all resources associated with the Tox instance and disconnects from
-- the network.
--
-- After calling this function, the Tox pointer becomes invalid. No other
-- functions can be called, and the pointer value can no longer be read.
--foreign import ccall tox_kill :: {- tox :: -} Ptr Tox -> {- result :: -} ()


--------------------------------------------------------------------------------
--
-- :: Connection lifecycle and event loop
--
--------------------------------------------------------------------------------



data TOX_ERR_BOOTSTRAP 

  = TOX_ERR_BOOTSTRAP_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_BOOTSTRAP_NULL
    -- ^ 
    -- One of the arguments to the function was NULL when it was not expected.
  
  | TOX_ERR_BOOTSTRAP_BAD_HOST
    -- ^ 
    -- The address could not be resolved to an IP address, or the IP address
    -- passed was invalid.
  
  | TOX_ERR_BOOTSTRAP_BAD_PORT
    -- ^ 
    -- The port passed was invalid. The valid port range is (1, 65535).
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Sends a "get nodes" request to the given bootstrap node with IP, port, and
-- public key to setup connections.
--
-- This function will attempt to connect to the node using UDP. You must use
-- this function even if ${ToxOptions}.${udpEnabled} was set to false.
--
-- @param address The hostname or IP address (IPv4 or IPv6) of the node.
-- @param port The port on the host on which the bootstrap Tox instance is
--   listening.
-- @param public_key The long term public key of the bootstrap node
--   (${TOX_PUBLIC_KEY_SIZE} bytes).
-- @return true on success.
--foreign import ccall tox_bootstrap :: {- tox :: -} Ptr Tox -> {- address :: -} CString -> {- port :: -} Word16 -> {- public_key :: -} Ptr (Word8{-[TOX_PUBLIC_KEY_SIZE]-}) -> {- error :: -} Ptr TOX_ERR_BOOTSTRAP -> {- result :: -} Bool
-- | 
-- Adds additional host:port pair as TCP relay.
--
-- This function can be used to initiate TCP connections to different ports on
-- the same bootstrap node, or to add TCP relays without using them as
-- bootstrap nodes.
--
-- @param address The hostname or IP address (IPv4 or IPv6) of the TCP relay.
-- @param port The port on the host on which the TCP relay is listening.
-- @param public_key The long term public key of the TCP relay
--   (${TOX_PUBLIC_KEY_SIZE} bytes).
-- @return true on success.
--foreign import ccall tox_add_tcp_relay :: {- tox :: -} Ptr Tox -> {- address :: -} CString -> {- port :: -} Word16 -> {- public_key :: -} Ptr (Word8{-[TOX_PUBLIC_KEY_SIZE]-}) -> {- error :: -} Ptr TOX_ERR_BOOTSTRAP -> {- result :: -} Bool
-- | 
-- Protocols that can be used to connect to the network or friends.
data TOX_CONNECTION 

  = TOX_CONNECTION_NONE
    -- ^ 
    -- There is no connection. This instance, or the friend the state change is
    -- about, is now offline.
  
  | TOX_CONNECTION_TCP
    -- ^ 
    -- A TCP connection has been established. For the own instance, this means it
    -- is connected through a TCP relay, only. For a friend, this means that the
    -- connection to that particular friend goes through a TCP relay.
  
  | TOX_CONNECTION_UDP
    -- ^ 
    -- A UDP connection has been established. For the own instance, this means it
    -- is able to send UDP packets to DHT nodes, but may still be connected to
    -- a TCP relay. For a friend, this means that the connection to that
    -- particular friend was built using direct UDP packets.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Return whether we are connected to the DHT. The return value is equal to the
-- last value received through the `${self_connection_status}` callback.
--foreign import ccall tox_self_get_connection_status :: {- tox :: -} Ptr Tox -> {- result :: -} TOX_CONNECTION
-- | 
-- @param connection_status Whether we are connected to the DHT.
--typedef tox_self_connection_status_cb = {- tox :: -} Ptr Tox -> {- connection_status :: -} TOX_CONNECTION -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${self_connection_status}` event. Pass NULL to unset.
--
-- This event is triggered whenever there is a change in the DHT connection
-- state. When disconnected, a client may choose to call ${tox_bootstrap} again, to
-- reconnect to the DHT. Note that this state may frequently change for short
-- amounts of time. Clients should therefore not immediately bootstrap on
-- receiving a disconnect.
--
-- TODO(iphydf): how long should a client wait before bootstrapping again?
--foreign import ccall tox_callback_self_connection_status :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_self_connection_status_cb -> {- result :: -} ()
-- | 
-- Return the time in milliseconds before ${tox_iterate}() should be called again
-- for optimal performance.
--foreign import ccall tox_iteration_interval :: {- tox :: -} Ptr Tox -> {- result :: -} Word32
-- | 
-- The main loop that needs to be run in intervals of ${tox_iteration_interval}()
-- milliseconds.
--foreign import ccall tox_iterate :: {- tox :: -} Ptr Tox -> {- user_data :: -} <unresolved> -> {- result :: -} ()


--------------------------------------------------------------------------------
--
-- :: Internal client information (Tox address/id)
--
--------------------------------------------------------------------------------


-- | 
-- Writes the Tox friend address of the client to a byte array. The address is
-- not in human-readable format. If a client wants to display the address,
-- formatting is required.
--
-- @param address A memory region of at least ${TOX_ADDRESS_SIZE} bytes. If this
--   parameter is NULL, this function has no effect.
-- @see ${TOX_ADDRESS_SIZE} for the address format.
--foreign import ccall tox_self_get_address :: {- tox :: -} Ptr Tox -> {- address :: -} Ptr (Word8{-[TOX_ADDRESS_SIZE]-}) -> {- result :: -} ()
-- | 
-- Set the 4-byte nospam part of the address. This value is expected in host
-- byte order. I.e. 0x12345678 will form the bytes [12, 34, 56, 78] in the
-- nospam part of the Tox friend address.
--
-- @param nospam Any 32 bit unsigned integer.
--foreign import ccall tox_self_set_nospam :: {- tox :: -} Ptr Tox -> {- nospam :: -} Word32 -> {- result :: -} ()
-- | 
-- Get the 4-byte nospam part of the address. This value is returned in host
-- byte order.
--foreign import ccall tox_self_get_nospam :: {- tox :: -} Ptr Tox -> {- result :: -} Word32
-- | 
-- Copy the Tox Public Key (long term) from the Tox object.
--
-- @param public_key A memory region of at least ${TOX_PUBLIC_KEY_SIZE} bytes. If
--   this parameter is NULL, this function has no effect.
--foreign import ccall tox_self_get_public_key :: {- tox :: -} Ptr Tox -> {- public_key :: -} Ptr (Word8{-[TOX_PUBLIC_KEY_SIZE]-}) -> {- result :: -} ()
-- | 
-- Copy the Tox Secret Key from the Tox object.
--
-- @param secret_key A memory region of at least ${TOX_SECRET_KEY_SIZE} bytes. If
--   this parameter is NULL, this function has no effect.
--foreign import ccall tox_self_get_secret_key :: {- tox :: -} Ptr Tox -> {- secret_key :: -} Ptr (Word8{-[TOX_SECRET_KEY_SIZE]-}) -> {- result :: -} ()


--------------------------------------------------------------------------------
--
-- :: User-visible client information (nickname/status)
--
--------------------------------------------------------------------------------


-- | 
-- Common error codes for all functions that set a piece of user-visible
-- client information.
data TOX_ERR_SET_INFO 

  = TOX_ERR_SET_INFO_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_SET_INFO_NULL
    -- ^ 
    -- One of the arguments to the function was NULL when it was not expected.
  
  | TOX_ERR_SET_INFO_TOO_LONG
    -- ^ 
    -- Information length exceeded maximum permissible size.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Set the nickname for the Tox client.
--
-- Nickname length cannot exceed ${TOX_MAX_NAME_LENGTH}. If length is 0, the name
-- parameter is ignored (it can be NULL), and the nickname is set back to empty.
--
-- @param name A byte array containing the new nickname.
-- @param length The size of the name byte array.
--
-- @return true on success.
--foreign import ccall tox_self_set_name :: {- tox :: -} Ptr Tox -> {- name :: -} Ptr (Word8{-[length <= TOX_MAX_NAME_LENGTH]-}) -> {- length :: -} CSize -> {- error :: -} Ptr TOX_ERR_SET_INFO -> {- result :: -} Bool
-- | 
-- Return the length of the current nickname as passed to ${tox_self_set_name}.
--
-- If no nickname was set before calling this function, the name is empty,
-- and this function returns 0.
--
-- @see threading for concurrency implications.
--foreign import ccall tox_self_get_name_size :: {- tox :: -} Ptr Tox -> {- result :: -} CSize
-- | 
-- Write the nickname set by ${tox_self_set_name} to a byte array.
--
-- If no nickname was set before calling this function, the name is empty,
-- and this function has no effect.
--
-- Call ${tox_self_get_name_size} to find out how much memory to allocate for
-- the result.
--
-- @param name A valid memory location large enough to hold the nickname.
--   If this parameter is NULL, the function has no effect.
--foreign import ccall tox_self_get_name :: {- tox :: -} Ptr Tox -> {- name :: -} Ptr (Word8{-[<unresolved> <= TOX_MAX_NAME_LENGTH]-}) -> {- result :: -} ()
-- | 
-- Set the client's status message.
--
-- Status message length cannot exceed ${TOX_MAX_STATUS_MESSAGE_LENGTH}. If
-- length is 0, the status parameter is ignored (it can be NULL), and the
-- user status is set back to empty.
--foreign import ccall tox_self_set_status_message :: {- tox :: -} Ptr Tox -> {- status_message :: -} Ptr (Word8{-[length <= TOX_MAX_STATUS_MESSAGE_LENGTH]-}) -> {- length :: -} CSize -> {- error :: -} Ptr TOX_ERR_SET_INFO -> {- result :: -} Bool
-- | 
-- Return the length of the current status message as passed to ${tox_self_set_status_message}.
--
-- If no status message was set before calling this function, the status
-- is empty, and this function returns 0.
--
-- @see threading for concurrency implications.
--foreign import ccall tox_self_get_status_message_size :: {- tox :: -} Ptr Tox -> {- result :: -} CSize
-- | 
-- Write the status message set by ${tox_self_set_status_message} to a byte array.
--
-- If no status message was set before calling this function, the status is
-- empty, and this function has no effect.
--
-- Call ${tox_self_get_status_message_size} to find out how much memory to allocate for
-- the result.
--
-- @param status_message A valid memory location large enough to hold the
--   status message. If this parameter is NULL, the function has no effect.
--foreign import ccall tox_self_get_status_message :: {- tox :: -} Ptr Tox -> {- status_message :: -} Ptr (Word8{-[<unresolved> <= TOX_MAX_STATUS_MESSAGE_LENGTH]-}) -> {- result :: -} ()
-- | 
-- Set the client's user status.
--
-- @param status One of the user statuses listed in the enumeration above.
--foreign import ccall tox_self_set_status :: {- tox :: -} Ptr Tox -> {- status :: -} TOX_USER_STATUS -> {- result :: -} ()
-- | 
-- Returns the client's user status.
--foreign import ccall tox_self_get_status :: {- tox :: -} Ptr Tox -> {- result :: -} TOX_USER_STATUS


--------------------------------------------------------------------------------
--
-- :: Friend list management
--
--------------------------------------------------------------------------------



data TOX_ERR_FRIEND_ADD 

  = TOX_ERR_FRIEND_ADD_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_FRIEND_ADD_NULL
    -- ^ 
    -- One of the arguments to the function was NULL when it was not expected.
  
  | TOX_ERR_FRIEND_ADD_TOO_LONG
    -- ^ 
    -- The length of the friend request message exceeded
    -- ${TOX_MAX_FRIEND_REQUEST_LENGTH}.
  
  | TOX_ERR_FRIEND_ADD_NO_MESSAGE
    -- ^ 
    -- The friend request message was empty. This, and the TOO_LONG code will
    -- never be returned from ${tox_friend_add_norequest}.
  
  | TOX_ERR_FRIEND_ADD_OWN_KEY
    -- ^ 
    -- The friend address belongs to the sending client.
  
  | TOX_ERR_FRIEND_ADD_ALREADY_SENT
    -- ^ 
    -- A friend request has already been sent, or the address belongs to a friend
    -- that is already on the friend list.
  
  | TOX_ERR_FRIEND_ADD_BAD_CHECKSUM
    -- ^ 
    -- The friend address checksum failed.
  
  | TOX_ERR_FRIEND_ADD_SET_NEW_NOSPAM
    -- ^ 
    -- The friend was already there, but the nospam value was different.
  
  | TOX_ERR_FRIEND_ADD_MALLOC
    -- ^ 
    -- A memory allocation failed when trying to increase the friend list size.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Add a friend to the friend list and send a friend request.
--
-- A friend request message must be at least 1 byte long and at most
-- ${TOX_MAX_FRIEND_REQUEST_LENGTH}.
--
-- Friend numbers are unique identifiers used in all functions that operate on
-- friends. Once added, a friend number is stable for the lifetime of the Tox
-- object. After saving the state and reloading it, the friend numbers may not
-- be the same as before. Deleting a friend creates a gap in the friend number
-- set, which is filled by the next adding of a friend. Any pattern in friend
-- numbers should not be relied on.
--
-- If more than INT32_MAX friends are added, this function causes undefined
-- behaviour.
--
-- @param address The address of the friend (returned by ${tox_self_get_address} of
--   the friend you wish to add) it must be ${TOX_ADDRESS_SIZE} bytes.
-- @param message The message that will be sent along with the friend request.
-- @param length The length of the data byte array.
--
-- @return the friend number on success, UINT32_MAX on failure.
--foreign import ccall tox_friend_add :: {- tox :: -} Ptr Tox -> {- address :: -} Ptr (Word8{-[TOX_ADDRESS_SIZE]-}) -> {- message :: -} Ptr (Word8{-[length <= TOX_MAX_FRIEND_REQUEST_LENGTH]-}) -> {- length :: -} CSize -> {- error :: -} Ptr TOX_ERR_FRIEND_ADD -> {- result :: -} Word32
-- | 
-- Add a friend without sending a friend request.
--
-- This function is used to add a friend in response to a friend request. If the
-- client receives a friend request, it can be reasonably sure that the other
-- client added this client as a friend, eliminating the need for a friend
-- request.
--
-- This function is also useful in a situation where both instances are
-- controlled by the same entity, so that this entity can perform the mutual
-- friend adding. In this case, there is no need for a friend request, either.
--
-- @param public_key A byte array of length ${TOX_PUBLIC_KEY_SIZE} containing the
--   Public Key (not the Address) of the friend to add.
--
-- @return the friend number on success, UINT32_MAX on failure.
-- @see ${tox_friend_add} for a more detailed description of friend numbers.
--foreign import ccall tox_friend_add_norequest :: {- tox :: -} Ptr Tox -> {- public_key :: -} Ptr (Word8{-[TOX_PUBLIC_KEY_SIZE]-}) -> {- error :: -} Ptr TOX_ERR_FRIEND_ADD -> {- result :: -} Word32

data TOX_ERR_FRIEND_DELETE 

  = TOX_ERR_FRIEND_DELETE_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_FRIEND_DELETE_FRIEND_NOT_FOUND
    -- ^ 
    -- There was no friend with the given friend number. No friends were deleted.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Remove a friend from the friend list.
--
-- This does not notify the friend of their deletion. After calling this
-- function, this client will appear offline to the friend and no communication
-- can occur between the two.
--
-- @param friend_number Friend number for the friend to be deleted.
--
-- @return true on success.
--foreign import ccall tox_friend_delete :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- error :: -} Ptr TOX_ERR_FRIEND_DELETE -> {- result :: -} Bool


--------------------------------------------------------------------------------
--
-- :: Friend list queries
--
--------------------------------------------------------------------------------



data TOX_ERR_FRIEND_BY_PUBLIC_KEY 

  = TOX_ERR_FRIEND_BY_PUBLIC_KEY_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_FRIEND_BY_PUBLIC_KEY_NULL
    -- ^ 
    -- One of the arguments to the function was NULL when it was not expected.
  
  | TOX_ERR_FRIEND_BY_PUBLIC_KEY_NOT_FOUND
    -- ^ 
    -- No friend with the given Public Key exists on the friend list.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Return the friend number associated with that Public Key.
--
-- @return the friend number on success, UINT32_MAX on failure.
-- @param public_key A byte array containing the Public Key.
--foreign import ccall tox_friend_by_public_key :: {- tox :: -} Ptr Tox -> {- public_key :: -} Ptr (Word8{-[TOX_PUBLIC_KEY_SIZE]-}) -> {- error :: -} Ptr TOX_ERR_FRIEND_BY_PUBLIC_KEY -> {- result :: -} Word32
-- | 
-- Checks if a friend with the given friend number exists and returns true if
-- it does.
--foreign import ccall tox_friend_exists :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- result :: -} Bool
-- | 
-- Return the number of friends on the friend list.
--
-- This function can be used to determine how much memory to allocate for
-- ${tox_self_get_friend_list}.
--foreign import ccall tox_self_get_friend_list_size :: {- tox :: -} Ptr Tox -> {- result :: -} CSize
-- | 
-- Copy a list of valid friend numbers into an array.
--
-- Call ${tox_self_get_friend_list_size} to determine the number of elements to allocate.
--
-- @param friend_list A memory region with enough space to hold the friend
--   list. If this parameter is NULL, this function has no effect.
--foreign import ccall tox_self_get_friend_list :: {- tox :: -} Ptr Tox -> {- friend_list :: -} Ptr (Word32{-[tox_self_get_friend_list_size]-}) -> {- result :: -} ()

data TOX_ERR_FRIEND_GET_PUBLIC_KEY 

  = TOX_ERR_FRIEND_GET_PUBLIC_KEY_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_FRIEND_GET_PUBLIC_KEY_FRIEND_NOT_FOUND
    -- ^ 
    -- No friend with the given number exists on the friend list.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Copies the Public Key associated with a given friend number to a byte array.
--
-- @param friend_number The friend number you want the Public Key of.
-- @param public_key A memory region of at least ${TOX_PUBLIC_KEY_SIZE} bytes. If
--   this parameter is NULL, this function has no effect.
--
-- @return true on success.
--foreign import ccall tox_friend_get_public_key :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- public_key :: -} Ptr (Word8{-[TOX_PUBLIC_KEY_SIZE]-}) -> {- error :: -} Ptr TOX_ERR_FRIEND_GET_PUBLIC_KEY -> {- result :: -} Bool

data TOX_ERR_FRIEND_GET_LAST_ONLINE 

  = TOX_ERR_FRIEND_GET_LAST_ONLINE_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_FRIEND_GET_LAST_ONLINE_FRIEND_NOT_FOUND
    -- ^ 
    -- No friend with the given number exists on the friend list.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Return a unix-time timestamp of the last time the friend associated with a given
-- friend number was seen online. This function will return UINT64_MAX on error.
--
-- @param friend_number The friend number you want to query.
--foreign import ccall tox_friend_get_last_online :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- error :: -} Ptr TOX_ERR_FRIEND_GET_LAST_ONLINE -> {- result :: -} Word64


--------------------------------------------------------------------------------
--
-- :: Friend-specific state queries (can also be received through callbacks)
--
--------------------------------------------------------------------------------


-- | 
-- Common error codes for friend state query functions.
data TOX_ERR_FRIEND_QUERY 

  = TOX_ERR_FRIEND_QUERY_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_FRIEND_QUERY_NULL
    -- ^ 
    -- The pointer parameter for storing the query result (name, message) was
    -- NULL. Unlike the `_self_` variants of these functions, which have no effect
    -- when a parameter is NULL, these functions return an error in that case.
  
  | TOX_ERR_FRIEND_QUERY_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend_number did not designate a valid friend.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Return the length of the friend's name. If the friend number is invalid, the
-- return value is unspecified.
--
-- The return value is equal to the `length` argument received by the last
-- `${friend_name}` callback.
--foreign import ccall tox_friend_get_name_size :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- error :: -} Ptr TOX_ERR_FRIEND_QUERY -> {- result :: -} CSize
-- | 
-- Write the name of the friend designated by the given friend number to a byte
-- array.
--
-- Call ${tox_friend_get_name_size} to determine the allocation size for the `name`
-- parameter.
--
-- The data written to `name` is equal to the data received by the last
-- `${friend_name}` callback.
--
-- @param name A valid memory region large enough to store the friend's name.
--
-- @return true on success.
--foreign import ccall tox_friend_get_name :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- name :: -} Ptr (Word8{-[<unresolved> <= TOX_MAX_NAME_LENGTH]-}) -> {- error :: -} Ptr TOX_ERR_FRIEND_QUERY -> {- result :: -} Bool
-- | 
-- @param friend_number The friend number of the friend whose name changed.
-- @param name A byte array containing the same data as
--   ${tox_friend_get_name} would write to its `name` parameter.
-- @param length A value equal to the return value of
--   ${tox_friend_get_name_size}.
--typedef tox_friend_name_cb = {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- name :: -} Ptr (Word8{-[length <= TOX_MAX_NAME_LENGTH]-}) -> {- length :: -} CSize -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${friend_name}` event. Pass NULL to unset.
--
-- This event is triggered when a friend changes their name.
--foreign import ccall tox_callback_friend_name :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_friend_name_cb -> {- result :: -} ()
-- | 
-- Return the length of the friend's status message. If the friend number is
-- invalid, the return value is SIZE_MAX.
--foreign import ccall tox_friend_get_status_message_size :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- error :: -} Ptr TOX_ERR_FRIEND_QUERY -> {- result :: -} CSize
-- | 
-- Write the status message of the friend designated by the given friend number to a byte
-- array.
--
-- Call ${tox_friend_get_status_message_size} to determine the allocation size for the `status_name`
-- parameter.
--
-- The data written to `status_message` is equal to the data received by the last
-- `${friend_status_message}` callback.
--
-- @param status_message A valid memory region large enough to store the friend's status message.
--foreign import ccall tox_friend_get_status_message :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- status_message :: -} Ptr (Word8{-[<unresolved> <= TOX_MAX_STATUS_MESSAGE_LENGTH]-}) -> {- error :: -} Ptr TOX_ERR_FRIEND_QUERY -> {- result :: -} Bool
-- | 
-- @param friend_number The friend number of the friend whose status message
--   changed.
-- @param message A byte array containing the same data as
--   ${tox_friend_get_status_message} would write to its `status_message` parameter.
-- @param length A value equal to the return value of
--   ${tox_friend_get_status_message_size}.
--typedef tox_friend_status_message_cb = {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- message :: -} Ptr (Word8{-[length <= TOX_MAX_STATUS_MESSAGE_LENGTH]-}) -> {- length :: -} CSize -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${friend_status_message}` event. Pass NULL to unset.
--
-- This event is triggered when a friend changes their status message.
--foreign import ccall tox_callback_friend_status_message :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_friend_status_message_cb -> {- result :: -} ()
-- | 
-- Return the friend's user status (away/busy/...). If the friend number is
-- invalid, the return value is unspecified.
--
-- The status returned is equal to the last status received through the
-- `${friend_status}` callback.
--foreign import ccall tox_friend_get_status :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- error :: -} Ptr TOX_ERR_FRIEND_QUERY -> {- result :: -} TOX_USER_STATUS
-- | 
-- @param friend_number The friend number of the friend whose user status
--   changed.
-- @param status The new user status.
--typedef tox_friend_status_cb = {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- status :: -} TOX_USER_STATUS -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${friend_status}` event. Pass NULL to unset.
--
-- This event is triggered when a friend changes their user status.
--foreign import ccall tox_callback_friend_status :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_friend_status_cb -> {- result :: -} ()
-- | 
-- Check whether a friend is currently connected to this client.
--
-- The result of this function is equal to the last value received by the
-- `${friend_connection_status}` callback.
--
-- @param friend_number The friend number for which to query the connection
--   status.
--
-- @return the friend's connection status as it was received through the
--   `${friend_connection_status}` event.
--foreign import ccall tox_friend_get_connection_status :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- error :: -} Ptr TOX_ERR_FRIEND_QUERY -> {- result :: -} TOX_CONNECTION
-- | 
-- @param friend_number The friend number of the friend whose connection status
--   changed.
-- @param connection_status The result of calling
--   ${tox_friend_get_connection_status} on the passed friend_number.
--typedef tox_friend_connection_status_cb = {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- connection_status :: -} TOX_CONNECTION -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${friend_connection_status}` event. Pass NULL to unset.
--
-- This event is triggered when a friend goes offline after having been online,
-- or when a friend goes online.
--
-- This callback is not called when adding friends. It is assumed that when
-- adding friends, their connection status is initially offline.
--foreign import ccall tox_callback_friend_connection_status :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_friend_connection_status_cb -> {- result :: -} ()
-- | 
-- Check whether a friend is currently typing a message.
--
-- @param friend_number The friend number for which to query the typing status.
--
-- @return true if the friend is typing.
-- @return false if the friend is not typing, or the friend number was
--   invalid. Inspect the error code to determine which case it is.
--foreign import ccall tox_friend_get_typing :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- error :: -} Ptr TOX_ERR_FRIEND_QUERY -> {- result :: -} Bool
-- | 
-- @param friend_number The friend number of the friend who started or stopped
--   typing.
-- @param is_typing The result of calling ${tox_friend_get_typing} on the passed
--   friend_number.
--typedef tox_friend_typing_cb = {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- is_typing :: -} Bool -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${friend_typing}` event. Pass NULL to unset.
--
-- This event is triggered when a friend starts or stops typing.
--foreign import ccall tox_callback_friend_typing :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_friend_typing_cb -> {- result :: -} ()


--------------------------------------------------------------------------------
--
-- :: Sending private messages
--
--------------------------------------------------------------------------------



data TOX_ERR_SET_TYPING 

  = TOX_ERR_SET_TYPING_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_SET_TYPING_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend number did not designate a valid friend.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Set the client's typing status for a friend.
--
-- The client is responsible for turning it on or off.
--
-- @param friend_number The friend to which the client is typing a message.
-- @param typing The typing status. True means the client is typing.
--
-- @return true on success.
--foreign import ccall tox_self_set_typing :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- typing :: -} Bool -> {- error :: -} Ptr TOX_ERR_SET_TYPING -> {- result :: -} Bool

data TOX_ERR_FRIEND_SEND_MESSAGE 

  = TOX_ERR_FRIEND_SEND_MESSAGE_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_FRIEND_SEND_MESSAGE_NULL
    -- ^ 
    -- One of the arguments to the function was NULL when it was not expected.
  
  | TOX_ERR_FRIEND_SEND_MESSAGE_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend number did not designate a valid friend.
  
  | TOX_ERR_FRIEND_SEND_MESSAGE_FRIEND_NOT_CONNECTED
    -- ^ 
    -- This client is currently not connected to the friend.
  
  | TOX_ERR_FRIEND_SEND_MESSAGE_SENDQ
    -- ^ 
    -- An allocation error occurred while increasing the send queue size.
  
  | TOX_ERR_FRIEND_SEND_MESSAGE_TOO_LONG
    -- ^ 
    -- Message length exceeded ${TOX_MAX_MESSAGE_LENGTH}.
  
  | TOX_ERR_FRIEND_SEND_MESSAGE_EMPTY
    -- ^ 
    -- Attempted to send a zero-length message.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Send a text chat message to an online friend.
--
-- This function creates a chat message packet and pushes it into the send
-- queue.
--
-- The message length may not exceed ${TOX_MAX_MESSAGE_LENGTH}. Larger messages
-- must be split by the client and sent as separate messages. Other clients can
-- then reassemble the fragments. Messages may not be empty.
--
-- The return value of this function is the message ID. If a read receipt is
-- received, the triggered `${friend_read_receipt}` event will be passed this message ID.
--
-- Message IDs are unique per friend. The first message ID is 0. Message IDs are
-- incremented by 1 each time a message is sent. If UINT32_MAX messages were
-- sent, the next message ID is 0.
--
-- @param type Message type (normal, action, ...).
-- @param friend_number The friend number of the friend to send the message to.
-- @param message A non-NULL pointer to the first element of a byte array
--   containing the message text.
-- @param length Length of the message to be sent.
--foreign import ccall tox_friend_send_message :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- type :: -} TOX_MESSAGE_TYPE -> {- message :: -} Ptr (Word8{-[length <= TOX_MAX_MESSAGE_LENGTH]-}) -> {- length :: -} CSize -> {- error :: -} Ptr TOX_ERR_FRIEND_SEND_MESSAGE -> {- result :: -} Word32
-- | 
-- @param friend_number The friend number of the friend who received the message.
-- @param message_id The message ID as returned from ${tox_friend_send_message}
--   corresponding to the message sent.
--typedef tox_friend_read_receipt_cb = {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- message_id :: -} Word32 -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${friend_read_receipt}` event. Pass NULL to unset.
--
-- This event is triggered when the friend receives the message sent with
-- ${tox_friend_send_message} with the corresponding message ID.
--foreign import ccall tox_callback_friend_read_receipt :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_friend_read_receipt_cb -> {- result :: -} ()


--------------------------------------------------------------------------------
--
-- :: Receiving private messages and friend requests
--
--------------------------------------------------------------------------------


-- | 
-- @param public_key The Public Key of the user who sent the friend request.
-- @param message The message they sent along with the request.
-- @param length The size of the message byte array.
--typedef tox_friend_request_cb = {- tox :: -} Ptr Tox -> {- public_key :: -} Ptr (Word8{-[TOX_PUBLIC_KEY_SIZE]-}) -> {- message :: -} Ptr (Word8{-[length <= TOX_MAX_MESSAGE_LENGTH]-}) -> {- length :: -} CSize -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${friend_request}` event. Pass NULL to unset.
--
-- This event is triggered when a friend request is received.
--foreign import ccall tox_callback_friend_request :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_friend_request_cb -> {- result :: -} ()
-- | 
-- @param friend_number The friend number of the friend who sent the message.
-- @param message The message data they sent.
-- @param length The size of the message byte array.
--typedef tox_friend_message_cb = {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- type :: -} TOX_MESSAGE_TYPE -> {- message :: -} Ptr (Word8{-[length <= TOX_MAX_MESSAGE_LENGTH]-}) -> {- length :: -} CSize -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${friend_message}` event. Pass NULL to unset.
--
-- This event is triggered when a message from a friend is received.
--foreign import ccall tox_callback_friend_message :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_friend_message_cb -> {- result :: -} ()


--------------------------------------------------------------------------------
--
-- :: File transmission: common between sending and receiving
--
--------------------------------------------------------------------------------


-- | 
-- Generates a cryptographic hash of the given data.
--
-- This function may be used by clients for any purpose, but is provided
-- primarily for validating cached avatars. This use is highly recommended to
-- avoid unnecessary avatar updates.
--
-- If hash is NULL or data is NULL while length is not 0 the function returns false,
-- otherwise it returns true.
--
-- This function is a wrapper to internal message-digest functions.
--
-- @param hash A valid memory location the hash data. It must be at least
--   ${TOX_HASH_LENGTH} bytes in size.
-- @param data Data to be hashed or NULL.
-- @param length Size of the data array or 0.
--
-- @return true if hash was not NULL.
--foreign import ccall tox_hash :: {- hash :: -} Ptr (Word8{-[TOX_HASH_LENGTH]-}) -> {- data :: -} Ptr (Word8{-[length]-}) -> {- length :: -} CSize -> {- result :: -} Bool

data TOX_FILE_KIND 

  = TOX_FILE_KIND_DATA
    -- ^ 
    -- Arbitrary file data. Clients can choose to handle it based on the file name
    -- or magic or any other way they choose.
  
  | TOX_FILE_KIND_AVATAR
    -- ^ 
    -- Avatar file_id. This consists of ${tox_hash}(image).
    -- Avatar data. This consists of the image data.
    --
    -- Avatars can be sent at any time the client wishes. Generally, a client will
    -- send the avatar to a friend when that friend comes online, and to all
    -- friends when the avatar changed. A client can save some traffic by
    -- remembering which friend received the updated avatar already and only send
    -- it if the friend has an out of date avatar.
    --
    -- Clients who receive avatar send requests can reject it (by sending
    -- ${TOX_FILE_CONTROL_CANCEL} before any other controls), or accept it (by
    -- sending ${TOX_FILE_CONTROL_RESUME}). The file_id of length ${TOX_HASH_LENGTH} bytes
    -- (same length as ${TOX_FILE_ID_LENGTH}) will contain the hash. A client can compare
    -- this hash with a saved hash and send ${TOX_FILE_CONTROL_CANCEL} to terminate the avatar
    -- transfer if it matches.
    --
    -- When file_size is set to 0 in the transfer request it means that the client
    -- has no avatar.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)

data TOX_FILE_CONTROL 

  = TOX_FILE_CONTROL_RESUME
    -- ^ 
    -- Sent by the receiving side to accept a file send request. Also sent after a
    -- ${TOX_FILE_CONTROL_PAUSE} command to continue sending or receiving.
  
  | TOX_FILE_CONTROL_PAUSE
    -- ^ 
    -- Sent by clients to pause the file transfer. The initial state of a file
    -- transfer is always paused on the receiving side and running on the sending
    -- side. If both the sending and receiving side pause the transfer, then both
    -- need to send ${TOX_FILE_CONTROL_RESUME} for the transfer to resume.
  
  | TOX_FILE_CONTROL_CANCEL
    -- ^ 
    -- Sent by the receiving side to reject a file send request before any other
    -- commands are sent. Also sent by either side to terminate a file transfer.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)

data TOX_ERR_FILE_CONTROL 

  = TOX_ERR_FILE_CONTROL_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_FILE_CONTROL_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend_number passed did not designate a valid friend.
  
  | TOX_ERR_FILE_CONTROL_FRIEND_NOT_CONNECTED
    -- ^ 
    -- This client is currently not connected to the friend.
  
  | TOX_ERR_FILE_CONTROL_NOT_FOUND
    -- ^ 
    -- No file transfer with the given file number was found for the given friend.
  
  | TOX_ERR_FILE_CONTROL_NOT_PAUSED
    -- ^ 
    -- A RESUME control was sent, but the file transfer is running normally.
  
  | TOX_ERR_FILE_CONTROL_DENIED
    -- ^ 
    -- A RESUME control was sent, but the file transfer was paused by the other
    -- party. Only the party that paused the transfer can resume it.
  
  | TOX_ERR_FILE_CONTROL_ALREADY_PAUSED
    -- ^ 
    -- A PAUSE control was sent, but the file transfer was already paused.
  
  | TOX_ERR_FILE_CONTROL_SENDQ
    -- ^ 
    -- Packet queue is full.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Sends a file control command to a friend for a given file transfer.
--
-- @param friend_number The friend number of the friend the file is being
--   transferred to or received from.
-- @param file_number The friend-specific identifier for the file transfer.
-- @param control The control command to send.
--
-- @return true on success.
--foreign import ccall tox_file_control :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- file_number :: -} Word32 -> {- control :: -} TOX_FILE_CONTROL -> {- error :: -} Ptr TOX_ERR_FILE_CONTROL -> {- result :: -} Bool
-- | 
-- When receiving ${TOX_FILE_CONTROL_CANCEL}, the client should release the
-- resources associated with the file number and consider the transfer failed.
--
-- @param friend_number The friend number of the friend who is sending the file.
-- @param file_number The friend-specific file number the data received is
--   associated with.
-- @param control The file control command received.
--typedef tox_file_recv_control_cb = {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- file_number :: -} Word32 -> {- control :: -} TOX_FILE_CONTROL -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${file_recv_control}` event. Pass NULL to unset.
--
-- This event is triggered when a file control command is received from a
-- friend.
--foreign import ccall tox_callback_file_recv_control :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_file_recv_control_cb -> {- result :: -} ()

data TOX_ERR_FILE_SEEK 

  = TOX_ERR_FILE_SEEK_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_FILE_SEEK_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend_number passed did not designate a valid friend.
  
  | TOX_ERR_FILE_SEEK_FRIEND_NOT_CONNECTED
    -- ^ 
    -- This client is currently not connected to the friend.
  
  | TOX_ERR_FILE_SEEK_NOT_FOUND
    -- ^ 
    -- No file transfer with the given file number was found for the given friend.
  
  | TOX_ERR_FILE_SEEK_DENIED
    -- ^ 
    -- File was not in a state where it could be seeked.
  
  | TOX_ERR_FILE_SEEK_INVALID_POSITION
    -- ^ 
    -- Seek position was invalid
  
  | TOX_ERR_FILE_SEEK_SENDQ
    -- ^ 
    -- Packet queue is full.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Sends a file seek control command to a friend for a given file transfer.
--
-- This function can only be called to resume a file transfer right before
-- ${TOX_FILE_CONTROL_RESUME} is sent.
--
-- @param friend_number The friend number of the friend the file is being
--   received from.
-- @param file_number The friend-specific identifier for the file transfer.
-- @param position The position that the file should be seeked to.
--foreign import ccall tox_file_seek :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- file_number :: -} Word32 -> {- position :: -} Word64 -> {- error :: -} Ptr TOX_ERR_FILE_SEEK -> {- result :: -} Bool

data TOX_ERR_FILE_GET 

  = TOX_ERR_FILE_GET_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_FILE_GET_NULL
    -- ^ 
    -- One of the arguments to the function was NULL when it was not expected.
  
  | TOX_ERR_FILE_GET_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend_number passed did not designate a valid friend.
  
  | TOX_ERR_FILE_GET_NOT_FOUND
    -- ^ 
    -- No file transfer with the given file number was found for the given friend.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Copy the file id associated to the file transfer to a byte array.
--
-- @param friend_number The friend number of the friend the file is being
--   transferred to or received from.
-- @param file_number The friend-specific identifier for the file transfer.
-- @param file_id A memory region of at least ${TOX_FILE_ID_LENGTH} bytes. If
--   this parameter is NULL, this function has no effect.
--
-- @return true on success.
--foreign import ccall tox_file_get_file_id :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- file_number :: -} Word32 -> {- file_id :: -} Ptr (Word8{-[TOX_FILE_ID_LENGTH]-}) -> {- error :: -} Ptr TOX_ERR_FILE_GET -> {- result :: -} Bool


--------------------------------------------------------------------------------
--
-- :: File transmission: sending
--
--------------------------------------------------------------------------------



data TOX_ERR_FILE_SEND 

  = TOX_ERR_FILE_SEND_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_FILE_SEND_NULL
    -- ^ 
    -- One of the arguments to the function was NULL when it was not expected.
  
  | TOX_ERR_FILE_SEND_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend_number passed did not designate a valid friend.
  
  | TOX_ERR_FILE_SEND_FRIEND_NOT_CONNECTED
    -- ^ 
    -- This client is currently not connected to the friend.
  
  | TOX_ERR_FILE_SEND_NAME_TOO_LONG
    -- ^ 
    -- Filename length exceeded ${TOX_MAX_FILENAME_LENGTH} bytes.
  
  | TOX_ERR_FILE_SEND_TOO_MANY
    -- ^ 
    -- Too many ongoing transfers. The maximum number of concurrent file transfers
    -- is 256 per friend per direction (sending and receiving).
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Send a file transmission request.
--
-- Maximum filename length is ${TOX_MAX_FILENAME_LENGTH} bytes. The filename
-- should generally just be a file name, not a path with directory names.
--
-- If a non-UINT64_MAX file size is provided, it can be used by both sides to
-- determine the sending progress. File size can be set to UINT64_MAX for streaming
-- data of unknown size.
--
-- File transmission occurs in chunks, which are requested through the
-- `${file_chunk_request}` event.
--
-- When a friend goes offline, all file transfers associated with the friend are
-- purged from core.
--
-- If the file contents change during a transfer, the behaviour is unspecified
-- in general. What will actually happen depends on the mode in which the file
-- was modified and how the client determines the file size.
--
-- - If the file size was increased
--   - and sending mode was streaming (file_size = UINT64_MAX), the behaviour
--     will be as expected.
--   - and sending mode was file (file_size != UINT64_MAX), the
--     ${file_chunk_request} callback will receive length = 0 when Core thinks
--     the file transfer has finished. If the client remembers the file size as
--     it was when sending the request, it will terminate the transfer normally.
--     If the client re-reads the size, it will think the friend cancelled the
--     transfer.
-- - If the file size was decreased
--   - and sending mode was streaming, the behaviour is as expected.
--   - and sending mode was file, the callback will return 0 at the new
--     (earlier) end-of-file, signalling to the friend that the transfer was
--     cancelled.
-- - If the file contents were modified
--   - at a position before the current read, the two files (local and remote)
--     will differ after the transfer terminates.
--   - at a position after the current read, the file transfer will succeed as
--     expected.
--   - In either case, both sides will regard the transfer as complete and
--     successful.
--
-- @param friend_number The friend number of the friend the file send request
--   should be sent to.
-- @param kind The meaning of the file to be sent.
-- @param file_size Size in bytes of the file the client wants to send, UINT64_MAX if
--   unknown or streaming.
-- @param file_id A file identifier of length ${TOX_FILE_ID_LENGTH} that can be used to
--   uniquely identify file transfers across core restarts. If NULL, a random one will
--   be generated by core. It can then be obtained by using ${tox_file_get_file_id}().
-- @param filename Name of the file. Does not need to be the actual name. This
--   name will be sent along with the file send request.
-- @param filename_length Size in bytes of the filename.
--
-- @return A file number used as an identifier in subsequent callbacks. This
--   number is per friend. File numbers are reused after a transfer terminates.
--   On failure, this function returns UINT32_MAX. Any pattern in file numbers
--   should not be relied on.
--foreign import ccall tox_file_send :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- kind :: -} Word32 -> {- file_size :: -} Word64 -> {- file_id :: -} Ptr (Word8{-[TOX_FILE_ID_LENGTH]-}) -> {- filename :: -} Ptr (Word8{-[filename_length <= TOX_MAX_FILENAME_LENGTH]-}) -> {- filename_length :: -} CSize -> {- error :: -} Ptr TOX_ERR_FILE_SEND -> {- result :: -} Word32

data TOX_ERR_FILE_SEND_CHUNK 

  = TOX_ERR_FILE_SEND_CHUNK_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_FILE_SEND_CHUNK_NULL
    -- ^ 
    -- The length parameter was non-zero, but data was NULL.
  
  | TOX_ERR_FILE_SEND_CHUNK_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend_number passed did not designate a valid friend.
  
  | TOX_ERR_FILE_SEND_CHUNK_FRIEND_NOT_CONNECTED
    -- ^ 
    -- This client is currently not connected to the friend.
  
  | TOX_ERR_FILE_SEND_CHUNK_NOT_FOUND
    -- ^ 
    -- No file transfer with the given file number was found for the given friend.
  
  | TOX_ERR_FILE_SEND_CHUNK_NOT_TRANSFERRING
    -- ^ 
    -- File transfer was found but isn't in a transferring state: (paused, done,
    -- broken, etc...) (happens only when not called from the request chunk callback).
  
  | TOX_ERR_FILE_SEND_CHUNK_INVALID_LENGTH
    -- ^ 
    -- Attempted to send more or less data than requested. The requested data size is
    -- adjusted according to maximum transmission unit and the expected end of
    -- the file. Trying to send less or more than requested will return this error.
  
  | TOX_ERR_FILE_SEND_CHUNK_SENDQ
    -- ^ 
    -- Packet queue is full.
  
  | TOX_ERR_FILE_SEND_CHUNK_WRONG_POSITION
    -- ^ 
    -- Position parameter was wrong.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Send a chunk of file data to a friend.
--
-- This function is called in response to the `${file_chunk_request}` callback. The
-- length parameter should be equal to the one received though the callback.
-- If it is zero, the transfer is assumed complete. For files with known size,
-- Core will know that the transfer is complete after the last byte has been
-- received, so it is not necessary (though not harmful) to send a zero-length
-- chunk to terminate. For streams, core will know that the transfer is finished
-- if a chunk with length less than the length requested in the callback is sent.
--
-- @param friend_number The friend number of the receiving friend for this file.
-- @param file_number The file transfer identifier returned by tox_file_send.
-- @param position The file or stream position from which to continue reading.
-- @return true on success.
--foreign import ccall tox_file_send_chunk :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- file_number :: -} Word32 -> {- position :: -} Word64 -> {- data :: -} Ptr (Word8{-[length]-}) -> {- length :: -} CSize -> {- error :: -} Ptr TOX_ERR_FILE_SEND_CHUNK -> {- result :: -} Bool
-- | 
-- If the length parameter is 0, the file transfer is finished, and the client's
-- resources associated with the file number should be released. After a call
-- with zero length, the file number can be reused for future file transfers.
--
-- If the requested position is not equal to the client's idea of the current
-- file or stream position, it will need to seek. In case of read-once streams,
-- the client should keep the last read chunk so that a seek back can be
-- supported. A seek-back only ever needs to read from the last requested chunk.
-- This happens when a chunk was requested, but the send failed. A seek-back
-- request can occur an arbitrary number of times for any given chunk.
--
-- In response to receiving this callback, the client should call the function
-- `${tox_file_send_chunk}` with the requested chunk. If the number of bytes sent
-- through that function is zero, the file transfer is assumed complete. A
-- client must send the full length of data requested with this callback.
--
-- @param friend_number The friend number of the receiving friend for this file.
-- @param file_number The file transfer identifier returned by ${tox_file_send}.
-- @param position The file or stream position from which to continue reading.
-- @param length The number of bytes requested for the current chunk.
--typedef tox_file_chunk_request_cb = {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- file_number :: -} Word32 -> {- position :: -} Word64 -> {- length :: -} CSize -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${file_chunk_request}` event. Pass NULL to unset.
--
-- This event is triggered when Core is ready to send more file data.
--foreign import ccall tox_callback_file_chunk_request :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_file_chunk_request_cb -> {- result :: -} ()


--------------------------------------------------------------------------------
--
-- :: File transmission: receiving
--
--------------------------------------------------------------------------------


-- | 
-- The client should acquire resources to be associated with the file transfer.
-- Incoming file transfers start in the PAUSED state. After this callback
-- returns, a transfer can be rejected by sending a ${TOX_FILE_CONTROL_CANCEL}
-- control command before any other control commands. It can be accepted by
-- sending ${TOX_FILE_CONTROL_RESUME}.
--
-- @param friend_number The friend number of the friend who is sending the file
--   transfer request.
-- @param file_number The friend-specific file number the data received is
--   associated with.
-- @param kind The meaning of the file to be sent.
-- @param file_size Size in bytes of the file the client wants to send,
--   UINT64_MAX if unknown or streaming.
-- @param filename Name of the file. Does not need to be the actual name. This
--   name will be sent along with the file send request.
-- @param filename_length Size in bytes of the filename.
--typedef tox_file_recv_cb = {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- file_number :: -} Word32 -> {- kind :: -} Word32 -> {- file_size :: -} Word64 -> {- filename :: -} Ptr (Word8{-[filename_length <= TOX_MAX_FILENAME_LENGTH]-}) -> {- filename_length :: -} CSize -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${file_recv}` event. Pass NULL to unset.
--
-- This event is triggered when a file transfer request is received.
--foreign import ccall tox_callback_file_recv :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_file_recv_cb -> {- result :: -} ()
-- | 
-- When length is 0, the transfer is finished and the client should release the
-- resources it acquired for the transfer. After a call with length = 0, the
-- file number can be reused for new file transfers.
--
-- If position is equal to file_size (received in the file_receive callback)
-- when the transfer finishes, the file was received completely. Otherwise, if
-- file_size was UINT64_MAX, streaming ended successfully when length is 0.
--
-- @param friend_number The friend number of the friend who is sending the file.
-- @param file_number The friend-specific file number the data received is
--   associated with.
-- @param position The file position of the first byte in data.
-- @param data A byte array containing the received chunk.
-- @param length The length of the received chunk.
--typedef tox_file_recv_chunk_cb = {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- file_number :: -} Word32 -> {- position :: -} Word64 -> {- data :: -} Ptr (Word8{-[length]-}) -> {- length :: -} CSize -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${file_recv_chunk}` event. Pass NULL to unset.
--
-- This event is first triggered when a file transfer request is received, and
-- subsequently when a chunk of file data for an accepted request was received.
--foreign import ccall tox_callback_file_recv_chunk :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_file_recv_chunk_cb -> {- result :: -} ()


--------------------------------------------------------------------------------
--
-- :: Conference management
--
--------------------------------------------------------------------------------


-- | 
-- Conference types for the ${conference_invite} event.
data TOX_CONFERENCE_TYPE 

  = TOX_CONFERENCE_TYPE_TEXT
    -- ^ 
    -- Text-only conferences that must be accepted with the ${tox_conference_join} function.
  
  | TOX_CONFERENCE_TYPE_AV
    -- ^ 
    -- Video conference. The function to accept these is in toxav.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- The invitation will remain valid until the inviting friend goes offline
-- or exits the conference.
--
-- @param friend_number The friend who invited us.
-- @param type The conference type (text only or audio/video).
-- @param cookie A piece of data of variable length required to join the
--   conference.
-- @param length The length of the cookie.
--typedef tox_conference_invite_cb = {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- type :: -} TOX_CONFERENCE_TYPE -> {- cookie :: -} Ptr (Word8{-[length]-}) -> {- length :: -} CSize -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${conference_invite}` event. Pass NULL to unset.
--
-- This event is triggered when the client is invited to join a conference.
--foreign import ccall tox_callback_conference_invite :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_conference_invite_cb -> {- result :: -} ()
-- | 
-- @param conference_number The conference number of the conference the message is intended for.
-- @param peer_number The ID of the peer who sent the message.
-- @param type The type of message (normal, action, ...).
-- @param message The message data.
-- @param length The length of the message.
--typedef tox_conference_message_cb = {- tox :: -} Ptr Tox -> {- conference_number :: -} Word32 -> {- peer_number :: -} Word32 -> {- type :: -} TOX_MESSAGE_TYPE -> {- message :: -} Ptr (Word8{-[length]-}) -> {- length :: -} CSize -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${conference_message}` event. Pass NULL to unset.
--
-- This event is triggered when the client receives a conference message.
--foreign import ccall tox_callback_conference_message :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_conference_message_cb -> {- result :: -} ()
-- | 
-- @param conference_number The conference number of the conference the title change is intended for.
-- @param peer_number The ID of the peer who changed the title.
-- @param title The title data.
-- @param length The title length.
--typedef tox_conference_title_cb = {- tox :: -} Ptr Tox -> {- conference_number :: -} Word32 -> {- peer_number :: -} Word32 -> {- title :: -} Ptr (Word8{-[length]-}) -> {- length :: -} CSize -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${conference_title}` event. Pass NULL to unset.
--
-- This event is triggered when a peer changes the conference title.
--
-- If peer_number == UINT32_MAX, then author is unknown (e.g. initial joining the conference).
--foreign import ccall tox_callback_conference_title :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_conference_title_cb -> {- result :: -} ()
-- | 
-- Peer list state change types.
data TOX_CONFERENCE_STATE_CHANGE 

  = TOX_CONFERENCE_STATE_CHANGE_PEER_JOIN
    -- ^ 
    -- A peer has joined the conference.
  
  | TOX_CONFERENCE_STATE_CHANGE_PEER_EXIT
    -- ^ 
    -- A peer has exited the conference.
  
  | TOX_CONFERENCE_STATE_CHANGE_PEER_NAME_CHANGE
    -- ^ 
    -- A peer has changed their name.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- @param conference_number The conference number of the conference the title change is intended for.
-- @param peer_number The ID of the peer who changed the title.
-- @param change The type of change (one of ${TOX_CONFERENCE_STATE_CHANGE}).
--typedef tox_conference_namelist_change_cb = {- tox :: -} Ptr Tox -> {- conference_number :: -} Word32 -> {- peer_number :: -} Word32 -> {- change :: -} TOX_CONFERENCE_STATE_CHANGE -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${conference_namelist_change}` event. Pass NULL to unset.
--
-- This event is triggered when the peer list changes (name change, peer join, peer exit).
--foreign import ccall tox_callback_conference_namelist_change :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_conference_namelist_change_cb -> {- result :: -} ()

data TOX_ERR_CONFERENCE_NEW 

  = TOX_ERR_CONFERENCE_NEW_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_CONFERENCE_NEW_INIT
    -- ^ 
    -- The conference instance failed to initialize.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Creates a new conference.
--
-- This function creates a new text conference.
--
-- @return conference number on success, or UINT32_MAX on failure.
--foreign import ccall tox_conference_new :: {- tox :: -} Ptr Tox -> {- error :: -} Ptr TOX_ERR_CONFERENCE_NEW -> {- result :: -} Word32

data TOX_ERR_CONFERENCE_DELETE 

  = TOX_ERR_CONFERENCE_DELETE_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_CONFERENCE_DELETE_CONFERENCE_NOT_FOUND
    -- ^ 
    -- The conference number passed did not designate a valid conference.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- This function deletes a conference.
--
-- @param conference_number The conference number of the conference to be deleted.
--
-- @return true on success.
--foreign import ccall tox_conference_delete :: {- tox :: -} Ptr Tox -> {- conference_number :: -} Word32 -> {- error :: -} Ptr TOX_ERR_CONFERENCE_DELETE -> {- result :: -} Bool
-- | 
-- Error codes for peer info queries.
data TOX_ERR_CONFERENCE_PEER_QUERY 

  = TOX_ERR_CONFERENCE_PEER_QUERY_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_CONFERENCE_PEER_QUERY_CONFERENCE_NOT_FOUND
    -- ^ 
    -- The conference number passed did not designate a valid conference.
  
  | TOX_ERR_CONFERENCE_PEER_QUERY_PEER_NOT_FOUND
    -- ^ 
    -- The peer number passed did not designate a valid peer.
  
  | TOX_ERR_CONFERENCE_PEER_QUERY_NO_CONNECTION
    -- ^ 
    -- The client is not connected to the conference.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Return the number of peers in the conference. Return value is unspecified on failure.
--foreign import ccall tox_conference_peer_count :: {- tox :: -} Ptr Tox -> {- conference_number :: -} Word32 -> {- error :: -} Ptr TOX_ERR_CONFERENCE_PEER_QUERY -> {- result :: -} Word32
-- | 
-- Return the length of the peer's name. Return value is unspecified on failure.
--foreign import ccall tox_conference_peer_get_name_size :: {- tox :: -} Ptr Tox -> {- conference_number :: -} Word32 -> {- peer_number :: -} Word32 -> {- error :: -} Ptr TOX_ERR_CONFERENCE_PEER_QUERY -> {- result :: -} CSize
-- | 
-- Copy the name of peer_number who is in conference_number to name.
-- name must be at least ${TOX_MAX_NAME_LENGTH} long.
--
-- @return true on success.
--foreign import ccall tox_conference_peer_get_name :: {- tox :: -} Ptr Tox -> {- conference_number :: -} Word32 -> {- peer_number :: -} Word32 -> {- name :: -} Ptr (Word8{-[tox_conference_peer_get_name_size]-}) -> {- error :: -} Ptr TOX_ERR_CONFERENCE_PEER_QUERY -> {- result :: -} Bool
-- | 
-- Copy the public key of peer_number who is in conference_number to public_key.
-- public_key must be ${TOX_PUBLIC_KEY_SIZE} long.
--
-- @return true on success.
--foreign import ccall tox_conference_peer_get_public_key :: {- tox :: -} Ptr Tox -> {- conference_number :: -} Word32 -> {- peer_number :: -} Word32 -> {- public_key :: -} Ptr (Word8{-[TOX_PUBLIC_KEY_SIZE]-}) -> {- error :: -} Ptr TOX_ERR_CONFERENCE_PEER_QUERY -> {- result :: -} Bool
-- | 
-- Return true if passed peer_number corresponds to our own.
--foreign import ccall tox_conference_peer_number_is_ours :: {- tox :: -} Ptr Tox -> {- conference_number :: -} Word32 -> {- peer_number :: -} Word32 -> {- error :: -} Ptr TOX_ERR_CONFERENCE_PEER_QUERY -> {- result :: -} Bool

data TOX_ERR_CONFERENCE_INVITE 

  = TOX_ERR_CONFERENCE_INVITE_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_CONFERENCE_INVITE_CONFERENCE_NOT_FOUND
    -- ^ 
    -- The conference number passed did not designate a valid conference.
  
  | TOX_ERR_CONFERENCE_INVITE_FAIL_SEND
    -- ^ 
    -- The invite packet failed to send.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Invites a friend to a conference.
--
-- @param friend_number The friend number of the friend we want to invite.
-- @param conference_number The conference number of the conference we want to invite the friend to.
--
-- @return true on success.
--foreign import ccall tox_conference_invite :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- conference_number :: -} Word32 -> {- error :: -} Ptr TOX_ERR_CONFERENCE_INVITE -> {- result :: -} Bool

data TOX_ERR_CONFERENCE_JOIN 

  = TOX_ERR_CONFERENCE_JOIN_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_CONFERENCE_JOIN_INVALID_LENGTH
    -- ^ 
    -- The cookie passed has an invalid length.
  
  | TOX_ERR_CONFERENCE_JOIN_WRONG_TYPE
    -- ^ 
    -- The conference is not the expected type. This indicates an invalid cookie.
  
  | TOX_ERR_CONFERENCE_JOIN_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend number passed does not designate a valid friend.
  
  | TOX_ERR_CONFERENCE_JOIN_DUPLICATE
    -- ^ 
    -- Client is already in this conference.
  
  | TOX_ERR_CONFERENCE_JOIN_INIT_FAIL
    -- ^ 
    -- Conference instance failed to initialize.
  
  | TOX_ERR_CONFERENCE_JOIN_FAIL_SEND
    -- ^ 
    -- The join packet failed to send.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Joins a conference that the client has been invited to.
--
-- @param friend_number The friend number of the friend who sent the invite.
-- @param cookie Received via the `${conference_invite}` event.
-- @param length The size of cookie.
--
-- @return conference number on success, UINT32_MAX on failure.
--foreign import ccall tox_conference_join :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- cookie :: -} Ptr (Word8{-[length]-}) -> {- length :: -} CSize -> {- error :: -} Ptr TOX_ERR_CONFERENCE_JOIN -> {- result :: -} Word32

data TOX_ERR_CONFERENCE_SEND_MESSAGE 

  = TOX_ERR_CONFERENCE_SEND_MESSAGE_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_CONFERENCE_SEND_MESSAGE_CONFERENCE_NOT_FOUND
    -- ^ 
    -- The conference number passed did not designate a valid conference.
  
  | TOX_ERR_CONFERENCE_SEND_MESSAGE_TOO_LONG
    -- ^ 
    -- The message is too long.
  
  | TOX_ERR_CONFERENCE_SEND_MESSAGE_NO_CONNECTION
    -- ^ 
    -- The client is not connected to the conference.
  
  | TOX_ERR_CONFERENCE_SEND_MESSAGE_FAIL_SEND
    -- ^ 
    -- The message packet failed to send.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Send a text chat message to the conference.
--
-- This function creates a conference message packet and pushes it into the send
-- queue.
--
-- The message length may not exceed ${TOX_MAX_MESSAGE_LENGTH}. Larger messages
-- must be split by the client and sent as separate messages. Other clients can
-- then reassemble the fragments.
--
-- @param conference_number The conference number of the conference the message is intended for.
-- @param type Message type (normal, action, ...).
-- @param message A non-NULL pointer to the first element of a byte array
--   containing the message text.
-- @param length Length of the message to be sent.
--
-- @return true on success.
--foreign import ccall tox_conference_send_message :: {- tox :: -} Ptr Tox -> {- conference_number :: -} Word32 -> {- type :: -} TOX_MESSAGE_TYPE -> {- message :: -} Ptr (Word8{-[length]-}) -> {- length :: -} CSize -> {- error :: -} Ptr TOX_ERR_CONFERENCE_SEND_MESSAGE -> {- result :: -} Bool

data TOX_ERR_CONFERENCE_TITLE 

  = TOX_ERR_CONFERENCE_TITLE_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_CONFERENCE_TITLE_CONFERENCE_NOT_FOUND
    -- ^ 
    -- The conference number passed did not designate a valid conference.
  
  | TOX_ERR_CONFERENCE_TITLE_INVALID_LENGTH
    -- ^ 
    -- The title is too long or empty.
  
  | TOX_ERR_CONFERENCE_TITLE_FAIL_SEND
    -- ^ 
    -- The title packet failed to send.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Return the length of the conference title. Return value is unspecified on failure.
--
-- The return value is equal to the `length` argument received by the last
-- `${conference_title}` callback.
--foreign import ccall tox_conference_get_title_size :: {- tox :: -} Ptr Tox -> {- conference_number :: -} Word32 -> {- error :: -} Ptr TOX_ERR_CONFERENCE_TITLE -> {- result :: -} CSize
-- | 
-- Write the title designated by the given conference number to a byte array.
--
-- Call ${tox_conference_get_title_size} to determine the allocation size for the `title` parameter.
--
-- The data written to `title` is equal to the data received by the last
-- `${conference_title}` callback.
--
-- @param title A valid memory region large enough to store the title.
--   If this parameter is NULL, this function has no effect.
--
-- @return true on success.
--foreign import ccall tox_conference_get_title :: {- tox :: -} Ptr Tox -> {- conference_number :: -} Word32 -> {- title :: -} Ptr (Word8{-[<unresolved> <= TOX_MAX_NAME_LENGTH]-}) -> {- error :: -} Ptr TOX_ERR_CONFERENCE_TITLE -> {- result :: -} Bool
-- | 
-- Set the conference title and broadcast it to the rest of the conference.
--
-- Title length cannot be longer than ${TOX_MAX_NAME_LENGTH}.
--
-- @return true on success.
--foreign import ccall tox_conference_set_title :: {- tox :: -} Ptr Tox -> {- conference_number :: -} Word32 -> {- title :: -} Ptr (Word8{-[length <= TOX_MAX_NAME_LENGTH]-}) -> {- length :: -} CSize -> {- error :: -} Ptr TOX_ERR_CONFERENCE_TITLE -> {- result :: -} Bool
-- | 
-- Return the number of conferences in the Tox instance.
-- This should be used to determine how much memory to allocate for `${tox_conference_get_chatlist}`.
--foreign import ccall tox_conference_get_chatlist_size :: {- tox :: -} Ptr Tox -> {- result :: -} CSize
-- | 
-- Copy a list of valid conference IDs into the array chatlist. Determine how much space
-- to allocate for the array with the `${tox_conference_get_chatlist_size}` function.
--foreign import ccall tox_conference_get_chatlist :: {- tox :: -} Ptr Tox -> {- chatlist :: -} Ptr (Word32{-[tox_conference_get_chatlist_size]-}) -> {- result :: -} ()
-- | 
-- Returns the type of conference (${TOX_CONFERENCE_TYPE}) that conference_number is. Return value is
-- unspecified on failure.
data TOX_ERR_CONFERENCE_GET_TYPE 

  = TOX_ERR_CONFERENCE_GET_TYPE_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_CONFERENCE_GET_TYPE_CONFERENCE_NOT_FOUND
    -- ^ 
    -- The conference number passed did not designate a valid conference.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)

--foreign import ccall tox_conference_get_type :: {- tox :: -} Ptr Tox -> {- conference_number :: -} Word32 -> {- error :: -} Ptr TOX_ERR_CONFERENCE_GET_TYPE -> {- result :: -} TOX_CONFERENCE_TYPE


--------------------------------------------------------------------------------
--
-- :: Low-level custom packet sending and receiving
--
--------------------------------------------------------------------------------



data TOX_ERR_FRIEND_CUSTOM_PACKET 

  = TOX_ERR_FRIEND_CUSTOM_PACKET_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_FRIEND_CUSTOM_PACKET_NULL
    -- ^ 
    -- One of the arguments to the function was NULL when it was not expected.
  
  | TOX_ERR_FRIEND_CUSTOM_PACKET_FRIEND_NOT_FOUND
    -- ^ 
    -- The friend number did not designate a valid friend.
  
  | TOX_ERR_FRIEND_CUSTOM_PACKET_FRIEND_NOT_CONNECTED
    -- ^ 
    -- This client is currently not connected to the friend.
  
  | TOX_ERR_FRIEND_CUSTOM_PACKET_INVALID
    -- ^ 
    -- The first byte of data was not in the specified range for the packet type.
    -- This range is 200-254 for lossy, and 160-191 for lossless packets.
  
  | TOX_ERR_FRIEND_CUSTOM_PACKET_EMPTY
    -- ^ 
    -- Attempted to send an empty packet.
  
  | TOX_ERR_FRIEND_CUSTOM_PACKET_TOO_LONG
    -- ^ 
    -- Packet data length exceeded ${TOX_MAX_CUSTOM_PACKET_SIZE}.
  
  | TOX_ERR_FRIEND_CUSTOM_PACKET_SENDQ
    -- ^ 
    -- Packet queue is full.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Send a custom lossy packet to a friend.
--
-- The first byte of data must be in the range 200-254. Maximum length of a
-- custom packet is ${TOX_MAX_CUSTOM_PACKET_SIZE}.
--
-- Lossy packets behave like UDP packets, meaning they might never reach the
-- other side or might arrive more than once (if someone is messing with the
-- connection) or might arrive in the wrong order.
--
-- Unless latency is an issue, it is recommended that you use lossless custom
-- packets instead.
--
-- @param friend_number The friend number of the friend this lossy packet
--   should be sent to.
-- @param data A byte array containing the packet data.
-- @param length The length of the packet data byte array.
--
-- @return true on success.
--foreign import ccall tox_friend_send_lossy_packet :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- data :: -} Ptr (Word8{-[length <= TOX_MAX_CUSTOM_PACKET_SIZE]-}) -> {- length :: -} CSize -> {- error :: -} Ptr TOX_ERR_FRIEND_CUSTOM_PACKET -> {- result :: -} Bool
-- | 
-- Send a custom lossless packet to a friend.
--
-- The first byte of data must be in the range 160-191. Maximum length of a
-- custom packet is ${TOX_MAX_CUSTOM_PACKET_SIZE}.
--
-- Lossless packet behaviour is comparable to TCP (reliability, arrive in order)
-- but with packets instead of a stream.
--
-- @param friend_number The friend number of the friend this lossless packet
--   should be sent to.
-- @param data A byte array containing the packet data.
-- @param length The length of the packet data byte array.
--
-- @return true on success.
--foreign import ccall tox_friend_send_lossless_packet :: {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- data :: -} Ptr (Word8{-[length <= TOX_MAX_CUSTOM_PACKET_SIZE]-}) -> {- length :: -} CSize -> {- error :: -} Ptr TOX_ERR_FRIEND_CUSTOM_PACKET -> {- result :: -} Bool
-- | 
-- @param friend_number The friend number of the friend who sent a lossy packet.
-- @param data A byte array containing the received packet data.
-- @param length The length of the packet data byte array.
--typedef tox_friend_lossy_packet_cb = {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- data :: -} Ptr (Word8{-[length <= TOX_MAX_CUSTOM_PACKET_SIZE]-}) -> {- length :: -} CSize -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${friend_lossy_packet}` event. Pass NULL to unset.
--
--foreign import ccall tox_callback_friend_lossy_packet :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_friend_lossy_packet_cb -> {- result :: -} ()
-- | 
-- @param friend_number The friend number of the friend who sent the packet.
-- @param data A byte array containing the received packet data.
-- @param length The length of the packet data byte array.
--typedef tox_friend_lossless_packet_cb = {- tox :: -} Ptr Tox -> {- friend_number :: -} Word32 -> {- data :: -} Ptr (Word8{-[length <= TOX_MAX_CUSTOM_PACKET_SIZE]-}) -> {- length :: -} CSize -> {- user_data :: -} Ptr () -> ()

-- | 
-- Set the callback for the `${friend_lossless_packet}` event. Pass NULL to unset.
--
--foreign import ccall tox_callback_friend_lossless_packet :: {- tox :: -} Ptr Tox -> {- callback :: -} Ptr tox_friend_lossless_packet_cb -> {- result :: -} ()


--------------------------------------------------------------------------------
--
-- :: Low-level network information
--
--------------------------------------------------------------------------------


-- | 
-- Writes the temporary DHT public key of this instance to a byte array.
--
-- This can be used in combination with an externally accessible IP address and
-- the bound port (from ${tox_self_get_udp_port}) to run a temporary bootstrap node.
--
-- Be aware that every time a new instance is created, the DHT public key
-- changes, meaning this cannot be used to run a permanent bootstrap node.
--
-- @param dht_id A memory region of at least ${TOX_PUBLIC_KEY_SIZE} bytes. If this
--   parameter is NULL, this function has no effect.
--foreign import ccall tox_self_get_dht_id :: {- tox :: -} Ptr Tox -> {- dht_id :: -} Ptr (Word8{-[TOX_PUBLIC_KEY_SIZE]-}) -> {- result :: -} ()

data TOX_ERR_GET_PORT 

  = TOX_ERR_GET_PORT_OK
    -- ^ 
    -- The function returned successfully.
  
  | TOX_ERR_GET_PORT_NOT_BOUND
    -- ^ 
    -- The instance was not bound to any port.
  deriving (Eq, Ord, Enum, Bounded, Read, Show)
-- | 
-- Return the UDP port this Tox instance is bound to.
--foreign import ccall tox_self_get_udp_port :: {- tox :: -} Ptr Tox -> {- error :: -} Ptr TOX_ERR_GET_PORT -> {- result :: -} Word16
-- | 
-- Return the TCP port this Tox instance is bound to. This is only relevant if
-- the instance is acting as a TCP relay.
--foreign import ccall tox_self_get_tcp_port :: {- tox :: -} Ptr Tox -> {- error :: -} Ptr TOX_ERR_GET_PORT -> {- result :: -} Word16
