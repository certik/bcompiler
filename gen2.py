f = open("hex1.lst").readlines()
for line in f:
    if line[8] == " ":
        code2 = ""
    else:
        code = line[16:40].strip().lower()
        code2 = ""
        for i in range(len(code)//2):
            code2 += code[2*i:2*i+2] + " "
        code2 = code2.strip()
    comment = line[40:-1]
    print("%-16s # %s" % (code2, comment))
