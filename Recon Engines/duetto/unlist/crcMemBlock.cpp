//
// file: crcMemBlock.c
//
// This is the same checksum algorithm used by product acquisition code.
// Therefore, the output of 'rdfTell -S' should generate the same checksum
// as this MATLAB function.
//
// Mex'd April 2013 by Dan Schlifske
//

/*===========================================================================
 *===========================================================================
 *@crcMemBlock
 *
 * Adler-32 CRC Algorithm
 *
 * The original C source is published at
 *     http://en.wikipedia.org/wiki/Adler-32
 *
 * This CRC algorithm was implemented to speed up CRC calculation for acq
 * regression test.
 *
 */
/**
 * The Algorithm
 * =============
 *
 * An Adler-32 checksum is obtained by calculating two 16-bit checksums A
 * and B and concatenating their bits into a 32-bit integer. A is the sum
 * of all bytes in the string plus one, and B is the sum of the individual
 * values of A from each step.
 *
 * At the beginning of an Adler-32 run, A is initialized to 1, B to 0. The
 * sums are done modulo 65521 (the largest prime number smaller than 216).
 * The bytes are stored in network order (big endian), B occupying the two
 * most significant bytes.
 *
 * The function may be expressed as
 *
 *   A = 1 + D1 + D2 + ... + Dn (mod 65521)
 *   B = (1 + D1) + (1 + D1 + D2) + ... + (1 + D1 + D2 + ... + Dn) (mod 65521)
 *     = n * D1 + (n-1) * D2 + (n-2) * D3 + ... + Dn + n (mod 65521)
 *
 *   Adler-32(D) = B * 65536 + A
 *
 * where D is the string of bytes for which the checksum is to be calculated,
 * and n is the length of D.
 *
 *
 * Example
 * =======
 *
 * The Adler-32 sum of the ASCII string "Wikipedia" would be calculated as
 * follows:
 *
 *    ASCII code          A                   B
 *    (shown as base 10)
 *    W: 87           1 +  87 =  88        0 +  88 =   88
 *    i: 105         88 + 105 = 193       88 + 193 =  281
 *    k: 107        193 + 107 = 300      281 + 300 =  581
 *    i: 105        300 + 105 = 405      581 + 405 =  986
 *    p: 112        405 + 112 = 517      986 + 517 = 1503
 *    e: 101        517 + 101 = 618     1503 + 618 = 2121
 *    d: 100        618 + 100 = 718     2121 + 718 = 2839
 *    i: 105        718 + 105 = 823     2839 + 823 = 3662
 *    a: 97         823 +  97 = 920     3662 + 920 = 4582
 *
 *    A = 920  =  398 hex (base 16)
 *    B = 4582 = 11E6 hex
 *
 *    Output = 300286872 = 11E60398 hex
 *
 * (The modulo operation had no effect in this example, since none of the
 * values reached 65521).
 *
 *
 * C Programming Language Implementation
 * =====================================
 *
 *   - data: Pointer to the data to be summed
 *   - len: Length in bytes
 *
 * A few tricks are used here for efficiency:
 *
 * - Most importantly, by using larger (32-bit) temporary sums, it is
 *   possible to sum a great deal of data before needing to reduce modulo
 *   65521. The requirement is that the reduction modulo 65521 must be
 *   performed before the sums overflow, which would cause an implicit
 *   reduction modulo 232 = 4294967296 and corrupt the computation.
 *
 * - The magic value 5550 is the largest number of sums that can be performed
 *   without overflowing b. Any smaller value is also permissible; 4096 may
 *   be convenient in some cases. Because this implementation does not
 *   completely reduce a, its limit is slightly lower than the 5552 mentioned
 *   in the RFC. The proof that 5550 is safe (and 5551 is not) is a bit
 *   intricate, and starts by proving that a can be at most 0x1013a at the
 *   start of the inner loop.
 *
 */
#include <string.h>
#include <stdio.h>
#include <mex.h>

/* Bring these from GEtypes.h*/
typedef char s8;
typedef unsigned char n8;
typedef short s16;
typedef unsigned short n16;
typedef int s32;
typedef unsigned int n32;
typedef float f32;
typedef double f64;

#define MOD_ADLER 65521

n32 crcChecksum(char *startAddress, n32 sizeOfBlock)
{
    n32 a = 1, b = 0;
    s8 *data;
    n32 len=0;
    
    /*
     * Initialize loop accelerator variables
     */
    data = startAddress;
    len = sizeOfBlock;
    
    /*
     * Calculate CRC
     */
    while (len)
    {
        size_t tlen = len > 5550 ? 5550 : len;
        len -= tlen;
        do
        {
            a += *data++;
            b += a;
        } while (--tlen);
        
        a %= MOD_ADLER;
        b %= MOD_ADLER;
    }
    
    return (b << 16) | a;
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mwSize ndims;
    mwSize dims[1];
    
    if ((nrhs != 2) ||(nlhs != 1) )
        mexErrMsgTxt("syntax:\n\t cksum = crcChecksum(data,dataLength)");
    
    n8* data = (n8 *)mxGetPr(prhs[0]);
    n32 dataLength = mxGetScalar(prhs[1]);
    
    
    n32 checksum = crcChecksum(reinterpret_cast<char *>(data), dataLength);
    
    ndims=1;
    dims[0]=1;
    plhs[0]=mxCreateNumericArray(ndims,dims,mxUINT32_CLASS,mxREAL);
    
    n32* pChecksum = (n32 *) mxGetPr(plhs[0]);
    *pChecksum=checksum;
    
}
