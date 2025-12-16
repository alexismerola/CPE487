LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        reset : IN STD_LOGIC; -- initiates serve
        btnl : IN STD_LOGIC;
        btnr : IN STD_LOGIC;
        btnu : IN STD_LOGIC;
        btnd : IN STD_LOGIC;
        red : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        green : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        blue : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    CONSTANT bat_w : INTEGER := 400; -- bat width in pixels
    CONSTANT bat_h : INTEGER := 3; -- bat height in pixels
    CONSTANT vbat_w : INTEGER := 3; -- bat width in pixels
    CONSTANT vbat_h : INTEGER := 300; -- bat height in pixels
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether ball is in play
    SIGNAL move_count : INTEGER := 0;
    
    -- bat vertical position
    CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(450, 11);
    CONSTANT bat1_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
    CONSTANT bat2_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(150, 11);
    -- bat horizontal position
    CONSTANT bat_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    
    -- bat vertical position
    CONSTANT vbat_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(200, 11);
    CONSTANT vbat1_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    CONSTANT vbat2_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(600, 11);
    -- bat horizontal position
    CONSTANT vbat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
    
    CONSTANT sizex  : INTEGER := 95;
    CONSTANT sizey  : INTEGER := 70;
    
    SIGNAL S_red, S_green, S_blue : STD_LOGIC_VECTOR (3 DOWNTO 0);
    
	-- SIGNAL box_on : STD_LOGIC; -- indicates whether ball is over current pixel position	
	type boxes is array(0 to 3, 0 to 3) of std_logic_vector(10 downto 0);
    type boxesOn is array (0 to 3, 0 to 3) of std_logic;
    type boxesValue is array (0 to 3, 0 to 3) of integer;
    shared variable boxes_x: boxes := ((CONV_STD_LOGIC_VECTOR(100, 11),CONV_STD_LOGIC_VECTOR(300, 11),CONV_STD_LOGIC_VECTOR(500, 11),CONV_STD_LOGIC_VECTOR(700, 11)),
        (CONV_STD_LOGIC_VECTOR(100, 11),CONV_STD_LOGIC_VECTOR(300, 11),CONV_STD_LOGIC_VECTOR(500, 11),CONV_STD_LOGIC_VECTOR(700, 11)),
        (CONV_STD_LOGIC_VECTOR(100, 11),CONV_STD_LOGIC_VECTOR(300, 11),CONV_STD_LOGIC_VECTOR(500, 11),CONV_STD_LOGIC_VECTOR(700, 11)),
        (CONV_STD_LOGIC_VECTOR(100, 11),CONV_STD_LOGIC_VECTOR(300, 11),CONV_STD_LOGIC_VECTOR(500, 11),CONV_STD_LOGIC_VECTOR(700, 11))); -- grid x array
    shared variable boxes_y: boxes := ((CONV_STD_LOGIC_VECTOR(75, 11),CONV_STD_LOGIC_VECTOR(75, 11),CONV_STD_LOGIC_VECTOR(75, 11),CONV_STD_LOGIC_VECTOR(75, 11)),
        (CONV_STD_LOGIC_VECTOR(225, 11),CONV_STD_LOGIC_VECTOR(225, 11),CONV_STD_LOGIC_VECTOR(225, 11),CONV_STD_LOGIC_VECTOR(225, 11)),
        (CONV_STD_LOGIC_VECTOR(375, 11),CONV_STD_LOGIC_VECTOR(375, 11),CONV_STD_LOGIC_VECTOR(375, 11),CONV_STD_LOGIC_VECTOR(375, 11)),
        (CONV_STD_LOGIC_VECTOR(525, 11),CONV_STD_LOGIC_VECTOR(525, 11),CONV_STD_LOGIC_VECTOR(525, 11),CONV_STD_LOGIC_VECTOR(525, 11))); -- grid y array
    shared variable bOn : boxesOn := ((others => (others => '0'))); -- initialize all to '0'; -- how the game knows whether/where it can draw a box
    
    shared variable boxvalues : boxesValue := ((2,0,0,0), (0,0,0,0), (0,0,0,0), (0,0,0,0)); -- how the game knows what value each box is
    
    

