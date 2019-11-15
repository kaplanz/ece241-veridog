//
//  stats.v
//  Stats
//
//  Created by Alex Lehner on 2019-11-10.
//  Copyright © 2019 Alex Lehner. All rights reserved.
//

module hungerCounter(slowClk, eating, fullLevel);
    input slowClk;
    inout eating;
    output reg [6:0] fullLevel;

    reg [6:0] fullBar = 7'd100; // the maximum level you can eat to
    reg eatingIncrease = 1'd1; // how much eating
    reg hungerLoss = 1'd1;
    reg [2:0] eatingCount = 0;

    always @(negedge slowCkk)
    begin
        if (eating)
        begin
            if (fullLevel + eatingIncrease > fullBar || eatingCount > 4'd5)
            begin
                eating = 0;
                eatingCount =0;
            end
            fullLevel <= fullLevel + eatingIncrease;
            eatingCount <= eatingCount + 1'd1;
        end
        if (!eating)
        begin
            if (fullLevel > 0)
                fullLevel <= fullLevel - hungerLoss;
        end
    end
endmodule


module tirednessCounter(slowClk, sleeping, sleepLevel);
    input tiredness;
    inout sleeping;
    output reg [6:0] sleepLevel;

    reg [6:0] fullBar = 7'd100; // the maximum level you can eat to
    reg sleepingIncrease = 1'd1; // how much eating
    reg tiredLoss = 1'd1;
    reg [2:0] sleepingCount = 0;

    always @(negedge slowClk)
    begin
        if (sleeping)
        begin
            if (sleepLevel + sleepingIncrease > fullBar || sleepCount > 4'd5)
            begin
                sleeping = 0;
                sleepCount =0;
            end
            sleepLevel <= sleepLevel + sleepingIncrease;
            sleepingCount <= sleepingCount + 1'd1;
        end
        if (!sleeping)
        begin
            if (sleepingLevel > 0)
                sleepLevel <= sleepLevel - tiredLoss;
        end
    end
endmodule
