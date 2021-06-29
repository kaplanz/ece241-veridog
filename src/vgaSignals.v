// File:        vgaSignals.v
// Author:      Zakhary Kaplan <https://zakharykaplan.ca>
// Created:     25 Nov 2019
// SPDX-License-Identifier: NONE

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
                ARCADE  = 4'h2,
                GAME    = 4'h3,
                END     = 4'hF;
    // Actions
    localparam  STAY    = 4'h0,
                EAT     = 4'h1,
                SLEEP   = 4'h2;
    // GAME    = 4'h3
    // Game states
    localparam  SPIN    = 4'h1,
                NUN     = 4'h2,
                GIMEL   = 4'h3,
                HAY     = 4'h4,
                SHIN    = 4'h5,
                WIN     = 4'h7,
                LOSE    = 4'd8;


    // -- Base frame rate --
    wire frameRate;
    rateDivider FRAME_RATE(
        .resetn(resetn),
        .clk(clk),
        .out(frameRate)
    );
    defparam FRAME_RATE.MAX = 25_000_000;


    // -- Drawing data --
    // Internal wires
    wire startBg, startFg;
    wire sHome, sArcade, sGame, sEnd, sDog, sEat, sSleep, sDead, sSpin, sNun, sGimel, sHay, sShin, sWin, sLose;
    wire [7:0] xHome, xArcade, xEnd, xGame, xDog, xEat, xSleep, xDead, xSpin, xNun, xGimel, xHay, xShin, xWin, xLose;
    wire [6:0] yHome, yArcade, yEnd, yGame, yDog, yEat, ySleep, yDead, ySpin, yNun, yGimel, yHay, yShin, yWin, yLose;
    wire [7:0] cHome, cArcade, cEnd, cGame, cDog, cEat, cSleep, cDead, cSpin, cNun, cGimel, cHay, cShin, cWin, cLose;
    wire wHome, wArcade, wGame, wEnd, wDog, wEat, wSleep, wDead, wSpin, wNun, wGimel, wHay, wShin, wWin, wLose;
    wire dHome, dArcade, dGame, dEnd, dDog, dEat, dSleep, dDead, dSpin, dNun, dGimel, dHay, dShin, dWin, dLose;
    wire doneBg, doneFg;

    // Start signals
    assign startBg = (start);
    assign startFg = (doneBg);
    // Background
    assign sHome = (startBg); // & (location == HOME));
    assign sArcade = (startBg); // & (location == ARCADE));
    assign sGame = (startBg); // & (location == GAME));
    assign sEnd = (startBg);
    // Foreground
    assign sDog = (startFg); // & (action != GAME));
    assign sEat = (startFg);
    assign sSleep = (startFg);
    assign sDead = (startFg);
    assign sSpin = (startFg); // & (gameState == SPIN));
    assign sNun = (startFg); // & (gameState == NUN));
    assign sGimel = (startFg); // & (gameState == GIMEL));
    assign sHay = (startFg); // & (gameState == HAY));
    assign sShin = (startFg); // & (gameState == SHIN));
    assign sWin = (startFg);
    assign sLose = (startFg);

    // Done signals
    assign doneBg = (dHome | dArcade | dGame | dEnd);
    assign doneFg = (dDog | dEat | dSleep |
        dSpin | dNun | dGimel | dHay | dShin | dWin | dLose);

    // -- Module instantiations --
    // - Background -
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
    defparam DRAW_GAME.X_WIDTH = 8;
    defparam DRAW_GAME.Y_WIDTH = 7;
    defparam DRAW_GAME.X_MAX = 160;
    defparam DRAW_GAME.Y_MAX = 120;
    defparam DRAW_GAME.IMAGE = "assets/game.mif";

    // End
    draw DRAW_END(
        .resetn(resetn),
        .clk(clk),
        .start(sEnd),
        .xInit(8'd0),
        .yInit(7'd0),
        .xOut(xEnd),
        .yOut(yEnd),
        .colour(cEnd),
        .writeEn(wEnd),
        .done(dEnd)
    );
    defparam DRAW_END.X_WIDTH = 8;
    defparam DRAW_END.Y_WIDTH = 7;
    defparam DRAW_END.X_MAX = 160;
    defparam DRAW_END.Y_MAX = 120;
    defparam DRAW_END.IMAGE = "assets/end.mif";

    // Win
    draw DRAW_WIN(
        .resetn(resetn),
        .clk(clk),
        .start(sWin),
        .xInit(8'd0),
        .yInit(7'd0),
        .xOut(xWin),
        .yOut(yWin),
        .colour(cWin),
        .writeEn(wWin),
        .done(dWin)
    );
    defparam DRAW_WIN.X_WIDTH = 8;
    defparam DRAW_WIN.Y_WIDTH = 7;
    defparam DRAW_WIN.X_MAX = 160;
    defparam DRAW_WIN.Y_MAX = 120;
    defparam DRAW_WIN.IMAGE = "assets/youwin.mif";

    // Lose
    draw DRAW_LOSE(
        .resetn(resetn),
        .clk(clk),
        .start(sLose),
        .xInit(8'd0),
        .yInit(7'd0),
        .xOut(xLose),
        .yOut(yLose),
        .colour(cLose),
        .writeEn(wLose),
        .done(dLose)
    );
    defparam DRAW_LOSE.X_WIDTH = 8;
    defparam DRAW_LOSE.Y_WIDTH = 7;
    defparam DRAW_LOSE.X_MAX = 160;
    defparam DRAW_LOSE.Y_MAX = 120;
    defparam DRAW_LOSE.IMAGE = "assets/youloseD.mif";


    // - Foreground -
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
    defparam DRAW_DOG.IMAGE = "assets/dog-stay.mif";

    // Eat
    draw DRAW_EAT(
        .resetn(resetn),
        .clk(clk),
        .start(sEat),
        .xInit(8'd60),
        .yInit(7'd80),
        .xOut(xEat),
        .yOut(yEat),
        .colour(cEat),
        .writeEn(wEat),
        .done(dEat)
    );
    defparam DRAW_EAT.X_WIDTH = 6;
    defparam DRAW_EAT.Y_WIDTH = 6;
    defparam DRAW_EAT.X_MAX = 40;
    defparam DRAW_EAT.Y_MAX = 40;
    defparam DRAW_EAT.IMAGE = "assets/dog-eat.mif";

    // Sleep
    draw DRAW_SLEEP(
        .resetn(resetn),
        .clk(clk),
        .start(sSleep),
        .xInit(8'd60),
        .yInit(7'd80),
        .xOut(xSleep),
        .yOut(ySleep),
        .colour(cSleep),
        .writeEn(wSleep),
        .done(dSleep)
    );
    defparam DRAW_SLEEP.X_WIDTH = 6;
    defparam DRAW_SLEEP.Y_WIDTH = 6;
    defparam DRAW_SLEEP.X_MAX = 40;
    defparam DRAW_SLEEP.Y_MAX = 40;
    defparam DRAW_SLEEP.IMAGE = "assets/dog-sleep.mif";

    // Dead
    draw DRAW_DEAD(
        .resetn(resetn),
        .clk(clk),
        .start(sDead),
        .xInit(8'd60),
        .yInit(7'd80),
        .xOut(xDead),
        .yOut(yDead),
        .colour(cDead),
        .writeEn(wDead),
        .done(dDead)
    );
    defparam DRAW_DEAD.X_WIDTH = 6;
    defparam DRAW_DEAD.Y_WIDTH = 6;
    defparam DRAW_DEAD.X_MAX = 40;
    defparam DRAW_DEAD.Y_MAX = 40;
    defparam DRAW_DEAD.IMAGE = "assets/dog-dead.mif";

    // Spin
    draw DRAW_SPIN(
        .resetn(resetn),
        .clk(clk),
        .start(sSpin),
        .xInit(8'd60),
        .yInit(7'd40),
        .xOut(xSpin),
        .yOut(ySpin),
        .colour(cSpin),
        .writeEn(wSpin),
        .done(dSpin)
    );
    defparam DRAW_SPIN.X_WIDTH = 6;
    defparam DRAW_SPIN.Y_WIDTH = 6;
    defparam DRAW_SPIN.X_MAX = 40;
    defparam DRAW_SPIN.Y_MAX = 40;
    defparam DRAW_SPIN.IMAGE = "assets/dreidel-spin.mif";

    // Nun
    draw DRAW_NUN(
        .resetn(resetn),
        .clk(clk),
        .start(sNun),
        .xInit(8'd60),
        .yInit(7'd40),
        .xOut(xNun),
        .yOut(yNun),
        .colour(cNun),
        .writeEn(wNun),
        .done(dNun)
    );
    defparam DRAW_NUN.X_WIDTH = 6;
    defparam DRAW_NUN.Y_WIDTH = 6;
    defparam DRAW_NUN.X_MAX = 40;
    defparam DRAW_NUN.Y_MAX = 40;
    defparam DRAW_NUN.IMAGE = "assets/dreidel-nun.mif";

    // Gimel
    draw DRAW_GIMEL(
        .resetn(resetn),
        .clk(clk),
        .start(sGimel),
        .xInit(8'd60),
        .yInit(7'd40),
        .xOut(xGimel),
        .yOut(yGimel),
        .colour(cGimel),
        .writeEn(wGimel),
        .done(dGimel)
    );
    defparam DRAW_GIMEL.X_WIDTH = 6;
    defparam DRAW_GIMEL.Y_WIDTH = 6;
    defparam DRAW_GIMEL.X_MAX = 40;
    defparam DRAW_GIMEL.Y_MAX = 40;
    defparam DRAW_GIMEL.IMAGE = "assets/dreidel-gimel.mif";

    // Hay
    draw DRAW_HAY(
        .resetn(resetn),
        .clk(clk),
        .start(sHay),
        .xInit(8'd60),
        .yInit(7'd40),
        .xOut(xHay),
        .yOut(yHay),
        .colour(cHay),
        .writeEn(wHay),
        .done(dHay)
    );
    defparam DRAW_HAY.X_WIDTH = 6;
    defparam DRAW_HAY.Y_WIDTH = 6;
    defparam DRAW_HAY.X_MAX = 40;
    defparam DRAW_HAY.Y_MAX = 40;
    defparam DRAW_HAY.IMAGE = "assets/dreidel-hay.mif";

    // Shin
    draw DRAW_SHIN(
        .resetn(resetn),
        .clk(clk),
        .start(sShin),
        .xInit(8'd60),
        .yInit(7'd40),
        .xOut(xShin),
        .yOut(yShin),
        .colour(cShin),
        .writeEn(wShin),
        .done(dShin)
    );
    defparam DRAW_SHIN.X_WIDTH = 6;
    defparam DRAW_SHIN.Y_WIDTH = 6;
    defparam DRAW_SHIN.X_MAX = 40;
    defparam DRAW_SHIN.Y_MAX = 40;
    defparam DRAW_SHIN.IMAGE = "assets/dreidel-shin.mif";


    // -- Control --
    // Declare state values
    localparam  IDLE    = 4'h0,
        DRAW_BG = 4'h1,
        DRAW_FG = 4'h2,
        DONE    = 4'h3;

    // State register
    reg [3:0] currentState;

    // Assign outputs
    assign writeEn = ((wHome | wArcade | wGame | wEnd | wDog |
                       wSpin | wNun | wGimel | wHay | wShin) &
                      (colour != 8'b001001)); // ignore "green screen" colour
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
                    currentState <= (startBg) ? DRAW_BG: IDLE;
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

                        GAME: begin
                            x <= xGame;
                            y <= yGame;
                            colour <= cGame;
                        end

                        END: begin
                            x <= xEnd;
                            y <= yEnd;
                            colour <= cEnd;
                        end

                        default: begin
                            currentState <= DONE;
                            x <= 8'bz;
                            y <= 7'bz;
                            colour <= 8'bz;
                        end
                    endcase
                end

                DRAW_FG: begin
                    currentState <= (doneFg) ? DONE : DRAW_FG;
                    case (location)
                        HOME: begin
                            case (action)
                                STAY: begin
                                    x <= xDog;
                                    y <= yDog;
                                    colour <= cDog;
                                end

                                EAT: begin
                                    x <= xEat;
                                    y <= yEat;
                                    colour <= cEat;
                                end

                                SLEEP: begin
                                    x <= xSleep;
                                    y <= ySleep;
                                    colour <= cSleep;
                                end
                            endcase
                        end

                        ARCADE: begin
                            x <= xDog;
                            y <= yDog;
                            colour <= cDog;
                        end

                        GAME: begin
                            case (gameState)
                                SPIN: begin
                                    x <= xSpin;
                                    y <= ySpin;
                                    colour <= cSpin;
                                end

                                NUN: begin
                                    x <= xNun;
                                    y <= yNun;
                                    colour <= cNun;
                                end

                                GIMEL: begin
                                    x <= xGimel;
                                    y <= yGimel;
                                    colour <= cGimel;
                                end

                                HAY: begin
                                    x <= xHay;
                                    y <= yHay;
                                    colour <= cHay;
                                end

                                SHIN: begin
                                    x <= xShin;
                                    y <= yShin;
                                    colour <= cShin;
                                end

                                WIN: begin
                                    x <= xWin;
                                    y <= yWin;
                                    colour <= cWin;
                                end

                                LOSE: begin
                                    x <= xLose;
                                    y <= yLose;
                                    colour <= cLose;
                                end
                            endcase
                        end

                        END: begin
                            x <= xDead;
                            y <= yDead;
                            colour <= cDead;
                        end

                        default: begin
                            x <= 8'bz;
                            y <= 7'bz;
                            colour <= 8'bz;
                        end
                    endcase
                end

                DONE:
                    currentState <= (~start) ? IDLE : DONE;

                default:
                    currentState <= IDLE;
            endcase
        end
    end // stateFFs
endmodule
