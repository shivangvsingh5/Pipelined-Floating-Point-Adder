/*

FLOATING POINT IEEE 32 BIT FORMAT
Sign    Exponent    Mentisa
 1          8           23      (bits)



ADDER MODULE NAME: float_add_81
MODULE PINS: 
            INPUT: a81(32 bit),b81(32 bit), clk81, reset_81
            OUTPUT: result_81(32 bit)


*/
module float_add_81 (result_81, a81, b81, clk81, reset_81);
    
    input [31:0]  a81, b81;
    input clk81, reset_81;
    output [31:0] result_81;
    
    wire [31:0] result_81;
    
    parameter reg_81=46;
    
    reg [7:0] exp_a81,exp_b81, exp_diff_81, result_exp_81;
    reg sign_a81, sign_b81;
    reg [22:0] men_a81, men_b81;
    reg [reg_81:0] fract_a81,fract_b81, fract_result_81; 
    reg zeroa81,zerob81;
    reg result_sign_81;
    reg [31:0] final_result_81;
    integer renorm_81;
    
    parameter [reg_81:0] zero_81=0;


    assign result_81 = final_result_81;
    
    always @ (posedge clk81 or posedge reset_81) begin
    
    if (reset_81) begin
            exp_a81<= 0;
            exp_b81<= 0;
            exp_diff_81 <= 0; 
            result_exp_81 <= 0;
            exp_a81 <= 0;                 // Exponent
            exp_b81 <= 0;
            sign_a81 <= 0;                //Sign
            sign_b81 <= 0;
            men_a81 <= 0;                 // Mentisa
            men_b81 <= 0;
            fract_a81 <= 0;
            fract_b81 <= 0;
            final_result_81 <= 0;
    
    end
    
    else begin  
    
    
        zeroa81 = (a81[30:0]==0)?1:0;
        zerob81 = (b81[30:0]==0)?1:0;
        renorm_81=0;
        if (b81[30:0] > a81 [30:0]) begin                                     // Smaller number always goes in the B part for both cases that makes the execution easy
            
            exp_a81 = b81[30:23];                                             // Exponent
            exp_b81 = a81[30:23];
            sign_a81 = b81 [31];                                              //Sign
            sign_b81 = a81[31];
            men_a81 = b81 [22:0];                                             // Mentisa
            men_b81 = a81 [22:0];
            fract_a81 = (zerob81)?0:{ 2'b1, b81[22:0],zero_81[reg_81:25]};
            fract_b81 = (zeroa81)?0:{ 2'b1, a81[22:0],zero_81[reg_81:25]};
            
        end
        else begin
            
            exp_a81 = a81[30:23];                                             // Exponent
            exp_b81 = b81[30:23];
            sign_a81 = a81 [31];                                              //Sign
            sign_b81 = b81[31];
            men_a81 = a81 [22:0];                                             // Mentisa
            men_b81 = b81 [22:0]; 
            fract_a81 = (zeroa81)?0:{ 2'b1, a81[22:0],zero_81[reg_81:25]};
            fract_b81 = (zerob81)?0:{ 2'b1, b81[22:0],zero_81[reg_81:25]};
            
        end
        result_sign_81 = sign_a81;
        exp_diff_81 = exp_a81 - exp_b81;                                      // Difference of Exponent
        
        if(exp_diff_81 > 24) begin                                             //Shift the mentisa by the Difference of the exponent
            result_exp_81 = exp_a81;
            fract_result_81 = fract_a81;
        end
        
        else begin
            result_exp_81 = exp_a81;
        
             fract_b81 = (exp_diff_81 [4]) ? {16'b0,fract_b81[reg_81:16]} : {fract_b81};
             fract_b81 = (exp_diff_81 [3]) ? {8'b0,fract_b81[reg_81:6]} : {fract_b81};
             fract_b81 = (exp_diff_81 [2]) ? {4'b0,fract_b81[reg_81:4]} : {fract_b81};
             fract_b81 = (exp_diff_81 [1]) ? {2'b0,fract_b81[reg_81:2]} : {fract_b81};
             fract_b81 = (exp_diff_81 [0]) ? {1'b0,fract_b81[reg_81:1]} : {fract_b81};
            
        end
        
        if (sign_a81 == sign_b81)begin                                              // Add the both Mentisa and store it in result.
            fract_result_81 = fract_a81 + fract_b81;
        end
        
        else begin
            fract_result_81 = fract_a81 - fract_b81;
        end
        
        
        renorm_81=0;
        
      
        if(fract_result_81[reg_81])                                            // Normalize the result by shifting the mentisa.
        begin
            fract_result_81={1'b0,fract_result_81[reg_81:1]};
            result_exp_81=result_exp_81+1;
        end
        
        if(fract_result_81[reg_81-1:reg_81-16]==0) begin 
            renorm_81[4]=1; 
            fract_result_81={ 1'b0,fract_result_81[reg_81-17:0],16'b0 }; 
        end
        if(fract_result_81[reg_81-1:reg_81-8]==0) begin 
            renorm_81[3]=1; 
            fract_result_81={ 1'b0,fract_result_81[reg_81-9:0], 8'b0 }; 
        end
        if(fract_result_81[reg_81-1:reg_81-4]==0) begin 
            renorm_81[2]=1; 
            fract_result_81={ 1'b0,fract_result_81[reg_81-5:0], 4'b0 }; 
        end
        if(fract_result_81[reg_81-1:reg_81-2]==0) begin 
            renorm_81[1]=1; 
            fract_result_81={ 1'b0,fract_result_81[reg_81-3:0], 2'b0 }; 
        end
        if(fract_result_81[reg_81-1   ]==0) begin 
            renorm_81[0]=1; 
            fract_result_81={ 1'b0,fract_result_81[reg_81-2:0], 1'b0 }; 
        end
        
        
        if (exp_diff_81 <=24)                                                            //  2nd normalization process.
         begin
         
             if(fract_result_81 != 0) begin
                     if(fract_result_81[reg_81-24:0]==0 && fract_result_81[reg_81-23]==1) begin
                         
                         if(fract_result_81[reg_81-22]==1) begin
                             fract_result_81 = fract_result_81+{1'b1,zero_81[reg_81-23:0]};
                         end
                         
                     end else begin
                         if(fract_result_81[reg_81-23]==1) begin
                                     fract_result_81=fract_result_81+{1'b1,zero_81[reg_81-24:0]};
                         end
                     end
                                 
                     result_exp_81=result_exp_81-renorm_81;
             
                         if(fract_result_81[reg_81-1]==0) begin
                             result_exp_81=result_exp_81+1;
                             fract_result_81={1'b0,fract_result_81[reg_81-1:1]};
                         end
                         end else begin
                             result_exp_81=0;
                             result_sign_81=0;
                         end
                end
            //fractPreRound_18
        final_result_81 ={result_sign_81,result_exp_81,fract_result_81[reg_81-2:reg_81-24]};        // Final result store in this registor 
    
        
    end
   
    end



endmodule