f = open("hex1.lst").readlines()
for line in f:
    comment = line[40:-1]
    if line[8] == " ":
        if comment.strip() == "":
            print()
        else:
            print("# %s" % (comment))
    else:
        code = line[16:40].strip().lower()
        code2 = ""
        for i in range(len(code)//2):
            code2 += code[2*i:2*i+2] + " "
        code2 = code2.strip()
        print("    %-16s # %s" % (code2, comment))
