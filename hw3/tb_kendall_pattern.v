`timescale 1ns/1ps
`define SIZE 10000
module tb_kendall();

	reg [3:0] i0_x, i1_x, i2_x, i3_x;
	reg [3:0] i0_y, i1_y, i2_y, i3_y;
	wire [3:0] kendall;

	reg  [3:0] i0mem[0:2*`SIZE-1];
	reg  [3:0] i1mem[0:2*`SIZE-1];
	reg  [3:0] i2mem[0:2*`SIZE-1];
	reg  [3:0] i3mem[0:2*`SIZE-1];

	reg  [3:0] kendallmem[0:`SIZE-1];
	reg  [3:0] ans;


	integer i,j,error,error_total,error_part,hide;
	real time_avg,time_step_sum,time_step,acc,total;

	kendall_rank top(					.kendall(kendall),
										.i0_x(i0_x),
										.i0_y(i0_y),
										.i1_x(i1_x),
										.i1_y(i1_y),
										.i2_x(i2_x),
										.i2_y(i2_y),
										.i3_x(i3_x),
										.i3_y(i3_y)
										);

	initial	begin
		$readmemh("i0.dat", i0mem);
		$readmemh("i1.dat", i1mem);
		$readmemh("i2.dat", i2mem);
		$readmemh("i3.dat", i3mem);
		$readmemb("golden.dat",kendallmem);
	end

	initial begin
		$fsdbDumpfile("kendall.fsdb");
		$fsdbDumpvars;
		$fsdbDumpMDA;
	end

	initial begin
		$display("-----------------------------------------------------\n");
 		$display("START!!! Simulation Start .....\n");
 		$display("-----------------------------------------------------\n");
		time_step_sum = 0 ;
		error_total = 0;
		error_part = 0;
		hide = 0;
		for (i = 0;i < `SIZE; i = i + 2)
		begin
			time_step = 0;
			i0_x  = i0mem[i];
			i0_y  = i0mem[i+1];
			i1_x  = i1mem[i];
			i1_y  = i1mem[i+1];
			i2_x  = i2mem[i];
			i2_y  = i2mem[i+1];
			i3_x  = i3mem[i];
			i3_y  = i3mem[i+1];

			ans = kendallmem[i/2];

			for (j = 0; j< `SIZE/10 ;j = j+1)
			begin
				#1;
				if (ans!==kendall) begin
					error = 1;
					time_step = j+1;
				end
				else begin
					time_step = j+1;
					error  = 0;
					j=`SIZE;
				end
			end


			if (error==1) begin
				error_part = error_part +1;
				error_total = error_total +1;
			end

			if (error==1&&hide!=1)  begin// error
				$display ("[ERROR] The golden in %d is 0x%h, but your output is 0x%h",i,ans,kendall);



				time_step_sum = time_step_sum + time_step;

			end
			else begin
				//$display ("The golden in %d is %h ,  your output is %h.Correct!",i,ans,average);
				time_step_sum = time_step_sum + time_step;
			end

			if (error_total > 100 && hide==0) begin
				$display("-------------------------------------------------------------\n");
				$display ("There are more than 100 errors!! So the following error message will be pruned!!");
				$display("-------------------------------------------------------------\n");
				hide = 1;


			end
			if (error_part ==0 && i%1000 ==999 ) begin
				$display ("\033[1;32m[CORRECT] \033[mYour output in %d ~ %d  is correct.",i-999,i);

			end
			else if (i%1000 ==999 ) begin
				$display ("[ERROR]Your output in %d ~ %d  has %d errors.",i-999,i,error_part);

			end

			if (i%1000==999) begin
				error_part = 0;
			end


		end
			if (error_total==0) begin
				time_avg =time_step_sum/`SIZE;
				total = error_total;
				acc = (total)/`SIZE;

				$display("-------------------------------------------------------------\n");
				$display("Your score in correctness part is 40.Accuracy is %.2f %",(1-acc)*100);
	    		$display("Congratulations!!! All data have been generated successfully!\n");
            	$display("---------- The test result is ..... PASS --------------------\n");

		    	//$display("\033[1;32m********************************\033[m");
		    	//$display("\033[1;32m********************************\033[m");

				//$display("\033[1;33mYour average latency is %f ns\033[m",time_avg);


			end
			else begin
				time_avg =time_step_sum/`SIZE;
				total = error_total;
				acc = (total)/`SIZE;

				$display("-----------------------------------------------------\n");
				$display("Error!!! There is something wrong with your code ...!");
				$display ("There are %d errors ! Your score in correctness part is %.2f. Accuracy is %.2f %",error_total,(1-acc)*40,(1-acc)*100);
 				$display("------The test result is .....FAIL ------------------\n");
 				$display("-----------------------------------------------------\n");
				//$display ("Note that the latency is inaccurate if there are some errors!!!");
			end
				$finish;


	end








endmodule





