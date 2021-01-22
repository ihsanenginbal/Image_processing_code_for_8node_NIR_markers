% Script for DIC (Digital Image Processing) of 8-node rectangular 
% marker configuration for Painted Markers.
% Coded by Dr. Ihsan Engin BAL
% Professor in Earthquake Resistant Structures
% Hanze University of Applied Sciences, Groningen, Netherlands
% v9.0 / January 2021
% i.e.bal@pl.hanze.nl / iebal@icloud.com


% LICENSING ---------------------------------------------------------------
% Information in this code is free. Please use this code as you please, 
% improve it, change it, do what you like. But do not forget to cite our paper:
% <<< Bal I.E., Dais D., Smyrou E. and Sarhosis V., 2021, 'Novel invisible markers 
% for monitoring cracked masonry structures', Construction and Building
% Materials, Special Issue on Structural Health Monitoring and NDT for
% Masonry Structures, DOI:to-come-later-paper-in-review.>>>

clear all
clc



% 8-node marker set with two groups of markers on both sides of a crack
% Marker configuration and numbering:

% 1        2              3         4
%
%
%
%
% 5        6              7         8

% Marker-to-marker distances (mm) measured on-site
first_points=[1 3 5 7 5 6 7 8 5 6 7 8];
second_points=[2 4 6 8 1 2 3 4 2 1 4 3];
LL_real=[30 30 30 30 30 30 30 30 42.43 42.43 42.43 42.43];

maxit=9;    % Maximum number of iterations for finding the correct illumination factor
markit_step=0.05;  % Iteration step
error_margin=0.12;   % Error margin of calculated lengths

pplot=1;   % 1: plot the corrected orthophot, 0: do not plot

% Count only the images satisfaying the error margin
counter=0;

% Limits to look into a frame on the image when searching the markers
bottom_strip=1/4;
top_strip=3/4;
left_strip=1/4;
right_strip=3/4;

% Limits for marker area ratios in searching the markers
min_area_rat=0.00005;   % minimum acceptable ratio of a marker area to the picture area
max_area_rat=0.005;     % max acceptable ratio of a marker area to the picture area

% Tolerance of error of square bounding box when searching for the markers
shape_error_tol=0.02;

% 4 diagonal lengths for each marker group, in mm, for geomerty check
LL_for_diagonals_real=LL_real(end-3:end);

% Names of the folders where the images are stored
folder_names={'Set1_0.00mm', 'Set2_0.25mm', 'Set3_0.53mm', 'Set4_1.18mm',...
    'Set5_1.91mm', 'Set6_2.59mm', 'Set7_3.70mm', 'Set8_5.04mm', };

% F values of photographs stored in each folder
fval=[10 10 10 10 10 10 10 10];

% ISO values of photographs stored in each folder
isoval=[1000 1000 1000 1000 1000 1000 1000 1000 1000 1000 ];

