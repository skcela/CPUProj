#include "types.h"
#include "benchmark.h"
#include "ascii.h"
#include "uart.h"

#define N 6
#define DATA (int32_t *) 0x10018000
#define BUF_LEN 128

/* Computes S = AB where A, B, and S are all of 2^N x 2^N matrices. A, B, and S
 * are stored sequentially in row-major order beginning at DATA. Prints the sum
 * of the entries of S to the UART. */

int32_t times(int32_t a, int32_t b) {
    int8_t buffer[BUF_LEN];
    int32_t a_neg = a < 0;
    int32_t b_neg = b < 0;
    int32_t result = 0;
    if (a_neg) a = -a;
    if (b_neg) b = -b;
    uwrite_int8s("\r\nA0: ");
    uwrite_int8s(uint32_to_ascii_hex(a, buffer, BUF_LEN));
    uwrite_int8s("\r\nB0: ");
    uwrite_int8s(uint32_to_ascii_hex(b, buffer, BUF_LEN));
    while (b) {
        uwrite_int8s("\r\nA1: ");
        uwrite_int8s(uint32_to_ascii_hex(a, buffer, BUF_LEN));
        uwrite_int8s("\r\nB1: ");
        uwrite_int8s(uint32_to_ascii_hex(b, buffer, BUF_LEN));
        if (b & 1) {
        	result += a;
        }
        a <<= 1;
        b >>= 1;
        uwrite_int8s("\r\nA2: ");
        uwrite_int8s(uint32_to_ascii_hex(a, buffer, BUF_LEN));
        uwrite_int8s("\r\nB2: ");
        uwrite_int8s(uint32_to_ascii_hex(b, buffer, BUF_LEN));
    }
    if ((a_neg && !b_neg) || (!a_neg && b_neg)) {
        result = -result;
    }
    return result;
}


typedef void (*entry_t)(void);

int main(int argc, char**argv) {
    int8_t buffer[BUF_LEN];
    uint32_t a = 1;
    uint32_t b = 0xABCD;
    uwrite_int8s("\r\nA: ");
    uwrite_int8s(uint32_to_ascii_hex(a, buffer, BUF_LEN));
    uwrite_int8s("\r\nB: ");
    uwrite_int8s(uint32_to_ascii_hex(b, buffer, BUF_LEN));
    uint32_t result = times(a,b);
    uwrite_int8s("\r\nResult: ");
    uwrite_int8s(uint32_to_ascii_hex(result, buffer, BUF_LEN));
    // go back to the bios - using this function causes a jr to the addr,
    // the compiler "jals" otherwise and then cannot set PC[31:28]
    uint32_t bios = ascii_hex_to_uint32("40000000");
    entry_t start = (entry_t) (bios);
    start();
    return result;
}
