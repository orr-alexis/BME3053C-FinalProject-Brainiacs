% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% The overall purpose of this code is to scan the MRI brain scans in the 
% provided folders, and then determine if a tumor is present in the image.
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

clear; clc;

% This first part of the code will ask the user to enter the name of the
% image they would like scanned from the folder they have uploaded.  It is
% assumed that the user will upload the image into the correct path before
% running the code.  In our code, the images from the two folders (yes and 
% no) have already been uploaded to the appropriate area in the MATLAB path.

img = input('Enter the name of the .jpg MRI brain image to be scanned for abnormalities: ', 's');
img = imread(img);
 
% This remainder of the code will utilize image filtering and edge detection
% to identify any areas of the scan which may contain an abnormality, based
% off the color of each section in the established 'bounding box' after 
% denoising and filtering has occured.

% Denoise the inputted image, and resize it to an appropriate size to
% complete the filtering and outlining.  The function 'project_function'
% denoises the image and differentiates different areas to ensure that only
% the tumor (if there is one) will be outlined, and not any normal portions
% of the MRI scan.  The function also applies a filter so that the
% outlining can happen correctly.

num_iteration = 10;
delta = 1/7;
k = 15;
option = 2;

% This portion shows the function titled 'project_function' being used to
% properly denoise the image without losing any integral parts of the scan.
inp = project_function(img,num_iteration,delta,k,option);
inp = uint8(inp);
    
% This portion resizes the image, and converts it into a black and white
% image (if it was initially not so), so that thresholding can be implemented.  
inp=imresize(inp,[256,256]);
if size(inp,3)>1
    inp=rgb2gray(inp);
end

% This portion resizes the image again, and thresholds it to isolate areas that
% may be tumors from the rest of the scan.
new = imresize(inp,[256,256]);
t = 60;
th = t + ((max(inp(:)) + min(inp(:)))./2);
for i = 1:1:size(inp,1)
    for j = 1:1:size(inp,2)
        if inp(i,j)>th
            new(i,j) = 1;
        else
            new(i,j) = 0;
        end
    end
end

% This portion creates a box over the area that may be a tumor, and allows
% this individual area to be scanned in order to determine if it is a
% tumor, based off its shape and area.
label = bwlabel(new);
stats = regionprops(logical(new),'Solidity','Area','BoundingBox');
density = [stats.Solidity];
area = [stats.Area];

% This portion sets an area of 'high density' as that above 0.5.  We
% determined this would be the appropriate value after testing many of the
% images in the folders, and seeing what value would be classified as 'high
% density' for a brain tumor.  Due to this, our code outlines the areas of
% highest density, so that other areas of the scan that may only appear to
% be a tumor are not highlighted.
high_dense_area = density > 0.5;
max_area = max(area(high_dense_area));
tumor_label = find(area == max_area);
tumor = ismember(label,tumor_label);

% Tests if an area is a tumor based off of its area.  If it does not meet
% the criteria, then a message stating there is no tumor is given to the
% user.
if max_area > 140
else
    fprintf('No tumor detected.')
    return;
end

box = stats(tumor_label);
wantedBox = box.BoundingBox;

% If there is a tumor present, then this next portion of the code outlines
% the tumor so that the user is able to see it.  
dilationAmount = 5;
rad = floor(dilationAmount);
[r,c] = size(tumor);
filledImage = imfill(tumor, 'holes');
for i = 1:r
   for j = 1:c
       x1 = i - rad;
       x2 = i + rad;
       y1 = j - rad;
       y2 = j + rad;
       if x1 < 1
           x1 = 1;
       end
       if x2 > r
           x2 = r;
       end
       if y1 < 1
           y1 = 1;
       end
       if y2 > c
           y2 = c;
       end
       erodedimage(i,j) = min(min(filledImage(x1:x2,y1:y2)));
   end
end

% This portion of the code will implement the outline onto the original
% image, as to allow the user to see clearly where exactly the tumor is on
% the MRI scan.
outline = tumor;
outline(erodedimage) = 0;

rgb = inp(:,:,[1 1 1]);
r = rgb(:,:,1);
r(outline) = 255;
g = rgb(:,:,2);
g(outline) = 0;
b = rgb(:,:,3);
b(outline) = 0;
outlineadded(:,:,1) = r; 
outlineadded(:,:,2) = g; 
outlineadded(:,:,3) = b; 

% After the tumor (if present) is detected and outlined, the code will
% display the original inputted image alongside the image with the outlined
% tumor to the user, with each image being labelled as such.
fprintf('Tumor detected. \n')
figure
subplot(1,2,1)
imshow(img);title('Input Image','FontSize',15);
subplot(1,2,2)
imshow(outlineadded);title('Detected Tumor','FontSize',15);