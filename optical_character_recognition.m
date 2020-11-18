%   Parker Johnson
%   Jonathan Roth
%   2020-11-18

function optical_character_recognition(image_gray, is_weekend)
%   find all lines
    image_binary = image_gray < 0.65;
    [H,T,R] = hough(image_binary);
    P  = houghpeaks(H,100);
    lines = houghlines(image_binary,T,R,P,'FillGap',10,'MinLength',100);

    %count number of horizontal lines
    count = 0;
    for k=1:size(lines,2)
        xy = [lines(k).point1; lines(k).point2];
        if(abs(xy(1,1)-xy(2,1))<5)
            continue;
        end
        count = count + 1;
    end
    
    %   obtain and sort horizontal lines
    horizontal_lines = zeros(count,3);
    sorted_horizontal_lines = zeros(count,3);
    count=0;
    for k=1:size(lines,2)
        xy = [lines(k).point1; lines(k).point2];
        if(abs(xy(1,1)-xy(2,1))<5)
            continue;
        end
        count = count + 1;
        horizontal_lines(count,1)=xy(1,1);
        horizontal_lines(count,2)=xy(2,1);
        horizontal_lines(count,3)=xy(1,2);
    end
    sorted_heights = sort(horizontal_lines(:,3));
    for i=1:size(sorted_horizontal_lines,1)
        for j=1:size(sorted_horizontal_lines)
            if horizontal_lines(i,3)== sorted_heights(j)
                sorted_horizontal_lines(j,1) = horizontal_lines(i,1);
                sorted_horizontal_lines(j,2) = horizontal_lines(i,2);
                sorted_horizontal_lines(j,3) = horizontal_lines(i,3);
            end
        end
    end
    
    %   weekend puzzle
    if(is_weekend)
        
        coordinates = zeros(6,7,4,2);
        circles = zeros(4,6);
        squares = zeros(4,6);
       
        %   ensure that the proper number of horizontal lines are detected
        if(size(sorted_horizontal_lines,1)==12)
          
        elseif(size(sorted_horizontal_lines,1)==13)
            sorted_horizontal_lines = sorted_horizontal_lines(2:13,:);
        else
            disp('error on horizontal lines');
            return 
        end
        
        %   obtain all relevant coordinates of puzzle from lines
        for i=1:6
            index = ((i-1)*2)+1;
             
            x1 = sorted_horizontal_lines(index, 1);
            x2 = 0;
            x3 = sorted_horizontal_lines(index, 2);
            y1 = 0;
            y2 = sorted_horizontal_lines(index, 3);
            y3 = sorted_horizontal_lines(index+1,3);
            
            length = x3-x1;
            height = y3-y2;
            n = (length/6);
            
            y1 = y2 - height;
            x2 = x1 + (5*n);

            %   rectangle 1
            coordinates(i, 1, 1, 1)=x1;
            coordinates(i, 1, 1, 2)=y1;
            coordinates(i, 1, 2, 1)=x2;
            coordinates(i, 1, 2, 2)=y1;
            coordinates(i, 1, 3, 1)=x1;
            coordinates(i, 1, 3, 2)=y2;
            coordinates(i, 1, 4, 1)=x2;
            coordinates(i, 1, 4, 2)=y2;

            %   rectangle 2-7
            a = x1;
            for j=2:7
                b = a + n;
                coordinates(i,j,1,1) = a;
                coordinates(i,j,1,2) = y2;
                coordinates(i,j,2,1) = b;
                coordinates(i,j,2,2) = y2;
                coordinates(i,j,3,1) = a;
                coordinates(i,j,3,2) = y3;
                coordinates(i,j,4,1) = b;
                coordinates(i,j,4,2) = y3;
                a = b;
            end
        end
        
    %   non-weekend puzzles    
    else
        
        %   ensure that the proper number of horizontal lines are detected
        if(size(sorted_horizontal_lines,1)==12)
        else
            disp('error on horizontal lines');
            return 
        end

        coordinates = zeros(4,7,4,2);
        circles = zeros(4,6);
        squares = zeros(4,6);

        %   obtain all relevant coordinates of puzzle from lines
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
    end
    
    %   the width of the letter boxes / radius of circles
    radius = int32((coordinates(1,2,2,1) - coordinates(1,2,1,1))/2);
    
    %   determine whether a box contains a circle
    for i=1:size(coordinates)
        for j=2:7
            image_box = image_gray(coordinates(i,j,1,2)+5:coordinates(i,j,4,2)-5,coordinates(i,j,1,1)+5:coordinates(i,j,4,1)-4)<.65;
            [centers,r, m] = imfindcircles(image_box,[radius-10 radius+10],'Sensitivity',1,'EdgeThreshold',.8);
             if(~size(m,1)==0)
                 if(m(1)>.01)
                     circles(i,j-1)=1;
                 end
             end
        end
    end
    
    %   perform ocr to obtain unscrambled letters
    character_set = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    words_scrambled = strings(size(coordinates,1),1);
    for i=1:size(coordinates)
        
        %   run ocr
        x_crop=7;
        y_crop=7;
        image_word = image_gray(coordinates(i,1,1,2)+x_crop:coordinates(i,1,4,2)-x_crop,coordinates(i,1,1,1)+y_crop:coordinates(i,1,4,1)-y_crop);
        image_word = imgaussfilt(image_word);
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
    
    
    %   unscramble the words
    words_solved = solve_words(words_scrambled);

    
    %   write solved words on image, display letters contained in circles
    fprintf('the following letters are containted in circles:\n');
    for i=1:size(coordinates)

        %   ignore squares that do not contain words
        word = char(words_solved(i));
        offset = 1;
        if(size(word,2)==5)
            offset = 2;
        elseif(size(word,2)==6)
            offset = 1;
        else
            continue;
        end
        
        %   write letter on image
        for j=1:size(word,2)
            
            index = j + offset;
            position = [coordinates(i,index,1,1)+radius, coordinates(i,index,1,2)+radius];
            image_gray = insertText(image_gray,position,word(j),'FontSize', 50, 'BoxOpacity',0,'AnchorPoint','Center');
            
            %   print letter if box contains circle
            if(circles(i,index-1))
                fprintf('%s ',word(j));
            else
                squares(i,index-1)=1;
            end
        end
    end
    fprintf('\n');
    
    %   final output
    figure, imshow(image_gray), hold on;
    for i=1:size(coordinates)
        
        x1 = coordinates(i,1,1,1);
        x2 = coordinates(i,1,2,1);
        y1 = coordinates(i,1,1,2);
        y2 = coordinates(i,1,3,2);
        position = [x1, y1, x2-x1, y2-y1];
        
        %   display yellow rectangle around box with input letters
        rectangle('position', position, 'EdgeColor','y');
        
        for j=2:7
                
            x1 = coordinates(i,j,1,1);
            x2 = coordinates(i,j,2,1);
            y1 = coordinates(i,j,1,2);
            y2 = coordinates(i,j,3,2);
            
            %   draw circle accordingly   
            if(circles(i,j-1))
                position = [x1, y1, x2-x1, y2-y1];
                %rectangle('position', position, 'EdgeColor','b');
                viscircles([x1+radius,y1+radius],radius,'Color','b');
            
            %   draw red rectangle othterwise
            elseif(squares(i,j-1))
                position = [x1, y1, x2-x1, y2-y1];
                rectangle('position', position, 'EdgeColor','r');
            end
        end
    end
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
        if(size(word,2)==5)
            dictionary = dictionary_i;
        elseif(size(word,2)==6)
            dictionary = dictionary_ii;
        else
            words_solved(i)='';
            continue;
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