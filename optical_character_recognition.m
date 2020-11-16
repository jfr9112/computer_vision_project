function optical_character_recognition(image_gray)

    

    %path = 'C:\Users\jonat\Documents\rit\2020_2021_fall\introduction_to_computer_vision\Project\project_git\puzzle_small_0107.jpg';
    %image_gray = im2double(imread(path));
    image_binary = image_gray < 0.65;

    
    [H,T,R] = hough(image_binary);
    P  = houghpeaks(H,100);
    lines = houghlines(image_binary,T,R,P,'FillGap',5,'MinLength',50);
   
    %   count number of horizontal lines
    count = 0;
    for k=1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        if(xy(1,1)==xy(2,1))
            continue;
        end
        count = count + 1;
    end
    %a=xy(1,1);%x1
    %b=xy(1,2);%y1
    %c=xy(2,1);%x2
    %d=xy(2,2);%y2
    

    %   will contain all relevant coordinates
    coordinates = zeros((count/3),7,4,2);
    
    %   obtain horizontal lines
    horizontal_lines = zeros(count,3);
    count=0;
    for k=1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        if(xy(1,1)==xy(2,1))
            continue;
        end
        count = count + 1;
        horizontal_lines(count,1)=xy(1,1);
        horizontal_lines(count,2)=xy(2,1);
        horizontal_lines(count,3)=xy(1,2);
    end
    
    %   obtain sorted horizontal lines
    sorted_heights = sort(horizontal_lines(:,3));
    sorted_horizontal_lines = zeros(count,3);
    for i=1:size(sorted_horizontal_lines)
        for j=1:size(sorted_horizontal_lines)
            if horizontal_lines(i,3)== sorted_heights(j)
                sorted_horizontal_lines(j,1) = horizontal_lines(i,1);
                sorted_horizontal_lines(j,2) = horizontal_lines(i,2);
                sorted_horizontal_lines(j,3) = horizontal_lines(i,3);
            end
        end
    end
    

    %   obtain all relevant coordinates 
    for i=1:size(coordinates)
        index = ((i-1)*3)+1;
        
        %   rectangle 1
        coordinates(i, 1, 1, 1)=sorted_horizontal_lines(index, 1);
        coordinates(i, 1, 1, 2)=sorted_horizontal_lines(index, 3);
        coordinates(i, 1, 2, 1)=sorted_horizontal_lines(index, 2);
        coordinates(i, 1, 2, 2)=sorted_horizontal_lines(index, 3);
        coordinates(i, 1, 3, 1)=sorted_horizontal_lines(index, 1);
        coordinates(i, 1, 3, 2)=sorted_horizontal_lines(index+1, 3);
        coordinates(i, 1, 4, 1)=sorted_horizontal_lines(index, 2);
        coordinates(i, 1, 4, 2)=sorted_horizontal_lines(index+1, 3);
        
        %   rectangle 2-7
        n = sorted_horizontal_lines(index+1, 2)-sorted_horizontal_lines(index+1, 1);
        n = (n/6);
        n = int32(n);
        x1 = sorted_horizontal_lines(index+1, 1);
        y1 = sorted_horizontal_lines(index+1, 3);
        y2 = sorted_horizontal_lines(index+2, 3);
        for j=2:7
            x2 = x1 + n;
            coordinates(i,j,1,1) = x1;
            coordinates(i,j,1,2) = y1;
            coordinates(i,j,2,1) = x2;
            coordinates(i,j,2,2) = y1;
            coordinates(i,j,3,1) = x1;
            coordinates(i,j,3,2) = y2;
            coordinates(i,j,4,1) = x2;
            coordinates(i,j,4,2) = y2;
            x1 = x2;
        end
    end
    
%     figure, imshow(image_gray), hold on
%     for i=1:size(coordinates)
%         for j=1:7
%             a = [coordinates(i, j, 1, 1),coordinates(i, j, 1, 2)];
%             b = [coordinates(i, j, 2, 1),coordinates(i, j, 2, 2)];
%             c = [coordinates(i, j, 3, 1),coordinates(i, j, 3, 2)];
%             d = [coordinates(i, j, 4, 1),coordinates(i, j, 4, 2)];
% 
%             A = [a(1), b(1)];
%             B = [a(2),b(2)];
%             plot(A,B);
% 
%             A = [a(1), c(1)];
%             B = [a(2),c(2)];
%             plot(A,B);
% 
%             A = [b(1), d(1)];
%             B = [b(2),d(2)];
%             plot(A,B);
% 
%             A = [c(1), d(1)];
%             B = [c(2),d(2)];
%             plot(A,B);
%         end
%     end
%     
%     input('');

    character_set = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    
    words_scrambled = strings(size(coordinates,1),1);
    for i=1:size(coordinates)
        
        %   run ocr
        image_word = image_binary(coordinates(i,1,1,2):coordinates(i,1,4,2),coordinates(i,1,1,1):coordinates(i,1,4,1));
        imshow(image_word);
        ocr_output = ocr(image_word,'TextLayout', 'Word', 'CharacterSet',character_set);
        
        %   remove letters with low confidence
        word = ocr_output.Text;
        confidence = ocr_output.CharacterConfidences;
        for j= 1:size(word,2)
            if(~isnan(confidence(j)))
                if(confidence(j)<0.3)
                    word(j)=' ';
                end
            end
        end

        word = strtrim(word);
        words_scrambled(i)=word;
    end
    
    
    
    words_solved = solve_words(words_scrambled);
    %disp(words_solved);
    
    %   writed solved words on image
    for i=1:size(coordinates)

        %   offset words of length 5
        word = char(words_solved(i));
        offset = 1;
        if(size(word,2)==5)
            offset = 2;
        end
        
        for j=1:size(word,2)
            
            %   get coordinates of top-left vertex of rectangle
            index = j + offset;
            position = [coordinates(i,index,1,1),coordinates(i,index,1,2)];
            
            %   write letter on image
            image_gray = insertText(image_gray,position,word(j));
        end
    end
    
    %   output
    imshow(image_gray);
    
end

function words_solved = solve_words(words_scrambled)
    
    %   return array of strings
    words_solved = words_scrambled(:);
    
    %   two dictionaries consisting of words of lengths 5 or 6
    path_i = 'roth_words_i.txt';
    path_ii = 'roth_words_ii.txt';
    dictionary_i = readcell(path_i,'TextType','string');
    dictionary_ii = readcell(path_ii,'TextType','string');

    
    %   iterate through scambled words
    for i = 1:length(words_scrambled)
        
        %   the scrambled word
        word = char(words_scrambled(i));
        
        %   determine dictionary
        dictionary = dictionary_i;
        if(size(word,2)==6)
            dictionary = dictionary_ii;
        end
        
        %   compare against every entry in dictionary
        template = zeros(size(word,2),1,'logical')+1;
        for ii = 1:size(dictionary)
            
            %   the comparison
            compare = dictionary(ii);
            compare = compare{1};
            compare = char(compare);
            
            %   if every letter in the comparison corresponds to a letter
            %   in word, then we have found the solution
            
            %   iterate though letters in comparison
            yeah = template(:);
            flag_ii = 1;
            for iii = 1:size(compare,2)
                flag_iii = 0;
                
                %   iterate through letters in word
                for iv = 1:size(compare,2)
                    if(compare(iii)==word(iv))
                        if(yeah(iv))
                            yeah(iv)=0;
                            flag_iii=1;
                            break
                        end
                    end
                end
                if(flag_iii==0)
                    flag_ii=0;
                   break
                end
            end
            if(flag_ii)
                words_solved(i)=compare;
            end
        end
    end
end