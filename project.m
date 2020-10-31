%   Parker Johnson
%   Jonathan Roth
%   2020-08-11

function project(input_path, output_path)

    %read in the image
    %convert to grayscale
    %not sure if "rgb2gray" is the best approach
    im = imread(input_path);
    im = im2double(im);
    im=rgb2gray(im);

    %standard gausiian filter
    fltr = fspecial('Gauss', 25, 4);
    im_filtered = imfilter(im, fltr, 'same', 'repl');

    
    %convert the images into a binary image
    %1 for ink, 0 for no ink
    %.7 works for most images, but not all
    %if there is a better way to calculate this for any given image, we
    %should
    %see examples in /imgages_binary
    im_binary = im_filtered>.7;
    [length, width] = size(im_binary);
    
    %dont count black edges around the newspaper as ink
    for x = 1:width
        for y = 1:length
            if im_binary(y,x)==0
                im_binary(y,x)=1;
            else
                break
            end
        end
    end
    for x = 1:width
        for y = length:-1:1
            if im_binary(y,x)==0
                im_binary(y,x)=1;
            else
                break
            end
        end
    end
    for y = 1:length
        for x = 1:width
            if im_binary(y,x)==0
                im_binary(y,x)=1;
            else
                break
            end
        end
    end
    for y = 1:length
        for x = width:-1:1
            if im_binary(y,x)==0
                im_binary(y,x)=1;
            else
                break
            end
        end
    end

   
    
    %identify grids by seeing if we can get to them from border of image
    %this gives us the large rectangular portions but also text
    %examples in /images_accessable
    accessable = zeros(length, width);
    for x = 1:length
        accessable(x,1)=1;
        accessable(x,width)=1;
    end
    for y = 1:width
        accessable(1,y)=1;
        accessable(length,y)=1;
    end
    
    for x = 2:length-1
        for y = 2:width-1
            if(accessable(x-1,y-1) || accessable(x-1,y) || accessable(x,y-1))
                if(im_binary(x,y))
                    accessable(x,y)=1;
                end
            end
        end
    end
    for x = length-1:-1:2
        for y = width-1:-1:2
            if(accessable(x+1,y+1) || accessable(x+1,y) || accessable(x,y+1))
                if(im_binary(x,y))
                    accessable(x,y)=1;
                end
            end
        end
    end
    

    %remove text by requiring that to be a rectangle you cant have any white
    %pixels
    %examples in images_rectangle
    new = zeros(length, width);
    for x = 1:100:length-100
        for y = 1:100:width-100
            square=accessable(x:x+100,y:y+100);
            flag = 0;
            for xx = 1:100
                if(flag)
                    break
                end
                for yy = 1:100
                    if(square(xx,yy))
                        flag=1;
                        break;
                    end
                end
            end
            if(flag==0)
                for xx=x:x+100
                    for yy=y:y+100
                        new(xx,yy)=1;
                    end
                end
            end
        end
    end
    for x = 1:length-1
        for y = 1:width-1
            if(new(x,y))
                if(accessable(x+1,y+1)==0)
                    new(x+1,y+1)=1;
                end
                if(accessable(x,y+1)==0)
                    new(x,y+1)=1;
                end
                if(accessable(x+1,y)==0)
                    new(x+1,y)=1;
                end
            end
        end
    end
    for x = length:-1:2
        for y = width:-1:2
            if(new(x,y))
                if(accessable(x-1,y-1)==0)
                    new(x-1,y-1)=1;
                end
                if(accessable(x,y-1)==0)
                    new(x,y-1)=1;
                end
                if(accessable(x-1,y)==0)
                    new(x-1,y)=1;
                end
            end
        end
    end
    
    
    %imshow(new);
    %imwrite(new, output_path)
end
