function optical_character_recognition()

    
   
    path = 'C:\Users\jonat\Documents\rit\2020_2021_fall\introduction_to_computer_vision\Project\project_git\puzzle_small_0107.jpg';
    image_gray = im2double(imread(path));
    image_binary = image_gray < 0.65;

    
    [H,T,R] = hough(image_binary);
    P  = houghpeaks(H,100);
    lines = houghlines(image_binary,T,R,P,'FillGap',5,'MinLength',50);
    
    
%     figure, imshow(image_binary), hold on
%     max_len = 0;
%     for k = 1:length(lines)
%        
%        
% 
%        % Plot beginnings and ends of lines
%        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 
%        % Determine the endpoints of the longest line segment
%        len = norm(lines(k).point1 - lines(k).point2);
%        if ( len > max_len)
%           max_len = len;
% 
%        end
%     end



   %a=xy(1,1);%x1
   %b=xy(1,2);%y1
   %c=xy(2,1);%x2
   %d=xy(2,2);%y2
   
   max_number_of_words=6;
   max_number_of_letters=6;

   
    %in_use = zeros(6,7,'logical');
    %coordinates = zeros(6,7,4,2);
    
    
    
    
    count = 0;
    for k=1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        if(xy(1,1)==xy(2,1))
            continue;
        end
        count = count + 1;
    end
    
    number_of_words = (count/3);
    horizontal_lines = zeros(count,3);
    sorted_horizontal_lines = zeros(count,3);
    
    
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
    
    %x =_intmax(u)
    

    
 


end