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

    wire resetn = SW[9];
    reg [3:0] colour;
    reg [7:0] x;
    reg [6:0] y;
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


    // VGA drawing
    reg [3:0] start;
    wire done;

    localparam  ROOT     = 4'h0,
                HOME     = 4'h1,
                ARCADE   = 4'h2;

    wire [8:0] xHome;
    wire [7:0] yHome;
    wire cHome;
    wire drawHome;

    draw #(8, 7, 160, 120) home(
        .resetn(resetn),
        .clk(CLOCK_50),
        .start(start == HOME),
        .xInit(1'b0),
        .yInit(1'b0),
        .xOut(xHome),
        .yOut(yHome),
        .colour(colourHome),
        .writeEn(drawHome),
        .done(doneHome)
    );


    // VGA signal assignments
    assign writeEn = (drawHome);
    assign done = (doneHome);

    always @(location, done)
    begin: vgaSignals
        start = (~done) ? location : ROOT;

        case (start)
            HOME: begin
                x = xHome;
                y = yHome;
                colour = cHome;
            end
        endcase
    end // vgaSignals



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


    // DEBUG
    seg7 hex1(location, HEX1);
    seg7 hex0(activity, HEX0);
endmodule
