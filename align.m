% Assumes the puzzle is rotated by some multiple of 90 degrees from the 
% desired orientation
function im_aligned = align(fileName, downSampleFactor)
    im_rgb = im2double(imread(fileName));
    %im_rgb = imrotate(im_rgb, 90 * 0);
    imshow(im_rgb);
    im_gray_full_size = im_rgb(:,:,2); % Green channel
    
    
    im_gray = im_gray_full_size(1:downSampleFactor:end, 1:downSampleFactor:end);
    
    [im_width, im_height] = size(im_gray);
    
    b_im = im_gray < 0.65; % Chosen from histogram, TO_DO automate
    
    %structuring_element_h = strel('rectangle', [2, 5]);
    %structuring_element_v = strel('rectangle', [5, 2]);
    
    %b_im_opened_h = imopen(b_im, structuring_element_h);
    %b_im_opened_v = imopen(b_im, structuring_element_v);
    
    %b_im_opened = b_im_opened_h & b_im_opened_v;
    b_im_opened = b_im;
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
    %max_rad = round( ( (85 * sqrt(area)) / sqrt(4960 * 6864) ) );
    max_rad = round( ( (120 * sqrt(area)) / sqrt(4960 * 6864) ) );
    
    
    [centers, radii, metric] = imfindcircles(~b_im_opened, [min_rad, max_rad], 'Sensitivity', 0.84);
    %toc
    
    
    
    %imshow(b_im_opened);
    %hold on;
    %viscircles(centers, radii, 'EdgeColor', 'r');
    
    % disp(size(centers));
    [num_centers, ignore] = size(centers);
    
    if num_centers == 0
        disp("no centers found, exiting");
        im_aligned = 1;
        return
    end
    
    if num_centers < 5
       disp("Found less than 5 centers, exiting");
       im_aligned = 1;
       return
    end
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
    
    %line([1, im_width], [center_extrema(1), center_extrema(1)], 'Color', 'green');
    %line([1, im_width], [center_extrema(2), center_extrema(2)], 'Color', 'green');
    
    %line([center_extrema(4), center_extrema(4)], [1, im_height], 'Color', 'green');
    %line( [center_extrema(3), center_extrema(3)], [1, im_height], 'Color', 'green');
    
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
    
  

    % Need to adjust slight angles
    bot_centers_x = [];
    bot_centers_y = [];
    hit = 0;
    for center_num = 1:num_centers
        c_x = centers( center_num, 1 );
        c_y = centers( center_num, 2 );
        im_centers(round(c_x), round(c_y)) = 1; % this might be transposed

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
    
    num_bot_centers = size(bot_centers_x);
    disp(num_bot_centers);
%     
%     weekend = 0;
%     if(num_bot_centers(2) > 12)
%         disp("This is a weekend puzzle")
%         weekend = 1;
%     end

    if num_bot_centers(2) < 5
       disp("Found less than 5 centers in the bottom row, exiting");
       im_aligned = 1;
       return
    end
    
    standard_dev_x = std(bot_centers_x);
    standard_dev_y = std(bot_centers_y);
    
    % Big and small sides of triangle
    max_big = -1; % sentinel
    min_big = -1; % sentinel
    max_small = -1; % sentinel
    min_small = -1; % sentinel
    
    if standard_dev_x > standard_dev_y
        max_big = max(bot_centers_x);
        min_big = min(bot_centers_x);
        
        max_small = max(bot_centers_y);
        min_small = min(bot_centers_y);
    else
        max_big = max(bot_centers_y);
        min_big = min(bot_centers_y);
        
        max_small = max(bot_centers_x);
        min_small = min(bot_centers_x);
    end
    
    angle_direction = 1;
    %bottom_indx
    switch(bottom_indx)
        case(1)
            % Up side down
            check_center = [min_big min_small];
            l_is_center = ismember(centers, check_center, 'rows');
            n = sum(l_is_center(:));
            if n == 0
                angle_direction = -1;
            end
            
        case(2)
            % Right side up
            check_center = [min_big min_small];
            l_is_center = ismember(centers, check_center, 'rows');
            n = sum(l_is_center(:));
            if n == 0
                angle_direction = -1;
            end
            
        case(3)
           % Rotated 90 degrees CCW
            check_center = [min_small min_big];
            l_is_center = ismember(centers, check_center, 'rows');
            n = sum(l_is_center(:));
            if n == 1
                angle_direction = -1;
            end
            
        case(4)
            % Rotated 90 degrees CW
            check_center = [min_small min_big];
            l_is_center = ismember(centers, check_center, 'rows');
            n = sum(l_is_center(:));
            if n == 1
                angle_direction = -1;
            end
    end
        
    small_angle = 90 - rad2deg(atan((max_big - min_big)/(max_small - min_small)));
    angle = small_angle * angle_direction;
    
    im_aligned = imrotate(im_gray_full_size, angle , 'nearest', 'crop');
    %im_aligned = [im_aligned weekend];
    %im_and_weekend
end


