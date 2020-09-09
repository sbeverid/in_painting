%%%% Driver for running inpainting method on spectrum data %%%%

clear all      % Clear workspace before running code

% State the folder which the data resides
dataFolder = '/depot/rtanama/share/VORTEX-SE/2016/data/radar/umassfmcw/nc_inpaint/0314/'

% Create a list of all the NetCDF file within the stated folder
ncfiles = fullfile(dataFolder, '**/*.nc');
theFiles = dir(ncfiles);

% Loop for running through each of the files
for i = 1:length(theFiles)
    clearvars baseFileName fullFillName ncid sf d1 d2 d3 finfo    % Clear variables associated with specific file
    
    sf_clean = [];                      % Empty variable for each file
    
    baseFileName = theFiles(i).name;    % Get name of the file
    fullFileName = fullfile(dataFolder, baseFileName);  % File with path
    
    ncid = netcdf.open(fullFileName);   % Open the Netcdf file
    
    finfo = ncinfo(fullFileName);       % Get quick details of NetCDF file
    
    % If statement to test if the 12th variable (or sfp in this case)
    % exists, if not continue with inpainting.
    if length(finfo.Variables) < 12
    
        sf = netcdf.getVar(ncid,4,'double')/10;    % Extract sf variable (variable numbering starts at 0, so 4 is 5th varible in file)
        [d1,d2,d3] = size(sf);             % Get values of the dimesio

        % Ensures there is data to be run
        if d1~=0 && d2~=0

            % Loop to run through each  time step for the sf variable in the file
            for j = 1:d3
                clearvars rawData data output inpaint inpaint10      % Clear variables specific to time step
                rawData = sf(:,:,j);       % Chose the time spet
                data = rawData.';           % Transpose the matrix

                [output] = rtanamachi_driver(data);   % Run data through inpainting

                inpaint = output.';           % Transpose output to original size
                inpaint10 = inpaint*10;         % Multiply the output by 10 to match sf

                sf_clean = cat(3,sf_clean,inpaint10); % Recontruct 3D matrix
            end

            % Create new variable, write in new variable, and add attributes
             nccreate(fullFileName, 'sfp', 'Datatype', 'int16', 'Format', 'classic', 'Dimensions', {'vels',256,'gate',1024,'time',d3});
             ncwrite(fullFileName, 'sfp', sf_clean);    
             ncwriteatt(fullFileName, 'sfp', 'Name', 'Clean Raw Spectral Power');
             ncwriteatt(fullFileName, 'sfp', 'Units', 'dB(uncalibrated) x10');
             netcdf.close(ncid)              % Close the file
        end
    end
end

% Send email when complete...everything in place to use Purdue email system
setpref('Internet','SMTP_Server','smtp.purdue.edu');
setpref('Internet','E_mail','EMAIL@purdue.edu');
setpref('Internet','SMTP_Username','EMAIL@purdue.edu');
setpref('Internet','SMTP_Password','PASSWORD');
sendmail('EMAIL@purdue.edu','Inpaint code finished','Inpaint code finished without error')




