#include "memory_map.h"

int main(void)
{
    TONE_GEN_OUTPUT_ENABLE = 1;
 
    for ( ; ; )
    {
        // Set the volume of the AC97 headphone codec with the DIP switch setting
        AC97_VOLUME = DIP_SWITCHES & 0xF;

        while (MIC_STATUS & 1) ; // wait while mic fifo empty signal is 1
        uint32_t sample = MIC_SAMPLE;

        while(AC97_FULL);	// wait until ac97 fifo is not full
        AC97_DATA = sample;

    }

    return 0;
}
