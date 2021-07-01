module MS(
	rst_n , 
	clk , 
	maze ,
	in_valid ,
	out_valid,
	maze_not_valid,
	out_x, 
	out_y
);

//IO
input rst_n, clk, maze ,in_valid ;
output reg out_valid;
output reg maze_not_valid;
output reg [3:0]out_x, out_y ;




//map
logic map[0:15][0:15];
logic [1:0] precedence[0:15][0:15];

logic right_ena, down_ena, left_ena, up_ena;
logic [3:0] tail_x_right, tail_x_left, tail_y_up, tail_y_down;

parameter RIGHT= 2'd0, LEFT=2'd1, UP= 2'd2, DOWN=2'd3;

//counter
logic [7:0] counter;

//state machine
parameter RECEIVE= 2'd0, COMPUTION= 2'd1, 
		  BACK= 2'd2,	 SENDING= 2'd3;

logic [1:0] state, state_nxt;

logic receive,compution, sending, back;


//sending
logic clear;
logic start_sending;
logic [3:0] out_x_nxt, out_y_nxt;

logic counter_ready;
logic not_found, not_found_nxt;

//back
logic start_backing;
logic write_ena, del_ena;

logic [1:0] dir_in, dir_out;


//fifo
logic empty, tail_del_ena;
logic [3:0] tail_x, tail_y, head1_x, head1_y, head2_x, head2_y, head3_x, head3_y, head4_x, head4_y;
logic [2:0]add_num;

fifo fifo1(.*);



//fsm control circuit
assign receive= state==RECEIVE;
assign compution= state==COMPUTION && !empty;
assign sending= state==SENDING;
assign back= state==BACK;

assign counter_ready= counter== 'd239;

always_ff @( posedge clk, negedge rst_n ) begin
	if(! rst_n)state<= RECEIVE;
	else state<= state_nxt;

end


always_comb begin
	case(state)
		RECEIVE:begin
			if(counter_ready)state_nxt= COMPUTION;
			else state_nxt= RECEIVE;
		end
		COMPUTION:begin
			if(not_found && !in_valid)state_nxt= SENDING;
			else if(start_backing)state_nxt= BACK;
			else state_nxt= COMPUTION;
		end
		BACK:begin
			if(start_sending)state_nxt= SENDING;
			else state_nxt= BACK;
		end
		SENDING:begin
			if(!clear)state_nxt= SENDING;
			else state_nxt= RECEIVE;
		end
	endcase
end


//counter circuit
always_ff @( posedge clk, negedge rst_n ) begin
	if(!rst_n)counter<= 'd0;
	else if(in_valid) counter<= counter+'d1;
	else counter<= counter;

end

//receive circuit+ distance
always_ff @( posedge clk, negedge rst_n) begin
	integer i;
	
	if(!rst_n)begin
		map[1][1]<= 1'b0;
		map[14][14]<= 1'b0;
		
		for(i=0;i<15;i=i+1)begin
			map[i][0]<= 1'b1;
			map[i][15]<= 1'b1;
			map[0][i]<= 1'b1;
			map[15][i]<= 1'b1;
		end
	end
	else if(clear)begin
		map[1][1]<= 1'b0;
		map[14][14]<= 1'b0;
		for(i=0;i<15;i=i+1)begin
			map[i][0]<= 1'b1;
			map[i][15]<= 1'b1;
			map[0][i]<= 1'b1;
			map[15][i]<= 1'b1;
		end
	end
	else if(receive)begin
		map[counter[7:4]][counter[3:0]]<= maze;
		for(i=0;i<15;i=i+1)begin
			map[i][0]<= 1'b1;
			map[i][15]<= 1'b1;
			map[0][i]<= 1'b1;
			map[15][i]<= 1'b1;
		end
	end
	else begin
		if(compution)begin
			map[tail_y][tail_x_left]<= 1'b1;
			map[tail_y_up][tail_x]<= 1'b1;
			map[tail_y][tail_x_right]<= 1'b1;
			map[tail_y_down][tail_x]<= 1'b1;
		end
		for(i=0;i<15;i=i+1)begin
			map[i][0]<= 1'b1;
			map[i][15]<= 1'b1;
			map[0][i]<= 1'b1;
			map[15][i]<= 1'b1;
		end
	end
	
