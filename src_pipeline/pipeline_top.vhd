--------------------------------------------------------------------------------
--
-- File     : pipeline_top.vhd
-- Author   : Marc Leemann
-- Date     : 23.05.2022
--
-- Context  : Mandelbrot project
--
--------------------------------------------------------------------------------
-- Description :
--  Top-level file using two iterator state machines to use a two-stage
--  pipelined ZC adder. Computes a Mandelbrot set, but normally twice as fast.
--------------------------------------------------------------------------------
-- Dependencies :
--  zc_adder.vhd
--  iterator_pl.vhd
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 1.0   23.05.2022  MLN        Initial version
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library iter_pl;
--use iter_pl.iter_pl_pkg.all;
library xil_defaultlib;
use xil_defaultlib.iter_pl_pkg.all;


entity pipeline_top is
    generic (
        R_SQ          : integer := 4;
        DSP_WIDTH     : integer := 18;
        N_DECIMALS    : integer := 14;
        MAX_ITER      : integer := 100;
        COORD_WIDTH   : integer := 10;
        MEM_WIDTH     : integer := 9
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
end pipeline_top;
architecture seq of pipeline_top is

  COMPONENT ila_1

  PORT (
  	clk : IN STD_LOGIC;



  	probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
  END COMPONENT;

    -- Component declarations
    component zc_adder_pl
      generic (
          SIZE : integer := 18;
          FIXEDPOINT : integer := 4;
          R_SQ : integer := 4
      );
      port (
          clk_i : in std_logic;
          rst_i : in std_logic;
          zc_i : in iter_zc_out_t;
          zc_o : out iter_zc_in_t
      );
    end component;

    component iterator_pl
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
    end component;



    signal cv_i : iter_compgen_in_t;

    signal iter0_o : iterator_outputs_t;
    signal iter1_o : iterator_outputs_t;

    signal iter0_i : iterator_inputs_t;
    signal iter1_i : iterator_inputs_t;

    signal zc_i_s : iter_zc_out_t;
    signal zc_o_s : iter_zc_in_t;


    signal addr_pl_s : std_logic;
begin
  your_instance_name : ila_1
  PORT MAP (
  	clk => clk_i,



  	probe0(0) => addr_pl_s
  );
    adder : zc_adder_pl
    generic map(
        SIZE => DSP_WIDTH,
        FIXEDPOINT => N_DECIMALS,
        R_SQ => R_SQ
    )
    port map(
        clk_i => clk_i,
        rst_i => rst_i,
        zc_i  => zc_i_s,
        zc_o  => zc_o_s
    );

    -- Iterator declarations
    -- Iter 1 is master of the pipeline selection
    iter_0 : iterator_pl
    generic map(
      R_SQ          => R_SQ,
      DSP_WIDTH     => DSP_WIDTH,
      N_DECIMALS    => N_DECIMALS,
      MAX_ITER      => MAX_ITER,
      COORD_WIDTH   => COORD_WIDTH,
      MEM_WIDTH     => MEM_WIDTH,
      ITERATOR_ID   => '0'
    )
    port map (
        clk_i => clk_i,
        rst_i => rst_i,
        -- Inputs
        iter_i    => iter0_i,
        -- Outpus
        iter_o    => iter0_o
    );

    iter_1 : iterator_pl
    generic map(
      R_SQ          => R_SQ,
      DSP_WIDTH     => DSP_WIDTH,
      N_DECIMALS    => N_DECIMALS,
      MAX_ITER      => MAX_ITER,
      COORD_WIDTH   => COORD_WIDTH,
      MEM_WIDTH     => MEM_WIDTH,
      ITERATOR_ID   => '1'
    )
    port map (
        clk_i => clk_i,
        rst_i => rst_i,
        -- Inputs
        iter_i    => iter1_i,
        -- Outputs
        iter_o    => iter1_o
    );

    -- addr_pl in iterator masks those inputs, so they are wired in parallel
    -- Architecture inputs from coordinate generator
    cv_i.c_real <= c_real_i;
    cv_i.c_imag <= c_imag_i;
    cv_i.x <= x_i;
    cv_i.y <= y_i;
    iter0_i.cv <= cv_i;
    iter1_i.cv <= cv_i;
    -- ZC interconnect
    iter0_i.zc <= zc_o_s;
    iter1_i.zc <= zc_o_s;

    -- Output selection with iterator 1 as master
    addr_pl_s <= iter1_i.zc.addr_pl;

    -- ZC interconnect
    zc_i_s <= iter1_o.zc when addr_pl_s else iter0_o.zc;
    -- Architecture outputs to complex value generator and memory
    nextval_o <= iter1_o.nextval  when addr_pl_s else iter0_o.nextval;
    addr_o    <= iter1_o.mem.addr when addr_pl_s else iter0_o.mem.addr;
    data_o    <= iter1_o.mem.data when addr_pl_s else iter0_o.mem.data;
    we_o      <= iter1_o.mem.we   when addr_pl_s else iter0_o.mem.we;

end seq;
