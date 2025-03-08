

#ifndef ZLibHelper_h
#define ZLibHelper_h

unsigned char* zUncompress(const unsigned char *src,unsigned int inSize,unsigned int *outSize);
void zFree(void* data);
unsigned char* zCompress(const unsigned char *src,unsigned int inSize,unsigned int *outSize);

#endif
