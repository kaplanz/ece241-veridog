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
                DECREASE    = 1;
    ) (
    input resetn,
    input slowClk,
    input doingAction,

    output [6:0] statLevel
    );

    // Internal register
    reg [7:0] statReg = MAX;

    // Assign output
    assign statLevel = statReg;

    // Perform stat changes
    always @(posedge slowClk)
    begin
        if (!resetn) begin
            statLevel <= MAX;
        end
        if (doingAction) begin
            if (statLevel + INCREASE > MAX) begin
            end
            else begin
                statLevel <= statLevel + INCREASE;
            end
        end
        else if (!doingAction) begin
            if (statLevel > 0)
                statLevel <= statLevel - DECREASE;
        end
    end
endmodule
