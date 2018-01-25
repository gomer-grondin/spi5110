// gpio definitions

// Address of GPIO controllers
#define GPIO0 0x44E07000
#define GPIO1 0x4804C000
#define GPIO2 0x481AC000
#define GPIO3 0x481AE000

#define GPIO_DATAIN       0x138
#define GPIO_CLEARDATAOUT 0x190
#define GPIO_SETDATAOUT   0x194
#define GPIO_OE           0x134   // output enable

#define GPIO0_hi          0x44E07194
#define GPIO0_low         0x44E07190
#define GPIO0_datain      0x44E07138
#define GPIO0_OE          0x44E07134
#define GPIO1_hi          0x4804C194
#define GPIO1_low         0x4804C190
#define GPIO1_datain      0x4804C138
#define GPIO1_OE          0x4804C134
#define GPIO2_hi          0x481AC194
#define GPIO2_low         0x481AC190
#define GPIO2_datain      0x481AC138
#define GPIO2_OE          0x481AC134
#define GPIO3_hi          0x481AE194
#define GPIO3_low         0x481AE190
#define GPIO3_datain      0x481AE138
#define GPIO3_OE          0x481AE134

#define P8_13             0x17    // GPIO0
#define P8_14             0x1A    // GPIO0
#define P8_17             0x1B    // GPIO0
#define P8_19             0x16    // GPIO0

#define P8_11             0x0D    // GPIO1
#define P8_12             0x0C    // GPIO1
#define P8_15             0x0F    // GPIO1
#define P8_16             0x0E    // GPIO1

#define P8_07             0x02    // GPIO2
#define P8_08             0x03    // GPIO2
#define P8_09             0x05    // GPIO2
#define P8_10             0x04    // GPIO2
#define P8_18             0x01    // GPIO2

#define P9_14             0x12    // GPIO1
#define P9_15             0x10    // GPIO1
#define P9_16             0x13    // GPIO1
#define P9_23             0x11    // GPIO1

#define P8_07_bitmap      0x00000002
#define P8_08_bitmap      0x00000004
#define P8_09_bitmap      0x00000010
#define P8_10_bitmap      0x00000008
#define P8_11_bitmap      0x00002000
#define P8_12_bitmap      0x00001000
#define P8_13_bitmap      0x00800000
#define P8_14_bitmap      0x04000000
#define P8_15_bitmap      0x00008000
#define P8_16_bitmap      0x00004000
#define P8_17_bitmap      0x08000000
#define P8_18_bitmap      0x00000001
#define P8_19_bitmap      0x00400000
#define P9_14_bitmap      0x00040000
#define P9_15_bitmap      0x00010000
#define P9_16_bitmap      0x00080000
#define P9_23_bitmap      0x00020000
