class fooBar
{
  struct this;

  event thing {
    /**
     * yoy
     */
    typedef void();
  }

  namespace bleh {
    event thing {
      /**
       * yoy
       */
      typedef void();
    }

    event otherthing const {
      /**
       * Heyo haha.
       */
      typedef `a(uint32_t fluff);
    }
  }

  `a iterate(`a user_data);

  any iterate2(any user_data);
}
