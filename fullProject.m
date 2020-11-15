function fullProject(fileName)
    addpath('images');
    
    im_puzzle = find_puzzle(fileName, 3);
    hold off;
    imshow(im_puzzle);
    
    [h, w] = size(im_puzzle);
    im_small = im_puzzle(  round(0.1816 * h):round(0.85 * h), 1:round(0.5 * w), : );
    imshow(im_small);
    
    % Need to change this to take an arg 
    % optical_character_recognition(im_small);
end