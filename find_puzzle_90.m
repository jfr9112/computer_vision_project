% Assumes the puzzle is rotated by some multiple of 90 degrees from the 
% desired orientation
function im_puzzle = find_puzzle_90(aligned_gray_image, downSampleFactor)
    show_stuff = 1;
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
    %tic
    
    % Radius range
    % A = 4960 * 6864
    % r_range = [55 85]
    % radius is linearly proportional to the square root of the area of the
    % image, so with an experimentally found ratio we should be able to
    % automatically scale the radius range for whatever size image assuming
    % any given image is approximately the same amount of newspaper.
    area = im_width * im_height;
    min_rad = round( ( (55 * sqrt(area)) / sqrt(4960 * 6864) ) );
    max_rad = round( ( (120 * sqrt(area)) / sqrt(4960 * 6864) ) );
    
    
    [centers, radii, metric] = imfindcircles(~b_im, [min_rad, max_rad], 'Sensitivity', 0.84);
    %toc
    
    
    
    if show_stuff == 1
        imshow(b_im);
        hold on;
        viscircles(centers, radii, 'EdgeColor', 'r');
    end
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
    
    if(show_stuff == 1)
        line([1, im_width], [center_extrema(1), center_extrema(1)], 'Color', 'green');
        line([1, im_width], [center_extrema(2), center_extrema(2)], 'Color', 'green');
        
        line([center_extrema(4), center_extrema(4)], [1, im_height], 'Color', 'green');
        line( [center_extrema(3), center_extrema(3)], [1, im_height], 'Color', 'green');
    end
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
    
    
    
   % Distance from top cirlce to top of puzzle
    % needs to be in terms of circle radii
    avg_radii = mean(radii);
    
    top_margin = 10 * avg_radii;
    % Distance from other extrema circles to corresponding edge of puzzle
    other_margin = (100/65) * avg_radii;
    
    % The top circle is (experimentally) 19 radii above the bottom circle
    top2bot = 20;
    
    % Need to adjust slight angles
    bot_centers_x = [];
    bot_centers_y = [];
    hit = 0;
    for center_num = 1:num_centers
        c_x = centers( center_num, 1 );
        c_y = centers( center_num, 2 );
        switch(bottom_indx)
            case(1)
                if (c_y < center_extrema(1)+50) && (c_y > center_extrema(1) - 50)
                    hit = 1;
                end
                
            case(2)
                if (c_y < center_extrema(2)+50) && (c_y > center_extrema(2) - 50)
                    hit = 1;
                end
                
            case(3)
                if (c_x < center_extrema(3)+50) && (c_x > center_extrema(3) - 50)
                    hit = 1;
                end
                
            case(4)
                if (c_x < center_extrema(4)+50) && (c_x > center_extrema(4) - 50)
                    hit = 1;
                end
        end
        if hit == 1
           bot_centers_x( end + 1 ) = c_x;
           bot_centers_y( end + 1 ) = c_y;
        end
        hit = 0;
    end
    
    
    
    crop_rect_save = [ center_extrema(3), center_extrema(1) , center_extrema(4) - center_extrema(3), center_extrema(2) - center_extrema(1)];
    margin_mat = [0, 0, 0, 0];
    rotation_angle = 0;
    switch bottom_indx
        case 1
            % Upside down
            margin_mat = [-other_margin, -other_margin, 2 * other_margin, top_margin + other_margin];
            rotation_angle = 180;
            
            % Adjust top end to be based on distance from bottom, rather
            % than highest circle
            center_extrema(2) = center_extrema(1) + (top2bot * avg_radii);
            dist_from_centers = abs(centers(:,2) - center_extrema(2));
            target = min(dist_from_centers);
            cntr_indx = find(dist_from_centers == target, 1, 'first');
            center_extrema(2) = centers(cntr_indx,2);
            
            % Adjust sides to only be based on circles along the bottom
            center_extrema(3) = min(bot_centers_x);
            center_extrema(4) = max(bot_centers_x);
            
            % Left side of bottom is occasionally not far enough left
            dist_to_centers = abs(center_extrema(1) - centers(:,2));
            dev = std(dist_to_centers);
            l_close_centers = dist_to_centers < (1.5 * dev);
            close_centers = centers(l_close_centers, :);
            if show_stuff == 1
                viscircles(close_centers, radii(l_close_centers), 'EdgeColor', 'g');
            end
            center_extrema(4) = max(close_centers(:,1));
            
        case 2
            % Already right side up
            margin_mat = [-other_margin, -top_margin, 2 * other_margin, top_margin + other_margin];
            rotation_angle = 0;
            
            % Adjust top end to be based on distance from bottom, rather
            % than highest circle
            center_extrema(1) = center_extrema(2) - (top2bot * avg_radii);
            dist_from_centers = abs(centers(:,2) - center_extrema(1));
            target = min(dist_from_centers);
            cntr_indx = find(dist_from_centers == target, 1, 'first');
            center_extrema(1) = centers(cntr_indx,2);
            
            % Adjust sides to only be based on circles along the bottom
            center_extrema(3) = min(bot_centers_x);
            center_extrema(4) = max(bot_centers_x);
            
            % Left side of bottom is occasionally not far enough left
            dist_to_centers = abs(center_extrema(2) - centers(:,2));
            dev = std(dist_to_centers);
            l_close_centers = dist_to_centers < (1.5 * dev);
            close_centers = centers(l_close_centers, :);
            if show_stuff == 1
                viscircles(close_centers, radii(l_close_centers), 'EdgeColor', 'g');
            end
            center_extrema(3) = min(close_centers(:,1));
            
        case 3
            % Rotated clockwise
            margin_mat = [-other_margin, -other_margin, top_margin + other_margin, 2 * other_margin];
            rotation_angle = 270;
            
            % Adjust top end to be based on distance from bottom, rather
            % than highest circle
            center_extrema(4) = center_extrema(3) + (top2bot * avg_radii);
            dist_from_centers = abs(centers(:,1) - center_extrema(4));
            target = min(dist_from_centers);
            cntr_indx = find(dist_from_centers == target, 1, 'first');
            center_extrema(4) = centers(cntr_indx,1);
            
            % Adjust sides to only be based on circles along the bottom
            center_extrema(1) = min(bot_centers_y);
            center_extrema(2) = max(bot_centers_y);
            
            % Left side of bottom is occasionally not far enough left
            dist_to_centers = abs(center_extrema(3) - centers(:,1));
            dev = std(dist_to_centers);
            l_close_centers = dist_to_centers < (1.5 * dev);
            close_centers = centers(l_close_centers, :);
            if show_stuff == 1
                viscircles(close_centers, radii(l_close_centers), 'EdgeColor', 'g');
            end
            center_extrema(1) = min(close_centers(:,2));
            
        case 4
            % Rotated counterclockwise
            margin_mat = [-top_margin, -other_margin, top_margin + other_margin, 2 * other_margin];
            rotation_angle = 90;
            
            % Adjust top end to be based on distance from bottom, rather
            % than highest circle
            center_extrema(3) = center_extrema(4) - (top2bot * avg_radii);
            dist_from_centers = abs(centers(:,1) - center_extrema(3));
            target = min(dist_from_centers);
            cntr_indx = find(dist_from_centers == target, 1, 'first');
            center_extrema(3) = centers(cntr_indx,1);
            
            % Adjust sides to only be based on circles along the bottom
            center_extrema(1) = min(bot_centers_y);
            center_extrema(2) = max(bot_centers_y);
            
            % Left side of bottom is occasionally not far enough left
            dist_to_centers = abs(center_extrema(4) - centers(:,1));
            dev = std(dist_to_centers);
            l_close_centers = dist_to_centers < (1.5 * dev);
            close_centers = centers(l_close_centers, :);
            if show_stuff == 1
                viscircles(close_centers, radii(l_close_centers), 'EdgeColor', 'g');
            end
            center_extrema(2) = max(close_centers(:,2));
    end
    
    
    crop_rect = [ center_extrema(3), center_extrema(1) , center_extrema(4) - center_extrema(3), center_extrema(2) - center_extrema(1)];
    
    if (show_stuff == 1)
        line([1, im_width], [center_extrema(1), center_extrema(1)], 'Color', 'red');
        line([1, im_width], [center_extrema(2), center_extrema(2)], 'Color', 'red');
        
        line([center_extrema(4), center_extrema(4)], [1, im_height], 'Color', 'magenta');
        line( [center_extrema(3), center_extrema(3)], [1, im_height], 'Color', 'cyan');
    end
    
    crop_parameter = crop_rect + margin_mat;
    
    im_cropped = imcrop(im_gray_full_size, downSampleFactor * crop_parameter);
    im_puzzle = imrotate(im_cropped, -rotation_angle);
    if (show_stuff == 1)
        hold off;
        imshow(im_puzzle);
    end
    
end
