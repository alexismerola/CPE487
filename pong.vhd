LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY pong IS
    PORT (
        clk_in : IN STD_LOGIC; -- system clock
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA outputs
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
        btnl : IN STD_LOGIC;
        btnr : IN STD_LOGIC;
        btnu : IN STD_LOGIC;
        btnd : IN STD_LOGIC;
        btn0 : IN STD_LOGIC;
        SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of four 7-seg displays
        SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    ); 
END pong;

ARCHITECTURE Behavioral OF pong IS
    SIGNAL pxl_clk : STD_LOGIC := '0'; -- 25 MHz clock to VGA sync module
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    -- SIGNAL boxposx : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(100, 11); -- 9 downto 0
    -- SIGNAL boxposy : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(75, 11);
    SIGNAL count : STD_LOGIC_VECTOR (22 DOWNTO 0);
    SIGNAL display : std_logic_vector (15 DOWNTO 0); -- value to be displayed
    SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0); -- 7-seg multiplexing clock
    COMPONENT bat_n_ball IS
        PORT (
            v_sync : IN STD_LOGIC;
            pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            reset : IN STD_LOGIC; -- initiates serve
            btnl : IN STD_LOGIC;
            btnr : IN STD_LOGIC;
            btnu : IN STD_LOGIC;
            btnd : IN STD_LOGIC;
            red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
        );
    
    END COMPONENT;
    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_in  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_in   : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            red_out   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_out  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            hsync : OUT STD_LOGIC;
            vsync : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT clk_wiz_0 is
        PORT (
            clk_in1  : in std_logic;
            clk_out1 : out std_logic
        );
    END COMPONENT;
    COMPONENT leddec16 IS
        PORT (
            dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT; 
    
BEGIN
--    pos : PROCESS (clk_in) is
--    BEGIN
--        if rising_edge(clk_in) then
--            count <= count + 1;
--            IF (btnl = '1' and count = 0 and boxposx > 100) THEN
--                boxposx <= boxposx - 200;
--            ELSIF (btnr = '1' and count = 0 and boxposx < 700) THEN
--                boxposx <= boxposx + 200;
--            END IF;
--        end if;
--        if rising_edge(clk_in) then
--            count <= count + 1;
--            IF (btnu = '1' and count = 0 and boxposy > 100) THEN
--                boxposy <= boxposy - 150;
--            ELSIF (btnd = '1' and count = 0 and boxposy < 500) THEN
--                boxposy <= boxposy + 150;
--            END IF;
--        end if;
--    END PROCESS;
    led_mpx <= count(19 DOWNTO 17); -- 7-seg multiplexing clock    
    add_bb : bat_n_ball
    PORT MAP(--instantiate bat and ball component
        v_sync => S_vsync, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        reset => btn0,
        btnl => btnl,
        btnr => btnr,
        btnu => btnu,
        btnd => btnd,
        red => S_red, 
        green => S_green, 
        blue => S_blue
    );
    
    vga_driver : vga_sync
    PORT MAP(--instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in => S_red, --& "000", 
        green_in => S_green, --& "000", 
        blue_in => S_blue, --& "000", 
        red_out => VGA_red, 
        green_out => VGA_green, 
        blue_out => VGA_blue, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync => VGA_hsync, 
        vsync => S_vsync
    );
    VGA_vsync <= S_vsync; --connect output vsync
        
    clk_wiz_0_inst : clk_wiz_0
    port map (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );
    led1 : leddec16
    PORT MAP(
      dig => led_mpx, data => display, 
      anode => SEG7_anode, seg => SEG7_seg
    );
END Behavioral;

