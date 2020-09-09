% Code for plotting the 3 spectral data within NetCDF files from inpainting

% State the folder which the data resides
dataFolder = '/'

% Create a list of all the NetCDF file within the stated folder
ncfiles = fullfile(dataFolder, '**/*.nc');
theFiles = dir(ncfiles);

%ncid = netcdf.open('/depot/rtanama/users/masel/VORTEX-SE/data/2016/nc/0314/S20160314T030010.nc')

% Loop for running through each of the files
%for k = 1:length(theFiles)
    baseFileName = theFiles(7).name;    % Get name of the file
    fullFileName = fullfile(dataFolder, baseFileName);  % File with path
    ncid = netcdf.open(fullFileName);   % Open the Netcdf file
    %status = mkdir(baseFileName) 
    sf_var = netcdf.getVar(ncid,4)/10;     % Extract sf variable
    sff_var = netcdf.getVar(ncid,6)/10;    % Extract sff variable
%    sfp_var = netcdf.getVar(ncid,11)/10;   % Extract sfp variable
    [d1,d2,d3] = size(sf_var);             % Get values of the dimesions
    
    % Loop to run through every 10th time step and plot sf, sff, and sfp
   for m = 1:10:d3
        sf = flipud(sf_var(:,:,m).');
        sff = flipud(sff_var(:,:,m).');
%        sfp = flipud(sfp_var(:,:,m).');
        
        f = figure('Visible','off')
        subplot(1,2,1), imshow(sf,[-50 50]);
        colormap(subplot(1,2,1), parula)
        title('Raw');
        subplot(1,2,2), imshow(sff,[-50 50]);
        colormap(subplot(1,2,2), parula)
        title('Median Filtered');
%        subplot(1,3,3), imshow(sfp,[-50 50]);
%        colormap(subplot(1,3,3), parula)
%        title('Inpainted');
%        colormap(f,'parula')
        %saveas(f,sprintf(sprintf('/depot/rtanama/users/masel/VORTEX-SE/data/2016/0307/',baseFileName),'/FIG%d.png',m));
        saveas(f,sprintf('FIG%d.png',m));
    end
%end
    
%ncdisp('/depot/rtanama/users/masel/VORTEX-SE/data/2016/nc/0314/S20160314T030010.nc')