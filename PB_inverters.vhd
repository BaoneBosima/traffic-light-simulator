--LS201_T16_Aditya_Bajpai_&_Baone_Bosima


library ieee;
use ieee.std_logic_1164.all;

--entity for pb inverters that will invert all the bit the receive to change from active low to active high.
entity PB_inverters is port (
	rst_n				: in	std_logic;--reset bit
	rst				: out std_logic;--inverted reset bit
 	pb_n_filtered	: in  std_logic_vector (3 downto 0);--input bit
	pb					: out	std_logic_vector(3 downto 0)	--inverted filter bit.						 
	); 
end PB_inverters;

architecture ckt of PB_inverters is

begin

rst <= NOT(rst_n);-- inverts reset
pb <= NOT(pb_n_filtered);-- inverst the filtered button


end ckt;