%%%%%% Cartesian Data Manual Reconstruction version CBM %%%%%%%%%%%%%%%%%%%
%
% version modified 05/22/2023
%
% The motivation for this code is to reconstruct ventilation data in bulk
% manually so we can test the HP RF depletion compensation filter
% correction on large amounts of past data. We can use this code in
% combination with our previous segmentions of the data and our VDP
% analysis code to test the influence of the RF compensation on the VDP
% outcome.

%% Step 1: select the data from the appropriate directory.
%
% * The directory should contain the .data, the .list files, and the 
% polarization schedule as an identifying key.  
% * It should have a descriptive name (e.g.
% reverse-date-of-scan_subject-ID_axial-or-coronal-orientation, if
% possible), 
% * and also the bulk data should be stored in its own directory, on your CPIR-share
% folder, as a centralized spot for sharing and storing the bulk data.
%
% 
%ImgOrientation = 'Coronal'; % just choose coronal or axial by commenting/uncommenting
ImgOrientation = 'Axial';
MainInput.ScannerSoftware = '5.9.0';

[filename, path] = uigetfile('*.*','Select .data file for the cartesian ventilation'); 
MainInput.XeFullPath = [path,filename];
MainInput.XeDataLocation = path(1:end-1);
[~,~,xe_ext] = fileparts([path, filename]);
MainInput.XeFileName = filename;
MainInput.XeDataext = xe_ext;
MainInput.ImgOrientation = ImgOrientation;


%% Step 2: feed the filename into the load data function. 
%
% Notes about the load data function: 
%
% * For the current version of this code, the matrix size of the Philips
% image slices is fed into the function (e.g. 192x192). We will call this
% field MainInput.ImageSize for now
% 
% * This is a temporary feature for testing purposes (say 10 subjects or
% so). Bulk amounts of data would be cumbersome because the matrix size
% would have to be looked up and fed into the code for each individual
% subject. 
%

MainInput.ImageSize = [128, 128];

Ventilation = Functions.Load_VentRawData(MainInput);
orthosliceViewer(Ventilation.Image);

%% Step 3: save to NIFTI format
[parentFile,parentPath] = uigetfile('*.nii.gz', 'Select template Nifti file');

cd(parentPath)

%info=niftiinfo([MainInput.XeDataLocation, '\', 'img_ventilation_reconstruction.nii.gz']);
info_temp=niftiinfo([parentPath parentFile]);
A = niftiread(info_temp);
A2=squeeze(A); % Remove dimensions of legnth 1
% save_img=A2(:,:,:,1); % Select the 1st component of the 4d array
save_img = A2; 
% info.ImageSize = info_temp.ImageSize(1:3); %Input the 3d array dimensions of the image set
info.PixelDimensions=info_temp.PixelDimensions(1:3);
% info.TransformName = info_temp.TransformName;
% info.Transform.T = info_temp.Transform.T;
%Input the 3d array voxel size of the image set
%save_img = flipud(rot90(Ventilation.Image,1));
%niftiwrite(save_img,'img_ventilation_reconstruction',Compressed=true);
niftiwrite(save_img,'img_ventilation_reconstruction',info,Compressed=true);