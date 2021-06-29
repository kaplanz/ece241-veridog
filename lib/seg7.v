// File:        seg7.v
// Author:      Zakhary Kaplan <https://zakharykaplan.ca>
// Created:     29 Sep 2019
// SPDX-License-Identifier: NONE

module seg7(
    input [3:0] dataIn,
    output reg [6:0] segment
    );

    always @(*)
    begin: dataEncoding
        case (dataIn)
            4'h0: segment = 7'b1000000; // 0
            4'h1: segment = 7'b1111001; // 1
            4'h2: segment = 7'b0100100; // 2
            4'h3: segment = 7'b0110000; // 3
            4'h4: segment = 7'b0011001; // 4
            4'h5: segment = 7'b0010010; // 5
            4'h6: segment = 7'b0000010; // 6
            4'h7: segment = 7'b1111000; // 7
            4'h8: segment = 7'b0000000; // 8
            4'h9: segment = 7'b0011000; // 9
            4'hA: segment = 7'b0001000; // A
            4'hB: segment = 7'b0000011; // b
            4'hC: segment = 7'b1000110; // C
            4'hD: segment = 7'b0100001; // d
            4'hE: segment = 7'b0000110; // E
            4'hF: segment = 7'b0001110; // F
            default: segment = 7'b1111111;
        endcase
    end // dataEncoding
endmodule
