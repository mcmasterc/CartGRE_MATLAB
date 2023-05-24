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

% valid for axial data
nii = nii_tool('init',Ventilation.Image);
nii.img = rot90(flipud(nii.img),-1);
%nii.img = permute(nii.img,[2 1 3]);

[parentFile,parentPath] = uigetfile('*.nii.gz', 'Select template Nifti file');

temp_hdr = nii_tool('hdr',[parentPath, parentFile]);
nii.hdr = temp_hdr;
nii_tool('save',nii,[path,'img_ventilation_reconstruction.nii.gz'])
