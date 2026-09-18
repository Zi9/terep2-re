#include <stdint.h>
#include <stdio.h>
#include <windows.h>
#include "common.h"
#include "resource.h"

extern volatile uintptr_t all_segments[];
extern volatile call_portal_t call_portal[];
extern volatile uint8_t  base_mem[];

extern st_image gameImg;

void drawTheFramebuffer(HDC hdc,int scale){
    int videoSegSel = base_mem[0xdb10];
    void *video = (void*)all_segments[videoSegSel];

    if(scale == T2_SCALE_P2){
        StretchDIBits(hdc,
            0,  0, 320*2, 200*2,
            0,  0, 320, 200,
            video, (void *)&gameImg,
            DIB_RGB_COLORS, SRCCOPY
        );
        return;
    }
    if(scale == T2_SCALE_S3){
        StretchDIBits(hdc,
            0,  0, 320*5, 200*6,
            0,  0, 320, 200,
            video, (void *)&gameImg,
            DIB_RGB_COLORS, SRCCOPY
        );
        return;
    }

    //defaults to tiny 1:1
    SetDIBitsToDevice(hdc,
        0, 0, 320, 200,
        0, 0, 0, 200,
        video, (void *)&gameImg,
        DIB_RGB_COLORS);
    
}


void prepare_bitmap_info(int w, int h, st_image *bminfo, uint8_t *palette){
    BITMAPINFOHEADER bih = {
        .biSize = sizeof(BITMAPINFOHEADER),
        .biPlanes = 1,
        .biBitCount = 8,
        .biCompression = BI_RGB,
    };

    bih.biWidth = w;
    bih.biHeight = -h,
    bih.biSizeImage = w * h;

    bminfo->info = bih;

    if(palette == NULL){
        return;
    }

    uint8_t *ptr = palette;
    for(int i =0; i<256;i++){
        bminfo->palette[i].rgbRed   = ptr[0];
        bminfo->palette[i].rgbGreen = ptr[1];
        bminfo->palette[i].rgbBlue  = ptr[2];
        ptr += 3;
    }
}