
function [Image, parentPath, FileNames] = LoadData_ListData_R590(DataLocation,Fourier_sz,recon_sz)

    DataFiles = dir([DataLocation,'\*.data']);
    FileNames = DataFiles.name;
    parentPath = DataFiles.folder;
    ch_range = [1 1]; % assume one channel for data import by default
    filterim = 'Fermi';
    %filterim = 'none';
    cd(parentPath)
    filename = FileNames;
    filename(end-4:end)=[];
    [ImgK,~,kx_oversample_factor] = Functions.load_philips_extr1_2D(filename,ch_range);
      
    data_size = size(ImgK);
    ky = data_size(1);
    kx = data_size(2);
    slices = data_size(3);
    %----------------------------------------------------------------------
                    % from .sin file of test data 20220816_IRC186H-416_axial
                    % %                  
% put this variable in the main script for editing 
%                     Fourier_sz = [116,256,21]; 

                    % from .sin file of test data 20220816_IRC186H-416_axial
% %                  
% put this variable in the main script for editing 
% 
%                     recon_sz = [128,128,21];

                    % from the list and .data files 
                    input_sz = [ky,kx,slices];
    
%%%%%%%%%%%%%%%%%%%%%%% Ideally the above sizes are extracted from the raw
%%%%%%%%%%%%%%%%%%%%%%% data files using the above function:
%%%%%%%%%%%%%%%%%%%%%%% load_philips_extr1_2D
    %----------------------------------------------------------------------
    if  length(size(ImgK)) ~= 3

        error("k space data for ventilation data must be a 3 dimensional array.")

    elseif length(size(ImgK)) == 3
            imgcmplx = zeros(Fourier_sz);
            %Image = zeros(recon_sz(1),recon_sz(2),slices);
            Image = zeros(recon_sz);
            if strcmp(filterim,'Fermi') == 1
                    filter= Functions.fermi_filter_2D_AB(Fourier_sz(1),Fourier_sz(2)*kx_oversample_factor,10);
            else
                    filter = 1;
            end
            kx_size = kx/kx_oversample_factor;
%             Image = zeros(128,128,slices);
%-------------------------------------------------------------------------------------------------


                    % find the linear index of the absolute maximum of data
                    [~,I] = max(abs(ImgK),[],'all');  

                    % define the size of the data array
                    sz = size(ImgK);

                    % convert linear indices into the subscript indices
                    % used for matrices
                    [ky_max,kx_max,~] = ind2sub(sz,I);
                    
                    % center by zero-filling
                    % where does 222 come from? kx_max sub ind?
                    % padAmount(2) = (kx - kx_max) * oversample factor x
                    padAmount = [input_sz(1),((kx-2*kx_max)),slices] - [input_sz(1), 0, slices];
                    ImgK_pad1 = padarray(ImgK,padAmount,0,'pre');
                    %ImgK_pad1 = padarray(ImgK_pad1,[0,1,0],0,'pre');

                    % zero-fill until the required Fourier lengths are
                    % achieved in each dimention, with k_0 at the center
                    padAmount_y = [Fourier_sz(1), 0, 0] - [data_size(1), 0, 0]; 
                    
                    padAmount_x = [0, Fourier_sz(2)*kx_oversample_factor, 0] - [0, size(ImgK_pad1,2), 0];

                    padAmount2 = padAmount_x + padAmount_y;

                    % padding by two rows (one pre and one post) in y-dim
                    ImgK_pad2 = padarray(ImgK_pad1,ceil(padAmount2./2),0,'both');

                    if mod(size(ImgK_pad2,1)/2,2) ~= 0
                        ImgK_pad2 = ImgK_pad2(1:end-1,:,:);
                    end

                    % take a look at k-space to check that it worked
                    %orthosliceViewer(abs(ImgK_pad2));

%                         New code test 
%
% Should work for data example 20220816_IRC186H-416_axial
%
% * Fourier matrix size should now have the same Fourier lengths in each
% dimension as the Philips reconstruction, with the k-zero point centered
% in each gradent echo in the time domain data (the k_x dimension). 
%-------------------------------------------------------------------------------------------------
            for sl =1:slices
                    data_slice = ImgK_pad2(:,:,sl).*filter;
                    recon_slice = fftshift(fft2(data_slice),2);
                    x_ind1 = size(ImgK_pad2,2)/2-recon_sz(2)/2;
                    x_ind2 = size(ImgK_pad2,2)/2+recon_sz(2)/2-1;
                    recon_slice = recon_slice(:,x_ind1:x_ind2); % crop extra pixels from oversample factor 
                    imgcmplx(:,:,sl) = recon_slice;
                    img(:,:,sl) = abs(imgcmplx(:,:,sl)); % make magnitude data
                    img = rot90(img,2);
                    %Image(:,:,sl) = imresize(img(:,:,sl),recon_sz([1,2]));
                    Image(:,:,sl) = padarray(img(:,:,sl),[(recon_sz(1)-Fourier_sz(1))/2,0,0],0,'both');
%                     Image(:,:,sl) = diffimg(:,:,sl) ;
            end
            
    end
    

end