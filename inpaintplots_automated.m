% Driver for running inpainting method on spectrum data

clear all     % Clear workspace before running code

% State the folder which the data resides
dataFolder = '/depot/rtanama/share/VORTEX-SE/2016/data/radar/umassfmcw/nc_inpaint/0310/'

% Create a list of all the NetCDF file within the stated folder
ncfiles = fullfile(dataFolder, '**/*.nc');
theFiles = dir(ncfiles);

% Loop for running through each of the files
for i = 1:length(theFiles)
    baseFileName = theFiles(i).name;    % Get name of the file
    fullFileName = fullfile(dataFolder, baseFileName);  % File with path
    ncid = netcdf.open(fullFileName);   % Open the Netcdf file
    var_sf = netcdf.getVar(ncid,4,'double')/10;    % Extract sf variable
    var_sff = netcdf.getVar(ncid,6,'double')/10;   % Extract sff variable
    var_sfp = netcdf.getVar(ncid,11,'double')/10;   % Extract sfp variable
    [d1,d2,d3] = size(var_sf);             % Get values of the dimesions
    
    % Make folder for each of the files within the folder.
    [path,file,ext] = fileparts(fullFileName);   % Get file name w/out extention
    mkdir(sprintf('%s%s',dataFolder,file))

    % Loop to run through each  time step for the sf variable in the file
    for j = 1:10:d3
        rawsf = var_sf(:,:,j);          % Chose the time step
        sf = flipud(rawsf.');                   % Transpose the matrix
        rawsff = var_sff(:,:,j);        % Chose the time step
        sff = flipud(rawsff.');                % Transpose the matrix
        rawsfp = var_sfp(:,:,j);        % Chose the time step
        sfp = flipud(rawsfp.');
        
        f = figure('Visible','off')
        subplot(1,3,1), imshow(sf,[-50 50]);
        colormap(subplot(1,3,1), parula)
        title('Raw');
        subplot(1,3,2), imshow(sff,[-50 50]);
        colormap(subplot(1,3,2), parula)
        title('Median Filtered');
        subplot(1,3,3), imshow(sfp,[-50 50]);
        colormap(subplot(1,3,3), parula)
        title('In-painted');
        
        
        % Save each figure in the designated folder for the file.
        saveas(f,sprintf('%s%s/%s_%d.png',dataFolder,file,file,j));
        
    end
    netcdf.close(ncid)
end