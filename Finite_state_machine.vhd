--LS201_T16_Aditya_Bajpai_&_Baone_Bosima

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity finite_state_machine is port(

		clk_input, reset,sm_clken,ns_request,ew_request : in std_logic;
		blink_sig											: in std_logic;--blinking light signal
		ns_green,ns_amber,ns_red						: out std_logic;-- NS red,amber and green traffic light color outputs
		ew_green,ew_amber,ew_red						: out std_logic;-- EW red,amber and green traffic light color outputs
		ns_crossing	,ew_crossing						: out std_logic ;--indicates that pedestrians are crossing from North-South or from East-West
		ns_clear, ew_clear 								: out std_logic;-- signals to clear pedestrian request registers
		
		state_num											:out std_logic_vector(3 downto 0);--corresponds to the different states of the finite state machine
			sw_0												:in std_logic--used to switch from offline to online mode
		);
		
		end finite_state_machine;
		
		
architecture behavioral of finite_state_machine is
 
 TYPE STATE_NAMES IS (S0, S1, S2, S3, S4, S5, S6, S7,S8,S9,S10,S11,S12,S13,S14,S15);   -- all the STATE_NAMES values

 ---SIGNALS USED---
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES

 
 BEGIN
 
  -- REGISTER_LOGIC PROCESS EXAMPLE
 
Register_Section: PROCESS (clk_input)  -- this process updates with a clock

--updates current state on rising clock edge if reset is not active
BEGIN
	IF(rising_edge(clk_input)) THEN
		IF (reset = '1') THEN
			current_state <= S0;--when reset is active, start at state 0
		ELSIF (reset = '0' and sm_clken= '1') THEN
			current_state <= next_State;
		END IF;
	END IF;
