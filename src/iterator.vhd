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


entity iterator is
    generic (
        R_SQ          : integer := 4;
        DSP_WIDTH     : integer := 18;
        N_DECIMALS    : integer := 14;
        MAX_ITER      : integer := 100;
        COORD_WIDTH   : integer := 16;
        MEM_WIDTH     : integer := 8
    );
    port (
        clk_i     : in std_logic;
        rst_i     : in std_logic;

        -- Feed from coordinate generator
        c_real_i  : in std_logic_vector(DSP_WIDTH  -1 downto 0);
        c_imag_i  : in std_logic_vector(DSP_WIDTH  -1 downto 0);
        x_i       : in std_logic_vector(COORD_WIDTH-1 downto 0);
        y_i       : in std_logic_vector(COORD_WIDTH-1 downto 0);

        -- Control signals
        nextval_o : out std_logic;

        -- Memory control signals
        addr_o : out std_logic_vector(2*COORD_WIDTH-1 downto 0);
        data_o : out std_logic_vector(MEM_WIDTH-1 downto 0);
        we_o   : out std_logic
    );
end iterator;
architecture seq of iterator is

    -- Component declarations
    component zc_adder
      generic (
          SIZE : integer := 18;
          FIXEDPOINT : integer := 4;
          R_SQ : integer := 4
      );
      port (
          z_real_i      : in  std_logic_vector(SIZE-1 downto 0);
          z_imag_i      : in  std_logic_vector(SIZE-1 downto 0);
          c_real_i      : in  std_logic_vector(SIZE-1 downto 0);
          c_imag_i      : in  std_logic_vector(SIZE-1 downto 0);
          z_next_real_o : out std_logic_vector(SIZE-1 downto 0);
          z_next_imag_o : out std_logic_vector(SIZE-1 downto 0);
          z_greater_r_o : out std_logic
      );
    end component;

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
    nextval_o  <= nextval_s; -- todo replace with we if it works


    adder : zc_adder
    generic map(
        SIZE => DSP_WIDTH,
        FIXEDPOINT => N_DECIMALS,
        R_SQ => R_SQ
    )
    port map(
        z_real_i      => z_real_reg_s,
        z_imag_i      => z_imag_reg_s,
        c_real_i      => c_next_real_s,
        c_imag_i      => c_next_imag_s,
        z_next_real_o => z_next_real_s,
        z_next_imag_o => z_next_imag_s,
        z_greater_r_o => z_greater_r_s
    );

    -- State selection process
    state : process(clk_i, rst_i)
    begin
      if rst_i = '1' then
        state_s <= INIT;
      elsif rising_edge(clk_i) then
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
    end process state;

    output_decode: process(clk_i,rst_i)
    begin
      nextval_s     <= '0';
      --z_next_real_s <= (others => '0');
      --z_next_imag_s <= (others => '0');
      addr_o        <= (others => '0');
      data_o        <= (others => '0');
      we_o          <= '0';
      cnt_incr_s    <= '0';

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
          addr_o <= y_reg_s & x_reg_s;
          --data_o <= std_logic_vector(to_unsigned(iter_cnt_s,data_o'length));
          data_o <= (others=>'0') when z_greater_r_reg_s else (others=>'1');
          we_o   <= '1';

        when others =>
        -- default outputs
      end case;
    end process output_decode;


    -- Registers: C-coords, XY-coords and counter
    regs : process (clk_i, rst_i) is
    begin
      -- Async reset
      if rst_i = '1' then
        c_next_real_s <= (others=>'0');
        c_next_imag_s <= (others=>'0');
        x_reg_s       <= (others=>'0');
        y_reg_s       <= (others=>'0');
        z_real_reg_s  <= (others=>'0');
        z_imag_reg_s  <= (others=>'0');
        iter_cnt_s    <= 0;
        z_greater_r_reg_s <= '0';
      elsif(rising_edge(clk_i)) then

        z_greater_r_reg_s <= z_greater_r_s;
        if nextval_s = '1' then -- Load from inputs -> start sequence
          c_next_real_s <= c_real_i;
          c_next_imag_s <= c_imag_i;
          x_reg_s       <= x_i;
          y_reg_s       <= y_i;
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
