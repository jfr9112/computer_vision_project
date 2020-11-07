path_input = "C:\\Users\\jonat\\Documents\\rit\\2020_2021_fall\\introduction_to_computer_vision\\project\\project_git\\words_2171_sorted.txt"
path_output = "C:\\Users\\jonat\\Documents\\rit\\2020_2021_fall\\introduction_to_computer_vision\\project\\project_git\\roth_words.txt"
file_input = open(path_input, "r")
file_output = open(path_output, "w")
count=1
while(True):
    word = file_input.readline().strip().upper()
    count = count + 1
    if(word == "ZYGOTES"):
        break
    if len(word) in [5,6]:
        file_output.write(word+"\n")



    #print(i, word, end="\n")
