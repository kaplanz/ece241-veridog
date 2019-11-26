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
        input [3:0] location, action, gameState,

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
    // Actions
    localparam  STAY    = 4'h0,
                EAT     = 4'h1,
                SLEEP   = 4'h2;
    // Game states
    localparam  SPIN    = 4'h1,
                NUN     = 4'h2,
                GIMEL   = 4'h3,
                HAY     = 4'h3,
                SHIN    = 4'h4;


    // -- Drawing data --
    // Internal wires
    wire sHome, sArcade, sGame, sDog, sSpin, sNun, sGimel, sHay, sShin;
    wire [7:0] xHome, xArcade, xGame, xDog, xSpin, xNun, xGimel, xHay, xShin;
    wire [6:0] yHome, yArcade, yGame, yDog, ySpin, yNun, yGimel, yHay, yShin;
    wire [7:0] cHome, cArcade, cGame, cDog, cSpin, cNun, cGimel, cHay, cShin;
    wire wHome, wArcade, wGame, wDog, wSpin, wNun, wGimel, wHay, wShin;
    wire dHome, dArcade, dGame, dDog, dSpin, dNun, dGimel, dHay, dShin;
    wire doneBg, doneFg;

    // Start signals
    assign sHome = (start & (location == HOME));
    assign sArcade = (start & (location == ARCADE));
    assign sGame = (start & location == GAME));
    assign sDog = (doneBg & (activity != GAME)));
    assign sSpin = (doneBg & (activity == GAME));
    assign sNun = (dSpin & (gameState == NUN));
    assign sGimel = (dSpin & (gameState == GIMEL));
    assign sHay = (dSpin & (gameState == HAY));
    assign sShin = (dSpin & (gameState == SHIN));

    // Done signals
    assign doneBg = (dHome | dArcade | dGame);
    assign doneFg = (dDog | dSpin | dNun | dGimel | dHay | dShin);

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

    // Game
    draw DRAW_GAME(
        .resetn(resetn),
        .clk(clk),
        .start(sGame),
        .xInit(8'd0),
        .yInit(7'd0),
        .xOut(xGame),
        .yOut(yGame),
        .colour(cGame),
        .writeEn(wGame),
        .done(dGame)
    );
    defparam DRAW_ARCADE.X_WIDTH = 8;
    defparam DRAW_ARCADE.Y_WIDTH = 7;
    defparam DRAW_ARCADE.X_MAX = 160;
    defparam DRAW_ARCADE.Y_MAX = 120;
    defparam DRAW_ARCADE.IMAGE = "assets/table.mif";

    // Dog
    draw DRAW_DOG(
        .resetn(resetn),
        .clk(clk),
        .start(sDog),
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

    // Spin
    draw DRAW_SPIN(
        .resetn(resetn),
        .clk(clk),
        .start(sSpin),
        .xInit(8'd60),
        .yInit(7'd80),
        .xOut(xSpin),
        .yOut(ySpin),
        .colour(cSpin),
        .writeEn(wSpin),
        .done(dSpin)
    );
    defparam DRAW_DOG.X_WIDTH = 6;
    defparam DRAW_DOG.Y_WIDTH = 6;
    defparam DRAW_DOG.X_MAX = 40;
    defparam DRAW_DOG.Y_MAX = 40;
    defparam DRAW_DOG.IMAGE = "assets/dreidel-spin.mif";

    // Nun
    draw DRAW_SPIN(
        .resetn(resetn),
        .clk(clk),
        .start(sNun),
        .xInit(8'd60),
        .yInit(7'd80),
        .xOut(xNun),
        .yOut(yNun),
        .colour(cNun),
        .writeEn(wNun),
        .done(dNun)
    );
    defparam DRAW_DOG.X_WIDTH = 6;
    defparam DRAW_DOG.Y_WIDTH = 6;
    defparam DRAW_DOG.X_MAX = 40;
    defparam DRAW_DOG.Y_MAX = 40;
    defparam DRAW_DOG.IMAGE = "assets/dreidel-nun.mif";

    // Gimel
    draw DRAW_SPIN(
        .resetn(resetn),
        .clk(clk),
        .start(sGimel),
        .xInit(8'd60),
        .yInit(7'd80),
        .xOut(xGimel),
        .yOut(yGimel),
        .colour(cGimel),
        .writeEn(wGimel),
        .done(dGimel)
    );
    defparam DRAW_DOG.X_WIDTH = 6;
    defparam DRAW_DOG.Y_WIDTH = 6;
    defparam DRAW_DOG.X_MAX = 40;
    defparam DRAW_DOG.Y_MAX = 40;
    defparam DRAW_DOG.IMAGE = "assets/dreidel-gimel.mif";

    // Hay
    draw DRAW_SPIN(
        .resetn(resetn),
        .clk(clk),
        .start(sHay),
        .xInit(8'd60),
        .yInit(7'd80),
        .xOut(xHay),
        .yOut(yHay),
        .colour(cHay),
        .writeEn(wHay),
        .done(dHay)
    );
    defparam DRAW_DOG.X_WIDTH = 6;
    defparam DRAW_DOG.Y_WIDTH = 6;
    defparam DRAW_DOG.X_MAX = 40;
    defparam DRAW_DOG.Y_MAX = 40;
    defparam DRAW_DOG.IMAGE = "assets/dreidel-hay.mif";

    // Shin
    draw DRAW_SPIN(
        .resetn(resetn),
        .clk(clk),
        .start(sShin),
        .xInit(8'd60),
        .yInit(7'd80),
        .xOut(xShin),
        .yOut(yShin),
        .colour(cShin),
        .writeEn(wShin),
        .done(dShin)
    );
    defparam DRAW_DOG.X_WIDTH = 6;
    defparam DRAW_DOG.Y_WIDTH = 6;
    defparam DRAW_DOG.X_MAX = 40;
    defparam DRAW_DOG.Y_MAX = 40;
    defparam DRAW_DOG.IMAGE = "assets/dreidel-shin.mif";


    // -- Control --
    // Declare state values
    localparam  IDLE    = 4'h0,
                DRAW_BG = 4'h1,
                DRAW_FG = 4'h2,
                DONE    = 4'h3;

    // State register
    reg [3:0] currentState;

    // Assign outputs
    assign writeEn = (wHome | wArcade | wGame | wDog | wSpin | wNun | wGimel | wHay | wShin) & (colour != 8'b001001); // ignore "green screen" colour
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
                    case (location)
                        GAME: begin
                            currentState <= (doneFg) ? DONE : DRAW_FG;
                            case (gameState)
                                SPIN: begin
                                    x <= xSpin;
                                    y <= ySpin;
                                    colour = <= cSpin;
                                end

                                NUN: begin
                                    x <= xNun;
                                    y <= yNun;
                                    colour = <= cNun;
                                end

                                GIMEL: begin
                                    x <= xGimel;
                                    y <= yGimel;
                                    colour = <= cGimel;
                                end

                                HAY: begin
                                    x <= xHay;
                                    y <= yHay;
                                    colour = <= cHay;
                                end

                                SHIN: begin
                                    x <= xShin;
                                    y <= yShin;
                                    colour = <= cShin;
                                end
                            endcase
                        end

                        default: begin
                            currentState <= (doneFg) ? DONE : DRAW_FG;
                            x <= xDog;
                            y <= yDog;
                            colour <= cDog;
                        end
                    endcase
                end

                DONE: currentState <= (~start) ? IDLE : DONE;

                default: currentState <= IDLE;
            endcase
        end
    end // stateFFs
endmodule
