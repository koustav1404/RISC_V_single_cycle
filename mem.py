# python script to set all memory to zero


file1 = open('data.hex', 'w')
file2 = open('instr.hex', 'w')
for i in range(1024):
    file1.write("00000000 \n")
    file2.write("00000000 \n")
    

file1.close()
file2.close()