ptitle={'Set 1 - No Seperation', 'Set 2 - 0.25mm Seperation', 'Set 3 - 0.53mm Seperation',...
    'Set 4 - 1.18mm Seperation', 'Set 5 - 1.91mm Seperation',...
    'Set 6 - 2.59m Seperation', 'Set 7 - 3.70m Seperation', 'Set 8 - 5.04m Seperation'};

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for fld=1:size(folder_names,2)
%    for fld=4:4
    
    % Detect each .jpg file in each folder
    % Run as many as the number of jps images
    list=dir(strcat(folder_names{fld}, '/*.jpg'));
    
    for pictfl=1:size(list,1)
    %    for pictfl=4:12
        pictfl
        
        % Read the image
        I0 = imread(strcat(folder_names{fld},'/',list(pictfl).name));
        
        % Iterate illumination factor to find the best factor
        [geom_flag, bestI, best_illum]=iF_iterate_illumination(I0, maxit, markit_step, LL_for_diagonals_real, error_margin);
        
        % Now use the best illimunation factor and proceed
        % Check if the geometry of the found markers is proper
        if exist('bestI','var')&&size(bestI,1)>0&&size(best_illum,1)>0
            
            if geom_flag(bestI)==1   %If the geometry flag is 1 (i.e. if the geomerty of the markers found is proper)
                counter=counter+1;  % Number of images with acceptable error
                
                % Assign other information for this photo
                FVAL(counter)=fval(fld);
                ISOVAL(counter)=isoval(fld);
                nname=list(pictfl).name;
                DISTANCEVAL(counter)=str2num(nname(1:3));
                
                % Title for the plots to be produced
                pictitle=list(pictfl).name;
                
                % Filter out 8 markers
                [BW, B]=iF_8node_filterout_markers(I0,best_illum, bottom_strip, top_strip, left_strip, right_strip, min_area_rat, max_area_rat, shape_error_tol);
                
                % Calculate the coordinates of the 8 markers
                [Markers, ~, ~]=iF_8node_geom_check(BW,B,LL_for_diagonals_real, error_margin);
                
                if size(Markers,1)==8
                % Make a projection correction and produce the orthophoto based on the estimated marker positions
                I=iF_8node_leftsqr_orthophoto(I0, Markers, pplot, pictitle);
                
                % Filter out 8 markers again, now from the orthophoto
                [BW, B]=iF_8node_filterout_markers(I,best_illum, bottom_strip, top_strip, left_strip, right_strip, min_area_rat, max_area_rat, shape_error_tol);
                
                % Re-calculate the coordinates of the 8 markers from the orthophoto
                [Markers, ~, avg_error]=iF_8node_geom_check(BW,B,LL_for_diagonals_real, error_margin);
                
                    if pplot==1
                    figure()
                    imshow(BW)
                end
                    
                    %% Plot all the markers
                    for mrkr=1:8
                        mrkr
                        
                        % Find marker centroids
                        cnt=regionprops(BW,'Centroid');
                        % Get centroid coordinates
                        cent(B(mrkr),1)=cnt(B(mrkr)).Centroid(1);
                        cent(B(mrkr),2)=cnt(B(mrkr)).Centroid(2);
                        
                        % Plor marker centroids and marker group centroids
                        hold on
                        plot(cent(B(mrkr),1),cent(B(mrkr),2),'rx')
                        hold on
                        title(pictitle)
                        % Find the centroid of each marker group
                        cc_left1=(Markers(1,1)+Markers(2,1)+Markers(5,1)+Markers(6,1))/4;
                        cc_left2=(Markers(1,2)+Markers(2,2)+Markers(5,2)+Markers(6,2))/4;
                        cc_right1=(Markers(3,1)+Markers(4,1)+Markers(7,1)+Markers(8,1))/4;
                        cc_right2=(Markers(3,2)+Markers(4,2)+Markers(7,2)+Markers(8,2))/4;
                        hold on
                        plot(cc_left1, cc_left2, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y')
                        hold on
                        plot(cc_right1, cc_right2, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y')
                        
                        % Find pixel to mm relation for this image
                        for pt=1:size(LL_real,2)
                            
                            p1=first_points(pt);
                            p2=second_points(pt);
                            
                            Lx=(Markers(p1,1)-Markers(p2,1));
                            Ly=(Markers(p1,2)-Markers(p2,2));
                            LL(pt)=(Lx^2+Ly^2)^0.5;
                            
                        end
                        
                    end
                    pix2mm(counter)=mean(LL_real./LL);
                    LL_estimated(counter,:)=pix2mm(counter).*LL;
                    
                    % Get the flash power
                    fp1=str2num(nname(6));
                    fp2=str2num(nname(8));
                    fp3=str2num(nname(10:12));
                    % Find the flash power
                    fp(counter)=fp1/fp2-(fp1/(2*fp2))*fp3;
                    
                    fld_name_trns=folder_names{fld};
                    OutData{counter}.Seperation=str2num(fld_name_trns(6:9));
                    OutData{counter}.MarkerCoord1=Markers(:,1);
                    OutData{counter}.MarkerCoord2=Markers(:,2);
                    OutData{counter}.ISOval=ISOVAL(counter);
                    OutData{counter}.Fval=FVAL(counter);
                    OutData{counter}.Distanceval=DISTANCEVAL(counter);
                    OutData{counter}.FlashPower=fp(counter);
                    OutData{counter}.Pixeltomm=pix2mm(counter);
                    OutData{counter}.AverageError=avg_error;
                    
                else
                    % If markers are found and they are OK in the un-corrected
                    % (i.e. project correction) photo, but then they are not OK
                    % in the corrected orthophoto, we need to remove back the
                    % 1 step increase of the counter, because this is not a
                    % valid image anymore
                    counter=counter-1;
                end
                
            end
            
        end
        
    end
    
end


    % Save the output file
    save 'OutData_paint_markers.mat' OutData
