//
//  seg7.v
//  7-segment decoder
//
//  Created by Zakhary Kaplan on 2019-09-29.
//  Copyright © 2019 Zakhary Kaplan. All rights reserved.
//

module seg7(Input, Seg);
    input [3:0] Input;
    output reg [6:0] Seg;

    always @(*)
    begin
        case (Input)
            4'h0: Seg = 7'b1000000; // 0
            4'h1: Seg = 7'b1111001; // 1
            4'h2: Seg = 7'b0100100; // 2
            4'h3: Seg = 7'b0110000; // 3
            4'h4: Seg = 7'b0011001; // 4
            4'h5: Seg = 7'b0010010; // 5
            4'h6: Seg = 7'b0000010; // 6
            4'h7: Seg = 7'b1111000; // 7
            4'h8: Seg = 7'b0000000; // 8
            4'h9: Seg = 7'b0011000; // 9
            4'hA: Seg = 7'b0001000; // A
            4'hB: Seg = 7'b0000011; // b
            4'hC: Seg = 7'b1000110; // C
            4'hD: Seg = 7'b0100001; // d
            4'hE: Seg = 7'b0000110; // E
            4'hF: Seg = 7'b0001110; // F
            default: Seg = 7'b1111111;
        endcase
    end
endmodule
