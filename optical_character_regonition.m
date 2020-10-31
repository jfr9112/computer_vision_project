function optical_character_regocnition()

    
    %   read in image, convert to binary
    path = 'C:\Users\jonat\Documents\rit\2020_2021_fall\introduction_to_computer_vision\Project\project_git\puzzle_small_0107.jpg';
    %image_rgb = im2double(imread(path));
    %image_gray = image_rgb(:,:,2);
    image_gray = im2double(imread(path));
    image_binary = image_gray < 0.65;

    %imshow(image_binary);
    
    %image_gauss = imgaussfilt(image_binary);
    %imshow(image_gauss);
    
    text_class = ocr(image_binary);
    
    imshow(image_binary);
    disp(text_class.Text);
    
    
    
    
    
    
    
    


end