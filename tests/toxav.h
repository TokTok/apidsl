/**
 * External Tox type.
 */
class tox {
  struct this;
}

/**
 * ToxAv.
 */
class toxAv {

  struct this;

  namespace outer {
    namespace inner {

      /**
       * Using external Tox type.
       */
      uint32_t new (tox_t *messenger, uint32_t ma);

      /**
       * Same thing.
       */
      uint32_t new2 (tox::this *messenger, uint32_t ma);

    }
  }

  static this new (tox::this *messenger, uint32_t max_calls);

}
