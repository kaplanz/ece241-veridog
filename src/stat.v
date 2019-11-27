//
//  stat.v
//  Stat bar
//
//  Created by Alex Lehner on 2019-11-10.
//  Copyright © 2019 Alex Lehner. All rights reserved.
//

module stat #(
    parameter   MAX         = 100,
                INCREASE    = 5,
                DECREASE    = 1
    ) (
    input resetn,
    input slowClk,
    input doingAction,

    output [7:0] statLevel
    );

    // -- Internal signals --
    // Stat register
    reg [7:0] statReg = MAX;

    // Assign output
    assign statLevel = statReg;

    // Perform stat changes
    always @(posedge slowClk)
    begin: statUpdate
        if (!resetn) begin
            statReg <= MAX;
        end
        else if (doingAction) begin
            if (statReg + INCREASE > MAX) begin
                statReg <= MAX;
            end
            else begin
                statReg <= statReg + INCREASE;
            end
        end
        else if (~doingAction) begin
            if (statReg > 0)
                statReg <= statReg - DECREASE;
        end
    end // statUpdate
endmodule
