// This is where we define the functions we have set up in assembler.  The variable names aren't really important.
// However, the variable type is.  When called from C, the C compiler will push these values on the stack in reverse
// order.

extern void setDataPort(uint8_t stride, uint8_t data_port);
extern void setScreenScale(uint8_t hscale, uint8_t vscale, uint8_t mode);
extern void layer0Setup(uint8_t modeenable, uint8_t mapSize, int16_t mapBase, int16_t font, int16_t hscroll, int16_t vscroll);
extern void layer1Setup(uint8_t modeenable, uint8_t mapSize, int16_t mapBase, int16_t font, int16_t hscroll, int16_t vscroll);
extern void copyData(uint16_t numBytes, uint16_t sourceaddr, uint32_t destaddr);  //This is temporary, need to create a real function here.  For now it will just trigger a local copy.
extern void fillWindow(uint8_t numCols, uint8_t startCol, uint8_t startRow, uint8_t wdth, uint8_t hght, uint8_t chr, uint8_t clr, uint32_t layerMap);  //, uint8_t numCols, uint8_t startCol, uint8_t startRow, uint8_t width, uint8_t height, uint8_t char, uint8_t color
extern void fillChar(uint8_t numCols, uint8_t startCol, uint8_t startRow, uint8_t chr, uint8_t clr, uint32_t layerMap);

// Various memory addresses Vera uses.  These are values that need to be passed from the C program to the Assembly language functions
// For one reason or another.  This gives them some nicer names that can be used from C.

#define FONT_ASCII		0x1E800		// iso ascii font
#define FONT_UPETSCII	0x1F000		// PETSCII uppercase
#define FONT_LPETSCII	0x1F800		// PETSCII lowercase
#define PALETTE			0xF1000

#define L0_MAP_BASE		0x00000		// I don't think these should be veralib constants, because they're user defined.
#define L1_MAP_BASE		0x04000		// 0x04000



// Since it's much less work to shift 2 bits to the right in a 24 bit address, I felt it would be better
// to create these definitions in C.  It, also, shows how you can add C functionality to your Assembly language
// library functions.


void mlayer0Setup(uint8_t modeenable, uint8_t mapSize, int32_t mapBase, int32_t font, int16_t hscroll, int16_t vscroll)
{
	layer0Setup(modeenable, mapSize, (mapBase >> 2), (font >> 2), hscroll, vscroll);
}

void mlayer1Setup(uint8_t modeenable, uint8_t mapSize, int32_t mapBase, int32_t font, int16_t hscroll, int16_t vscroll)
{
	layer1Setup(modeenable, mapSize, (mapBase >> 2), (font >> 2), hscroll, vscroll);
}
