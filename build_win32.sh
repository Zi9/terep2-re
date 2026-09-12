#openwatcom needs to be correctly set up for this to run
#this include is necessary for the github build
cd reasm32
    nasm -f win32 -DWIN32 the_thing.asm
cd ..
i686-w64-mingw32-windres -DDEBUGMENU -i win32/menu.rc -o win32/menu.o
i686-w64-mingw32-gcc -DDEBUGMENU -std=c99 -m32 -mwindows -O2 -o terep2re32.exe reasm32/the_thing.obj win32/terep2re.c win32/menu.o -lshell32 -luser32 -lole32 -lgdi32