end

//searching circuit
assign tail_x_right= tail_x +'d1;
assign tail_x_left= tail_x- 'd1;
assign tail_y_down= tail_y + 'd1;
assign tail_y_up= tail_y -'d1;

assign right_ena= (!map[tail_y][tail_x_right]);
assign down_ena= (!map[tail_y_down][tail_x]);
assign left_ena= (!map[tail_y][tail_x_left]);
assign up_ena= (!map[tail_y_up][tail_x]);

assign not_found_nxt= ((map[1][1] || map[14][14] || (empty)) && (receive || (empty))) ;



always_ff @( posedge clk, negedge rst_n) begin 
	if(!rst_n)not_found<= 'd0;
	else if(clear)not_found<='d0;
	else if(not_found_nxt)not_found<= 'd1;
end

//precedence
always_ff @( posedge clk ) begin
	integer i;

	if(compution)begin
		if(left_ena)begin
			precedence[tail_y][tail_x_left]<= LEFT;
		end

		if(up_ena)begin
			precedence[tail_y_up][tail_x]<= UP;
		end	
		if(right_ena)begin
			precedence[tail_y][tail_x_right]<= RIGHT;
		end
		
		if(down_ena)begin
			precedence[tail_y_down][tail_x]<= DOWN;
		end

		
	end

	precedence[14][14]<= 'd0;

	

	for(i=0;i<16;i=i+1)begin
		precedence[i][0]<= 'd0;
		precedence[i][15]<= 'd0;
		precedence[0][i]<= 'd0;
		precedence[15][i]<= 'd0;
	end
end
//back stack
logic [3:0] back_x, back_y;

assign start_backing= ((tail_x== 'd1 && tail_y == 'd2) || (tail_x=='d2 && tail_y=='d1));


always_comb begin 
	dir_in= precedence[back_y][back_x];
	write_ena= !start_sending && back;
	del_ena= sending;
	
end

logic [3:0] back_x_plus, back_y_plus;
logic [1:0] back_dir;

assign back_dir= precedence[back_y][back_x];

assign back_x_plus= {{3{!back_dir[0] && ! back_dir[1]}}, !back_dir[1]};
assign back_y_plus= {{3{back_dir[0] && back_dir[1]}}, back_dir[1]};


always_ff @( posedge clk, negedge rst_n) begin 
	if(!rst_n)begin
		back_x<= 'd1;
		back_y<= 'd1;
	end
	else if(back)begin
		back_x<= back_x +back_x_plus;
		back_y<= back_y+ back_y_plus;
	end
	else begin
		back_x<= 'd1;
		back_y<= 'd1;
	end
end


