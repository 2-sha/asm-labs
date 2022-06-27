#include <stdint.h>
#include <stdio.h>

#ifndef BMP_GREY
#define BMP_GREY

typedef struct {
    uint16_t    bfType; // Signature
    uint32_t    bfSize; // Size in bytes

    uint16_t    bfReserved1;
    uint16_t    bfReserved2;

    uint32_t    bfOffBits; // Pixels data position
} BITMAPFILEHEADER;

typedef struct {
    uint32_t    bcSize;

    int32_t     biWidth;
    int32_t     biHeight;

    uint16_t    biPlanes;
    uint16_t    biBitCount;
    uint32_t    biCompression;
    uint32_t    biSizeImage;
    int32_t     biXPelsPerMeter;
    int32_t     biYPelsPerMeter;
    uint32_t    biClrUsed;
    uint32_t    biClrImportant;

    // V4
    uint32_t    bV4RedMask;
    uint32_t    bV4GreenMask;
    uint32_t    bV4BlueMask;
    uint32_t    bV4AlphaMask;
    uint32_t    bV4CSType;
    char        bV4Endpoints[36];
    uint32_t    bV4GammaRed;
    uint32_t    bV4GammaGreen;
    uint32_t    bV4GammaBlue;

    // V5
    uint32_t    bV5Intent;
    uint32_t    bV5ProfileData;
    uint32_t    bV5ProfileSize;
    uint32_t    bV5Reserved;
} BITMAPINFO;

typedef struct {
    BITMAPFILEHEADER bitmapheader;
    BITMAPINFO bitmapinfo;

    uint8_t *palette;
    uint8_t *pixels;
} BMP;


int read_bmp(FILE *fp, BMP *bmp);

int write_bmp(FILE *fp, BMP *bmp);

int get_pixels_size(BMP *bmp);

int make_grey(BMP *bmp, short row_height);

void _make_grey(uint8_t *pixels, short pixels_num, short row_height, short width);

#endif
