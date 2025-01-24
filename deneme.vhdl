library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

type tState is (zero, one, two); -- to show that the enumerated states can be arbitrary names
signal state: tState;

state_machine: process(state,btn_u, btn_d, clk)
begin
      if rising_edge(clk) then
            case state is
                when zero  => if (btn_u_re = '1') then
                              dir_check<='1';
                              lower<=15;
                              upper<=0;
                              sw_count<=0;
                              state<=one;
                              end if;
                              if (btn_d_re = '1') then
                              dir_check<='0';
                              lower<=15;
                              upper<=0;
                              sw_count<=0;
                              state<=one;
                              end if;
              
                when one   => for i in 0 to 15 loop
                               if sw(i) = '1' then
                                    sw_count<=sw_count+1;
                                    if i<lower  then
                                        lower <= i;
                                    end if;
                                    if i>upper then
                                        upper <= i;
                                    end if;
                                end if;            
                              end loop;  
                              state <= two;
                                      
                when two   => if dir_check = '1' then
                              floor1<=lower;
                              floor2<=upper;
                              elsif dir_check = '0' then
                              floor1<=lower;
                              floor2<=upper;
                              end if;
                              if sw_count/=2 then
                              sw_count_check='0';
                              else 
                              sw_count_check='1';
                              end if
                              state<=zero;
            end case;
    end if;
end process;

            