//fifo controller
always_comb begin
	if(up_ena) begin
		head1_x= tail_x;
		head1_y= tail_y_up;
	end
	else if(left_ena)begin
		head1_x= tail_x_left;
		head1_y= tail_y;
	end
	else if(down_ena)begin
		head1_x= tail_x;
		head1_y= tail_y_down;
	end
	else begin
		head1_x= tail_x_right;
		head1_y= tail_y;
	end
	if(compution)begin
		tail_del_ena= 1'b1;

		case({up_ena ,left_ena, down_ena, right_ena})
			4'd0:begin
				add_num= 3'd0;

				head2_x= 4'dx;
				head2_y= 4'dx;

				head3_x= 4'dx;
				head3_y= 4'dx;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b1000:begin
				add_num= 3'd1;

				head2_x= 4'dx;
				head2_y= 4'dx;

				head3_x= 4'dx;
				head3_y= 4'dx;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b0100:begin
				add_num= 3'd1;

				head2_x= 4'dx;
				head2_y= 4'dx;

				head3_x= 4'dx;
				head3_y= 4'dx;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b0010:begin
				add_num= 3'd1;

				head2_x= 4'dx;
				head2_y= 4'dx;

				head3_x= 4'dx;
				head3_y= 4'dx;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b0001:begin
				add_num= 3'd1;

				head2_x= 4'dx;
				head2_y= 4'dx;

				head3_x= 4'dx;
				head3_y= 4'dx;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b1100:begin
				add_num= 3'd2;

				head2_x= tail_x_left;
				head2_y= tail_y;

				head3_x= 4'dx;
				head3_y= 4'dx;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b1010:begin
				add_num= 3'd2;

				head2_x= tail_x;
				head2_y= tail_y_down;

				head3_x= 4'dx;
				head3_y= 4'dx;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b1001:begin
				add_num= 3'd2;

				head2_x= tail_x_right;
				head2_y= tail_y;

				head3_x= 4'dx;
				head3_y= 4'dx;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b0110:begin
				add_num= 3'd2;

				head2_x= tail_x;
				head2_y= tail_y_down;

				head3_x= 4'dx;
				head3_y= 4'dx;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b0101:begin
				add_num= 3'd2;

				head2_x= tail_x_right;
				head2_y= tail_y;

				head3_x= 4'dx;
				head3_y= 4'dx;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b0011:begin
				add_num= 3'd2;

				head2_x= tail_x_right;
				head2_y= tail_y;

				head3_x= 4'dx;
				head3_y= 4'dx;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b1110:begin
				add_num= 3'd3;

				head2_x= tail_x_left;
				head2_y= tail_y;

				head3_x= tail_x;
				head3_y= tail_y_down;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b1101:begin
				add_num= 3'd3;

				head2_x= tail_x_left;
				head2_y= tail_y;

				head3_x= tail_x_right;
				head3_y= tail_y;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b1011:begin
				add_num= 3'd3;

				head2_x= tail_x;
				head2_y= tail_y_down;

				head3_x= tail_x_right;
				head3_y= tail_y;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b0111:begin
				add_num= 3'd3;

				head2_x= tail_x;
				head2_y= tail_y_down;

				head3_x= tail_x_right;
				head3_y= tail_y;

				head4_x= 4'dx;
				head4_y= 4'dx;
			end
			4'b1111:begin
				add_num= 3'b100;

				head2_x= tail_x_left;
				head2_y= tail_y;

				head3_x= tail_x;
				head3_y= tail_y_down;

				head4_x= tail_x_right;
				head4_y= tail_y;
			end
		endcase
	end
	else begin
		tail_del_ena=1'b0;
		add_num= 3'd0;

		head1_x= 4'dx;
		head1_y =4'dx;

		head2_x= 4'dx;
		head2_y= 4'dx;

		head3_x= 4'dx;
		head3_y= 4'dx;

		head4_x= 4'dx;
		head4_y= 4'dx;
	end
end


//sending circuit
assign start_sending=  (back_x== 'd14) && (back_y== 'd14);
assign clear= maze_not_valid ||((out_x== 'd1) && (out_y== 'd1));
assign maze_not_valid= out_valid && not_found;

logic [3:0] out_x_plus, out_y_plus;
logic [1:0] dir;

assign dir= dir_out;
assign out_x_plus= {{3{(!dir[1] && dir[0]) }}, !dir[1]};
assign out_y_plus= {{3{(dir[1] && !dir[0]) }}, dir[1]};

always_comb begin
	out_x_nxt= out_x+ out_x_plus;
	out_y_nxt= out_y+ out_y_plus;
end


always_ff @( posedge clk, negedge rst_n ) begin 
	if(!rst_n)begin
		out_x<= 'd0;
		out_y<= 'd0;
	end
	else if(clear)begin
		out_x<= 'd0;
		out_y<= 'd0;
	end
	else if(sending)begin
		out_x<= out_x_nxt;
		out_y<= out_y_nxt;
	end
	else if(start_sending)begin
		out_x<= 'd14;
		out_y<= 'd14;
	end
	else begin
		out_x<= out_x;
		out_y<= out_y;
	end
	
	
end

assign out_valid= sending;


endmodule 


module fifo(
	input clk,
	input rst_n,
	input clear,
	input compution,
	input [1:0] dir_in,
	input write_ena,
	input del_ena,
	input [2:0] add_num,
	input [3:0] head1_x,
	input [3:0] head1_y,
	input [3:0] head2_x,
	input [3:0] head2_y,
	input [3:0] head3_x,
	input [3:0] head3_y,
	input [3:0] head4_x,
	input [3:0] head4_y,
	input tail_del_ena,
	output empty,
	output logic[3:0] tail_x,
	output logic [3:0] tail_y,
	output logic[1:0] dir_out
);

