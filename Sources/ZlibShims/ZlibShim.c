//
//  sysZlibShim.c
//  Zlib
//
//  Created by David Scrève on 07/03/2025.
//

#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <assert.h>
#include <zlib.h>
#include <stdio.h>

#define CHUNK 16384
#define max(x, y) (((x) > (y)) ? (x) : (y))
#define min(x, y) (((x) < (y)) ? (x) : (y))


void zFree(void* data) {
    if (NULL!=data) {
        free(data);
    }
}
unsigned char* zCompress(const unsigned char *src,unsigned int inSize,unsigned int *outSize) {
    int ret, flush;
    z_stream strm;
    unsigned char in[CHUNK];
    unsigned char out[CHUNK];

    unsigned long remaining;
    unsigned char *result;
    const unsigned char *currentIn;
    unsigned long readSize;
    unsigned long have;
    
    result = malloc(0);
    remaining = inSize;
    *outSize=0;
    currentIn=src;
    /* allocate deflate state */
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
  //  ret = deflateInit(&strm, Z_DEFAULT_COMPRESSION);
    
    ret = deflateInit2(&strm, Z_DEFAULT_COMPRESSION,Z_DEFLATED, -MAX_WBITS, MAX_MEM_LEVEL, Z_DEFAULT_STRATEGY);
    if (ret != Z_OK) {
        free(result);
        return NULL;
    }
    
    /* compress until end of file */
    do {
        readSize = min(CHUNK,remaining);
        memcpy(in,currentIn,readSize);
        currentIn+=readSize;
        remaining-=readSize;
        strm.avail_in = (unsigned int)readSize;
        
        flush = (remaining==0) ? Z_FINISH : Z_NO_FLUSH;
        strm.next_in = in;
        
        /* run deflate() on input until output buffer not full, finish
         compression if all of source has been read in */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = out;
            ret = deflate(&strm, flush);    /* no bad return value */
            assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
            have = CHUNK - strm.avail_out;
            
            result=realloc(result,(*outSize)+have);
            memcpy(result+(*outSize),out,have);
        
            (*outSize)+=have;
        } while (strm.avail_out == 0);
        assert(strm.avail_in == 0);     /* all input will be used */
        
        /* done when last data in file processed */
    } while (flush != Z_FINISH);
    assert(ret == Z_STREAM_END);        /* stream will be complete */
    
    /* clean up and return */
    deflateEnd(&strm);
     return result;
}


  /* Decompress from file source to file dest until stream ends or EOF.
     inf() returns Z_OK on success, Z_MEM_ERROR if memory could not be
     allocated for processing, Z_DATA_ERROR if the deflate data is
     invalid or incomplete, Z_VERSION_ERROR if the version of zlib.h and
     the version of the library linked do not match, or Z_ERRNO if there
     is an error reading or writing the files. */
unsigned char* zUncompress(const unsigned char *src,unsigned int inSize,unsigned int *outSize) {
    int ret;
    unsigned have;
    z_stream strm;
    unsigned char in[CHUNK];
    unsigned char out[CHUNK];
    
    unsigned int remaining;
    unsigned char *result;
    const unsigned char *currentIn;
    unsigned int readSize;

    result = malloc(0);
    remaining = inSize;
    *outSize=0;
    currentIn=src;

    /* allocate inflate state */
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.avail_in = 0;
    strm.next_in = Z_NULL;
        
    ret = inflateInit2(&strm,-MAX_WBITS);
    if (ret != Z_OK) {
        free(result);
        return NULL;
    }
    
    
    /* decompress until deflate stream ends or end of file */
    do {
        readSize = min(CHUNK,remaining);
        memcpy(in,currentIn,readSize);
        currentIn+=readSize;
        remaining-=readSize;
        strm.avail_in = (unsigned int)readSize;
        
        if (strm.avail_in == 0)
            break;
        strm.next_in = in;
        
        /* run inflate() on input until output buffer not full */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = out;
            ret = inflate(&strm, Z_NO_FLUSH);
            assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
            switch (ret) {
                case Z_NEED_DICT:
                    ret = Z_DATA_ERROR;     /* and fall through */
                case Z_DATA_ERROR:
                 case Z_MEM_ERROR:
                    inflateEnd(&strm);
                    free(result);
                    return NULL;
            }
            have = CHUNK - strm.avail_out;
            result=realloc(result,(*outSize)+have);
            memcpy(result+(*outSize),out,have);
            (*outSize)+=have;
        } while (strm.avail_out == 0);
        
        /* done when inflate() says it's done */
    } while (ret != Z_STREAM_END);
    
    /* clean up and return */
    (void)inflateEnd(&strm);
    if (ret == Z_STREAM_END) {
        return result;
    }
    else {
        free(result);
        return NULL;
    }
}

