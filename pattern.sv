`timescale 100ps/10ps
module PATTERN(
	rst_n, 
	clk, 
	maze ,
	in_valid ,
	out_valid,
	maze_not_valid,
	out_x, 
	out_y
);

real	CYCLE = 5;
//Port Declaration
input				out_valid;
input			maze_not_valid;
input		[3:0]	out_x;
input		[3:0]	out_y;
output reg 			clk;
output reg     		rst_n; 
output reg     		in_valid;
output reg     		maze;


//====================================== 

integer outans_x,outans_y;
integer input_file;
integer i,a,b,c,d,e,f,g,k,j,h;
integer patnum;
integer out_valid_cycle;
integer action_s;
integer patcount;
integer cycle_time;
integer lat,total_latency;
integer counter;




//================================================================
// clock
//================================================================
always	#(CYCLE/2.0) clk = ~clk;
initial	clk = 0;
reg [15:0]row1;
reg [15:0]row2;
reg [15:0]row3;
reg [15:0]row4;
reg [15:0]row5;
reg [15:0]row6;
reg [15:0]row7;
reg [15:0]row8;
reg [15:0]row9;
reg [15:0]row10;
reg [15:0]row11;
reg [15:0]row12;
reg [15:0]row13;
reg [15:0]row14;
reg [15:0]row15;
reg [4:0]ansX[50:0];
reg [4:0]ansY[50:0];
reg [4:0]ans_y;
reg [4:0]ans_x;
reg valid;
initial begin
	rst_n = 1;
	in_valid = 0 ;
	maze = 1'dx;
    force clk = 0;

	patcount = 0;
	total_latency = 0;
	outans_x=$fopen("out_x.txt","r");
	outans_y=$fopen("out_y.txt","r");
	input_file=$fopen("input.txt","r");
	reset_task;
	counter=0;
	h=0;
	@( negedge clk );
	for (j=1;j<=100;j=j+1)begin
		input_;
		wait_OUT_VALID;
		check_ans;
		out_data_reset;
	end

	YOU_PASS_task;
	repeat(200)@( negedge clk );
	$finish ;
end



task reset_task ; begin
    #(5); rst_n = 0;
	#(20.0);
	  if( ( out_x !== 0 ) || ( out_y !== 0 ) || ( out_valid !== 0 ) || ( maze_not_valid !== 0 ) )
	  begin
		fail;
		$display("**************************!");
		$display("*          FAIL !          ");
		$display(" out should be 0 after rst ");
		$display("**************************!");
	   $finish ;
	  end 
	
	#(10.0) rst_n = 1 ;
    #(10);  release clk;
end endtask

task input_; begin
	for (i=1;i<=256;i=i+1)begin
		in_valid=1;
        g=$fscanf(input_file,"%d",maze);   //read read
		@( negedge clk );

	end
	
	in_valid = 0 ;
	maze='d0;
	counter=0;
	
end endtask

task patt_loop; begin
	valid=0;
	for (i =14;i>=0;i=i-1)begin
		maze = row1[i];
		@( negedge clk );
	end
	for (i =14;i>=0;i=i-1)begin
		maze = row2[i];
		@( negedge clk );
	end
	for (i =14;i>=0;i=i-1)begin
		maze = row3[i];
		@( negedge clk );
	end
	for (i =14;i>=0;i=i-1)begin
		maze = row4[i];
		@( negedge clk );
	end
	for (i =14;i>=0;i=i-1)begin
		maze = row5[i];
		@( negedge clk );
	end
	for (i =14;i>=0;i=i-1)begin
		maze = row6[i];
		@( negedge clk );
	end
	for (i =14;i>=0;i=i-1)begin
		maze = row7[i];
		@( negedge clk );
	end
	for (i =14;i>=0;i=i-1)begin
		maze = row8[i];
		@( negedge clk );
	end
	for (i =14;i>=0;i=i-1)begin
		maze = row9[i];
		@( negedge clk );
	end
	for (i =14;i>=0;i=i-1)begin
		maze = row10[i];
		@( negedge clk );
	end
	for (i =14;i>=0;i=i-1)begin
		maze = row11[i];
		@( negedge clk );
	end
	for (i =14;i>=0;i=i-1)begin
		maze = row12[i];
		@( negedge clk );
	end
	for (i =14;i>=0;i=i-1)begin
		maze = row13[i];
		@( negedge clk );
	end
	for (i =14;i>=0;i=i-1)begin
		maze = row14[i];
		@( negedge clk );
	end
	for (i =14;i>=0;i=i-1)begin
		maze = row15[i];
		@( negedge clk );
	end	
	in_valid = 0 ;maze='dx;
	

		wait_OUT_VALID;
		counter=0;
		valid=0;
		check_ans;
		out_data_reset;
end endtask

integer out_num;
task check_ans ; begin
	valid=0;
	g=$fscanf(outans_x,"%d",out_num);
    a=$fscanf(outans_y,"%d",out_num);
    if(out_num!=1)begin
        if(maze_not_valid!==0)begin
			fail;
            $display("********************!");
			$display("*       FAIL !       ");
            $display("maze not valid wrong!");
            $display("********************!");
            $finish;
        end
        for (h=1;h<=out_num;h=h+1)begin
            
            b=$fscanf(outans_x,"%d",ans_x);   
            c=$fscanf(outans_y,"%d",ans_y);
			if(ans_x!==out_x || ans_y !== out_y)begin
				fail;
			end	
            @( negedge clk );
            
        end
    end
    else begin
        ans_x=0;
        ans_y=0;
        if(maze_not_valid!==1)begin
			fail;
            $display("********************!");
			$display("*       FAIL !       ");
            $display("maze not valid wrong!");
            $display("********************!");
            $finish;
        end
        if(ans_x!==out_x || ans_y !== out_y)begin
			fail;
            $display("********************!");
			$display("*       FAIL !       ");
            $display("    answer wrong!    ");
            $display("********************!");
        end	
        @( negedge clk );
    end


	
end endtask


task out_data_reset; begin

		if(out_x!==0 || out_y!==0)
		begin
			fail;
			$display("**************************************************************");
			$display("*                          		FAIL !                      ");
			$display("*                         Output   didn't reset               ");
			$display("**************************************************************");
			repeat(20) @(negedge clk);
			$finish;
		end
		if(out_valid!==0)
		begin
			fail;
			$display("**************************************************************");
			$display("*                          		FAIL !                      ");
			$display("*                         Out_valid didn't reset              ");
			$display("**************************************************************");
			repeat(20) @(negedge clk);
			$finish;
		end

end endtask



task wait_OUT_VALID;
begin
  lat = -1;
  while(out_valid !== 1)
  begin
	lat = lat + 1;

	if(lat == 3000) begin
		fail;
		$display("***************************************************************");
		$display("*     		       Spec_6 Is FAIL !      			*");
		$display("*         The execution latency are over 3000 cycles.          *");
		$display("***************************************************************");
		repeat(2)@(negedge clk);
		$finish;
	end
	@(negedge clk);
  end
  total_latency = total_latency + lat;
end
endtask


task fail; begin


$display("\033[33m	                                                         .:                                                                                         ");      
$display("                                                   .:                                                                                                 ");
$display("                                                  --`                                                                                                 ");
$display("                                                `--`                                                                                                  ");
$display("                 `-.                            -..        .-//-                                                                                      ");
$display("                  `.:.`                        -.-     `:+yhddddo.                                                                                    ");
$display("                    `-:-`             `       .-.`   -ohdddddddddh:                                                                                   ");
$display("                      `---`       `.://:-.    :`- `:ydddddhhsshdddh-                       \033[31m.yhhhhhhhhhs       /yyyyy`       .yhhy`   +yhyo           \033[33m");
$display("                        `--.     ./////:-::` `-.--yddddhs+//::/hdddy`                      \033[31m-MMMMNNNNNNh      -NMMMMMs       .MMMM.   sMMMh           \033[33m");
$display("                          .-..   ////:-..-// :.:oddddho:----:::+dddd+                      \033[31m-MMMM-......     `dMMmhMMM/      .MMMM.   sMMMh           \033[33m");
$display("                           `-.-` ///::::/::/:/`odddho:-------:::sdddh`                     \033[31m-MMMM.           sMMM/.NMMN.     .MMMM.   sMMMh           \033[33m");
$display("             `:/+++//:--.``  .--..+----::://o:`osss/-.--------::/dddd/             ..`     \033[31m-MMMMysssss.    /MMMh  oMMMh     .MMMM.   sMMMh           \033[33m");
$display("             oddddddddddhhhyo///.-/:-::--//+o-`:``````...------::dddds          `.-.`      \033[31m-MMMMMMMMMM-   .NMMN-``.mMMM+    .MMMM.   sMMMh           \033[33m");
$display("            .ddddhhhhhddddddddddo.//::--:///+/`.````````..``...-:ddddh       `.-.`         \033[31m-MMMM:.....`  `hMMMMmmmmNMMMN-   .MMMM.   sMMMh           \033[33m");
$display("            /dddd//::///+syhhdy+:-`-/--/////+o```````.-.......``./yddd`   `.--.`           \033[31m-MMMM.        oMMMmhhhhhhdMMMd`  .MMMM.   sMMMh```````    \033[33m");
$display("            /dddd:/------:://-.`````-/+////+o:`````..``     `.-.``./ym.`..--`              \033[31m-MMMM.       :NMMM:      .NMMMs  .MMMM.   sMMMNmmmmmms    \033[33m");
$display("            :dddd//--------.`````````.:/+++/.`````.` `.-      `-:.``.o:---`                \033[31m.dddd`       yddds        /dddh. .dddd`   +ddddddddddo    \033[33m");
$display("            .ddddo/-----..`........`````..```````..  .-o`       `:.`.--/-      ``````````` \033[31m ````        ````          ````   ````     ``````````     \033[33m");
$display("             ydddh/:---..--.````.`.-.````````````-   `yd:        `:.`...:` `................`                                                         ");
$display("             :dddds:--..:.     `.:  .-``````````.:    +ys         :-````.:...```````````````..`                                                       ");
$display("              sdddds:.`/`      ``s.  `-`````````-/.   .sy`      .:.``````-`````..-.-:-.````..`-                                                       ");
$display("              `ydddd-`.:       `sh+   /:``````````..`` +y`   `.--````````-..---..``.+::-.-``--:                                                       ");
$display("               .yddh``-.        oys`  /.``````````````.-:.`.-..`..```````/--.`      /:::-:..--`                                                       ");
$display("                .sdo``:`        .sy. .:``````````````````````````.:```...+.``       -::::-`.`                                                         ");
$display(" ````.........```.++``-:`        :y:.-``````````````....``.......-.```..::::----.```  ``                                                              ");
$display("`...````..`....----:.``...````  ``::.``````.-:/+oosssyyy:`.yyh-..`````.:` ````...-----..`                                                             ");
$display("                 `.+.``````........````.:+syhdddddddddddhoyddh.``````--              `..--.`                                                          ");
$display("            ``.....--```````.```````.../ddddddhhyyyyyyyhhhddds````.--`             ````   ``                                                          ");
$display("         `.-..``````-.`````.-.`.../ss/.oddhhyssssooooooossyyd:``.-:.         `-//::/++/:::.`                                                          ");
$display("       `..```````...-::`````.-....+hddhhhyssoo+++//////++osss.-:-.           /++++o++//s+++/                                                          ");
$display("     `-.```````-:-....-/-``````````:hddhsso++/////////////+oo+:`             +++::/o:::s+::o            \033[31m     `-/++++:-`                              \033[33m");
$display("    `:````````./`  `.----:..````````.oysso+///////////////++:::.             :++//+++/+++/+-            \033[31m   :ymMMMMMMMMms-                            \033[33m");
$display("    :.`-`..```./.`----.`  .----..`````-oo+////////////////o:-.`-.            `+++++++++++/.             \033[31m `yMMMNho++odMMMNo                           \033[33m");
$display("    ..`:..-.`.-:-::.`        `..-:::::--/+++////////////++:-.```-`            +++++++++o:               \033[31m hMMMm-      /MMMMo  .ssss`/yh+.syyyyyyyyss. \033[33m");
$display("     `.-::-:..-:-.`                 ```.+::/++//++++++++:..``````:`          -++++++++oo                \033[31m:MMMM:        yMMMN  -MMMMdMNNs-mNNNNNMMMMd` \033[33m");
$display("        `   `--`                        /``...-::///::-.`````````.: `......` ++++++++oy-                \033[31m+MMMM`        +MMMN` -MMMMh:--. ````:mMMNs`  \033[33m");
$display("           --`                          /`````````````````````````/-.``````.::-::::::/+                 \033[31m:MMMM:        yMMMm  -MMMM`       `oNMMd:    \033[33m");
$display("          .`                            :```````````````````````--.`````````..````.``/-                 \033[31m dMMMm:`    `+MMMN/  -MMMN       :dMMNs`     \033[33m");
$display("                                        :``````````````````````-.``.....````.```-::-.+                  \033[31m `yNMMMdsooymMMMm/   -MMMN     `sMMMMy/////` \033[33m");
$display("                                        :.````````````````````````-:::-::.`````-:::::+::-.`             \033[31m   -smNMMMMMNNd+`    -NNNN     hNNNNNNNNNNN- \033[33m");
$display("                                `......../```````````````````````-:/:   `--.```.://.o++++++/.           \033[31m      .:///:-`       `----     ------------` \033[33m");
$display("                              `:.``````````````````````````````.-:-`      `/````..`+sssso++++:                                                        ");
$display("                              :`````.---...`````````````````.--:-`         :-````./ysoooss++++.                                                       ");
$display("                              -.````-:/.`.--:--....````...--:/-`            /-..-+oo+++++o++++.                                                       ");
$display("             `:++/:.`          -.```.::      `.--:::::://:::::.              -:/o++++++++s++++                                                        ");
$display("           `-+++++++++////:::/-.:.```.:-.`              :::::-.-`               -+++++++o++++.                                                        ");
$display("           /++osoooo+++++++++:`````````.-::.             .::::.`-.`              `/oooo+++++.                                                         ");
$display("           ++oysssosyssssooo/.........---:::               -:::.``.....`     `.:/+++++++++:                                                           ");
$display("           -+syoooyssssssyo/::/+++++/+::::-`                 -::.``````....../++++++++++:`                                                            ");
$display("             .:///-....---.-..-.----..`                        `.--.``````````++++++/:.                                                               ");
$display("                                                                   `........-:+/:-.`                                                            \033[37m      ");


		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                  FAIL                                                                      ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
	$finish;

