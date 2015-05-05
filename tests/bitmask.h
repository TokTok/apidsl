bitmask USER_STATUS {
  /**
   * User is online and available.
   */
  NONE,
  /**
   * User is away. Clients can set this e.g. after a user defined
   * inactivity time.
   */
  AWAY,
  /**
   * User is busy. Signals to other clients that this client does not
   * currently wish to communicate.
   */
  BUSY,
}
