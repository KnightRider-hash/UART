module UART(
    output reg [7:0] data_out,
    input clk,
    input dain
);

reg Tick;
reg [2:0] bit_cnt;
reg [25:0] acc;
reg [3:0] b_c; // for adjusting the tick and ensure bit not noise logic
parameter CLK_FREQ = 50_000_000; // clock speed (The Bucket)
parameter BAUD_RATE = 1843200;   // desired speed (The Pour)

reg [1:0] state;

initial begin
  state=2'b00;
  Tick=1'b0;
  bit_cnt=3'b000;
  acc=0;
  b_c=4'b0000;
end  

always@(posedge clk)begin 

if (acc >= (CLK_FREQ - BAUD_RATE)) begin 
    
    acc <= acc - CLK_FREQ + BAUD_RATE; //for bring it to the range 
    Tick <= 1'b1;
    
end else begin
    
    acc <= acc + BAUD_RATE;//keeps adding 
    Tick <= 1'b0;
    
 end



if(Tick)begin
 case(state) 
  2'b00:if(dain==1'b0) begin
      state<=2'b01;
      b_c<=0;
      bit_cnt<=0;
      end


  2'b01:if(b_c==4'b0111 )begin
       if(dain==1'b0) begin
         state<=2'b10; 
         b_c<=0;
         end
         else 
           begin
           state<=2'b00;
           b_c<=0;
           end 
         end   
      else begin
        b_c<=b_c+1'b1;
       end
    
  2'b10: if(b_c==4'b1111)begin //15 tick for 1 bit to move
             data_out<={dain,data_out[7:1]}; // check here logic
              b_c<=0;
            if(bit_cnt==3'b111)begin // ensure all 8 bit is moved
                state<=2'b11;
               end
           else begin 
              bit_cnt<=bit_cnt+1'b1;
              end
            end  
          else begin
            b_c<=b_c+1'b1;
        end

        

   2'b11: begin 
           if(b_c==4'b1111)begin
            state<=2'b00;
            b_c<=0;
            end
        else begin 
          b_c<=b_c+1'b1;    
        end 
       end  
    default: state<=2'b00;    
 endcase
 end
 end

endmodule