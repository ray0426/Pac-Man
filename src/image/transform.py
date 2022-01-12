import os
from PIL import Image
import numpy as np

colors_map = { 0: (  0,   0,   0), # black
               1: (  0,   0, 255), # blue
               2: (255, 255, 255), # white
               3: (255, 255,   0), # yellow, for pacman
               4: (255,   0,   0), # red, for ghost
               5: (255, 204, 255), # pink, for ghost
               6: ( 79, 255, 255), # light blue, for ghost
               7: (255, 204,   0), # orange, for ghost
               }

colors_mapT = { '0, 0, 0'       : 0, # black
                '0, 0, 255'     : 1, # blue
                '255, 255, 255' : 2, # white
                '255, 255, 0'   : 1,   # yellow, for pacman
                '255, 0, 0'     : 4, # red, for ghost
                '255, 204, 255' : 5, # pink, for ghost
                '79, 255, 255'  : 6, # light blue, for ghost
                '255, 204, 0'   : 7, # orange, for ghost
                }

colors_mapT_pacman = {  '0, 0, 0'       : 0, # black
                        '255, 255, 0'   : 1,   # yellow, for pacman
                        }

colors_mapT_ghost = { '0, 0, 0'       : 0, # black
                      '0, 0, 255'     : 1, # blue
                      '255, 255, 255' : 2, # white
                      '255, 0, 0'     : 3, # red, for ghost
                      }

if __name__ == "__main__":
    tilesize = 16
    width = 2
    # image_amount = 16
    img_path = './src/image/ghost'
    output_mif = './src/image/ghost.mif'
    colors = colors_mapT_ghost
    filenames = os.listdir(img_path)
    print('file length: ', len(filenames))

    with open(os.path.join(output_mif), 'w', newline='') as out_file:

        out_file.write('WIDTH=' + str(width) + ';\n')
        out_file.write('DEPTH=' + str(len(filenames) * tilesize * tilesize) + ';\n')

        out_file.write('ADDRESS_RADIX=UNS;\n')
        out_file.write('DATA_RADIX=UNS;\n\n')
        out_file.write('CONTENT BEGIN\n')

        memory_i = 0
        for fn in filenames:
            img = np.array(Image.open(os.path.join(img_path, fn)))
            img = img[:, :, :3]

            out_file.write("    {:<5d}: ".format(memory_i))
            for i in range(tilesize):
                for j in range(tilesize):
                    out_file.write("{:>3}".format(
                        colors[str(img[i][j][0]) + ', ' + str(img[i][j][1]) + ', ' + str(img[i][j][2])]
                        ))
                    # colors.add(colors_mapT[str(img[i][j][0]) + ', ' + str(img[i][j][1]) + ', ' + str(img[i][j][2])])
            out_file.write(';\n')
            memory_i += tilesize * tilesize
        
        out_file.write('END;\n')
    

    