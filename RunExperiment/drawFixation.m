function drawFixation(windowPtr,center,color,size)

% Always draws on back of flipcard, when flip is called, will be shown
% NOTE: make this a jpeg and use MAKETEXTURE so that it returns a pointer
% and then just call that pointer with DRAWTEXTURE along with whatever is
% should be shown. Actually don't do this -- if speed is important, just
% draw two separate rectangles

centerX = center(3);
centerY = center(4);

Screen('FillRect', windowPtr, color, [centerX/2-size/2 centerY/2-size/2 centerX/2+size/2 centerY/2+size/2]); % draws horizontal bar
Screen('FillRect', windowPtr, color, [centerX/2-size/2 centerY/2-size/2 centerX/2+size/2 centerY/2+size/2]); % draws vertical bar
