//
//  veridog.v
//  Veridog top level module
//
//  Created by Zakhary Kaplan on 2019-11-11.
//  Copyright © 2019 Zakhary Kaplan. All rights reserved.
//

module veridog(
    input CLOCK_50,             // On Board 50 MHz
    input [3:0] KEY,            // On Board Keys
    input [9:0] SW,             // On Board Switches

    // -- DEBUG --
    output [6:0] HEX0, HEX1,    // On Board HEX
    output [6:0] HEX2, HEX3,
    output [6:0] HEX4, HEX5,
    output [9:0] LEDR,          // On Board LEDs
    // -----------

    // The ports below are for the VGA output.
    output VGA_CLK,             // VGA Clock
    output VGA_HS,              // VGA H_SYNC
    output VGA_VS,              // VGA V_SYNC
    output VGA_BLANK_N,         // VGA BLANK
    output VGA_SYNC_N,          // VGA SYNC
    output [7:0] VGA_R,         // VGA Red[9:0]
    output [7:0] VGA_G,         // VGA Green[9:0]
    output [7:0] VGA_B          // VGA Blue[9:0]
    );

    // Reset signal
    wire resetn = KEY[3];

    // VGA wires
    wire [7:0] x;
    wire [6:0] y;
    wire [7:0] colour;
    wire writeEn;
    wire done;

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
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 2;
    defparam VGA.BACKGROUND_IMAGE = "assets/black.mif";


    // -- Local parameters --
    // Locations
    localparam  ROOT    = 4'h0,
                HOME    = 4'h1,
                ARCADE  = 4'h2,
                GAME    = 4'h3;
    // Actions
    localparam  STAY    = 4'h0,
                EAT     = 4'h1,
                SLEEP   = 4'h2;


    // -- Control --
    // Internal wires
    wire doneAction = (doneHomeAction | doneGame);

    // Navigation
    wire startDraw;
    wire [3:0] location, action;
    wire [2:0] keys = ~KEY[2:0];
    navigation NAV(
        .resetn(resetn),
        .clk(CLOCK_50),
        .keys(keys),
        .doneAction(doneAction),
        .transition(startDraw),
        .location(location),
        .action(action)
    );

    // Stats
    wire doneHomeAction;
    wire [7:0] hunger, sleepiness;
    homeActions HOME_ACTIONS(
        .resetn(resetn),
        .clk(CLOCK_50),
        .doEat(action == EAT),
        .doSleep(action == SLEEP),
        .hunger(hunger),
        .sleepiness(sleepiness),
        .done(doneHomeAction)
    );

    // Game
    wire doneGame;
    wire [3:0] gameState;
    gameActions GAME_ACTIONS(
       .resetn(resetn),
       .clk(CLOCK_50),
       .doGame(action == GAME),
       .randIn({hunger[1], sleepiness[0]}),
       .gameState(gameState),
       .done(doneGame)
    );


    // -- VGA --
    vgaSignals VGA_SIGNALS(
        .resetn(resetn),
        .clk(CLOCK_50),
        .start(startDraw),
        .location(location),
        .action(action),
        .gameState(gameState),
        .x(x),
        .y(y),
        .colour(colour),
        .writeEn(writeEn),
        .done(done)
    );


    // -- DEBUG --
    // Navigation
    seg7 hex1(location, HEX1);
    seg7 hex0(action, HEX0);

    // Stats
    seg7 hex5(hunger[7:4], HEX5);
    seg7 hex4(hunger[3:0], HEX4);
    seg7 hex3(sleepiness[7:4], HEX3);
    seg7 hex2(sleepiness[3:0], HEX2);
    // -----------
endmodule
