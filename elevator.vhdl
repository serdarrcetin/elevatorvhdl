library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity elevator_project is
 Port (   clk     : in std_logic;
          sw      : in std_logic_vector(15 downto 0);
          seg     : out std_logic_vector(6 downto 0);
          led     : out std_logic_vector(15 downto 0);
          an      : out std_logic_vector(3 downto 0);
          btnU    : in std_logic_vector(0 downto 0);
          btnR    : in std_logic_vector(0 downto 0);
          btnL    : in std_logic_vector(0 downto 0);
          btnD    : in std_logic_vector(0 downto 0)
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

    signal btn_u     : std_logic_vector(0 downto 0); -- to match debouncer instantiation
    signal btn_u_d   : std_logic := '0';
    signal btn_u_re  : std_logic;
   
    signal btn_r     : std_logic_vector(0 downto 0); -- to match debouncer instantiation
    signal btn_r_d   : std_logic := '0';
    signal btn_r_re  : std_logic;
   
    signal btn_l     : std_logic_vector(0 downto 0); -- to match debouncer instantiation
    signal btn_l_d   : std_logic := '0';
    signal btn_l_re  : std_logic;

    signal btn_d     : std_logic_vector(0 downto 0); -- to match debouncer instantiation
    signal btn_d_d   : std_logic := '0';
    signal btn_d_re  : std_logic;

    signal sevsegval : integer range 0 to 9 := 0;
   
    signal people_count : integer range 0 to 9 := 0;

    signal count_sw   : INTEGER range 0 to 16 := 0;
    signal lower     : INTEGER range 0 to 15 := 0;
    signal upper     : INTEGER range 0 to 15 := 0;              
    signal floor1     : INTEGER range 0 to 15 := 0;        
    signal floor2     : INTEGER range 0 to 15 := 0;
    signal current_floor  : INTEGER range 0 to 15 := 0;
    signal dir_check: std_logic:= '0';


    signal count : integer range 0 to 99999999 := 0;
    signal state : INTEGER range 0 to 4 := 0;

   
begin
-- burayı revize edicez
      an <= "1110";
      with sevsegval select
          seg <=   "1000000" when 0,  -- 0
                   "1111001" when 1,  -- 1
                   "0100100" when 2,  -- 2
                   "0110000" when 3,  -- 3
                   "0011001" when 4,  -- 4
                   "0010010" when 5,  -- 5
                   "0000010" when 6,  -- 6
                   "1111000" when 7,  -- 7
                   "0000000" when 8,  -- 8
                   "0010000" when 9;  -- 9
           
    debounce_module_u: debouncer
        generic map(
            DEBNC_CLOCKS => (2**16), -- this number X the clock period (10 ns) makes approx. a 0.655 ms debouncing period
            PORT_WIDTH => 1) -- just 1 button
        port map(SIGNAL_I => btnU, CLK_I => clk, SIGNAL_O => btn_u);
   
    debounce_module_r: debouncer
        generic map(
            DEBNC_CLOCKS => (2**16), -- this number X the clock period (10 ns) makes approx. a 0.655 ms debouncing period
            PORT_WIDTH => 1) -- just 1 button
        port map(SIGNAL_I => btnR, CLK_I => clk, SIGNAL_O => btn_r);
     
     debounce_module_l: debouncer
        generic map(
            DEBNC_CLOCKS => (2**16), -- this number X the clock period (10 ns) makes approx. a 0.655 ms debouncing period
            PORT_WIDTH => 1) -- just 1 button
        port map(SIGNAL_I => btnL, CLK_I => clk, SIGNAL_O => btn_l);

    debounce_module_d: debouncer
        generic map(
            DEBNC_CLOCKS => (2**16), -- this number X the clock period (10 ns) makes approx. a 0.655 ms debouncing period
            PORT_WIDTH => 1) -- just 1 button
        port map(SIGNAL_I => btnD, CLK_I => clk, SIGNAL_O => btn_d);


    state_change: process(clk)
    begin
       if rising_edge(clk) then
           btn_d_d <= btn_d(0);
           btn_u_d <= btn_u(0);
           btn_r_d <= btn_r(0);
           btn_l_d <= btn_l(0);
           
           if (btn_r_re = '1') and state=0 then
           people_count <= people_count + 1;
           end if;
           
           if (btn_l_re = '1') and state=0 then
               if people_count /=0 then
               people_count <= people_count - 1;
               end if;
           end if;
           
           if (btn_u_re = '1') then
           dir_check<='1';
--           count_sw <=0;
--           Detect which switches are on
            for i in 0 to 15 loop
               if sw(i) = '1' then
                   if i=0 then
                        lower<=15;
                        upper<=0;
                    else
                    if i<lower  then
                        lower <= i;
                    end if;
                    if i>upper then
                        upper <= i;
                    end if;
                    end if;
                end if;            
            end loop;          
            end if;  
                       
            if (btn_d_re = '1') then
            dir_check<='0';
--            count_sw <=0;        
--            Detect which switches are on        
            for i in 0 to 15 loop
                    if sw(i) = '1' then
                        if i=0 then
                        lower<=15;
                        upper<=0;
                        else
                            if i<lower  then
                                lower <= i;
                            end if;
                            if i>upper then
                                upper <= i;
                            end if;
                         end if;
                    end if;  
                end loop;                                          
            end if;
           
            if dir_check='1' then
                floor1<=lower;
                floor2<=upper;
            elsif dir_check='0' then
                floor1<=upper;
                floor2<=lower;
            end if;
           
--burayla oyna
            if(current_floor = 0) then sevsegval <= 0;
            elsif (current_floor = 1) then sevsegval <= 1;
            elsif (current_floor = 2) then sevsegval <= 2;
            elsif (current_floor = 3) then sevsegval <= 3;
            elsif (current_floor = 4) then sevsegval <= 4;
            elsif (current_floor = 5) then sevsegval <= 5;
            elsif (current_floor = 6) then sevsegval <= 6;
            elsif (current_floor = 7) then sevsegval <= 7;
            elsif (current_floor = 8) then sevsegval <= 8;
            elsif (current_floor = 9) then sevsegval <= 9;
            end if;


 -- buraya kadar    

--      if count_sw_check ='1' then
--            if current_floor<floor1 then
--            initial_direction<=2;
--            elsif current_floor>floor1 then
--            initial_direction<=1;
--            else
--            initial_direction<=0;
--            end if;
--      else
--            initial_direction<=3;
--      end if;
      case state is
                when 0 => -- Idle
                if current_floor=floor2 then
                state <= 0;
                elsif current_floor<floor1 and people_count<7 then
                state <= 4;
                elsif current_floor>floor1 and people_count<7 then
                state <= 3;
                elsif current_floor=floor1 and current_floor<floor2 and people_count<7 then
                state <= 2;
                elsif current_floor=floor1 and current_floor>floor2 and people_count<7 then
                state <= 1;            
                end if;
             


                when 1 => -- Moving Down
                    if count = 99999 then
                       count <= 0;
                       if current_floor > floor2 then
                           current_floor <= current_floor - 1;
                       elsif current_floor = floor2 then
                           state <= 0; -- Back to Idle
                       end if;
                    else
                    count <= count + 1;
                    end if;

                when 2 => -- Moving Up
                    if count = 99999 then
                       count <= 0;
                       if current_floor < floor2 then
                           current_floor <= current_floor + 1;
                       elsif current_floor = floor2 then
                           state <= 0; -- Back to Idle
                       end if;
                    else
                    count <= count + 1;
                    end if;

                 when 3 => -- Initial Moving Down
                    if count = 99999 then
                       count <= 0;
                       if current_floor > floor1 then
                           current_floor <= current_floor - 1;
                       elsif current_floor = floor1 and current_floor<floor2 then
                           state <= 2;
                       elsif current_floor = floor1 and current_floor>floor2 then
                           state <= 1;
                       end if;
                    else
                    count <= count + 1;
                    end if;

                  when 4 => -- Initial Moving Up
                    if count = 99999 then
                       count <= 0;
                       if current_floor < floor1 then
                           current_floor <= current_floor + 1;
                       elsif current_floor = floor1 and current_floor<floor2 then
                           state <= 2;
                       elsif current_floor = floor1 and current_floor>floor2 then
                           state <= 1;
                       end if;
                    else
                    count <= count + 1;
                    end if;
            end case;

          for i in 0 to 15 loop
                if i = current_floor then
                    led(i) <= '1';
                else
                    led(i) <= '0';
                end if;
          end loop;


          btn_d_re <= not btn_d_d and btn_d(0);
          btn_u_re <= not btn_u_d and btn_u(0);
          btn_r_re <= not btn_r_d and btn_r(0);
          btn_l_re <= not btn_l_d and btn_l(0);


    end if;
  end process;
end Behavioral;
