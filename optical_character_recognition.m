function optical_character_recognition()

    
   
    path = 'C:\Users\jonat\Documents\rit\2020_2021_fall\introduction_to_computer_vision\Project\project_git\puzzle_small_0107.jpg';
    image_gray = im2double(imread(path));
    image_binary = image_gray < 0.65;

    
    [H,T,R] = hough(image_binary);
    P  = houghpeaks(H,100);
    lines = houghlines(image_binary,T,R,P,'FillGap',5,'MinLength',50);
    
    max_number_of_words=6;
    max_number_of_letters=6;
   
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

    character_set = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    for i=1:size(coordinates)
        image_word = image_binary(coordinates(i,1,1,2):coordinates(i,1,4,2),coordinates(i,1,1,1):coordinates(i,1,4,1));
        %imshow(image_word);
        word = ocr(image_word,'TextLayout', 'Word', 'CharacterSet',character_set);
        word = word.Text;
        word = strtrim(word);
        %disp(word.Text);
        fprintf("word: %s\n",word)
        %input('');
    end
    

    
    
    
    
    %disp(coordinates);
    %disp(size(image_gray));
    

    
 


end