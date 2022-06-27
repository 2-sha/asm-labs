// https://github.com/python-pillow/Pillow/blob/e6b7730c62992d0e7041b3a93ad87152959e76fa/src/PIL/BmpImagePlugin.py
#include "bmp.h"
#include <stdio.h>

int get_pixels_size(BMP *bmp) {
	return bmp->bitmapheader.bfSize - 14 - bmp->bitmapinfo.bcSize;
}

int read_bmp(FILE *fp, BMP *bmp) {
	// TODO: Если корявый файл, из которого не прочитать

	// Reading BITMAPFILEHEADER
	fread(&bmp->bitmapheader.bfType, 2, 1, fp);
	if (bmp->bitmapheader.bfType != 19778)
		return 1;

	fread(&bmp->bitmapheader.bfSize, 4, 1, fp);
	fread(&bmp->bitmapheader.bfReserved1, 2, 1, fp);
	fread(&bmp->bitmapheader.bfReserved2, 2, 1, fp);
	fread(&bmp->bitmapheader.bfOffBits, 4, 1, fp);

	// Reading BITMAPINFO 
	fread(&bmp->bitmapinfo.bcSize, 4, 1, fp);
	int header_size = bmp->bitmapinfo.bcSize;
	if (header_size == 40 || header_size == 64 || header_size == 108 || header_size == 124) {
		// Core
		fread(&bmp->bitmapinfo.biWidth, 4, 1, fp);
		fread(&bmp->bitmapinfo.biHeight, 4, 1, fp);
		fread(&bmp->bitmapinfo.biPlanes, 2, 1, fp);
		fread(&bmp->bitmapinfo.biBitCount, 2, 1, fp);

		// V3
		fread(&bmp->bitmapinfo.biCompression, 4, 1, fp);
		fread(&bmp->bitmapinfo.biSizeImage, 4, 1, fp);
		fread(&bmp->bitmapinfo.biXPelsPerMeter, 4, 1, fp);
		fread(&bmp->bitmapinfo.biYPelsPerMeter, 4, 1, fp);
		fread(&bmp->bitmapinfo.biClrUsed, 4, 1, fp);
		fread(&bmp->bitmapinfo.biClrImportant, 4, 1, fp);

		// V4
		fread(&bmp->bitmapinfo.bV4RedMask, 4, 1, fp);
		fread(&bmp->bitmapinfo.bV4GreenMask, 4, 1, fp);
		fread(&bmp->bitmapinfo.bV4BlueMask, 4, 1, fp);
		fread(&bmp->bitmapinfo.bV4AlphaMask, 4, 1, fp);
		fread(&bmp->bitmapinfo.bV4CSType, 4, 1, fp);
		fread(&bmp->bitmapinfo.bV4Endpoints, 36, 1, fp);
		fread(&bmp->bitmapinfo.bV4GammaRed, 4, 1, fp);
		fread(&bmp->bitmapinfo.bV4GammaGreen, 4, 1, fp);
		fread(&bmp->bitmapinfo.bV4GammaBlue, 4, 1, fp);

		// V5
		fread(&bmp->bitmapinfo.bV5Intent, 4, 1, fp);
		fread(&bmp->bitmapinfo.bV5ProfileData, 4, 1, fp);
		fread(&bmp->bitmapinfo.bV5ProfileSize, 4, 1, fp);
		fread(&bmp->bitmapinfo.bV5Reserved, 4, 1, fp);

	} else if (header_size == 12) {
		// Not supported
	} else {
		// Error
	}

	int pixels_size = get_pixels_size(bmp);
	bmp->pixels = (uint8_t*)malloc(pixels_size);
	fseek(fp, bmp->bitmapheader.bfOffBits, SEEK_SET);
	fread(bmp->pixels, 1, pixels_size, fp);

	return 0;
}

int write_bmp(FILE *fp, BMP *bmp) {
	// Writing BITMAPFILEHEADER
	fwrite(&bmp->bitmapheader.bfType, 2, 1, fp);
	fwrite(&bmp->bitmapheader.bfSize, 4, 1, fp);
	fwrite(&bmp->bitmapheader.bfReserved1, 2, 1, fp);
	fwrite(&bmp->bitmapheader.bfReserved2, 2, 1, fp);
	fwrite(&bmp->bitmapheader.bfOffBits, 4, 1, fp);

	// Writing BITMAPINFO
	fwrite(&bmp->bitmapinfo.bcSize, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.biWidth, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.biHeight, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.biPlanes, 2, 1, fp);
	fwrite(&bmp->bitmapinfo.biBitCount, 2, 1, fp);
	// V3
	fwrite(&bmp->bitmapinfo.biCompression, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.biSizeImage, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.biXPelsPerMeter, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.biYPelsPerMeter, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.biClrUsed, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.biClrImportant, 4, 1, fp);

	// V4
	fwrite(&bmp->bitmapinfo.bV4RedMask, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.bV4GreenMask, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.bV4BlueMask, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.bV4AlphaMask, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.bV4CSType, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.bV4Endpoints, 36, 1, fp);
	fwrite(&bmp->bitmapinfo.bV4GammaRed, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.bV4GammaGreen, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.bV4GammaBlue, 4, 1, fp);

	// V5
	fwrite(&bmp->bitmapinfo.bV5Intent, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.bV5ProfileData, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.bV5ProfileSize, 4, 1, fp);
	fwrite(&bmp->bitmapinfo.bV5Reserved, 4, 1, fp);

	// Writing pixels
	fwrite(bmp->pixels, 1, bmp->bitmapheader.bfSize - 14 - bmp->bitmapinfo.bcSize, fp);
}

int make_grey(BMP *bmp, short row_height) {
	// printf("ASM\n");
	_make_grey(bmp->pixels, get_pixels_size(bmp), row_height, bmp->bitmapinfo.biWidth);
	// int pixels_size = get_pixels_size(bmp);
	// int width = bmp->bitmapinfo.biWidth * 3;
	// int cur_color = 0;
	// int row_i = 0;
	// for (int i = 0; i < pixels_size; i += width) {
	// 	for (int j = 0; j < width; j += 3) {
	// 		uint8_t grey = 255;
	// 		grey = (bmp->pixels[i + j] < grey) ? bmp->pixels[i + j] : grey;
	// 		grey = (bmp->pixels[i + j + 1] < grey) ? bmp->pixels[i + j + 1] : grey;
	// 		grey = (bmp->pixels[i + j + 2] < grey) ? bmp->pixels[i + j + 2] : grey;

	// 		bmp->pixels[i + j] = 0;
	// 		bmp->pixels[i + j + 1] = 0;
	// 		bmp->pixels[i + j + 2] = 0;
	// 		bmp->pixels[i + j + cur_color] = grey;
	// 	}
	// 	row_i++;
	// 	if (row_i > row_height) {
	// 		row_i = 0;
	// 		cur_color++;
	// 		if (cur_color > 2)
	// 			cur_color = 0;
	// 	}
	// }
}