BEGIN
    -- White background, red grid lines, green boxes
    red <= S_red;  -- Red ON everywhere except boxes (grid + background = red)
    green <= S_green;  -- Green ON everywhere except grid (boxes + background = green)
    blue <= S_blue;  -- Blue ON only on background
    -- process to draw board grid (using bat code)
    batdraw : PROCESS (pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF (((pixel_col >= bat_x - bat_w) OR (bat_x <= bat_w)) AND
         pixel_col <= bat_x + bat_w AND
             pixel_row >= bat_y - bat_h AND
             pixel_row <= bat_y + bat_h) OR
             (((pixel_col >= bat_x - bat_w) OR (bat_x <= bat_w)) AND
             pixel_col <= bat_x + bat_w AND
             pixel_row >= bat1_y - bat_h AND
             pixel_row <= bat1_y + bat_h) or
             (((pixel_col >= bat_x - bat_w) OR (bat_x <= bat_w)) AND
             pixel_col <= bat_x + bat_w AND
             pixel_row >= bat2_y - bat_h AND
             pixel_row <= bat2_y + bat_h) or
             (((pixel_col >= vbat_x - vbat_w) OR (vbat_x <= vbat_w)) AND
             pixel_col <= vbat_x + vbat_w AND
             pixel_row >= vbat_y - vbat_h AND
             pixel_row <= vbat_y + vbat_h) or
             (((pixel_col >= vbat1_x - vbat_w) OR (vbat1_x <= vbat_w)) AND
             pixel_col <= vbat1_x + vbat_w AND
             pixel_row >= vbat_y - vbat_h AND
             pixel_row <= vbat_y + vbat_h) or
             (((pixel_col >= vbat2_x - vbat_w) OR (vbat2_x <= vbat_w)) AND
             pixel_col <= vbat2_x + vbat_w AND
             pixel_row >= vbat_y - vbat_h AND
             pixel_row <= vbat_y + vbat_h) THEN
                bat_on <= '1';
        ELSE
            bat_on <= '0';
        END IF;
    END PROCESS;
    -- process to spawn the first box
    
    color_generator : PROCESS (pixel_row, pixel_col, bat_on) IS
        VARIABLE current_box_value : INTEGER := 0;
        VARIABLE is_box_on         : BOOLEAN := FALSE;
    BEGIN
        -- 1. Initialize variables at start of process
        is_box_on := FALSE;
        current_box_value := 0;
        
        -- 2. Check if the pixel is inside any active box
        check_boxes: FOR i IN 0 TO 3 LOOP
            FOR j IN 0 TO 3 LOOP
                IF (bOn(i,j) = '1') AND
                   (pixel_col >= boxes_x(i,j) - sizex) AND
                   (pixel_col <= boxes_x(i,j) + sizex) AND
                   (pixel_row >= boxes_y(i,j) - sizey) AND
                   (pixel_row <= boxes_y(i,j) + sizey) THEN
                    
                    is_box_on := TRUE;
                    current_box_value := boxvalues(i,j);
                    EXIT check_boxes; -- Exit both loops using label
                END IF;
            END LOOP;
        END LOOP check_boxes;
        
        -- 3. Assign Color Based on Priority (Grid > Boxes > Background)
    
        IF bat_on = '1' THEN
            -- GRID LINES (Red)
            S_red   <= "1111";
            S_green <= "0000";
            S_blue  <= "0000";
            
        ELSIF is_box_on THEN
            -- BOXES - Assign color based on the value
            CASE current_box_value IS
                WHEN 2 => -- Dark Yellow
                    S_red   <= "1111";
                    S_green <= "1111";
                    S_blue  <= "0000";
                WHEN 4 => -- Cyan
                    S_red   <= "0000";
                    S_green <= "1111";
                    S_blue  <= "1111";
                WHEN 8 => -- Purple
                    S_red   <= "1010";
                    S_green <= "0000";
                    S_blue  <= "1010";
                WHEN 16 => -- Light Green
                    S_red   <= "0000";
                    S_green <= "1111";
                    S_blue  <= "0000";
                WHEN 32 => -- Orange
                    S_red   <= "1111";
                    S_green <= "0111";
                    S_blue  <= "0000";
                WHEN 64 => -- Hot Pink
                    S_red   <= "1111";
                    S_green <= "0000";
                    S_blue  <= "0111";
                WHEN 128 => -- Indigo
                    S_red   <= "0111";
                    S_green <= "0000";
                    S_blue  <= "1111";
                WHEN 256 => -- Maroon
                    S_red   <= "0011";
                    S_green <= "0000";
                    S_blue  <= "0000";
                WHEN 512 => -- Magenta
                    S_red   <= "0111";
                    S_green <= "0000";
                    S_blue  <= "0011";
                WHEN 1024 => -- More Purple Purple
                    S_red   <= "0110";
                    S_green <= "0000";
                    S_blue  <= "1001";
                WHEN OTHERS => -- Default (White)
                    S_red   <= "1111";
                    S_green <= "1111";
                    S_blue  <= "1111";
            END CASE;
        
        ELSE
            -- BACKGROUND (Light Gray)
            S_red   <= "0100";
            S_green <= "0100";
            S_blue  <= "0100";
        END IF;
    
    END PROCESS color_generator;
--	boxdraw : PROCESS (pixel_row, pixel_col) IS
--    BEGIN
--        box_on <= '0';  -- default to off
--        FOR i IN 0 TO 3 LOOP
--            FOR j IN 0 TO 3 LOOP
--                IF (pixel_col >= boxes_x(i,j) - sizex) AND
--                   (pixel_col <= boxes_x(i,j) + sizex) AND
--                   (pixel_row >= boxes_y(i,j) - sizey) AND
--                   (pixel_row <= boxes_y(i,j) + sizey) AND 
--                   bOn(i,j) = '1' THEN
--                    box_on <= '1';
--                END IF;
--            END LOOP;
--        END LOOP;
--    END PROCESS;

    mball : PROCESS
        VARIABLE moved : BOOLEAN;
        VARIABLE empty_count : INTEGER;
        VARIABLE merged : boxesOn;
        VARIABLE target_pos : INTEGER;
        VARIABLE can_merge : BOOLEAN;
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        
        IF reset = '1' THEN
            game_on <= '1';
            FOR i IN 0 TO 3 LOOP
                FOR j IN 0 TO 3 LOOP
                    bOn(i,j) := '0';
                    boxvalues(i,j) := 0;
                END LOOP;
            END LOOP;
            bOn(0,0) := '1';
            boxvalues(0,0) := 2;
            move_count <= 0;
            
        ELSIF game_on = '1' THEN
            IF move_count > 0 THEN
                move_count <= move_count - 1;
            END IF;
            
            -- ==================== MOVE LEFT ====================
            IF btnl = '1' AND move_count = 0 THEN
                move_count <= 30;
                moved := FALSE;
                
                FOR i IN 0 TO 3 LOOP
                    FOR j IN 0 TO 3 LOOP
                        merged(i,j) := '0';
                    END LOOP;
                END LOOP;
                
                FOR row IN 0 TO 3 LOOP
                    FOR col IN 1 TO 3 LOOP
                        IF bOn(row, col) = '1' THEN
                            target_pos := col;
                            can_merge := FALSE;
                            
                            scan_left: FOR scan IN col-1 DOWNTO 0 LOOP
                                IF bOn(row, scan) = '0' THEN
                                    target_pos := scan;
                                ELSIF boxvalues(row, scan) = boxvalues(row, col) AND merged(row, scan) = '0' THEN
                                    target_pos := scan;
                                    can_merge := TRUE;
                                    EXIT scan_left;
                                ELSE
                                    target_pos := scan + 1;
                                    EXIT scan_left;
                                END IF;
                            END LOOP scan_left;
                            
                            IF target_pos /= col THEN
                                IF can_merge THEN
                                    boxvalues(row, target_pos) := boxvalues(row, target_pos) * 2;
                                    merged(row, target_pos) := '1';
                                ELSE
                                    bOn(row, target_pos) := '1';
                                    boxvalues(row, target_pos) := boxvalues(row, col);
                                END IF;
                                bOn(row, col) := '0';
                                boxvalues(row, col) := 0;
                                moved := TRUE;
                            END IF;
                        END IF;
                    END LOOP;
                END LOOP;
                
                IF moved THEN
                    empty_count := 0;
                    FOR i IN 0 TO 3 LOOP
                        FOR j IN 0 TO 3 LOOP
                            IF bOn(i,j) = '0' THEN
                                empty_count := empty_count + 1;
                            END IF;
                        END LOOP;
                    END LOOP;
                    
                    IF empty_count > 0 THEN
                        spawn_left: FOR i IN 0 TO 3 LOOP
                            FOR j IN 0 TO 3 LOOP
                                IF bOn(i,j) = '0' THEN
                                    bOn(i,j) := '1';
                                    boxvalues(i,j) := 2;
                                    EXIT spawn_left;
                                END IF;
                            END LOOP;
                        END LOOP spawn_left;
                    END IF;
                END IF;
            END IF;
            
            -- ==================== MOVE RIGHT ====================
            IF btnr = '1' AND move_count = 0 THEN
                move_count <= 30;
                moved := FALSE;
                
                FOR i IN 0 TO 3 LOOP
                    FOR j IN 0 TO 3 LOOP
                        merged(i,j) := '0';
                    END LOOP;
                END LOOP;
                
                FOR row IN 0 TO 3 LOOP
                    FOR col IN 2 DOWNTO 0 LOOP
                        IF bOn(row, col) = '1' THEN
                            target_pos := col;
                            can_merge := FALSE;
                            
                            scan_right: FOR scan IN col+1 TO 3 LOOP
                                IF bOn(row, scan) = '0' THEN
                                    target_pos := scan;
                                ELSIF boxvalues(row, scan) = boxvalues(row, col) AND merged(row, scan) = '0' THEN
                                    target_pos := scan;
                                    can_merge := TRUE;
                                    EXIT scan_right;
                                ELSE
                                    target_pos := scan - 1;
                                    EXIT scan_right;
                                END IF;
                            END LOOP scan_right;
                            
                            IF target_pos /= col THEN
                                IF can_merge THEN
                                    boxvalues(row, target_pos) := boxvalues(row, target_pos) * 2;
                                    merged(row, target_pos) := '1';
                                ELSE
                                    bOn(row, target_pos) := '1';
                                    boxvalues(row, target_pos) := boxvalues(row, col);
                                END IF;
                                bOn(row, col) := '0';
                                boxvalues(row, col) := 0;
                                moved := TRUE;
                            END IF;
                        END IF;
                    END LOOP;
                END LOOP;
                
                IF moved THEN
                    empty_count := 0;
                    FOR i IN 0 TO 3 LOOP
                        FOR j IN 0 TO 3 LOOP
                            IF bOn(i,j) = '0' THEN
                                empty_count := empty_count + 1;
                            END IF;
                        END LOOP;
                    END LOOP;
                    
                    IF empty_count > 0 THEN
                        spawn_right: FOR i IN 0 TO 3 LOOP
                            FOR j IN 0 TO 3 LOOP
                                IF bOn(i,j) = '0' THEN
                                    bOn(i,j) := '1';
                                    boxvalues(i,j) := 2;
                                    EXIT spawn_right;
                                END IF;
                            END LOOP;
                        END LOOP spawn_right;
                    END IF;
                END IF;
            END IF;
            
            -- ==================== MOVE UP ====================
            IF btnu = '1' AND move_count = 0 THEN
                move_count <= 30;
                moved := FALSE;
                
                FOR i IN 0 TO 3 LOOP
                    FOR j IN 0 TO 3 LOOP
                        merged(i,j) := '0';
                    END LOOP;
                END LOOP;
                
                FOR col IN 0 TO 3 LOOP
                    FOR row IN 1 TO 3 LOOP
                        IF bOn(row, col) = '1' THEN
                            target_pos := row;
                            can_merge := FALSE;
                            
                            scan_up: FOR scan IN row-1 DOWNTO 0 LOOP
                                IF bOn(scan, col) = '0' THEN
                                    target_pos := scan;
                                ELSIF boxvalues(scan, col) = boxvalues(row, col) AND merged(scan, col) = '0' THEN
                                    target_pos := scan;
                                    can_merge := TRUE;
                                    EXIT scan_up;
                                ELSE
                                    target_pos := scan + 1;
                                    EXIT scan_up;
                                END IF;
                            END LOOP scan_up;
                            
                            IF target_pos /= row THEN
                                IF can_merge THEN
                                    boxvalues(target_pos, col) := boxvalues(target_pos, col) * 2;
                                    merged(target_pos, col) := '1';
                                ELSE
                                    bOn(target_pos, col) := '1';
                                    boxvalues(target_pos, col) := boxvalues(row, col);
                                END IF;
                                bOn(row, col) := '0';
                                boxvalues(row, col) := 0;
                                moved := TRUE;
                            END IF;
                        END IF;
                    END LOOP;
                END LOOP;
                
                IF moved THEN
                    empty_count := 0;
                    FOR i IN 0 TO 3 LOOP
                        FOR j IN 0 TO 3 LOOP
                            IF bOn(i,j) = '0' THEN
                                empty_count := empty_count + 1;
                            END IF;
                        END LOOP;
                    END LOOP;
                    
                    IF empty_count > 0 THEN
                        spawn_up: FOR i IN 0 TO 3 LOOP
                            FOR j IN 0 TO 3 LOOP
                                IF bOn(i,j) = '0' THEN
                                    bOn(i,j) := '1';
                                    boxvalues(i,j) := 2;
                                    EXIT spawn_up;
                                END IF;
                            END LOOP;
                        END LOOP spawn_up;
                    END IF;
                END IF;
            END IF;
            
            -- ==================== MOVE DOWN ====================
            IF btnd = '1' AND move_count = 0 THEN
                move_count <= 30;
                moved := FALSE;
                
                FOR i IN 0 TO 3 LOOP
                    FOR j IN 0 TO 3 LOOP
                        merged(i,j) := '0';
                    END LOOP;
                END LOOP;
                
                FOR col IN 0 TO 3 LOOP
                    FOR row IN 2 DOWNTO 0 LOOP
                        IF bOn(row, col) = '1' THEN
                            target_pos := row;
                            can_merge := FALSE;
                            
                            scan_down: FOR scan IN row+1 TO 3 LOOP
                                IF bOn(scan, col) = '0' THEN
                                    target_pos := scan;
                                ELSIF boxvalues(scan, col) = boxvalues(row, col) AND merged(scan, col) = '0' THEN
                                    target_pos := scan;
                                    can_merge := TRUE;
                                    EXIT scan_down;
                                ELSE
                                    target_pos := scan - 1;
                                    EXIT scan_down;
                                END IF;
                            END LOOP scan_down;
                            
                            IF target_pos /= row THEN
                                IF can_merge THEN
                                    boxvalues(target_pos, col) := boxvalues(target_pos, col) * 2;
                                    merged(target_pos, col) := '1';
                                ELSE
                                    bOn(target_pos, col) := '1';
                                    boxvalues(target_pos, col) := boxvalues(row, col);
                                END IF;
                                bOn(row, col) := '0';
                                boxvalues(row, col) := 0;
                                moved := TRUE;
                            END IF;
                        END IF;
                    END LOOP;
                END LOOP;
                
                IF moved THEN
                    empty_count := 0;
                    FOR i IN 0 TO 3 LOOP
                        FOR j IN 0 TO 3 LOOP
                            IF bOn(i,j) = '0' THEN
                                empty_count := empty_count + 1;
                            END IF;
                        END LOOP;
                    END LOOP;
                    
                    IF empty_count > 0 THEN
                        spawn_down: FOR i IN 0 TO 3 LOOP
                            FOR j IN 0 TO 3 LOOP
                                IF bOn(i,j) = '0' THEN
                                    bOn(i,j) := '1';
                                    boxvalues(i,j) := 2;
                                    EXIT spawn_down;
                                END IF;
                            END LOOP;
                        END LOOP spawn_down;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;

