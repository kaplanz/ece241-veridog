//
//  veridog.v
//  Veridog top level module
//
//  Created by Zakhary Kaplan on 2019-11-11.
//  Copyright © 2019 Zakhary Kaplan. All rights reserved.
//

module veridog(
    input CLOCK_50,         // On Board 50 MHz
    input [3:0] KEY,        // On Board Keys
    input [9:0] SW,         // On Board Switches

    output [6:0] HEX0, HEX1,// On Board HEX
    // The ports below are for the VGA output.  Do not change.
    output VGA_CLK,         // VGA Clock
    output VGA_HS,          // VGA H_SYNC
    output VGA_VS,          // VGA V_SYNC
    output VGA_BLANK_N,     // VGA BLANK
    output VGA_SYNC_N,      // VGA SYNC
    output VGA_R,           // VGA Red[9:0]
    output VGA_G,           // VGA Green[9:0]
    output VGA_B            // VGA Blue[9:0]
    );

    // Reset signal
    wire resetn = SW[9];

    // VGA wires
    reg [7:0] x;
    reg [6:0] y;
    reg [8:0] colour;
    wire writeEn;

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


    // -- Control --

    // Navigation
    wire [4:0] location, activity;
    wire [2:0] keys = ~KEY[2:0];
    navigation nav(
        .resetn(resetn),
        .clk(CLOCK_50),
        .keys(keys),
        .location(location),
        .activity(activity)
    );


    // State registers
    reg [8:0] hunger;
    reg [8:0] tiredness;


    // -- VGA --

    // VGA drawing
    reg start;
    wire done;

    wire [8:0] xBg;
    wire [7:0] yBg;
    wire wBg;
    wire doneBg;

    draw drawBg(
        .resetn(resetn),
        .clk(CLOCK_50),
        .start(start),
        .xInit(1'b0),
        .yInit(1'b0),
        .xOut(xBg),
        .yOut(yBg),
        .writeEn(wBg),
        .done(doneBg));
    defparam    drawBg.X_WIDTH = 8,
                drawBg.Y_WIDTH = 7,
                drawBg.X_MAX = 160,
                drawBg.Y_MAX = 120;


    // Image ROMs
    wire [7:0] cHome;
    rom160x120 homeROM(
        .address(xBg + 160 * yBg),
        .clock(CLOCK_50),
        .q(cHome));
    defparam homeROM.altsyncram_component.init_file = "./assets/home.mif";

    wire [7:0] cArcade;
    rom160x120 arcadeROM(
        .address(xBg + 160 * yBg),
        .clock(CLOCK_50),
        .q(cArcade));
    defparam arcadeROM.altsyncram_component.init_file = "./assets/arcade.mif";


    // VGA signal assignments
    assign writeEn = (wBg);
    assign done = (doneBg);

    localparam  ROOT     = 4'h0,
                HOME     = 4'h1,
                ARCADE   = 4'h2;

    always @(posedge (location != ROOT)) // FIXME
    begin: vgaStart
        start = 1'b1;
    end // vgaStart

    always @(*)
    begin: vgaSignals
        x <= xBg;
        y <= yBg;

        case (location)
            HOME: colour <= cHome;
            ARCADE: colour <= cArcade;
            default: colour <= 8'bz;
        endcase

        if (done)
            start <= 1'b0;
    end // vgaSignals


    // -- DEBUG --
    seg7 hex1(location, HEX1);
    seg7 hex0(activity, HEX0);
endmodule
