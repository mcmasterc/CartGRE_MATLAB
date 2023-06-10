
function [Ventilation] = Load_VentRawData(MainInput)
% Initialize output variables
Ventilation.Image = [];
Ventilation.filename = [];
Ventilation.folder = [];


%% Load/Read Xenon data 

if strcmp(MainInput.XeDataext,'.mat') == 1 
%         DataFiles = dir([MainInput.XeDataLocation,'\*.mat']);
        file_name = MainInput.XeFileName;
        file_folder = MainInput.XeDataLocation;
%         file_with_path = strcat(file_folder,'\',file_name);  % join path and filename to open
        load(MainInput.XeFullPath);
        file_name2 = file_name; 
        file_name2(end-3:end)=[];                    
        Ventilation.Image = eval(file_name2);
        Ventilation.filename = file_name;
        Ventilation.folder = file_folder;       
   
elseif strcmp(MainInput.XeDataext,'.nii') == 1 || strcmp(MainInput.XeDataext,'.gz') == 1 
%         DataFiles = MainInput.XeDataLocation; 
%         if length(DataFiles) == 1
%             DataFiles = dir([MainInput.XeDataLocation,'\*.nii.gz']); 
%         else 
%            DataFiles = dir([MainInput.XeDataLocation,'\*.nii']); 
%         end     
        file_name = MainInput.XeFileName;
        file_folder = MainInput.XeDataLocation;
        A1 = LoadData.load_nii(MainInput.XeFullPath); % Original
        A=A1.img;
        if strcmp(MainInput.ImgOrientation,'Coronal') == 1
            gzfile_coronal = [3 1 2];
            A=permute(A,gzfile_coronal);
            A=rot90(A,2); 
        else
            A=imrotate(A,90);
            A=flip(A,2);
        end  
        A = double(squeeze(A));                     
        Ventilation.Image = A;
        Ventilation.filename = file_name;
        Ventilation.folder = file_folder;       
    
elseif strcmp(MainInput.XeDataext,'.data') == 1  
               
        [Image, file_folder, file_name] = ...
            Functions.LoadData_ListData_R590(MainInput.XeDataLocation,MainInput.ImageSize);
        Ventilation.Image = Image;
        Ventilation.filename = file_name;
        Ventilation.folder = file_folder;          
               
%--------------------- add new read load function here --------------------
% elseif strcmp(MainInput.XeDataType,'add DataType') == 1
%     if strcmp(MainInput.AnalysisType,'Ventilation') == 1                 
%       %  add load/read function here 
%     elseif strcmp(MainInput.AnalysisType,'Diffusion') == 1 
%       %  add load/read function here
%     elseif strcmp(MainInput.AnalysisType,'GasExchange') == 1 
%       %  add load/read function here  
%     end    
end 




close all;
end