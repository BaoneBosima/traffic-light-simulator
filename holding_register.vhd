--LS201_T16_Aditya_Bajpai_&_Baone_Bosima

library ieee;
use ieee.std_logic_1164.all;

--dilding register enitities 
entity holding_register is port (

			clk					: in std_logic;--inpuit bit for clock
			reset				: in std_logic;--reset bit
			register_clr		: in std_logic;--register clear bit
			din					: in std_logic;--data input bit
			dout				: out std_logic
  );
 end holding_register;
 
 architecture circuit of holding_register is

	Signal sreg				: std_logic;--signal to internally hold register values


BEGIN



register_sync : process(clk)
--if clock is on rising edge, then continue with signal and output assignment
BEGIN
		if (rising_edge(clk)) then
		
		--store the value of din if it is '1' otherwise retain previous stae(sreg), unless reset of register_clr is asserted, which clears it
		sreg<= (din OR sreg) AND (Not (reset OR register_clr));

		dout<=(din OR sreg) AND (Not (reset OR register_clr));--output follows same logic
		
		
		end if;
		
	end process;
	


end;