END PROCESS;	


 --  TRANSITION LOGIC---
    process (current_state,sw_0)
    begin
        case current_state is
            when S0  => next_state <= S1;
				--skips to state 6 only if there is an EW request otherwise it continues with normal state sequence
				if( ew_request= '1' AND ns_request='0') then
					next_state<= S6;
				else
					next_state<= S1;
				end if;
				
				
				
            when S1  => next_state <= S2;
				--skips to state 6 only if there is an EW request otherwise it continues with normal state sequence
				if( ew_request= '1' AND ns_request='0') then
					next_state<= S6;
				else
					next_state<= S2;
				end if;
				
				
				
            when S2  => next_state <= S3;
				
            when S3  => next_state <= S4;
				
				
            when S4  => next_state <= S5;
				
            when S5  => next_state <= S6;
				
            when S6  => next_state <= S7;
				
            when S7  => next_state <= S8;
				
				
				
            when S8  => next_state <= S9;
				
				--skips to state 14 only if there is a crossing reqeust by NS pedestrians otherwise it continues with normal state sequence
				if( ew_request= '0' AND ns_request='1') then
					next_state<= S14;
				else
					next_state<= S9;
				end if;
				
				
				
				
            when S9  => next_state <= S10;
				--skips to state 14 only if there is a crossing reqeust by NS pedestrians otherwise it continues with normal state sequence
				
				if( ew_request= '0' AND ns_request='1') then
					next_state<= S14;
				else
					next_state<= S10;
				end if;
				
				
				
            when S10 => next_state <= S11;
				
            when S11 => next_state <= S12;
				
            when S12 => next_state <= S13;
				
            when S13 => next_state <= S14;
				
            when S14 => next_state <= S15;
				
            when S15 =>
				
				--if in offline mode, then it jumps to state 15
				if sw_0 = '1' then
				next_state<= S15;
				else
				--if in online mode, it continues with normal sequence
				next_state <= S0;
				end if;
				
            when others => next_state <= S0;
				
        end case;
    end process;
	 
	 
	 --DECODER SECTION----
	 
	 process (current_state,sw_0)
	 
	 --sets outputs for traffic light and control signals based on current state
	 BEGIN
	 
	 cASE current_state IS
	 
	 When S0| S1 => 
	 
	 --ns is assigned a blinking green signal whereas the EW traffic light is currently red
	 ns_green<= blink_sig;
	ns_amber<= '0';
	 ns_red<='0';
	 ns_clear<= '0';
	 
	 
	 
	ew_green<= '0';
	ew_amber<= '0';
	 
	 ew_red<='1';
	 
	 ew_clear<= '0';
	 
	 
	 --ns is at solid green at this point and  ns pedestrians can cross thus ns_crossing signal is active. ew traffic light is still red
	 When S2|S3|S4|S5 =>
	 
	 
	 ns_green<= '1';
	 ns_amber<= '0';
	 ns_red<='0';
	 ns_crossing<='1';
	 ns_clear<= '0';
	 
	 
	 ew_green<= '0';
	 ew_amber<= '0';
	 ew_red<='1';
	 
	 ew_crossing<='0';
	 ew_clear<= '0';
	 
	 
	 --ns traffic light turns amber and ns crossing reques is cleared. ew traffic light is still  red
	 when S6  =>
	 
	 ns_green<= '0';
	 ns_amber<= '1';
	 ns_red<='0';
	 ns_crossing<='0';
	 ns_clear<= '1';
	
	 
	 ew_green<= '0';
	 ew_amber<= '0';
	 ew_red<='1';
	 ew_crossing<='0';
	 ew_clear<= '0';
	 
	  --ns traffic light remains amber. ew traffic light is still  red
	 When S7  =>
	 
	 ns_green<= '0';
	 ns_amber<= '1';
	 ns_red<='0';
	 ns_crossing<='0';
	 ns_clear<= '0';
	 
	 ew_green<= '0';
	 ew_amber<= '0';
	 ew_red<='1';
	 ew_crossing<='0';
	 ew_clear<= '0';
	 
	 
	 -- the ew traffic light is assigned a blnking green signal. NS traffic light is now red
	 when S8|S9 =>
	 
	 
	  ns_green<= '0';
	 ns_amber<= '0';
	 ns_red<='1';
	 ns_crossing<='0';
	 ns_clear<= '0';
	 
	 ew_green<= blink_sig;
	 ew_amber<= '0';
	 ew_red<='0';
	 ew_crossing<='0';
	 ew_clear<= '0';
	 
	 --ns remaains red while ew traffic light turns solid green. ew pedestrians can now cross thus ew_crossing is on
	 When S10|S11|S12|S13  =>
	 
	 ns_green<= '0';
	 ns_amber<= '0';
	 ns_red<='1';
	 ns_crossing<='0';
	 ns_clear<= '0';
	 
	 ew_green<= '1';
	 ew_amber<= '0';
	 ew_red<='0';
	 ew_crossing<='1';
	 ew_clear<= '0';
	 
	 
	 --ns remains red and ew turns amber. Ew crossing requests are then cleared
	 When S14  =>
	 
	 ns_green<= '0';
	 ns_amber<= '0';
	 ns_red<='1';
	 ns_crossing<='0';
	 ns_clear<= '0';
	 
	 ew_green<= '0';
	 ew_amber<= '1';
	 ew_red<='0';
	 ew_crossing<='0';
	 ew_clear<= '1';
	 
	 
	--if in offline mode(sw_0=1) then the ns traffic light flashes red and ew traffic light flashes amber
	 When S15  =>
	 
	 
	 if sw_0 ='1' then
	  ns_green<= '0';
	 ns_amber<= '0';
	 ns_red<= blink_sig;
	 ns_crossing<='0';
	 ns_clear<= '0';
	 
	 ew_green<= '0';
	 ew_amber<= blink_sig;
	 ew_red<='0';
	 ew_crossing<='0';
	 ew_clear<= '0';
	 
	 --if not in offline mode, ns remains solid red and ew turns amber
	 else
	 
	 ns_green<= '0';
	 ns_amber<= '0';
	 ns_red<='1';
	 ns_crossing<='0';
	 ns_clear<= '0';
	 
	 ew_green<= '0';
	 ew_amber<= '1';
	 ew_red<='0';
	 ew_crossing<='0';
	 ew_clear<= '0';
	 end if;
	 
	 	  END CASE;

		  --  assigns a state's binary value to the state num
		 CASE current_state IS
    WHEN S0 => 
        state_num <= "0000";
    WHEN S1 => 
        state_num <= "0001";
    WHEN S2 => 
        state_num <= "0010";
    WHEN S3 => 
        state_num <= "0011";
    WHEN S4 => 
        state_num <= "0100"; 
    WHEN S5 => 
        state_num <= "0101";
    WHEN S6 => 
        state_num <= "0110";
    WHEN S7 => 
        state_num <= "0111";
    WHEN S8 => 
        state_num <= "1000";
    WHEN S9 => 
        state_num <= "1001";
    WHEN S10 => 
        state_num <= "1010";
    WHEN S11 => 
        state_num <= "1011";  
    WHEN S12 => 
        state_num <= "1100";
    WHEN S13 => 
        state_num <= "1101";
    WHEN S14 => 
        state_num <= "1110";
    WHEN S15 => 
        state_num <= "1111";
    WHEN OTHERS => 
        state_num <= "0000";  
END CASE;



		 
		 END PROCESS;

 END behavioral;

	 
	 
	 
	 
	 