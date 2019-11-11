//
//  veridog.v
//  Veridog top level module
//
//  Created by Zakhary Kaplan on 2019-11-11.
//  Copyright © 2019 Zakhary Kaplan. All rights reserved.
//

module veridog(
    input CLOCK_50,         // On Board 50 MHz
    // Your inputs and outputs here
    input [3:0] KEY,        // On Board Keys

    // The ports below are for the VGA output.  Do not change.
    input VGA_CLK,          // VGA Clock
    input VGA_HS,           // VGA H_SYNC
    input VGA_VS,           // VGA V_SYNC
    input VGA_BLANK_N,      // VGA BLANK
    input VGA_SYNC_N,       // VGA SYNC
    input VGA_R,            // VGA Red[9:0]
    input VGA_G,            // VGA Green[9:0]
    input VGA_B             // VGA Blue[9:0]
    );

    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
    vga_adapter VGA(
            .resetn(resetn),
            .clock(CLOCK_50),
            .colour(colour),
            .x(x),
            .y(y),
            .plot(writeEn),
            /* Signals for the DAC to drive the monitor. */
            .VGA_R(VGA_R),
            .VGA_G(VGA_G),
            .VGA_B(VGA_B),
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_BLANK(VGA_BLANK_N),
            .VGA_SYNC(VGA_SYNC_N),
            .VGA_CLK(VGA_CLK));
        defparam VGA.RESOLUTION = "160x120";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "assets/black.mif";

endmodule
