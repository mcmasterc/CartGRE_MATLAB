
function [Image, parentPath, FileNames] = LoadData_ListData(DataLocation,im_sz)

    DataFiles = dir([DataLocation,'\*.data']);
    FileNames = DataFiles.name;
    parentPath = DataFiles.folder;
    ch_range = [1 1]; % assume one channel for data import by default
    %filterim = 'Fermi';
    filterim = 'none';
    cd(parentPath)
    filename = FileNames;
    filename(end-4:end)=[];
    [ImgK,NoiK,kx_oversample_factor] = Functions.load_philips_extr1_2D(filename,ch_range);
    diffK = ImgK(:,:,:,:);
    
    
    if  length(size(diffK)) == 4

         error("k space data for ventilation data must be a 3 dimensional array.")
        
    elseif length(size(diffK)) == 3
            data_size = size(diffK);
            ky = data_size(1);
            kx =data_size(2);
            slices = data_size(3);
            diffimgcmplx = zeros(ky,round(kx/kx_oversample_factor),slices);
            if strcmp(filterim,'Fermi') == 1
                    filter= LoadData.fermi_filter_2D_AB(ky,kx,10);
            else
                    filter = 1;
            end
            for sl =1:slices
                    data_slice = diffK(:,:,sl).*filter;
                    recon_slice = fftshift(fft2(data_slice),2);
                    recon_slice(:,1:kx/(2*kx_oversample_factor))=[]; % crop extra pixels from oversample factor
                    recon_slice(:, (1+kx/kx_oversample_factor):end)=[]; 
                    diffimgcmplx(:,:,sl) = recon_slice;
                    diffimg(:,:,sl) = abs(diffimgcmplx(:,:,sl)); % make magnitude data
                    Image(:,:,sl) = imresize(diffimg(:,:,sl),im_sz);
            end
            
            Image = rot90(rot90(diffimg));  
            
    end
    
end