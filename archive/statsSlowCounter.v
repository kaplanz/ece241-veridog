//
//  statsCounter.v
//  Stats slowing counter
//
//  Created by Alex Lehner on 2019-11-10.
//  Copyright © 2019 Alex Lehner. All rights reserved.
//

module statsSlowCounter(input clk, output reg enable);
    reg [26:0] counter = 0;

    always @(posedge clk)
    begin
        counter <= counter + 1;
        if (counter == 25_000_000) begin
            counter <= 0;
            enable <= ~enable;
        end
    end
endmodule
