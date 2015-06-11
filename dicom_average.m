%creates female tibia model
%creates an average model from several dicom images
%Written by: Leela Goel
%May 2015

clear all
close all
clc

%%
% Defines all files for analysis

srcFiles = dir('C:\your\file\path\here\*.dcm');  % the folder in which ur images exists

for i = 1 : length(srcFiles)
    filename = strcat('C:\your\file\path\here\',srcFiles(i).name); %calls files
    
    %loads MRI
    I = dicomread(filename); %enters MRI

    %displays MRI
    figure
    imshow(I)
    imcontrast

    %selects regiono f interest
    %h = imfreehand;
    h = impoly; %may use imfreehand instead
    M = ~h.createMask();
    N = h.createMask();
    
    %makes image where properties are measured from
    I_props = I;
    I_props(M) = 0; %puts zeros outside of region of interest
    I_props(N) = 1;
    
    %calculates centroid, major/minor axis, and perimeter of region of
    %interest
    fig_props = regionprops(I_props, 'centroid', 'MajorAxisLength', 'MinorAxisLength', 'Perimeter');
    centroids = cat(1, fig_props.Centroid);
    
    %displays figure to be cropped with centroid marked
    figure
    I(M) =  0; %puts zeros outside of region of interest
    imshow(I); imcontrast
    hold on
    plot(centroids(:,1), centroids(:,2), 'b*')
    hold off
    
    %adds box
    box_size = 70;
    b = imrect(gca,[(centroids(1)-(box_size/2)) (centroids(2)-box_size/2) box_size box_size]); %defines aspect ratio of box
    position = wait(b); % returns coordinates in "position" when user doubleclicks on rectangle
    tib_final = imcrop(I,position); %crops image to region of interest
    
    %saves slice
    model_name = input('enter file name:  ', 's'); %enters name of file from user
    dicomwrite(tib_final, strcat(model_name, '.dcm')) %exports dicom
    imwrite(avg_tib, strcat(model_name, '.tif')) %exports tiff
    savefig(avg_tib_fig, model_name) %exports matlab figure
    
    if i == 1
        img_sums = tib_final; %initializes tibia model
    end
        img_sums = img_sums + tib_final; %adds subsequent tibias to same image    

end

%displays added tibia "stack"
figure
imshow(img_sums)
imcontrast

%%
%Averages images together
avg_tib = img_sums * (1 /length(srcFiles));

%displays average tibia
avg_tib_fig = figure
imshow(avg_tib)
imcontrast

%saves tibia model
model_name = input('enter file name:  ', 's'); %enters name of file from user
dicomwrite(avg_tib, strcat(model_name, '.dcm')) %exports dicom
imwrite(avg_tib, strcat(model_name, '.tif')) %exports tiff
savefig(avg_tib_fig, model_name) %exports matlab figure
