# Pac-Man
2021 Fall, DCLab final project

---

## 12-18 change log

### DE2_115.sv

connect i_map, w_pacman_x, w_pacman_y, w_ghost1_x, w_ghost1_y, w_mem_select, w_address_map, w_address_char, w_tile_offset, w_char_offset

### Debounce.sv

add to project(to debounce key)

### Map_controller.sv

add to output simple map

TODO:
1. load board from ram

### Mem_controller.sv

add to output rgb to vga interface

TODO:
1. load tile from ram
2. load character from ram

### Test_show_pacman.sv

add to test pacman & ghost position

---

## 12-17 change log

### DE2_115.sv

connect clk_25m, vga, vga_mem_addr_generator

TODO:
1. `i_map, w_pacman_x, w_pacman_y, w_ghost1_x, w_ghost1_y, w_mem_select, w_address_map, w_address_char, w_tile_offset, w_char_offset` are not connect yet
2. memory reader
3. module to judge show character or board
4. module for map

### VGA.sv

remove rgb address, output x, y pixel (0~479, 0~639)

### Vga_Mem_addr_generator.sv

add ghost1, pacman and board

ghost1 > pacman,  board

TODO:
1. ghost2~4
2. **vga display scale**

### Show_char.sv

judge is this pixel is character or not

TODO:
1. character at the edge(pixel need to judge across boundary)

### params.vh

add TILE parameters (BLANK, WALL)

