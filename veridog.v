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
    // output [6:0] HEX2, HEX3,
    // output [6:0] HEX4, HEX5,
    // output [9:0] LEDR,          // On Board LEDs
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
                ARCADE  = 4'h2;
    // Activities
    localparam  IDLE    = 4'h1,
                EAT     = 4'h2,
                SLEEP   = 4'h3;


    // -- Control --
    // Navigation
    wire start;
    wire [3:0] location, activity;
    wire [2:0] keys = ~KEY[2:0];
    navigation nav(
        .resetn(resetn),
        .clk(CLOCK_50),
        .keys(keys),
        .transition(start),
        .location(location),
        .activity(activity)
    );

    // Stats
    wire divEn;
    statsSlowCounter DIV(CLOCK_50, divEn);

    wire eatEn;
    wire doneEat;

    wire [6:0] hunger;

    hungerCounter HUNGER(
        .slowClk(divEn),
        .eating(eatEn),
        .doneEating(doneEat),
        .fullLevel(hunger)
    );


    // -- VGA --
    // -- Background --
    // Drawing wires
    wire [7:0] xHome, xArcade;
    wire [6:0] yHome, yArcade;
    wire [7:0] cHome, cArcade;
    wire wHome, wArcade;
    wire dHome, dArcade;

    // Drawing modules
    // Home
    draw drawHome(
        .resetn(resetn),
        .clk(CLOCK_50),
        .start(start & (location == HOME)),
        .xInit(8'd0),
        .yInit(7'd0),
        .xOut(xHome),
        .yOut(yHome),
        .colour(cHome),
        .writeEn(wHome),
        .done(dHome)
    );
    defparam drawHome.IMAGE = "assets/home.mif";

    // Arcade
    draw drawArcade(
        .resetn(resetn),
        .clk(CLOCK_50),
        .start(start & (location == ARCADE)),
        .xInit(8'd0),
        .yInit(7'd0),
        .xOut(xArcade),
        .yOut(yArcade),
        .colour(cArcade),
        .writeEn(wArcade),
        .done(dArcade)
    );
    defparam drawArcade.IMAGE = "assets/arcade.mif";

    // -- Foreground --
    // Drawing wires
    wire [7:0] xDog;
    wire [6:0] yDog;
    wire [7:0] cDog;
    wire wDog;
    wire dDog;

    // Drawing modules
    // Dog
    draw drawDog(
        .resetn(resetn),
        .clk(CLOCK_50),
        .start(dHome | dArcade), // FIXME
        .xInit(8'd60),
        .yInit(7'd80),
        .xOut(xDog),
        .yOut(yDog),
        .colour(cDog),
        .writeEn(wDog),
        .done(dDog)
    );
    defparam drawDog.X_WIDTH = 6;
    defparam drawDog.Y_WIDTH = 6;
    defparam drawDog.X_MAX = 40;
    defparam drawDog.Y_MAX = 40;
    defparam drawDog.IMAGE = "assets/dog1.mif";

    vgaSignals VGA_SIGNALS(
        .resetn(resetn),
        .clk(CLOCK_50),
        .start(start),
        .location(location),
        .activity(activity),
        .xHome(xHome), .yHome(yHome), .cHome(cHome), .wHome(wHome), .dHome(dHome),
        .xArcade(xArcade), .yArcade(yArcade), .cArcade(cArcade), .wArcade(wArcade), .dArcade(dArcade),
        .xDog(xDog), .yDog(yDog), .cDog(cDog), .wDog(wDog), .dDog(dDog),
        .x(x),
        .y(y),
        .colour(colour),
        .writeEn(writeEn),
        .done(done)
    );


    // -- DEBUG --
    // seg7 hex5(hunger[6:4], HEX5);
    // seg7 hex4(hunger[3:0], HEX4);
    // seg7 hex5(x[3:0], HEX5);
    // seg7 hex4(y[3:0], HEX4);
    seg7 hex1(location, HEX1);
    seg7 hex0(activity, HEX0);
    // assign LEDR[9] = done;
    // assign LEDR[8] = writeEn;
    // -----------
endmodule


module vgaSignals(
        input resetn,
        input clk,
        input start,
        input [3:0] location, activity,
        input [7:0] xHome, xArcade, xDog,
        input [6:0] yHome, yArcade, yDog,
        input [7:0] cHome, cArcade, cDog,
        input wHome, wArcade, wDog,
        input dHome, dArcade, dDog,

        output reg [7:0] x,
        output reg [6:0] y,
        output reg [7:0] colour,
        output writeEn,
        output done
    );

    // -- Local parameters --
    // Locations
    localparam  ROOT    = 4'h0,
        HOME    = 4'h1,
        ARCADE  = 4'h2;
    // Activities
    localparam  NONE    = 4'h1,
        EAT     = 4'h2,
        SLEEP   = 4'h3;

    // Declare state values
    localparam  IDLE    = 2'h0,
        DRAW_BG = 2'h1,
        DRAW_FG = 2'h2,
        DONE    = 2'h3;

    // State register
    reg [1:0] currentState;

    // Internal wires
    wire doneBg = (dHome | dArcade);
    wire doneFg = (dDog);

    // Assign outputs
    assign writeEn = (wHome | wArcade | wDog) & (colour != 8'b001001);
    assign done = (currentState == DONE);

    // Update state registers, perform incremental logic
    always @(posedge clk)
    begin: stateFFs
        if (!resetn) begin
            currentState <= IDLE;
        end
        else begin
            case (currentState)
                IDLE: begin
                    currentState <= (start) ? DRAW_BG: IDLE;
                    x <= 8'b0; // reset x
                    y <= 7'b0; // reset y
                    colour <= 8'b0; // reset colour
                end

                DRAW_BG: begin
                    currentState <= (doneBg) ? DRAW_FG : DRAW_BG;
                    case (location)
                        HOME: begin
                            x <= xHome;
                            y <= yHome;
                            colour <= cHome;
                        end
                        ARCADE: begin
                            x <= xArcade;
                            y <= yArcade;
                            colour <= cArcade;
                        end
                        default: begin
                            x <= 8'bz;
                            y <= 7'bz;
                            colour <= 8'bz;
                        end
                    endcase
                end

                DRAW_FG: begin
                    currentState <= (doneFg) ? DONE : DRAW_FG;
                    x <= xDog;
                    y <= yDog;
                    colour <= cDog;
                end

                DONE:
                    currentState <= (~start) ? IDLE : DONE;

                default:
                    currentState <= IDLE;
            endcase
        end
    end // stateFFs
endmodule
