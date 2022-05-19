--------------------------------------------------------------------------------
--
-- File     : iter_tb.vhd
-- Author   : Marc Leemann
-- Date     : 16.05.2022
--
-- Context  : Mandelbrot project
--
--------------------------------------------------------------------------------
-- Description :
--  Testbench for iterator
--------------------------------------------------------------------------------
-- Dependencies :
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person     Comments
-- 1.0   16.05.2022  MLN        Initial version
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- file library
use std.textio.all;

entity iter_adder_tb is
    generic (
        FIXEDPOINT  : integer := 12;
        SIZE        : integer := 18;
        R_SQ        : integer := 4;
        MAX_ITER    : integer := 100;
        COORD_WIDTH : integer := 10;
        MEM_WIDTH   : integer := 9
    );
end iter_adder_tb;


architecture tb of iter_adder_tb is

    type stimulus_t is record
        c_real  : std_logic_vector(SIZE - 1 downto 0);
        c_imag  : std_logic_vector(SIZE - 1 downto 0);
        x       : std_logic_vector(COORD_WIDTH - 1 downto 0);
        y       : std_logic_vector(COORD_WIDTH - 1 downto 0);
    end record;

    type observed_t is record
        addr    : std_logic_vector(COORD_WIDTH*2 - 1 downto 0);
        data    : std_logic_vector(MEM_WIDTH - 1 downto 0);
        we      : std_logic;
    end record;

    signal sti : stimulus_t; -- Stimulus
    signal obs : observed_t; -- Observed signals
    signal ref : observed_t; -- Reference output signals

    -- Clock period
    constant PERIOD : time := 10 ns;

    signal clk_s   : std_logic := '0';
    signal reset_s : std_logic := '0';


    -- Simulation flags
    signal sim_over_s : boolean   := false;
    signal sti_ok_s   : std_logic := '0';
    signal err_s      : std_logic := '0';

    -- DUV signals
    signal nextval_s : std_logic;

    -- Path for reference values
    constant txt_path : string := "/run/media/leemarc/Shared/Switchdrive/Private/Documents/Master/2_S2/LPSC/Mandelbrot/lpsc-mandelbrot/sim_iter/";

    -- File declarations (std.textio)
    -- Use python notebook mandelbrot_iters to generate files
    file sti_file : text; -- c_r c_i x y
    file ref_file : text; -- addr data


    -- DUV declaration
    component iterator is
        generic (
            R_SQ          : integer := 4;
            DSP_WIDTH     : integer := 18;
            N_DECIMALS    : integer := 14;
            MAX_ITER      : integer := 100;
            COORD_WIDTH   : integer := 8;
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
    end component;



begin

    duv : iterator
    generic map(
    R_SQ        => R_SQ,
    DSP_WIDTH   => SIZE,
    N_DECIMALS  => FIXEDPOINT,
    MAX_ITER    => MAX_ITER,
    COORD_WIDTH => COORD_WIDTH,
    MEM_WIDTH   => MEM_WIDTH
    )
    port map(
        clk_i     => clk_s,
        rst_i     => reset_s,
        c_real_i  => sti.c_real,
        c_imag_i  => sti.c_imag,
        x_i       => sti.x,
        y_i       => sti.y,
        nextval_o => nextval_s,
        addr_o    => obs.addr,
        data_o    => obs.data,
        we_o      => obs.we
    );


    -- CLK generation process
    clk : process is
    begin
        while not(sim_over_s) loop
            clk_s <= '0', '1' after PERIOD/2;
            wait for PERIOD;
        end loop;
        wait;
    end process;

    -- Stimulus input
    sti_process: process is
        variable txt_line   : Line;
        variable c_real_sti : std_logic_vector(SIZE - 1 downto 0);
        variable c_imag_sti : std_logic_vector(SIZE - 1 downto 0);
        variable x_sti      : std_logic_vector(COORD_WIDTH - 1 downto 0);
        variable y_sti      : std_logic_vector(COORD_WIDTH - 1 downto 0);

    begin
      -- expression doesn't work with only file name
        file_open(sti_file, txt_path & "sti.txt", READ_MODE);
        --file_open(sti_file, "sti.txt", READ_MODE);

        sti.c_real  <= (others => '0');
        sti.c_imag  <= (others => '0');
        sti.x       <= (others => '0');
        sti.y       <= (others => '0');

        -- Reset input for 3 periods
        --wait until rising_edge(clk_s);
        reset_s <= '1';
        wait for 3*PERIOD;
        reset_s <= '0';



        while not endfile(sti_file) loop
            --if nextval_s = '1' then
              -- read txt line into variable
              readline(sti_file, txt_line);

              -- read txt column into variable (space-separated)
              read(txt_line, c_real_sti);
              read(txt_line, c_imag_sti);
              read(txt_line, x_sti);
              read(txt_line, y_sti);

              sti.c_real  <= c_real_sti;
              sti.c_imag  <= c_imag_sti;
              sti.x       <= x_sti;
              sti.y       <= y_sti;

              -- signal new stimulus in
              sti_ok_s <= '1';
              wait for 2 ns;
              sti_ok_s <= '0';
              wait until nextval_s = '0';
              wait until nextval_s = '1';
              --wait until falling_edge(clk_s);
            --end if;


        end loop;

        -- close file
        file_close(sti_file);
        --wait for PERIOD*2;
        --wait for 2 ns;
        --wait until nextval_s = '1';
        wait for PERIOD;
        --wait until nextval_s = '1';
        -- end of simulation
        sim_over_s <= true;

        -- end of procedure
        wait;

    end process; -- stimulus_proc


    -- Reference signal comparison
    ref_process : process is
        variable txt_line : Line;
        variable addr_ref   : std_logic_vector(COORD_WIDTH*2 - 1 downto 0);
        variable data_ref   : std_logic_vector(MEM_WIDTH - 1 downto 0);
        variable we_ref     : std_logic;
    begin
        file_open(ref_file, txt_path & "ref.txt", READ_MODE);
        --file_open(ref_file, "ref.txt", READ_MODE);



        while not endfile(ref_file) loop
            -- read txt line into variable
            readline(ref_file, txt_line);

            -- read txt column into variable (space-separated)
            read(txt_line, addr_ref);
            read(txt_line, data_ref);
            read(txt_line, we_ref);
            -- wait for new stimulus
            wait until sti_ok_s = '1';
            wait for PERIOD;

            -- Assign to reference signals
            ref.addr    <= addr_ref;
            ref.data    <= data_ref;
            ref.we      <= we_ref;
            wait until nextval_s = '1'; -- wait for write enable output
            -- Check observed signal is the same as reference output
            if obs.addr     = ref.addr      and
               obs.data     = ref.data      and
               obs.we       = ref.we then
                err_s <= '0';
                report "OK" severity warning;
            else
                err_s <= '1';
                report "Error" severity error;
                wait for 2 ns;
                err_s <= '0';
            end if;


            --wait until rising_edge(clk_s);
            --wait for 2 ns;

        end loop;
        wait;
    end process;



end tb;
