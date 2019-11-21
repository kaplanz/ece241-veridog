//
//  vgaSignals.v
//  VGA input signals
//
//  Created by Zakhary Kaplan on 2019-11-20.
//  Copyright © 2019 Zakhary Kaplan. All rights reserved.
//

module vgaSignals(
        input resetn,
        input clk,
        input start,
        input [3:0] location, activity,

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
    localparam  STAY    = 4'h0,
                EAT     = 4'h1,
                SLEEP   = 4'h2;


    // -- Drawing data --
    // Internal wires
    wire [7:0] xHome, xArcade, xDog;
    wire [6:0] yHome, yArcade, yDog;
    wire [7:0] cHome, cArcade, cDog;
    wire wHome, wArcade, wDog;
    wire dHome, dArcade, dDog;

    // Start signals
    wire sHome = (start & (location == HOME));
    wire sArcade = (start & (location == ARCADE));
    wire sDog = doneBg;

    // Done signals
    wire doneBg = (dHome | dArcade);
    wire doneFg = (dDog);

    // Module instantiations
    // Home
    draw DRAW_HOME(
        .resetn(resetn),
        .clk(clk),
        .start(sHome),
        .xInit(8'd0),
        .yInit(7'd0),
        .xOut(xHome),
        .yOut(yHome),
        .colour(cHome),
        .writeEn(wHome),
        .done(dHome)
    );
    defparam DRAW_HOME.X_WIDTH = 8;
    defparam DRAW_HOME.Y_WIDTH = 7;
    defparam DRAW_HOME.X_MAX = 160;
    defparam DRAW_HOME.Y_MAX = 120;
    defparam DRAW_HOME.IMAGE = "assets/home.mif";

    // Arcade
    draw DRAW_ARCADE(
        .resetn(resetn),
        .clk(clk),
        .start(sArcade),
        .xInit(8'd0),
        .yInit(7'd0),
        .xOut(xArcade),
        .yOut(yArcade),
        .colour(cArcade),
        .writeEn(wArcade),
        .done(dArcade)
    );
    defparam DRAW_ARCADE.X_WIDTH = 8;
    defparam DRAW_ARCADE.Y_WIDTH = 7;
    defparam DRAW_ARCADE.X_MAX = 160;
    defparam DRAW_ARCADE.Y_MAX = 120;
    defparam DRAW_ARCADE.IMAGE = "assets/arcade.mif";

    // Dog
    draw DRAW_DOG(
        .resetn(resetn),
        .clk(clk),
        .start(doneBg),
        .xInit(8'd60),
        .yInit(7'd80),
        .xOut(xDog),
        .yOut(yDog),
        .colour(cDog),
        .writeEn(wDog),
        .done(dDog)
    );
    defparam DRAW_DOG.X_WIDTH = 6;
    defparam DRAW_DOG.Y_WIDTH = 6;
    defparam DRAW_DOG.X_MAX = 40;
    defparam DRAW_DOG.Y_MAX = 40;
    defparam DRAW_DOG.IMAGE = "assets/dog1.mif";


    // -- Control --
    // Declare state values
    localparam  IDLE    = 4'h0,
                DRAW_BG = 4'h1,
                DRAW_FG = 4'h2,
                DONE    = 4'h3;

    // State register
    reg [3:0] currentState;

    // Assign outputs
    assign writeEn = (wHome | wArcade | wDog) & (colour != 8'b001001); // ignore "green screen" colour
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
