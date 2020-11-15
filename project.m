%   Parker Johnson
%   Jonathan Roth
%   2020-08-11

function project(input_path)

    addpath('images');
    im_aligned = align(input_path, 3);
    hold off;
    im_puzzle = find_puzzle_90(im_aligned, 3);
    
    
    [h, w] = size(im_puzzle);
    im_small = im_puzzle(  round(0.1816 * h):round(0.85 * h), 1:round(0.5 * w), : );
    close all;
    imshow(im_small);

    % Need these to link up
    % optical_character_recognition(im_small);
end
