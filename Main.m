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
% * The directory should contain the .dat and the .list files,
% * it should have a descriptive name (e.g.
% reverse-date-of-scan_subject-ID_axial-or-coronal-orientation, if
% possible), 
% * 