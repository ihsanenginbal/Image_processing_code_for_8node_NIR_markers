function [Markers, geom_flag, avg_error]=iF_8node_geom_check(BW,B,LL_for_diagonals_real, error_margin)


% Assume and implement this marker order:
% Marker1    Marker2     Marker3     Marker4
%
%
%
% Marker5    Marker6     Marker7     Marker8

Markers=0;
avg_error=0;
geom_flag=1;  % If 1, then the detected markers make sense

for zz=1:8
    cnt0=regionprops(BW,'Centroid');
    cent0(zz,1)=cnt0(B(zz)).Centroid(1);
    cent0(zz,2)=cnt0(B(zz)).Centroid(2);
end

% find the centroid of all 8 markers (of the entire group)
G_cent(1)=mean(cent0(:,1));
G_cent(2)=mean(cent0(:,2));

% Find the markers on the left side
left_markers=find(cent0(:,1)<G_cent(1));
left_marker_nums=B(left_markers);

% Find the markers on the right side
right_markers=find(cent0(:,1)>G_cent(1));
right_marker_nums=B(right_markers);

% Find the markers on the bottom side
bottom_markers=find(cent0(:,2)>G_cent(2));
bottom_marker_nums=B(bottom_markers);

% Find the markers on the top side
top_markers=find(cent0(:,2)<G_cent(2));
top_marker_nums=B(top_markers);

% Do the first geometry check, 2 marker per quadrant
if size(left_markers,1)==4&&size(right_markers,1)==4&&size(top_markers,1)==4&&size(bottom_markers,1)==4
    geom_flag=1;
else
    geom_flag=0;
end

% ------------------------------------------------------------------
% Find the centroid of left and right marker groups
G_left(1)=mean(cent0(left_markers,1));
G_left(2)=mean(cent0(left_markers,2));

G_right(1)=mean(cent0(right_markers,1));
G_right(2)=mean(cent0(right_markers,2));

% Detect each marker's location
if geom_flag==1
    % Run if there is at least and only one marker fitting in the geometric description
    Marker1_zind=find(cent0(:,1)<G_left(1)&cent0(:,2)<G_cent(2));
    if isempty(Marker1_zind)==0&&geom_flag==1&&size(Marker1_zind,1)==1
        Markers(1,1)=cent0(Marker1_zind,1);
        Markers(1,2)=cent0(Marker1_zind,2);
    else
        geom_flag=0;
    end
    
    Marker2_zind=find(cent0(:,1)>G_left(1)&cent0(:,1)<G_cent(1)&cent0(:,2)<G_cent(2));
    if isempty(Marker2_zind)==0&&geom_flag==1&&size(Marker2_zind,1)==1
        Markers(2,1)=cent0(Marker2_zind,1);
        Markers(2,2)=cent0(Marker2_zind,2);
    else
        geom_flag=0;
    end
    
    Marker3_zind=find(cent0(:,1)<G_right(1)&cent0(:,1)>G_cent(1)&cent0(:,2)<G_cent(2));
    if isempty(Marker3_zind)==0&&geom_flag==1&&size(Marker3_zind,1)==1
        Markers(3,1)=cent0(Marker3_zind,1);
        Markers(3,2)=cent0(Marker3_zind,2);
    else
        geom_flag=0;
    end
    
    Marker4_zind=find(cent0(:,1)>G_right(1)&cent0(:,2)<G_cent(2));
    if isempty(Marker4_zind)==0&&geom_flag==1&&size(Marker4_zind,1)==1
        Markers(4,1)=cent0(Marker4_zind,1);
        Markers(4,2)=cent0(Marker4_zind,2);
    else
        geom_flag=0;
    end
    
    Marker5_zind=find(cent0(:,1)<G_left(1)&cent0(:,2)>G_cent(2));
    if isempty(Marker5_zind)==0&&geom_flag==1&&size(Marker5_zind,1)==1
        Markers(5,1)=cent0(Marker5_zind,1);
        Markers(5,2)=cent0(Marker5_zind,2);
    else
        geom_flag=0;
    end
    
    Marker6_zind=find(cent0(:,1)>G_left(1)&cent0(:,1)<G_cent(1)&cent0(:,2)>G_cent(2));
    if isempty(Marker6_zind)==0&&geom_flag==1&&size(Marker6_zind,1)==1
        Markers(6,1)=cent0(Marker6_zind,1);
        Markers(6,2)=cent0(Marker6_zind,2);
    else
        geom_flag=0;
    end
    
    Marker7_zind=find(cent0(:,1)<G_right(1)&cent0(:,1)>G_cent(1)&cent0(:,2)>G_cent(2));
    if isempty(Marker7_zind)==0&&geom_flag==1&&size(Marker7_zind,1)==1
        Markers(7,1)=cent0(Marker7_zind,1);
        Markers(7,2)=cent0(Marker7_zind,2);
    else
        geom_flag=0;
    end
    
    Marker8_zind=find(cent0(:,1)>G_right(1)&cent0(:,2)>G_cent(2));
    if isempty(Marker8_zind)==0&&geom_flag==1&&size(Marker8_zind,1)==1
        Markers(8,1)=cent0(Marker8_zind,1);
        Markers(8,2)=cent0(Marker8_zind,2);
    else
        geom_flag=0;
    end
    
    % Check the geometry
    first_check_points=[5 6 7 8];
    second_check_points=[2 1 4 3];
    
    if geom_flag==1
        % Find the 4 diagonal lengths
        for chk=1:4
            p1=first_check_points(chk);
            p2=second_check_points(chk);
            
            Lx=(Markers(p1,1)-Markers(p2,1));
            Ly=(Markers(p1,2)-Markers(p2,2));
            LL_estimated(chk)=(Lx^2+Ly^2)^0.5;
        end
        
        
        % Find the two diagonal ratios
        % LL52 / LL61
        LL_ratio_estimated(1)=LL_estimated(1)/LL_estimated(2);
        % LL74 / LL83
        LL_ratio_estimated(2)=LL_estimated(3)/LL_estimated(4);
        
        % Compare with the real diagonal ratios
        actual_ratio1=LL_for_diagonals_real(1)/LL_for_diagonals_real(2);
        actual_ratio2=LL_for_diagonals_real(3)/LL_for_diagonals_real(4);
        check1=abs((actual_ratio1-LL_ratio_estimated(1)))/actual_ratio1;
        check2=abs((actual_ratio2-LL_ratio_estimated(2)))/actual_ratio2;
        
    end
    
    % If the ratio of the two diagonals in the two markers groups are different
    % than the actual ratios, beyond the error margin, then raise the geometry
    % flag
    if geom_flag==1&&check1<error_margin&&check2<error_margin
        geom_flag=1;
    else
        geom_flag=0;
    end
    
    if geom_flag==1
        avg_error=(check1+check2)/2;
    end
    
end











