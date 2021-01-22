% Use the left group of markers because they form a more correct square



function xf1=iF_8node_leftsqr_orthophoto(I0, Markers, pplot, pictitle)

% Get the row and the 
r=[Markers(5,2) Markers(6,2) Markers(2,2) Markers(1,2)]';
c=[Markers(5,1) Markers(6,1) Markers(2,1) Markers(1,1)]';
% Find the average pixel length of the base square
avgpx=(abs(Markers(5,1)-Markers(6,1))+abs(Markers(2,1)-Markers(1,1))+abs(Markers(5,2)-Markers(1,2))+abs(Markers(6,2)-Markers(2,2)))/4;
base=[0 1; 1 1; 1 0; 0 0].*avgpx;
% Make the projection transformation
tf=fitgeotrans([c r], base, 'projective');
T=tf.T;
[xf1, xf1_ref]=imwarp(I0, tf);
% Normalize the base scale to better approximate the original
% picture pixel dimensions
corr2=(size(xf1,1)/size(I0,1)+size(xf1,2)/size(I0,2))/2;
% Redo the projection correction process with the normalized scale
% factor to match the pixel dimensions of the original image
% Use the left group of markers because they form a more correct square
r=[Markers(5,2) Markers(6,2) Markers(2,2) Markers(1,2)]';
c=[Markers(5,1) Markers(6,1) Markers(2,1) Markers(1,1)]';
% Find the average pixel length of the base square
avgpx=(abs(Markers(5,1)-Markers(6,1))+abs(Markers(2,1)-Markers(1,1))+abs(Markers(5,2)-Markers(1,2))+abs(Markers(6,2)-Markers(2,2)))/4;
base=[0 1; 1 1; 1 0; 0 0].*avgpx/corr2;
% Make the projection transformation
tf=fitgeotrans([c r], base, 'projective');
T=tf.T;
[xf1, xf1_ref]=imwarp(I0, tf);
if pplot==1
    % Plot the corrected figure for manual check
    figure
    imshow(xf1)
    title(pictitle)
end

end