//
//  homeActions.v
//  homeActions
//
//  Created by Alex Lehner on 2019-11-15.
//  Copyright © 2019 Alex Lehner. All rights reserved.
//

module homeActions(
    input resetn,
    input clk,
    input doEat, doSleep,

    output [6:0] hunger,
    output [6:0] sleepiness,
    output done
    );

    // -- Local parameters --
    // Actions
    localparam  IDLE    = 4'd0,
                EAT     = 4'd1,
                SLEEP   = 4'd2,
                DONE    = 4'd3;


    // -- Internal signals --
    // State register
    reg [3:0] currentState;

    // Wires
    wire doAction = (doEat | doSleep);
    wire doneAction;
    wire slowClk;

    // Set duration of an action
    rateDivider ACTION_DURATION(
        .resetn(~doAction), // reset when not performing action
        .clk(clk),
        .enable(doneAction) // turns on when action is completed
    );
    defparam ACTION_DURATION.MAX = 250_000_000;

    // Set 1Hz clock for stats
    rateDivider SLOW_CLK(
        .resetn(resetn),
        .clk(clk),
        .enable(slowClk)
    );


    // -- Stats --
    stat HUNGER(
        .resetn(resetn),
        .slowClk(slowClk),
        .doingAction(currentState == EAT),
        .statLevel(hunger)
    );

    stat SLEEPINESS(
        .resetn(resetn),
        .slowClk(slowClk),
        .doingAction(currentState == SLEEP),
        .statLevel(sleepiness)
    );


    // -- Control --
    // Assign outputs
    assign done = (currentState == DONE);

    // Update state registers, perform incremental logic
    always@(posedge clk)
    begin: stateFFs
        if (!resetn) begin
            currentState <= IDLE;
        end
        else begin
            case (currentState)
                IDLE: begin
                    if (~doAction)
                        currentState <= IDLE;
                    else if (doEat)
                        currentState <= EAT;
                    else if (doSleep)
                        currentState <= SLEEP;
                end

                EAT: currentState <= (doneAction) ? DONE: EAT;

                SLEEP: currentState <= (doneAction) ? DONE: SLEEP;

                DONE: currentState <= (~doAction) ? IDLE : DONE;

                default: currentState <= IDLE;
            endcase
        end
    end // stateFFs
endmodule
