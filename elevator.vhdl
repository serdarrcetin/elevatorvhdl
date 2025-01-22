library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity elevator_project is
 Port (clk     : in std_logic;
          sw      : in std_logic_vector(15 downto 0);
          seg     : out std_logic_vector(6 downto 0);
          led     : out std_logic_vector(15 downto 0);
          an      : out std_logic_vector(3 downto 0);
          btnU    : in std_logic_vector(0 downto 0);
          btnD    : in std_logic_vector(0 downto 0) -- to match debouncer instantiation, which is a vector type
          );
end elevator_project;

architecture Behavioral of elevator_project is
component debouncer
        Generic(
            DEBNC_CLOCKS : integer;
            PORT_WIDTH : integer);
        Port(
            SIGNAL_I : in std_logic_vector(0 downto 0); -- just 1 element, but it's a vector type
            CLK_I : in std_logic;          
            SIGNAL_O : out std_logic_vector(0 downto 0)); -- just 1 element, but it's a vector type
    end component;
   
    signal btn_d     : std_logic_vector(0 downto 0); -- to match debouncer instantiation
    signal btn_d_d   : std_logic := '0';
    signal btn_d_re  : std_logic;
   
    signal busy: std_logic := '0';
   
    type tState is (zero, one, two, three, four, five, six, seven, eight, nine, ten, eleven, twelve, thirteen, fourteen, fifteen);
    signal state_t0, state_t1: tState;
   
begin
-- burayı revize edicez
--an <= "1110";
--    with sevsegval select
--        seg <= "1000000" when 0,
--               "1111001" when 1,
--               "0100100" when 2,
--               "1000111" when 4,
--               "1111111" when others;

    debounce_module_u: debouncer
        generic map(
            DEBNC_CLOCKS => (2**16), -- this number X the clock period (10 ns) makes approx. a 0.655 ms debouncing period
            PORT_WIDTH => 1) -- just 1 button
        port map(SIGNAL_I => btnU, CLK_I => clk, SIGNAL_O => btn_d);
   
    debounce_module_d: debouncer
        generic map(
            DEBNC_CLOCKS => (2**16), -- this number X the clock period (10 ns) makes approx. a 0.655 ms debouncing period
            PORT_WIDTH => 1) -- just 1 button
        port map(SIGNAL_I => btnD, CLK_I => clk, SIGNAL_O => btn_d);

    state_machine: process(state_t0, btn_d, clk)
    begin

    end process;


    state_change: process(clk)
    begin
   
    end process;
   
   
end Behavioral;
