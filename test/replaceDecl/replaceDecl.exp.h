
uint8_t foo_bar(Foo *foo);

/**
 * Moop.
 */
struct Foo {

  uint8_t order;
  
};


uint8_t foo_get_order(const Foo *foo);

void foo_set_order(Foo *foo, uint8_t order);

uint8_t foo_cow(Foo *foo);
