function numDots = countDots(im)
%COUNTDOTS This function inputs an array, and outputs the number
%of dots.
im = rgb2gray(im);
im = imbinarize(im, 0.3);
im = imopen(im,strel('disk', 1));
im = imcomplement(im);
im = imopen(im,strel('disk',3));
[labels, numDots]=bwlabel(im);
end