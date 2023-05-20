%%%%%% Cartesian Data Manual Reconstruction version CBM %%%%%%%%%%%%%%%%%%%
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
ImgOrientation = 'Coronal'; % just choose coronal or axial by commenting/uncommenting
%ImgOrientation = 'Axial';
MainInput.ScannerSoftware = '5.9.0';

[filename, path] = uigetfile('*.*','Select .data file for the cartesian ventilation');
MainInput.XeFullPath = [path,filename];
MainInput.XeDataLocation = path(1:end-1);
[~,~,xe_ext] = fileparts([path, filename]);
MainInput.XeFileName = filename;
MainInput.XeDataext = xe_ext;
MainInput.ImgOrientation = ImgOrientation;

Ventilation = Functions.LoadReadData_VentDataList(MainInput);
orthosliceViewer(Ventilation.Image)