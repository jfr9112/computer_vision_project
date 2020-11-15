% Assumes the puzzle is rotated by some multiple of 90 degrees from the 
% desired orientation
function im_puzzle = find_puzzle_90(aligned_gray_image, downSampleFactor)
    im_gray_full_size = aligned_gray_image;
    
    im_gray = im_gray_full_size(1:downSampleFactor:end, 1:downSampleFactor:end);
    
    [im_width, im_height] = size(im_gray);
    
    b_im = im_gray < 0.65; % Chosen from histogram, TO_DO automate
    
%     structuring_element_h = strel('rectangle', [2, 5]);
%     structuring_element_v = strel('rectangle', [5, 2]);
%     
%     b_im_opened_h = imopen(b_im, structuring_element_h);
%     b_im_opened_v = imopen(b_im, structuring_element_v);
%     
%     b_im_opened = b_im_opened_h & b_im_opened_v;
    tic
    
    % Radius range
    % A = 4960 * 6864
    % r_range = [55 85]
    % radius is linearly proportional to the square root of the area of the
    % image, so with an experimentally found ratio we should be able to
    % automatically scale the radius range for whatever size image assuming
    % any given image is approximately the same amount of newspaper.
    area = im_width * im_height;
    min_rad = round( ( (55 * sqrt(area)) / sqrt(4960 * 6864) ) );
    max_rad = round( ( (85 * sqrt(area)) / sqrt(4960 * 6864) ) );
    
    
    [centers, radii, metric] = imfindcircles(~b_im, [min_rad, max_rad], 'Sensitivity', 0.84);
    toc
    
    
    
     imshow(b_im);
     hold on;
     viscircles(centers, radii, 'EdgeColor', 'r');
    % disp(size(centers));
    [num_centers, ignore] = size(centers);
    x = centers(1, 1);
    y = centers(1, 2);
    % Highest, Lowest, Leftmost, Rightmost 
    center_extrema = [ y, y, x, x ];
    for center_num = 2:num_centers
        c_x = centers( center_num, 1 );
        c_y = centers( center_num, 2 );
        
        if c_y < center_extrema(1)
            center_extrema(1) = c_y;
        end
        if c_y > center_extrema(2)
            center_extrema(2) = c_y;
        end
        
        if c_x < center_extrema(3)
            center_extrema(3) = c_x;
        end
        if c_x > center_extrema(4)
            center_extrema(4) = c_x;
        end
    end
    
    line([1, im_width], [center_extrema(1), center_extrema(1)], 'Color', 'green');
    line([1, im_width], [center_extrema(2), center_extrema(2)], 'Color', 'green');
    
    line([center_extrema(4), center_extrema(4)], [1, im_height], 'Color', 'green');
    line( [center_extrema(3), center_extrema(3)], [1, im_height], 'Color', 'green');
    
    num_on_extrema = [0,0,0,0];
    for center_num = 1:num_centers
        c_x = centers( center_num, 1 );
        c_y = centers( center_num, 2 );
        
        if (c_y < center_extrema(1)+50) && (c_y > center_extrema(1) - 50)
            num_on_extrema(1) = num_on_extrema(1) + 1;
        end
        if (c_y < center_extrema(2)+50) && (c_y > center_extrema(2) - 50)
            num_on_extrema(2) = num_on_extrema(2) + 1;
        end
        
        if (c_x < center_extrema(3)+50) && (c_x > center_extrema(3) - 50)
            num_on_extrema(3) = num_on_extrema(3) + 1;
        end
        if (c_x < center_extrema(4)+50) && (c_x > center_extrema(4) - 50)
            num_on_extrema(4) = num_on_extrema(4) + 1;
        end
    end
    
    %disp(num_on_extrema)
    
    l_bottom_indx = max(num_on_extrema) == num_on_extrema;
    bottom_indx = find(l_bottom_indx, 1, 'first');
    
    
    crop_rect = [ center_extrema(3), center_extrema(1) , center_extrema(4) - center_extrema(3), center_extrema(2) - center_extrema(1)];
   % Distance from top cirlce to top of puzzle
    % needs to be in terms of circle radii
    avg_radii = mean(radii);
    
    top_margin = 10 * avg_radii;
    % Distance from other extrema circles to corresponding edge of puzzle
    other_margin = (100/65) * avg_radii;
    
    margin_mat = [0, 0, 0, 0];
    rotation_angle = 0;
    switch bottom_indx
        case 1
            % Upside down
            margin_mat = [-other_margin, -other_margin, 2 * other_margin, top_margin + other_margin];
            rotation_angle = 180;
        case 2
            % Already right side up
            margin_mat = [-other_margin, -top_margin, 2 * other_margin, top_margin + other_margin];
            rotation_angle = 0;
        case 3
            % Rotated clockwise
            margin_mat = [-other_margin, -other_margin, top_margin + other_margin, 2 * other_margin];
            rotation_angle = 270;
        case 4
            % Rotated counterclockwise
            margin_mat = [-top_margin, -other_margin, top_margin + other_margin, 2 * other_margin];
            rotation_angle = 90;
            
    end
    
    crop_parameter = crop_rect + margin_mat
    
    
    im_cropped = imcrop(im_gray_full_size, downSampleFactor * crop_parameter);
    im_puzzle = imrotate(im_cropped, -rotation_angle);
    
    %hold off;
    %imshow(im_puzzle);
end
