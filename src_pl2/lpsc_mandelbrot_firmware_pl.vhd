----------------------------------------------------------------------------------
--                                 _             _
--                                | |_  ___ _ (_) _
--                                | ' \/ -_) '_ \ / _` |
--                                |_||_\___| ./_\,_|
--                                         |_|
--
----------------------------------------------------------------------------------
--
-- Company: hepia
-- Author: Joachim Schmidt <joachim.schmidt@hesge.ch
--
-- Module Name: lpsc_mandelbrot_firmware - arch
-- Target Device: digilentinc.com:nexys_video:part0:1.1 xc7a200tsbg484-1
-- Tool version: 2021.2
-- Description: lpsc_mandelbrot_firmware
--
-- Last update: 2022-04-12
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library lpsc_lib;
use lpsc_lib.lpsc_hdmi_interface_pkg.all;

library xil_defaultlib;
use xil_defaultlib.iter_pl_pkg.all;

entity lpsc_mandelbrot_firmware_pl is

    generic (
        C_CHANNEL_NUMBER : integer := 4;
        C_HDMI_LATENCY   : integer := 0;
        C_GPIO_SIZE      : integer := 8;
        C_AXI4_DATA_SIZE : integer := 32;
        C_AXI4_ADDR_SIZE : integer := 12);

    port (
        -- Clock and Reset Active Low
        ClkSys100MhzxCI : in    std_logic;
        ResetxRNI       : in    std_logic;
        -- Leds
        LedxDO          : out   std_logic_vector((C_GPIO_SIZE - 1) downto 0);
        -- Buttons
        -- BtnCxSI         : in    std_logic;
        -- HDMI
        HdmiTxRsclxSO   : out   std_logic;
        HdmiTxRsdaxSIO  : inout std_logic;
        HdmiTxHpdxSI    : in    std_logic;
        HdmiTxCecxSIO   : inout std_logic;
        HdmiTxClkPxSO   : out   std_logic;
        HdmiTxClkNxSO   : out   std_logic;
        HdmiTxPxDO      : out   std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0);
        HdmiTxNxDO      : out   std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0));

end lpsc_mandelbrot_firmware_pl;

architecture arch of lpsc_mandelbrot_firmware_pl is

    -- Constants

    ---------------------------------------------------------------------------
    -- Resolution configuration
    ---------------------------------------------------------------------------
    -- Possible resolutions
    --
    -- 1024x768
    -- 1024x600
    -- 800x600
    -- 640x480

    -- constant C_VGA_CONFIG : t_VgaConfig := C_1024x768_VGACONFIG;
    constant C_VGA_CONFIG : t_VgaConfig := C_1024x600_VGACONFIG;
    -- constant C_VGA_CONFIG : t_VgaConfig := C_800x600_VGACONFIG;
    -- constant C_VGA_CONFIG : t_VgaConfig := C_640x480_VGACONFIG;

    -- constant C_RESOLUTION : string := "1024x768";
    -- constant C_RESOLUTION : string := "1024x600";
    constant C_RESOLUTION : string := "1024x600";
    -- constant C_RESOLUTION : string := "640x480";

    constant C_DATA_SIZE                        : integer               := 16;
    constant C_PIXEL_SIZE                       : integer               := 8;
    constant C_BRAM_VIDEO_MEMORY_ADDR_SIZE      : integer               := 20;
    constant C_BRAM_VIDEO_MEMORY_HIGH_ADDR_SIZE : integer               := 10;
    constant C_BRAM_VIDEO_MEMORY_LOW_ADDR_SIZE  : integer               := 10;
    constant C_BRAM_VIDEO_MEMORY_DATA_SIZE      : integer               := 9;
    constant C_CDC_TYPE                         : integer range 0 to 2  := 1;
    constant C_RESET_STATE                      : integer range 0 to 1  := 0;
    constant C_SINGLE_BIT                       : integer range 0 to 1  := 1;
    constant C_FLOP_INPUT                       : integer range 0 to 1  := 1;
    constant C_VECTOR_WIDTH                     : integer range 0 to 32 := 2;
    constant C_MTBF_STAGES                      : integer range 0 to 6  := 5;
    constant C_ALMOST_FULL_LEVEL                : integer               := 948;
    constant C_ALMOST_EMPTY_LEVEL               : integer               := 76;
    constant C_FIFO_DATA_SIZE                   : integer               := 32;
    constant C_FIFO_PARITY_SIZE                 : integer               := 4;
    constant C_OUTPUT_BUFFER                    : boolean               := false;


    -- Components

    component hdmi is
        generic (
            C_CHANNEL_NUMBER : integer;
            C_DATA_SIZE      : integer;
            C_PIXEL_SIZE     : integer;
            C_HDMI_LATENCY   : integer;
            C_VGA_CONFIG     : t_VgaConfig;
            C_RESOLUTION     : string);
        port (
            ClkSys100MhzxCI : in    std_logic;
            RstxRI          : in    std_logic;
            PllLockedxSO    : out   std_logic;
            ClkVgaxCO       : out   std_logic;
            HCountxDO       : out   std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VCountxDO       : out   std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VidOnxSO        : out   std_logic;
            DataxDI         : in    std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
            HdmiTxRsclxSO   : out   std_logic;
            HdmiTxRsdaxSIO  : inout std_logic;
            HdmiTxHpdxSI    : in    std_logic;
            HdmiTxCecxSIO   : inout std_logic;
            HdmiTxClkPxSO   : out   std_logic;
            HdmiTxClkNxSO   : out   std_logic;
            HdmiTxPxDO      : out   std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0);
            HdmiTxNxDO      : out   std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0));
    end component hdmi;

    component clk_mandelbrot
        port(
            ClkMandelxCO    : out std_logic;
            reset           : in  std_logic;
            PllLockedxSO    : out std_logic;
            ClkSys100MhzxCI : in  std_logic);
    end component;

    component image_generator is
        generic (
            C_DATA_SIZE  : integer;
            C_PIXEL_SIZE : integer;
            C_VGA_CONFIG : t_VgaConfig);
        port (
            ClkVgaxCI    : in  std_logic;
            RstxRAI      : in  std_logic;
            PllLockedxSI : in  std_logic;
            HCountxDI    : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VCountxDI    : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VidOnxSI     : in  std_logic;
            DataxDO      : out std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
            Color1xDI    : in  std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0));
    end component image_generator;

    component bram_video_memory_wauto_dauto_rdclk1_wrclk1
         port (
             clka  : in  std_logic;
             wea   : in  std_logic_vector(0 downto 0);
             addra : in  std_logic_vector(19 downto 0);
             dina  : in  std_logic_vector(8 downto 0);
             douta : out std_logic_vector(8 downto 0);
             clkb  : in  std_logic;
             web   : in  std_logic_vector(0 downto 0);
             addrb : in  std_logic_vector(19 downto 0);
             dinb  : in  std_logic_vector(8 downto 0);
             doutb : out std_logic_vector(8 downto 0));
     end component;

     -- C generator

     component ComplexValueGenerator is
         generic
             (SIZE       : integer := 16;  -- Taille en bits de nombre au format virgule fixe
              X_SIZE     : integer := 1024;  -- Taille en X (Nombre de pixel) de la fractale à afficher
              Y_SIZE     : integer := 600;  -- Taille en Y (Nombre de pixel) de la fractale à afficher
              SCREEN_RES : integer := 10);  -- Nombre de bit pour les vecteurs X et Y de la position du pixel

         port
             (clk           : in  std_logic;
              reset         : in  std_logic;
              -- interface avec le module MandelbrotMiddleware
              next_value    : in  std_logic;
              c_inc_RE      : in  std_logic_vector((SIZE - 1) downto 0);
              c_inc_IM      : in  std_logic_vector((SIZE - 1) downto 0);
              c_top_left_RE : in  std_logic_vector((SIZE - 1) downto 0);
              c_top_left_IM : in  std_logic_vector((SIZE - 1) downto 0);
              c_real        : out std_logic_vector((SIZE - 1) downto 0);
              c_imaginary   : out std_logic_vector((SIZE - 1) downto 0);
              X_screen      : out std_logic_vector((SCREEN_RES - 1) downto 0);
              Y_screen      : out std_logic_vector((SCREEN_RES - 1) downto 0));
     end component;

     -- Homemade pipelined iterator
     component zc_adder_pl is
         generic (
           DSP_WIDTH   : integer := DSP_WIDTH;
           N_DECIMALS  : integer := N_DECIMALS;
           R_SQ        : integer := R_SQ;
           MAX_ITER    : integer := MAX_ITER;
           COORD_WIDTH : integer := COORD_WIDTH;
           MEM_WIDTH   : integer := MEM_WIDTH
         );
         port (
             clk_i : in  std_logic;
             rst_i : in  std_logic;

             coords_i  : in  coords_t;
             coords_o  : out coords_t;
             mem_o     : out mem_t
         );
     end component;


     --COMPONENT ila_0

     --PORT (
     --	clk : IN STD_LOGIC;



     --	probe0 : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
     --	probe1 : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
     --	probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
     --	probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
     --	probe4 : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
     --	probe5 : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
     --	probe6 : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
     --	probe7 : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
     --	probe8 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
     --	probe9 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
     --	probe10 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
     --);
     --END COMPONENT;

    -- Signals

    -- Clocks
    signal ClkVgaxC             : std_logic                                         := '0';
    signal ClkMandelxC          : std_logic;
    signal UBlazeUserClkxC      : std_logic                                         := '0';
    -- Reset
    signal ResetxR              : std_logic                                         := '0';
    -- Pll Locked
    signal PllLockedxS          : std_logic                                         := '0';
    signal PllLockedxD          : std_logic_vector(0 downto 0)                      := (others => '0');
    signal PllNotLockedxS       : std_logic                                         := '0';
    signal HdmiPllLockedxS      : std_logic                                         := '0';
    signal HdmiPllNotLockedxS   : std_logic                                         := '0';
    signal UBlazePllLockedxS    : std_logic                                         := '0';
    signal UBlazePllNotLockedxS : std_logic                                         := '0';
    -- VGA
    signal HCountxD             : std_logic_vector((C_DATA_SIZE - 1) downto 0);
    signal VCountxD             : std_logic_vector((C_DATA_SIZE - 1) downto 0);
    signal VidOnxS              : std_logic;
    -- Others
    signal DataImGen2HDMIxD     : std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
    signal DataImGen2BramMVxD         : std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
    signal DataBramMV2HdmixD          : std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
    signal HdmiSourcexD         : t_HdmiSource                                      := C_NO_HDMI_SOURCE;
    signal BramVideoMemoryWriteAddrxD : std_logic_vector((C_BRAM_VIDEO_MEMORY_ADDR_SIZE - 1) downto 0) := (others => '0');
    signal BramVideoMemoryReadAddrxD  : std_logic_vector((C_BRAM_VIDEO_MEMORY_ADDR_SIZE - 1) downto 0);
    signal BramVideoMemoryWriteDataxD : std_logic_vector((C_BRAM_VIDEO_MEMORY_DATA_SIZE - 1) downto 0);
    signal BramVideoMemoryReadDataxD  : std_logic_vector((C_BRAM_VIDEO_MEMORY_DATA_SIZE - 1) downto 0);
    -- AXI4 Lite To Register Bank Signals
    signal WrDataxD             : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal WrAddrxD             : std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0) := (others => '0');
    signal WrValidxS            : std_logic                                         := '0';
    signal RdDataxD             : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal RdAddrxD             : std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0) := (others => '0');
    signal RdValidxS            : std_logic                                         := '0';
    signal WrValidDelayedxS     : std_logic                                         := '0';
    signal RdValidFlagColor1xS  : std_logic                                         := '0';
    signal RdEmptyFlagColor1xS  : std_logic                                         := '0';
    signal RdDataFlagColor1xDP  : std_logic_vector((C_FIFO_DATA_SIZE - 1) downto 0) := x"003a8923";
    signal RdDataFlagColor1xDN  : std_logic_vector((C_FIFO_DATA_SIZE - 1) downto 0) := x"003a8923";

    -- BRAM
    signal bram_wea_s : std_logic_vector(0 downto 0);

-- Attributes
    -- attribute mark_debug                              : string;
    -- attribute mark_debug of DebugFlagColor1RegPortxDP : signal is "true";
    -- --
    -- attribute keep                                    : string;
    -- attribute keep of DebugFlagColor1RegPortxDP       : signal is "true";

    begin

    -- Asynchronous statements

    DebugxB : block is

        -- Debug signals
        -- signal DebugVectExamplexD : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');

        -- Attributes
        -- attribute mark_debug                       : string;
        -- attribute mark_debug of DebugVectExamplexD : signal is "true";
        -- --
        -- attribute keep                             : string;
        -- attribute keep of DebugVectExamplexD       : signal is "true";

    begin  -- block DebugxB

    end block DebugxB;

    IOPinoutxB : block is
    begin  -- block IOPinoutxB

        ResetxAS      : ResetxR                                 <= not ResetxRNI;
        HdmiTxRsclxAS : HdmiTxRsclxSO                           <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxRsclxS;
        HdmiTxRsdaxAS : HdmiTxRsdaxSIO                          <= HdmiSourcexD.HdmiSourceInOutxS.HdmiTxRsdaxS;
        HdmiTxHpdxAS  : HdmiSourcexD.HdmiSourceInxS.HdmiTxHpdxS <= HdmiTxHpdxSI;
        HdmiTxCecxAS  : HdmiTxCecxSIO                           <= HdmiSourcexD.HdmiSourceInOutxS.HdmiTxCecxS;
        HdmiTxClkPxAS : HdmiTxClkPxSO                           <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkPxS;
        HdmiTxClkNxAS : HdmiTxClkNxSO                           <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkNxS;
        HdmiTxPxAS    : HdmiTxPxDO                              <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxPxD;
        HdmiTxNxAS    : HdmiTxNxDO                              <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxNxD;

    end block IOPinoutxB;

    -- VGA HDMI Clock Domain
    ---------------------------------------------------------------------------

    VgaHdmiCDxB : block is
    begin  -- block VgaHdmiCDxB

        DataBramMV2HdmixAS : DataBramMV2HdmixD <= BramVideoMemoryReadDataxD(8 downto 6) & "00000" &
                                                   BramVideoMemoryReadDataxD(5 downto 3) & "00000" &
                                                   BramVideoMemoryReadDataxD(2 downto 0) & "00000";

        BramVMRdAddrxAS : BramVideoMemoryReadAddrxD <= VCountxD((C_BRAM_VIDEO_MEMORY_HIGH_ADDR_SIZE - 1) downto 0) &
                                                        HCountxD((C_BRAM_VIDEO_MEMORY_LOW_ADDR_SIZE - 1) downto 0);

        HdmiPllNotLockedxAS : HdmiPllNotLockedxS <= not HdmiPllLockedxS;


        LpscHdmixI : entity work.lpsc_hdmi
            generic map (
                C_CHANNEL_NUMBER => C_CHANNEL_NUMBER,
                C_DATA_SIZE      => C_DATA_SIZE,
                C_PIXEL_SIZE     => C_PIXEL_SIZE,
                C_HDMI_LATENCY   => C_HDMI_LATENCY,
                C_VGA_CONFIG     => C_VGA_CONFIG,
                C_RESOLUTION     => C_RESOLUTION)
            port map (
                ClkSys100MhzxCI => ClkSys100MhzxCI,
                RstxRI          => ResetxR,
                PllLockedxSO    => HdmiPllLockedxS,
                ClkVgaxCO       => ClkVgaxC,
                HCountxDO       => HCountxD,
                VCountxDO       => VCountxD,
                VidOnxSO        => open,--VidOnxS,
                DataxDI         => DataBramMV2HdmixD,--DataImGen2HDMIxD,
                HdmiTXRsclxSO   => HdmiSourcexD.HdmiSourceOutxD.HdmiTxRsclxS,
                HdmiTXRsdaxSIO  => HdmiSourcexD.HdmiSourceInOutxS.HdmiTxRsdaxS,
                HdmiTXHpdxSI    => HdmiSourcexD.HdmiSourceInxS.HdmiTxHpdxS,
                HdmiTXCecxSIO   => HdmiSourcexD.HdmiSourceInOutxS.HdmiTxCecxS,
                HdmiTXClkPxSO   => HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkPxS,
                HdmiTXClkNxSO   => HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkNxS,
                HdmiTXPxDO      => HdmiSourcexD.HdmiSourceOutxD.HdmiTxPxD,
                HdmiTXNxDO      => HdmiSourcexD.HdmiSourceOutxD.HdmiTxNxD);

    end block VgaHdmiCDxB;

    -- VGA HDMI To FPGA User Clock Domain Crossing
    ---------------------------------------------------------------------------

    VgaHdmiToFpgaUserCDCxB : block is
    begin  -- block VgaHdmiToFpgaUserCDCxB

         BramVideoMemoryxI : bram_video_memory_wauto_dauto_rdclk1_wrclk1
             port map (
                 -- Port A (Write) -> user clock domain
                 clka  => ClkMandelxC,
                 wea   => bram_wea_s,--PllLockedxD, -- -> signal & pll locked
                 addra => BramVideoMemoryWriteAddrxD,
                 dina  => BramVideoMemoryWriteDataxD,
                 douta => open,
                 -- Port B (Read)
                 clkb  => ClkVgaxC,
                 web   => (others => '0'),
                 addrb => BramVideoMemoryReadAddrxD,
                 dinb  => (others => '0'),
                 doutb => BramVideoMemoryReadDataxD);

    end block VgaHdmiToFpgaUserCDCxB;

    -- FPGA User Clock Domain
    ---------------------------------------------------------------------------

    FpgaUserCDxB : block is

        -- User constants
        constant DSP_WIDTH      : integer := 18;
        constant C_SCREEN_RES   : integer := 10;
        constant MEM_WIDTH      : integer := C_BRAM_VIDEO_MEMORY_DATA_SIZE;
        constant MAX_ITER       : integer := 100;
        constant N_DECIMALS     : integer := 14;

        constant C_TOP_LEFT_IM  : std_logic_vector(DSP_WIDTH-1 downto 0) :=
        "000100000000000000";
        --(DSP_WIDTH-1 downto DSP_WIDTH-3=>"111", others=>'0');
        constant C_TOP_LEFT_RE  : std_logic_vector(DSP_WIDTH-1 downto 0) :=
        "111000000000000000";
        --(DSP_WIDTH-4=>'1', others=>'0');
        constant C_INC_RE       : std_logic_vector(DSP_WIDTH-1 downto 0) := "000000000000110000";
        constant C_INC_IM       : std_logic_vector(DSP_WIDTH-1 downto 0) := "000000000000110111"; -- from resume_arch_mandel.pdf

        -- User signals
        signal c_real_s  : std_logic_vector((DSP_WIDTH - 1) downto 0);
        signal c_imag_s  : std_logic_vector((DSP_WIDTH - 1) downto 0);
        signal xcoord_s  : std_logic_vector((C_SCREEN_RES - 1) downto 0);
        signal ycoord_s  : std_logic_vector((C_SCREEN_RES - 1) downto 0);
        signal data_s    : std_logic_vector(MEM_WIDTH-1 downto 0);
        signal mem_s     : mem_t;
        signal coords_i_s: coords_t;


        signal ClkSys100MhzBufgxC : std_logic                                    := '0';
        signal HCountIntxD        : std_logic_vector((C_DATA_SIZE - 1) downto 0) := std_logic_vector(C_VGA_CONFIG.HActivexD - 1);
        signal VCountIntxD        : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');


    begin  -- block FpgaUserCDxB

        PllNotLockedxAS : PllNotLockedxS <= not PllLockedxS;
        PllLockedxAS    : PllLockedxD(0) <= PllLockedxS;

        --BramVideoMemoryWriteDataxAS : BramVideoMemoryWriteDataxD <= DataImGen2BramMVxD(23 downto 21) &
        --                                                            DataImGen2BramMVxD(15 downto 13) &
        --                                                            DataImGen2BramMVxD(7 downto 5);

        --BramVMWrAddrxAS : BramVideoMemoryWriteAddrxD <= VCountIntxD((C_BRAM_VIDEO_MEMORY_HIGH_ADDR_SIZE - 1) downto 0) &
        --                                                HCountIntxD((C_BRAM_VIDEO_MEMORY_LOW_ADDR_SIZE - 1) downto 0);

        BUFGClkSysToClkMandelxI : BUFG
            port map (
                O => ClkSys100MhzBufgxC,
                I => ClkSys100MhzxCI);

        ClkMandelbrotxI : clk_mandelbrot
             port map (
                 ClkMandelxCO    => ClkMandelxC,
                 reset           => ResetxR,
                 PllLockedxSO    => PllLockedxS,
                 ClkSys100MhzxCI => ClkSys100MhzBufgxC);

         -- Complex value generator
         compgen : ComplexValueGenerator
         generic map(
             SIZE       => DSP_WIDTH,
             X_SIZE     => 1024,
             Y_SIZE     => 600,
             SCREEN_RES => C_SCREEN_RES
             )
         port map(
             clk            => ClkMandelxC,
             reset          => ResetxR,
             next_value     => mem_s.we,
             c_inc_RE       => C_INC_RE,
             c_inc_IM       => C_INC_IM,
             c_top_left_RE  => C_TOP_LEFT_RE,
             c_top_left_IM  => C_TOP_LEFT_IM,
             c_real         => c_real_s,
             c_imaginary    => c_imag_s,
             X_screen       => xcoord_s,
             Y_screen       => ycoord_s
             );

        coords_i_s.c_real <= signed(c_real_s);
        coords_i_s.c_imag <= signed(c_imag_s);
        coords_i_s.x <= xcoord_s;
        coords_i_s.y <= ycoord_s;
        coords_i_s.index <= '0';

        -- Supposing RGB 3-3-3
        -- unsigned to RGB B/W
        --BramVideoMemoryWriteDataxD <= data_s(2 downto 0) & data_s(2 downto 0) & data_s(2 downto 0);
        BramVideoMemoryWriteDataxD <= mem_s.data;
        bram_wea_s(0) <= mem_s.we and PllLockedxD(0);
        BramVideoMemoryWriteAddrxD <= mem_s.addr;

        pl : zc_adder_pl
        generic map(
            DSP_WIDTH   => DSP_WIDTH,
            N_DECIMALS  => N_DECIMALS,
            R_SQ        => R_SQ,
            MAX_ITER    => MAX_ITER,
            COORD_WIDTH => COORD_WIDTH,
            MEM_WIDTH   => MEM_WIDTH
        )
        port map(
            clk_i     => ClkMandelxC,
            rst_i     => ResetxR,
            coords_i  => coords_i_s,
            --coords_o  => ,
            mem_o     => mem_s
        );




         --ila_iter : ila_0
         --PORT MAP (
          --clk => ClkSys100MhzxCI,--ClkMandelxC,



        --  probe0 => BramVideoMemoryWriteAddrxD, -- iter:addr_o
        --  probe1 => BramVideoMemoryWriteDataxD, -- iter:data_o
        --  probe2(0) => mem_s.we, -- iter:nextval
        --  probe3(0) => mem_s.we, -- free
        --  probe4 => xcoord_s, -- iter:xscreen
        --  probe5 => ycoord_s, -- iter:yscreen
        --  probe6 => c_real_s, -- iter:c_real_i
        --  probe7 => c_imag_s,  -- iter:c_imag_i
        --  probe8(0) => mem_s.we, -- free
        --  probe9(0) => mem_s.we, -- free
        --  probe10(0) => mem_s.we -- free
         --);
    end block FpgaUserCDxB;






end arch;
