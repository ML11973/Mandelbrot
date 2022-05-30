--------------------------------------------------------------------------------
--
-- File     : iterator.vhd
-- Author   : Marc Leemann
-- Date     : 09.05.2022
--
-- Context  : Mandelbrot project
--
--------------------------------------------------------------------------------
-- Description :
--  Iterator to compute Mandelbrot series until convergence or max iterations.
--  Feeds Z and C-values back to ZC adder until result is greater than radius
--  generic (R_SQ) or max iterations (generic) were reached.
--------------------------------------------------------------------------------
-- Dependencies :
--  zc_adder.vhd
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 1.0   09.05.2022  MLN        Initial version
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library iter_pl;
--use iter_pl.iter_pl_pkg.all;
library xil_defaultlib;
use xil_defaultlib.iter_pl_pkg.all;

entity iterator_pl is
    generic (
        R_SQ          : integer := 4;
        DSP_WIDTH     : integer := 18;
        N_DECIMALS    : integer := 14;
        MAX_ITER      : integer := 100;
        COORD_WIDTH   : integer := 16;
        MEM_WIDTH     : integer := 8;
        ITERATOR_ID   : std_logic := '0'
    );
    port (
        clk_i     : in std_logic;
        rst_i     : in std_logic;

        -- Inputs
        iter_i    : in iterator_inputs_t;
        -- Outpus
        iter_o    : out iterator_outputs_t
    );
end iterator_pl;
architecture seq of iterator_pl is

    type state_type is (INIT,ITER,MEM_WRITE);
    signal state_s : state_type;

    constant max_cnt_val : integer := MAX_ITER-1;
    -- Z output from zc_adder
    --signal z_real_s       : std_logic_vector(DSP_WIDTH-1 downto 0);
    --signal z_imag_s       : std_logic_vector(DSP_WIDTH-1 downto 0);
    signal z_greater_r_s  : std_logic;


    -- zc_adder inputs
    signal z_next_real_s  : std_logic_vector(DSP_WIDTH-1 downto 0);
    signal z_next_imag_s  : std_logic_vector(DSP_WIDTH-1 downto 0);
    -- C-values (register)
    signal c_next_real_s  : std_logic_vector(DSP_WIDTH-1 downto 0);
    signal c_next_imag_s  : std_logic_vector(DSP_WIDTH-1 downto 0);

    -- XY coordinate registers
    signal x_reg_s : std_logic_vector(COORD_WIDTH-1 downto 0);
    signal y_reg_s : std_logic_vector(COORD_WIDTH-1 downto 0);
    -- Z registers
    signal z_real_reg_s : std_logic_vector(DSP_WIDTH-1 downto 0);
    signal z_imag_reg_s : std_logic_vector(DSP_WIDTH-1 downto 0);

    -- Iteration counter (register)
    signal iter_cnt_s   : natural range 0 to MAX_ITER; -- TODO check synthesis
    signal z_greater_r_reg_s : std_logic;

    -- Control signals
    signal cnt_incr_s   : std_logic;
    signal nextval_s    : std_logic;


begin
    iter_o.nextval  <= nextval_s; -- todo replace with we if it works

    -- Former adder skeleton
    iter_o.zc.z_real <= z_real_reg_s;
    iter_o.zc.z_imag <= z_real_reg_s;
    iter_o.zc.c_real <= c_next_real_s;
    iter_o.zc.c_imag <= c_next_imag_s;
    z_next_real_s <= iter_i.zc.z_next_real;
    z_next_imag_s <= iter_i.zc.z_next_imag;
    z_greater_r_s <= iter_i.zc.z_greater_r;


    -- State selection process
    state : process(clk_i, rst_i)
    begin
      if rst_i = '1' then
        state_s <= INIT;
      elsif rising_edge(clk_i) then
        if iter_i.zc.addr_pl = ITERATOR_ID then
          case state_s is
            when INIT =>
              state_s <= ITER;

            when ITER =>
              -- On divergence or max iterations
              if (z_greater_r_s = '1') or (iter_cnt_s = max_cnt_val) then
                state_s <= MEM_WRITE;
              end if;

            when MEM_WRITE =>
              -- Get back to iterating
              state_s <= ITER;
            when others =>
              state_s <= INIT;
          end case;
        end if;
      end if;
    end process state;

    output_decode: process(clk_i,rst_i)
    begin
      nextval_s     <= '0';
      iter_o.mem.addr        <= (others => '0');
      iter_o.mem.data        <= (others => '0');
      iter_o.mem.we          <= '0';
      cnt_incr_s    <= '0';
      -- Signals iterator has not been active on this cycle
      iter_o.zc.addr_pl <= not ITERATOR_ID;

      if iter_i.zc.addr_pl = ITERATOR_ID then
        iter_o.zc.addr_pl <= ITERATOR_ID;
        case state_s is
          when INIT =>
            -- default outputs
            nextval_s <= '1';

          when ITER =>
            -- loop back z-values to zc_adder
            --z_real_s <= z_next_real_s;
            --z_imag_s <= z_next_imag_s; -- TODO add registers
            cnt_incr_s    <= '1';

          when MEM_WRITE =>
            -- load next values from coord generator
            nextval_s <= '1';
            -- write current iterations to memory
            iter_o.mem.addr <= y_reg_s & x_reg_s;
            iter_o.mem.data <= std_logic_vector(to_unsigned(iter_cnt_s,iter_o.mem.data'length));
            --iter_o.mem.data <= (others=>'0') when z_greater_r_reg_s else (others=>'1');
            iter_o.mem.we   <= '1';

          when others =>
          -- default outputs
        end case;
      end if;
    end process output_decode;


    -- Registers: C-coords, XY-coords and counter
    regs : process (clk_i, rst_i) is
    begin
      if(rising_edge(clk_i)) then
        z_greater_r_reg_s <= z_greater_r_s;

          -- Synchronous reset
        if rst_i = '1' then
          c_next_real_s <= (others=>'0');
          c_next_imag_s <= (others=>'0');
          x_reg_s       <= (others=>'0');
          y_reg_s       <= (others=>'0');
          z_real_reg_s  <= (others=>'0');
          z_imag_reg_s  <= (others=>'0');
          iter_cnt_s    <= 0;
          z_greater_r_reg_s <= '0';
        elsif nextval_s = '1' then -- Load from inputs -> start sequence
          c_next_real_s <= iter_i.cv.c_real;
          c_next_imag_s <= iter_i.cv.c_imag;
          x_reg_s       <= iter_i.cv.x;
          y_reg_s       <= iter_i.cv.y;
          iter_cnt_s    <= 0; -- reset counter on register load
          z_real_reg_s  <= (others=>'0');
          z_imag_reg_s  <= (others=>'0');
        elsif cnt_incr_s = '1' then
          iter_cnt_s    <= iter_cnt_s + 1; -- TODO check syntax and synthesis
          -- keep C and XY-values
          z_real_reg_s  <= z_next_real_s;
          z_imag_reg_s  <= z_next_imag_s;
        else -- hold
          -- keep values, do nothing
        end if;
      end if;
    end process;
end seq;
