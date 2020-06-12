module adder(A, B, out);
  // Inputs
  input  [31:0] A, B;
  
  // Outputs
  output [31:0] out;
  
  // Wires
  wire [31:0] out;
  wire [7:0] o_e;
  wire [24:0] o_m;
  
  // Registers
	reg a_sign;
	reg [7:0] a_exponent;
	reg [23:0] a_mantissa;
	reg b_sign;
	reg [7:0] b_exponent;
	reg [23:0] b_mantissa;
  reg o_sign;
  reg [7:0] o_exponent;
  reg [24:0] o_mantissa;
  reg [7:0] diff;
  reg [23:0] tmp_mantissa;
  reg [7:0] tmp_exponent;
  reg  [7:0] i_e;
  reg  [24:0] i_m;

  // Main
  addition_normaliser norm1
  (
    .in_e(i_e),
    .in_m(i_m),
    .out_e(o_e),
    .out_m(o_m)
  );

  assign out[31] = o_sign;
  assign out[30:23] = o_exponent;
  assign out[22:0] = o_mantissa[22:0];

  always @ ( * ) begin
		a_sign = A[31];
		if(A[30:23] == 0) begin
			a_exponent = 8'b00000001;
			a_mantissa = {1'b0, A[22:0]};
		end else begin
			a_exponent = A[30:23];
			a_mantissa = {1'b1, A[22:0]};
		end
		b_sign = B[31];
		if(B[30:23] == 0) begin
			b_exponent = 8'b00000001;
			b_mantissa = {1'b0, B[22:0]};
		end else begin
			b_exponent = B[30:23];
			b_mantissa = {1'b1, B[22:0]};
		end
    if (a_exponent == b_exponent) begin // Equal exponents
      o_exponent = a_exponent;
      if (a_sign == b_sign) begin // Equal signs = add
        o_mantissa = a_mantissa + b_mantissa;
        //Signify to shift
        o_mantissa[24] = 1;
        o_sign = a_sign;
      end else begin // Opposite signs = subtract
        if(a_mantissa > b_mantissa) begin
          o_mantissa = a_mantissa - b_mantissa;
          o_sign = a_sign;
        end else begin
          o_mantissa = b_mantissa - a_mantissa;
          o_sign = b_sign;
        end
      end
    end else begin //Unequal exponents
      if (a_exponent > b_exponent) begin // A is bigger
        o_exponent = a_exponent;
        o_sign = a_sign;
				diff = a_exponent - b_exponent;
        tmp_mantissa = b_mantissa >> diff;
        if (a_sign == b_sign)
          o_mantissa = a_mantissa + tmp_mantissa;
        else
          	o_mantissa = a_mantissa - tmp_mantissa;
      end else if (a_exponent < b_exponent) begin // B is bigger
        o_exponent = b_exponent;
        o_sign = b_sign;
        diff = b_exponent - a_exponent;
        tmp_mantissa = a_mantissa >> diff;
        if (a_sign == b_sign) begin
          o_mantissa = b_mantissa + tmp_mantissa;
        end else begin
					o_mantissa = b_mantissa - tmp_mantissa;
        end
      end
    end
    if(o_mantissa[24] == 1) begin
      o_exponent = o_exponent + 1;
      o_mantissa = o_mantissa >> 1;
    end else if((o_mantissa[23] != 1) && (o_exponent != 0)) begin
      i_e = o_exponent;
      i_m = o_mantissa;
      o_exponent = o_e;
      o_mantissa = o_m;
    end
  end
endmodule