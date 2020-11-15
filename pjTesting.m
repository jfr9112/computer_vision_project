function pjTesting(fileName)
    addpath('images');
    im_aligned = align(fileName, 3);
    hold off;
    im_puzzle = find_puzzle_90(im_aligned, 3);
    
    
    [h, w] = size(im_puzzle);
    im_small = im_puzzle(  round(0.1816 * h):round(0.85 * h), 1:round(0.5 * w), : );
    close all;
    imshow(im_small);

    %imwrite(im_puzzle, strcat('puzzle_', strcat(fileName(5:8), '.jpg')));
end