--LS201_T16_Aditya_Bajpai_&_Baone_Bosima


library ieee;
use ieee.std_logic_1164.all;

--synchronizer entity 
entity synchronizer is port (

			clk			: in std_logic;--clock input bit
			reset		: in std_logic;--reset bit
			din			: in std_logic;--input data which is the asynchrnous push button signal
			dout		: out std_logic-- output data bit after synchronization
  );
 end synchronizer;
 
 
architecture circuit of synchronizer is
--two-stage shift register to reduce metastability
	Signal sreg				: std_logic_vector(1 downto 0);

BEGIN
process(clk)


begin
--on clock rising edge, contiune with evaluation

if (rising_edge(clk)) then
--if reset is active, set the register contents to zero
	if reset='1' then 
	sreg<= "00'';
	
	else
	
-- shift the din signal through two flip flops
	sreg(0) <=  din;-- first stage: takes data input and  assign it to first register
	sreg(1) <=  sreg(0);--second  stage is a stable outpuit
end if;
end process;

--output the synchronized value from second stage
	dout <=  sreg(1); 

end;