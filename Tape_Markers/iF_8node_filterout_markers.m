function [BW, B]=iF_8node_filterout_markers(I,illum, bottom_strip, top_strip, left_strip, right_strip, min_area_rat, max_area_rat, shape_error_tol)


BW = im2bw(I,illum);
BW_filled = imfill(BW,'holes');
boundaries = bwboundaries(BW_filled);
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
indProperMarkers1=find(mcent(:,2)>size(BW,1)*bottom_strip&mcent(:,2)<size(BW,1)*top_strip&mcent(:,1)>size(BW,2)*left_strip&mcent(:,1)<size(BW,2)*right_strip);
% Remove areas that are too small or too big
indProperMarkers2=find(MA>BW_area*min_area_rat&MA<BW_area*max_area_rat);
% Remove areas that are not square-like
mbb0=struct2cell(marker_boundingbox);
mbb=cat(1,mbb0{:});
mbb_rat=mbb(:,3)./mbb(:,4); % width to height ratio of the bounding boxes
indProperMarkers3=find(mbb_rat<1+shape_error_tol&mbb_rat>1-shape_error_tol);
indProperMarkers3=intersect(indProperMarkers1,indProperMarkers2');
B=[];
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