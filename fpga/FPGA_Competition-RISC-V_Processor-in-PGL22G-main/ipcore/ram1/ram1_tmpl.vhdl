-- Created by IP Generator (Version 2022.1 build 99559)
-- Instantiation Template
--
-- Insert the following codes into your VHDL file.
--   * Change the_instance_name to your own instance name.
--   * Change the net names in the port map.


COMPONENT ram1
  PORT (
    wr_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    addr : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    wr_byte_en : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    rd_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;


the_instance_name : ram1
  PORT MAP (
    wr_data => wr_data,
    addr => addr,
    wr_en => wr_en,
    wr_byte_en => wr_byte_en,
    clk => clk,
    rst => rst,
    rd_data => rd_data
  );
