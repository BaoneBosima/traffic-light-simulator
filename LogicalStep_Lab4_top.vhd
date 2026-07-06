--LS201_T16_Aditya_Bajpai_&_Baone_Bosima

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
    clkin_50	    : in	std_logic;							-- The 50 MHz FPGA Clockinput
	rst_n			: in	std_logic;							-- The RESET input (ACTIVE LOW)
	pb_n			: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
 	sw   			: in  	std_logic_vector(7 downto 0); -- The switch inputs
    leds			: out 	std_logic_vector(7 downto 0);	-- for displaying the the lab4 project details
	-------------------------------------------------------------
	-- you can add temporary output ports here if you need to debug your design 
	
	
	
	-- temp declarations for finalsimulation 
	--sm_clken_sim, blink_sig_sim, NS_g, NS_a, NS_d, EW_a, EW_g, EW_d:	out std_logic;
	-- or to add internal signals for your simulations
	-------------------------------------------------------------
	
   seg7_data 	: out 	std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors for Ew
	seg7_char2  : out	std_logic							-- seg7 digi selectors for NS
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS
--seven segment display output
   component segment7_mux port (
             clk        	: in  	std_logic := '0';
			 DIN2 			: in  	std_logic_vector(6 downto 0);	--bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DIN1 			: in  	std_logic_vector(6 downto 0); --bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DOUT			: out	std_logic_vector(6 downto 0);--segments output
			 DIG2			: out	std_logic;-- outputs the North- South  states
			 DIG1			: out	std_logic-- outputs the East-West states
   );
   end component;

	--clock generator for the finite state machine and blinking signal
   component clock_generator port (
		sim_mode			: in boolean;		-- used to select the clocking frequency for the output signals "sm_clken" and "blink".
		 reset				: in std_logic;--reset input bit
       clkin      		: in  std_logic; -- input used for counter and register clocking
		 sm_clken			: out	std_logic; -- output used to enbl the sm to advance by 1 clk.
		 blink		  		: out std_logic  -- output used for blink signal (1/4 the rate of the sm_clken)
  );
   end component;

	--
    component pb_filters port (
			clkin				: in std_logic;
			rst_n				: in std_logic;
			rst_n_filtered	    : out std_logic;
			pb_n				: in  std_logic_vector (3 downto 0);
			pb_n_filtered	    : out	std_logic_vector(3 downto 0)							 
 );
   end component;

	
	--component to invert push buttons from active low to active high
	component pb_inverters port (
			rst_n				: in  std_logic;--reset bit
			rst				    : out	std_logic;	--inverted reset bit						 
			pb_n_filtered	    : in  std_logic_vector (3 downto 0);--input bits
			pb					: out	std_logic_vector(3 downto 0)	--inverted filter bits					 
  );
   end component;
	
	--component to convert asynchronous signals to synchronous signals
	component synchronizer port(
			clk					: in std_logic;--clock input bit
			reset					: in std_logic;--reset bit
		din					: in std_logic;--input data which is the asynchrnous push button signal
		dout					: out std_logic-- output data bit after synchronization
  );
  end component; 
  
  
  
  --holding regster to store pedestrian requests  for those that want to cross
 component holding_register port (
		clk					: in std_logic;--input bit for clock
			reset					: in std_logic;--reset bit
			register_clr		: in std_logic;--register clear bit
		din					: in std_logic;--data input bit
			dout					: out std_logic --output data bit
			);
  end component;
  
  
  --finite state machne component to control the different states of the traffic light
  component finite_state_machine port(
  	
		clk_input, reset,sm_clken,ns_request,ew_request : in std_logic;
		blink_sig: in std_logic;
		ns_green,ns_amber,ns_red						: out std_logic;-- NS red,amber and green traffic light color outputs
		ew_green,ew_amber,ew_red						: out std_logic;-- EW red,amber and green traffic light color outputs
		ns_crossing	,ew_crossing										: out std_logic ;--EW crossing outputs
		ns_clear, ew_clear 								: out std_logic	;--EW crossing outputs
        state_num                                   :out std_logic_vector(3 downto 0);--corresponds to the different states of the finite state machine
			sw_0												:in std_logic--used to switch from offline to online mode
		);
		
	end component finite_state_machine;
