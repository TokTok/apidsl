
/**
 * The call state is a set of operations that are currently being performed.
 * A value of 0 means we are neither sending nor receiving anything, meaning,
 * one of the sides requested pause. The call will be resumed once the side
 * that initiated pause resumes it.
 */
enum TOXAV_CALL_STATE {

  /**
   * The empty bit mask. None of the bits specified below are set.
   */
  TOXAV_CALL_STATE_NONE = 0,
  
  /**
   * The friend is sending audio (we are receiving).
   */
  TOXAV_CALL_STATE_SENDING_A = 1,
  
  /**
   * The friend is sending video (we are receiving).
   */
  TOXAV_CALL_STATE_SENDING_V = 2,
  
  /**
   * The friend is receiving audio (we are sending).
   */
  TOXAV_CALL_STATE_RECEIVING_A = 4,
  
  /**
   * The friend is receiving video (we are sending).
   */
  TOXAV_CALL_STATE_RECEIVING_V = 8,
  
  /**
   * The call has finished. This is the final state after which no more state
   * transitions can occur for the call.
   */
  TOXAV_CALL_STATE_END = 16,
  
  /**
   * Set by the AV core if an error occurred on the remote end. This call
   * state will never be triggered in combination with other call states.
   */
  TOXAV_CALL_STATE_ERROR = 32,
  
};

