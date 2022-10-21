#ifndef TSP_H
#define TSP_H

#define CTRL          0x000
#define DEV_CTRL	  0x14c // Control device
// #define DEV_CTRL             0x0004 // Control device
#define DUMP	      0x150 // Write and read to check device


// #define RESULT               0xC
#define ADDRESS_C0_L         0x10
#define ADDRESS_LENGTH       0x190
#define START_ADDRESS        0x110 // Begin address (assign for first file)
#define FILE_SIZE	         0x118 // File size (in byte)


#define TSP_DEV_CTRL_RESET      0x1
#define TSP_DEV_CTRL_CONTINUE   0x2
#define TSP_DEV_CTRL_MODE_1BYTE 0x0
#define TSP_DEV_CTRL_MODE_2BYTE 0x4
#define TSP_DEV_CTRL_MODE_3BYTE 0x8
#define TSP_DEV_CTRL_MODE_4BYTE 0xC
#define TSP_DEV_CTRL_LOADTEXT   0x10
#define TSP_DEV_CTRL_START      0x20

// #define TSP_KEY                 0x00c // Input key
#define TSP_KEY	                0x154 // Input key

#define TSP_SET_KEY_LEN(x)      (x & 0xFF)      //must
#define TSP_SET_KEY_X(x)        (x & 0xFF)      //must    
#define TSP_SET_KEY_MASK        0x0100          //rarely
#define TSP_SET_KET_END_GAP     0x0200          //rarely
#define TSP_SET_KEY_BEGIN_GAP   0x0400          //rarely
#define TSP_SET_KEY_LAST_BYTE   0x0800          //possible
#define TSP_SET_KEY_FIRST_BYTE  0x1000          //possible    
#define TSP_SET_KEY_LAST_KEY    0x2000          //must

#define RESULT		  0x120 // Direct address result
#define MATCH_COUNT   0x124 // Number of matches
#define BITSTREAM	  0x128 // Bitstream result
#define BASHCODE	  0x130 // Bash number of a file (when file is bigger than 32KB)
#define NEXT_ADDRESS  0x134 // Next physical address (optional read)
#define NEXT_FILESIZE 0x13c // Remain file size (after each bash)
#define BASH_OFFSET	  0x144 // Bash offset (add with address result to find exact result)
//========================================================
// Optional
#define DEBUG0		  0x14c
#define DEBUG1		  0x15c
#define DEBUG2		  0x154
#define DEBUG3		  0x158

/*
Register: CTRL_OFFSET -> Read status
----------------------------------------------------
| Device done | Load text done | Overlap | Reserve |
----------------------------------------------------
|      6      |       5        |    4    |   3:0   |
----------------------------------------------------
*/
// CTRL_OFFSET value
#define DEV_DONE 0x40
#define LOAD_DONE_MASK 0x20

/*
Register: DEV_CTRL -> Control device
--------------------------------------------------------------
|start device | load text | byte mode (2) | continue | reset |
--------------------------------------------------------------
|     5       |      4    |      3:2      |    1     |   0   |
--------------------------------------------------------------
*/
// DEV_CTRL value
#define DEV_RESET 		0x1
#define DEV_CONTINUE 	0x2
#define DEV_MODE1B 		0x0
#define DEV_MODE2B 		0x4
#define DEV_MODE3B 		0x8
#define DEV_MODE4B 		0xc
#define DEV_LOADTEXT	0x10
#define DEV_START 		0x20

/*
Register: KEY -> Input keyword
----------------------------------------------------
| first | last | begin gap | end gap | mask | data |
----------------------------------------------------
|  12   |  11  |    10     |    9    |  8   | 7:0  |
----------------------------------------------------
*/
// KEY value 
#define KEY_FIRST 0x1000
#define KEY_LAST  0x0800
#define GAP_BEGIN 0x0400
#define GAP_END   0x0200
#define KEY_MASK  0x0100

#endif //TSP_H



