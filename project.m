%   Parker Johnson
%   Jonathan Roth
%   2020-08-11


function project(input_path)
    show_stuff = 1;

    addpath('images');
    im = imread(input_path);
    im_gray = im(:,:, 2);
    [height, width] = size(im_gray);
    area = height * width;
    downSampleFactor = sqrt(area) / sqrt(4960 * 6864);
    downSampleFactor = downSampleFactor * 3; % 3 is arbitrary
    
    if (show_stuff == 1)
        disp("Down sample factor before rounding");
        disp(downSampleFactor);
    end
    
    % Can't downsample by 0
    
    downSampleFactor = max(round(downSampleFactor), 1);
    
    im_aligned = align(input_path, downSampleFactor);
    if(im_aligned == 1)
        disp("No puzzle detected");
        return 
    end
    
    if show_stuff == 1
        close all;
        imshow(im_aligned);
    end
    
    
    hold off;
    [im_puzzle, weekend] = find_puzzle_90(im_aligned, downSampleFactor);
    if(im_puzzle == 1)
        disp("No puzzle detected");
        return 
    end
   
    
    if show_stuff == 1
        close all;
        imshow(im_puzzle);
    end
    
    [h, w] = size(im_puzzle);
    top = 0.1816;
    bot = 0.85;
    right = 0.5;
    if (weekend == 1)
       right = 0.45;
       top = 0.136;
    end
    im_small = im_puzzle(  round(top * h):round(bot * h), 1:round(right * w), : );
    if show_stuff == 1
        close all;
        imshow(im_small);
    end
    
    %input('');

    % Need these to link up
    optical_character_recognition(im_small);
end