----------------------------------------------------------------------------------------------------
	CONSTANT	sim_mode								: boolean := FALSE;  -- set to FALSE for LogicalStep board downloads																						-- set to TRUE for SIMULATIONS
	SIGNAL rst, rst_n_filtered, synch_rst			    : std_logic;
	SIGNAL sm_clken, blink_sig							: std_logic; 
	SIGNAL pb_n_filtered, pb							: std_logic_vector(3 downto 0); 
	
	
	
	signal ns_request,ew_request 								: std_logic ;-- stores  pedestrian requests to cross 
--signal for ns clear
	signal ns_clear,ew_clear : std_logic;;--it resets the pedestrian requests once the appropriate state has been reached
	
	
	--indicates that pedestrians are crossing from North-South or from East-West
	signal ns_crossing 											:std_logic ;
	signal ew_crossing											:std_logic;
	
	
	--signal for ns display on seven segment mux
	signal ns_segments: std_logic_vector(6 downto 0);-- store the concatenated outputs of the red,green and amber colours
	signal ns_green,ns_amber,ns_red: std_logic;-- red,amber and green traffic light colors
	
	
	--signals for ew diaplay on seven segment mux
	signal ew_segments: std_logic_vector(6 downto 0);-- store the concatenated outputs of the red,green and amber colours
	signal ew_green,ew_amber,ew_red: std_logic;-- red,amber and green traffic light colors
	
	
	
	
	signal ns_sync_out, ew_sync_out :std_logic;--stores the synchronoized request signal after it goes through the clock domain
	signal sw_0: std_logic;--signal to store the offline/online inpuit of the switch
	
BEGIN
----------------------------------------------------------------------------------------------------
INST0: pb_filters		port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);
INST1: pb_inverters		port map (rst_n_filtered, rst, pb_n_filtered, pb);
INST2: synchronizer     port map (clkin_50,synch_rst, rst, synch_rst);	
INST3: clock_generator 	port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig);

-------EW synchronizer and holding register for storing pedeastrian requests---
EW_Holding_reg : holding_register port map( clkin_50,rst,ew_clear,ew_request,ew_sync_out);--holds the ew request until it is transfered to the FSM and then cleared
INST5: synchronizer port map( clkin_50,rst, pb(1),ew_request);--synchronizes ew pedestrian push button to the clock domain
leds(3)<= ew_sync_out;--assigns the synchronized request to led 3


--------------------NS synchronizer and holding register------
NS_Holding_reg : holding_register port map( clkin_50,rst,ns_clear,ns_request,ns_sync_out);--holds the NS request until it is transfered to the FSM and then cleare
INST4: synchronizer port map( clkin_50,rst, pb(0),ns_request);--synchronizes NS pedestrian push button to the clock domain
leds(1)<= ns_sync_out;--assigns the synchronized request to led 1

sw_0 <= sw(0);--reads the value from switch zero and then transfers it to the FSM

--instance of the finite state machine and handles the finite state trasnitions---
INST6: finite_state_machine port map(clkin_50, synch_rst, sm_clken,ns_sync_out,ew_sync_out, blink_sig, ns_green, ns_amber,ns_red,ew_green,ew_amber,
													ew_red, ns_crossing,ew_crossing,ns_clear, ew_clear,leds(7 downto 4 ), sw_0);

--leds light up when ns / ew pedestrians are crossing
leds(0)<= ns_crossing;
leds(2)<= ew_crossing;


-- seven-segment display output for NS and EW traffic lights states

ns_segments<= ns_amber & "00" & ns_green & "00" & ns_red;
ew_segments<=  ew_amber & "00" & ew_green & "00" & ew_red;


--sevent segment multiplexer instanciation to out put the traffic light states on the fpga board
INST7: segment7_mux port map(clkin_50,ns_segments,ew_segments,seg7_data,seg7_char2,seg7_char1);



--final waveform assignments
--sm_clken_sim <= sm_clken;
--blink_sig_sim <= blink_sig;
--NS_d <= ns_green;
--NS_g <= ns_amber;
--NS_a <= ns_red;
--EW_d <= ew_green;
--EW_g <= ew_amber;
--EW_a <= ew_red;




END SimpleCircuit;