parameter fifo_size=32;//must be 2^x
parameter counter_size=5;


logic [7:0] fifo[0: fifo_size-1];//[7:4] =>x, [3:0]=>y

logic [counter_size-1:0] tail_pointer;
logic [counter_size-1:0] head_pointer, head_pointer_nxt;

logic [counter_size+1:0] back_pointer,back_pointer_m1;

logic [counter_size-1:0]head_pointer_p1, head_pointer_p2, head_pointer_p3, head_pointer_p4, tail_pointer_p1;

assign empty= (head_pointer==tail_pointer);

assign head_pointer_p1= head_pointer+ 'd1;
assign head_pointer_p2= head_pointer+ 'd2;
assign head_pointer_p3= head_pointer+ 'd3;
assign head_pointer_p4= head_pointer+ 'd4;

assign tail_pointer_p1= tail_pointer+'d1;

assign back_pointer_m1= back_pointer- 'd1;

always_comb begin 
	case(back_pointer_m1[1:0])
		'd0: dir_out= fifo[back_pointer_m1[counter_size+1:2]][1:0];
		'd1: dir_out= fifo[back_pointer_m1[counter_size+1:2]][3:2];
		'd2: dir_out= fifo[back_pointer_m1[counter_size+1:2]][5:4];
		'd3: dir_out= fifo[back_pointer_m1[counter_size+1:2]][7:6];
	endcase	
end


always_ff @( posedge clk) begin
	if(tail_del_ena && (tail_pointer_p1== head_pointer))begin
		tail_x<= head1_x;
		tail_y<= head1_y;
	end
	else if(tail_del_ena)begin
		tail_x<= fifo[tail_pointer_p1][7:4];
		tail_y<= fifo[tail_pointer_p1][3:0];
	end
	
	
	else begin
		tail_x<= fifo[tail_pointer][7:4];
		tail_y<= fifo[tail_pointer][3:0];
	end
end

always_ff @( posedge clk, negedge rst_n ) begin 
	if(!rst_n)back_pointer<= {{counter_size{1'b0}}, 2'b00};
	else if(clear)back_pointer<= {{counter_size{1'b0}}, 2'b00};
	else if(del_ena)back_pointer<= back_pointer_m1;
	else if(write_ena)back_pointer<= back_pointer+ 'd1;
	
end

always_comb begin 
	casex(add_num)
		3'b000: begin
			head_pointer_nxt= head_pointer;
		end
		3'b001: begin
			head_pointer_nxt= head_pointer_p1;
		end
		3'b010: begin
			head_pointer_nxt= head_pointer_p2;
		end
		3'b011: begin
			head_pointer_nxt= head_pointer_p3;
		end
		3'b100: begin
			head_pointer_nxt= head_pointer_p4;
		end
		default:head_pointer_nxt= 'dx;
	endcase
	
end


always_ff @( posedge clk, negedge rst_n ) begin 
	if(!rst_n)begin
		head_pointer<= 'd1;
		tail_pointer<= 'd0;
	end
	else if(clear)begin
		head_pointer<= 'd1;
		tail_pointer<= 'd0;
	end
	else begin
		if(tail_del_ena) tail_pointer<=tail_pointer_p1;
		else tail_pointer <= tail_pointer;

		head_pointer<= head_pointer_nxt;
	end
end

always_ff @( posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		fifo[0]<= {4'd14, 4'd14};
	end
	else if(clear)begin
		fifo[0]<= {4'd14, 4'd14};
	end
	
	else if(compution)begin
		fifo[head_pointer_p3]<= {head4_x, head4_y};
		fifo[head_pointer_p2]<= {head3_x, head3_y};
		fifo[head_pointer_p1]<= {head2_x, head2_y};
		fifo[head_pointer]<= {head1_x, head1_y};
	end
	else if(write_ena)begin
		case(back_pointer[1:0])
			2'd0: fifo[back_pointer[counter_size+1:2]][1:0]<= dir_in;
			2'd1: fifo[back_pointer[counter_size+1:2]][3:2]<= dir_in;
			2'd2: fifo[back_pointer[counter_size+1:2]][5:4]<= dir_in;
			2'd3: fifo[back_pointer[counter_size+1:2]][7:6]<= dir_in;
		endcase
	end
	
end

endmodule