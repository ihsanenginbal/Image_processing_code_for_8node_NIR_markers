function [geom_flag, bestI, best_illum]=iF_iterate_illumination(I, maxit, markit_step, LL_for_diagonals_real, error_margin)


% Run 9 different illumination factors
for markit=1:maxit
    
    markit
    
    illum=(1-(maxit+1)*markit_step)+markit_step*markit;
    % Convert the image to binary
    BW = im2bw(I,illum);
    % Find the filled in regions
    BW_filled = imfill(BW,'holes');
    % Create boundaries
    boundaries = bwboundaries(BW_filled);
    
    % Don't run for case with too many boundaries
    if size(boundaries,1)<30000
        % Find our 8 markers
        marker_areas=regionprops(BW,'Area');
        marker_centroids=regionprops(BW,'Centroid');
        marker_boundingbox=regionprops(BW,'BoundingBox');
        MA=[marker_areas.Area];
        % Get the centorid coordinates into and array
        mcent0=struct2cell(marker_centroids);
        mcent=cat(1,mcent0{:});
        % Get the picture size in pixels
        BW_area=size(BW,1)*size(BW,2);
        % Remove areas from the quarters from each edge
        indProperMarkers1=find(mcent(:,2)>size(BW,1)/4&mcent(:,2)<size(BW,1)*3/4&mcent(:,1)>size(BW,2)/4&mcent(:,1)<size(BW,2)*3/4);
        % Remove areas that are too small or too big
        indProperMarkers2=find(MA>BW_area*0.00007&MA<BW_area*0.005);
        % Remove areas that are not square-like
        indProperMarkers3=intersect(indProperMarkers1,indProperMarkers2');
        B=[];
        if sum(indProperMarkers3)>0
            for rmv=1:size(indProperMarkers3,1)
                filtered_marker_index=indProperMarkers3(rmv);
                filtered_marker_area=MA(filtered_marker_index);
                filtered_boundingbox_width=marker_boundingbox(filtered_marker_index).BoundingBox(3);
                filtered_boundingbox_height=marker_boundingbox(filtered_marker_index).BoundingBox(4);
                filtered_boundingbox_aspect=filtered_boundingbox_width/filtered_boundingbox_height;
                if filtered_boundingbox_aspect<1.1&&filtered_boundingbox_aspect>0.9
                    B=vertcat(B, indProperMarkers3(rmv));
                end
            end
        end
        % Get the selected marker indices
        % B=intersect(indProperMarkers3,indProperMarkers4);
        
        % Find the centroids of the 8 markers
        avg_error=zeros(1,9);
        if size(B,1)==8
            [Markers, geom_flag(markit), avg_error(markit)]=iF_8node_geom_check(BW,B,LL_for_diagonals_real, error_margin);
        else
            geom_flag(markit)=0;
        end
        
    else
        geom_flag(markit)=0;
    end
    
end

if sum(geom_flag)>0&&sum(avg_error)>0
    geomflag1=find(geom_flag==1&avg_error>0);
    [bestV bestind]=min(avg_error(geomflag1));
    bestI=geomflag1(bestind);
    best_illum=(1-(maxit+1)*markit_step)+markit_step*bestI;
else
    geom_flag=[];
    bestI=[];
    best_illum=[];
end