end endtask









task YOU_PASS_task;begin
  $display("                                                             \033[33m`-                                                                            ");        
  $display("                                                             /NN.                                                                           ");        
  $display("                                                            sMMM+                                                                           ");        
  $display(" .``                                                       sMMMMy                                                                           ");        
  $display(" oNNmhs+:-`                                               oMMMMMh                                                                           ");        
  $display("  /mMMMMMNNd/:-`                                         :+smMMMh                                                                           ");        
  $display("   .sNMMMMMN::://:-`                                    .o--:sNMy                                                                           ");        
  $display("     -yNMMMM:----::/:-.                                 o:----/mo                                                                           ");        
  $display("       -yNMMo--------://:.                             -+------+/                                                                           ");        
  $display("         .omd/::--------://:`                          o-------o.                                                                           ");        
  $display("           `/+o+//::-------:+:`                       .+-------y                                                                            ");        
  $display("              .:+++//::------:+/.---------.`          +:------/+                                                                            ");        
  $display("                 `-/+++/::----:/:::::::::::://:-.     o------:s.          \033[37m:::::----.           -::::.          `-:////:-`     `.:////:-.    \033[33m");        
  $display("                    `.:///+/------------------:::/:- `o-----:/o          \033[37m.NNNNNNNNNNds-       -NNNNNd`       -smNMMMMMMNy   .smNNMMMMMNh    \033[33m");        
  $display("                         :+:----------------------::/:s-----/s.          \033[37m.MMMMo++sdMMMN-     `mMMmMMMs      -NMMMh+///oys  `mMMMdo///oyy    \033[33m");        
  $display("                        :/---------------------------:++:--/++           \033[37m.MMMM.   `mMMMy     yMMM:dMMM/     +MMMM:      `  :MMMM+`     `    \033[33m");        
  $display("                       :/---///:-----------------------::-/+o`           \033[37m.MMMM.   -NMMMo    +MMMs -NMMm.    .mMMMNdo:.     `dMMMNds/-`      \033[33m");        
  $display("                      -+--/dNs-o/------------------------:+o`            \033[37m.MMMMyyyhNMMNy`   -NMMm`  sMMMh     .odNMMMMNd+`   `+dNMMMMNdo.    \033[33m");        
  $display("                     .o---yMMdsdo------------------------:s`             \033[37m.MMMMNmmmdho-    `dMMMdooosMMMM+      `./sdNMMMd.    `.:ohNMMMm-   \033[33m");        
  $display("                    -yo:--/hmmds:----------------//:------o              \033[37m.MMMM:...`       sMMMMMMMMMMMMMN-  ``     `:MMMM+ ``      -NMMMs   \033[33m");        
  $display("                   /yssy----:::-------o+-------/h/-hy:---:+              \033[37m.MMMM.          /MMMN:------hMMMd` +dy+:::/yMMMN- :my+:::/sMMMM/   \033[33m");        
  $display("                  :ysssh:------//////++/-------sMdyNMo---o.              \033[37m.MMMM.         .mMMMs       .NMMMs /NMMMMMMMMmh:  -NMMMMMMMMNh/    \033[33m");        
  $display("                  ossssh:-------ddddmmmds/:----:hmNNh:---o               \033[37m`::::`         .::::`        -:::: `-:/++++/-.     .:/++++/-.      \033[33m");        
  $display("                  /yssyo--------dhhyyhhdmmhy+:---://----+-                                                                                  ");        
  $display("                  `yss+---------hoo++oosydms----------::s    `.....-.                                                                       ");        
  $display("                   :+-----------y+++++++oho--------:+sssy.://:::://+o.                                                                      ");        
  $display("                    //----------y++++++os/--------+yssssy/:--------:/s-                                                                     ");        
  $display("             `..:::::s+//:::----+s+++ooo:--------+yssssy:-----------++                                                                      ");        
  $display("           `://::------::///+/:--+soo+:----------ssssys/---------:o+s.``                                                                    ");        
  $display("          .+:----------------/++/:---------------:sys+----------:o/////////::::-...`                                                        ");        
  $display("          o---------------------oo::----------::/+//---------::o+--------------:/ohdhyo/-.``                                                ");        
  $display("          o---------------------/s+////:----:://:---------::/+h/------------------:oNMMMMNmhs+:.`                                           ");        
  $display("          -+:::::--------------:s+-:::-----------------:://++:s--::------------::://sMMMMMMMMMMNds/`                                        ");        
  $display("           .+++/////////////+++s/:------------------:://+++- :+--////::------/ydmNNMMMMMMMMMMMMMMmo`                                        ");        
  $display("             ./+oo+++oooo++/:---------------------:///++/-   o--:///////::----sNMMMMMMMMMMMMMMMmo.                                          ");        
  $display("                o::::::--------------------------:/+++:`    .o--////////////:--+mMMMMMMMMMMMMmo`                                            ");        
  $display("               :+--------------------------------/so.       +:-:////+++++///++//+mMMMMMMMMMmo`                                              ");        
  $display("              .s----------------------------------+: ````` `s--////o:.-:/+syddmNMMMMMMMMMmo`                                                ");        
  $display("              o:----------------------------------s. :s+/////--//+o-       `-:+shmNNMMMNs.                                                  ");        
  $display("             //-----------------------------------s` .s///:---:/+o.               `-/+o.                                                    ");        
  $display("            .o------------------------------------o.  y///+//:/+o`                                                                          ");        
  $display("            o-------------------------------------:/  o+//s//+++`                                                                           ");        
  $display("           //--------------------------------------s+/o+//s`                                                                                ");        
  $display("          -+---------------------------------------:y++///s                                                                                 ");        
  $display("          o-----------------------------------------oo/+++o                                                                                 ");        
  $display("         `s-----------------------------------------:s   ``                                                                                 ");        
  $display("          o-:::::------------------:::::-------------o.                                                                                     ");        
  $display("          .+//////////::::::://///////////////:::----o`                                                                                     ");        
  $display("          `:soo+///////////+++oooooo+/////////////:-//                                                                                      ");        
  $display("       -/os/--:++/+ooo:::---..:://+ooooo++///////++so-`                                                                                     ");        
  $display("      syyooo+o++//::-                 ``-::/yoooo+/:::+s/.                                                                                  ");        
  $display("       `..``                                `-::::///:++sys:                                                                                ");        
  $display("                                                    `.:::/o+  \033[37m                                                                              ");											  
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");                                                                      
	$display ("                                                            Congratulations!                                                                ");
	$display ("                                                     You have passed all patterns!                                                          ");
    $display ("                                                       latency : %.1f                                      ",total_latency*CYCLE);
	$display ("--------------------------------------------------------------------------------------------------------------------------------------------");    
	$finish;	
end endtask



endmodule


