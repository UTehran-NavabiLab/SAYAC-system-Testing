from lib2to3.pgen2.token import NEWLINE
import os
import shutil


# extract_name ; take the name and prune extra control tokens
#     @input   ; name
def extract_name(name):
    tokens = [',', '(', ')', '{', '}', ';', ':', '+', '-', '=']

    while name[-1] in tokens:
        name = name[:-1]
    return name

# extract_name ; find successive sequence in a string and split it into two part right after last element occures
#     @input   ;  page 
#                 input sequence
def split_page(page, sequence):
    pointer = 0
    for i in range(len(sequence)):
        pointer = page.find(sequence[i], pointer)
        
    return page[:pointer + len(sequence[-1])], page[pointer + len(sequence[-1]):]


# mkdir ; make directory inside current working directory if not existed
#     @input   ;  name of directory (usually end in profix _dir)
#     @output : newly created directory
def mkdir(name, cwd, fresh=True):
    name_dir = os.path.join(cwd, name)
    if not(os.path.isdir(name_dir)):
        os.mkdir(name_dir)
    elif (fresh):
        shutil.rmtree(name_dir)
        os.mkdir(name_dir)
    return name_dir

#find and replace gate names
def lut2gate(temp_page):

    page2line = temp_page.splitlines()

    for indx, line in enumerate(page2line):
    
        if (line.strip().find("DFFRSE") > -1):
            page2line[indx] = line.replace('DFFRSE', 'DFF')

        if (line.strip().find(",") > -1):
            if (line.strip().find("LUT 0x1") > -1):
                page2line[indx] = line.replace('LUT 0x1', 'NOR')
            if (line.strip().find("LUT 0x8") > -1):
                page2line[indx] = line.replace('LUT 0x8', 'AND')
            if (line.strip().find("LUT 0x7") > -1):
                page2line[indx] = line.replace('LUT 0x7', 'NAND')
        else:
            if (line.strip().find("LUT 0x1") > -1):
                page2line[indx] = line.replace('LUT 0x1', 'NOT')
            if (line.strip().find("LUT 0x2") > -1):
                page2line[indx] = line.replace('LUT 0x2', 'BUF')   
            if (line.strip().find("LUT 0xe") > -1):
                page2line[indx] = line.replace('LUT 0xe', 'DFF')   
       
    return "\n".join(page2line)

def restore_name(temp_page):

    page2line = temp_page.splitlines()

    for indx, line in enumerate(page2line):
        # remove "new_"
        # find line which contains "new_"
        if (line.strip().find("new_") > -1):
            # split line considering white spaces
            words = line.split()
            # for each word in line
            for indx_2, word in enumerate(words):
                # if it contains "new_"
                if (word.strip().find("new_") > -1):
                
                    if len(word) > 1:
                        # trim functional tokens at the end
                        name = extract_name(word)
                        # remove last "new_"
                        new_word = name.replace('new_', '')
                        # remove last "_"
                        new_word = new_word[:-1]
                        new_word = word.replace(name, new_word)
                        words[indx_2] = new_word
                        # aggregate spilted line to make new line
            
            new_line = " ".join(words)
            # replace modified line
            page2line[indx] = new_line


    return "\n".join(page2line)


#find and remove . port from DFF
def remove_DFFport(temp_page):

    page2line = temp_page.splitlines()

    for indx, line in enumerate(page2line):
        # find DFF_PP
        if (line.strip().find("DFF_PP") > -1) and (line.strip().find("(") > -1):
            for indx_2, line_2 in enumerate(page2line[indx:]):
                # find ");" that happens after 
                if line_2.strip().find(");") > -1:
                    for indx_3, line_3 in enumerate(page2line[indx: indx + indx_2]):
                        if line_3.strip().find(".C") > -1:
                            page2line[indx + indx_3] = ""
                    break

    # create new page
    return "\n".join(page2line)
