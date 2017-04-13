#include "memory_map.h"
#include "types.h"
#include "ascii.h"
#include "uart.h"

#define BUF_LEN 128
int main(void)
{

    int8_t buffer[BUF_LEN];
    TONE_GEN_OUTPUT_ENABLE = 1;
    
    uwrite_int8s("Start Mic\r\n");
    for ( ; ; )
    {
        // Set the volume of the AC97 headphone codec with the DIP switch setting
        AC97_VOLUME = DIP_SWITCHES & 0xF;

        while (MIC_STATUS & 1) ; // wait while mic fifo empty signal is 1
        uint32_t sample = MIC_SAMPLE;

        uwrite_int8s(uint32_to_ascii_hex(sample, buffer, BUF_LEN));
        uwrite_int8s("\r\n");
        
        while(AC97_FULL);   // wait until ac97 fifo is not full
        AC97_DATA = (sample & 0x000FFFFF);

    }

    return 0;
}
