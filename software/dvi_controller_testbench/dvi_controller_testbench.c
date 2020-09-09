#include "memory_map.h"
#include "routines.h"

int main(void) {
    // You should test both the fill and swline in simulation
    swline(1, 0, 0, 1024, 768);    
    //fill(1);
    store_pixel(1, 100, 100);
    store_pixel(1, 1023, 100);
    store_pixel(1, 1023, 0);
    while (1) {}
    return 0;
}


