% In order to denoise the MRI image, we did research into different
% functions that are utilized to do so.  From there, we found a few
% different examples of commonly used functions for denoising, and altered
% them to best fit our code's purpose.

function diffim = project_function(img, num_iteration, delta_t, k, option)

% This portion converts the input image to a double image.
img = double(img);

% This portions establishes the PDE (partial differential equation) initial 
% condition.
diffim = img;

% Center pixel distances set.
dx = 1;
dy = 1;
dd = sqrt(2);

% 2D convolution masks - finite differences.
hN = [0 1 0; 0 -1 0; 0 0 0];
hS = [0 0 0; 0 -1 0; 0 1 0];
hE = [0 0 0; 0 -1 1; 0 0 0];
hW = [0 0 0; 1 -1 0; 0 0 0];
hNE = [0 0 1; 0 -1 0; 0 0 0];
hSE = [0 0 0; 0 -1 0; 0 0 1];
hSW = [0 0 0; 0 -1 0; 1 0 0];
hNW = [1 0 0; 0 -1 0; 0 0 0];

% This portion of the code utilizes anisotropic diffusion, which is a method 
% image denoising that removes any unneccesary noise from an image without 
% removing significant parts of the image content intself.
for t = 1:num_iteration

        % This portion establishes the finite differences.
        nablaN = imfilter(diffim,hN,'conv');
        nablaS = imfilter(diffim,hS,'conv');   
        nablaW = imfilter(diffim,hW,'conv');
        nablaE = imfilter(diffim,hE,'conv');   
        nablaNE = imfilter(diffim,hNE,'conv');
        nablaSE = imfilter(diffim,hSE,'conv');   
        nablaSW = imfilter(diffim,hSW,'conv');
        nablaNW = imfilter(diffim,hNW,'conv'); 
        
        % This is the diffusion function.
        if option == 1
            cN = exp(-(nablaN/k).^2);
            cS = exp(-(nablaS/k).^2);
            cW = exp(-(nablaW/k).^2);
            cE = exp(-(nablaE/k).^2);
            cNE = exp(-(nablaNE/k).^2);
            cSE = exp(-(nablaSE/k).^2);
            cSW = exp(-(nablaSW/k).^2);
            cNW = exp(-(nablaNW/k).^2);
        elseif option == 2
            cN = 1./(1 + (nablaN/k).^2);
            cS = 1./(1 + (nablaS/k).^2);
            cW = 1./(1 + (nablaW/k).^2);
            cE = 1./(1 + (nablaE/k).^2);
            cNE = 1./(1 + (nablaNE/k).^2);
            cSE = 1./(1 + (nablaSE/k).^2);
            cSW = 1./(1 + (nablaSW/k).^2);
            cNW = 1./(1 + (nablaNW/k).^2);
        end

        % Discrete PDE solution.
        diffim = diffim + delta_t*((1/(dy^2))*cN.*nablaN + (1/(dy^2))*cS.*nablaS + (1/(dx^2))*cW.*nablaW + (1/(dx^2))*cE.*nablaE + (1/(dd^2))*cNE.*nablaNE + (1/(dd^2))*cSE.*nablaSE + (1/(dd^2))*cSW.*nablaSW + (1/(dd^2))*cNW.*nablaNW );
end