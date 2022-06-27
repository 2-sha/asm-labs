#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include "bmp.h"

int main(int argc, char* argv[]) {
	if (argc < 3) {
		printf("You should specify input and output files\n");
		return 0;
	}
	FILE *in_file = fopen(argv[1], "rb"); 
	if (in_file == NULL) {
		printf("Unable to open file\n");
		perror(argv[1]);
		return 0;
	}

	BMP bmp;
	int bmp_status = read_bmp(in_file, &bmp);
	if (bmp_status != 0) {
		printf("%d\n", bmp_status);
		fclose(in_file);
		return 0;
	}
	fclose(in_file);

	printf("Size: %d x %d px\n", bmp.bitmapinfo.biWidth, bmp.bitmapinfo.biHeight);
	printf("Bit count: %d\n", bmp.bitmapinfo.biBitCount);
	printf("Compression: %d\n", bmp.bitmapinfo.biCompression);

	struct timespec t, t1, t2;
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t1);
	make_grey(&bmp, 16);
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &t2);
	t.tv_sec=t2.tv_sec-t1.tv_sec;
	if ((t.tv_nsec=t2.tv_nsec-t1.tv_nsec)<0){
		t.tv_sec--;
		t.tv_nsec+=1000000000;
	}
	printf("make_grey ASM: %ld.%09ld\n", t.tv_sec, t.tv_nsec);

	FILE *out_file = fopen(argv[2], "wb"); 
	if (out_file == NULL) {
		printf("Unable to open file\n");
		perror(argv[1]);
		return 0;
	}
	write_bmp(out_file, &bmp);
	fclose(out_file);

	free(bmp.pixels);
	return 0;
}