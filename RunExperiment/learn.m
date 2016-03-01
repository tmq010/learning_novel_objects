function [IsQuit, performance] = learn(subjID, whichStimuli, whichFamily, sequentCode, learnRepeat,itemDurDefine,blankDur)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% command:
%% learn(subjID, whichStimuli, sequentCode)
%%
%% subjID: subject name (string)
%% whichStimuli: the number following 'axis' (6 or 12 now)
%% sequentCode: 1 for sequential display; 2 for nonsequential display.
%%
%% for example:
%% learn('tt', 6, 1)  % sequential display axis6
%% learn('tt', 12, 2)  % nonsequential display axis12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Screen('Preference', 'Verbosity', 1);
if nargin ~= 7
    error('Please input all the parameter for learning: subjID, whichStimuli, sequentCode');
end
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'VisualDebugLevel', 1);


AssertOpenGL; % check for Opengl compatibility, abort otherwise (to verify PTB3)
Screen('Preference', 'SkipSyncTests',1);


%% Experiment parameter
% itemDurDefine = 1/8;% 1/multistim; % Unit: second
% blankDur = 1/30; % duration of blank screen between learning stimuli; % Unit: second
whetherfix = 0; % whetherfix=1, have a fixation during trials; if ~=1, no fixation
firstFixationDurDefine = 0; % Unit: second
ISIDurDefine = 0.3; % Unit: second
% nonsequenInter = 4; %% the minimum interval between two nonsequential stimuli
itemsPerBlock = 7;
pixRect = [0 0 800 600];
maskRect = pixRect*0.7;
numBlocks = 4;
sKey = KbName('space');
escKey = KbName('ESCAPE');
rspKey = KbName('t');

rootDir = pwd;
fmt = 'jpg';

'endpoint1';

BeginTime=clock;
Filefix = [subjID, '_Learning', '_', num2str(BeginTime(1)),num2str(BeginTime(2),'%02d'), ...
    num2str(BeginTime(3),'%02d'), '_H', num2str(BeginTime(4), '%02d'),'M', num2str(BeginTime(5),'%02d'), '_axis', num2str(whichStimuli), '_', num2str(sequentCode)];

% Duration for each picture
itemDur =  itemDurDefine;

% Inter stimulus interval
ISIDur = ISIDurDefine;
% trialDur = itemDur + ISIDur;
firstFixationDur = firstFixationDurDefine;

% Initial screen
screens = Screen('Screens');
screenNumber = max(screens);
%screenNumber = 1;
screenRect  = Screen(screenNumber, 'rect');

stimuliDir = char([rootDir '/3DStim/axis' num2str(whichStimuli)]);
dataDir = char([rootDir, '/data/']);
maskDir = char([rootDir, '/3DStim/mask']);

IsQuit = 0;
'endpoint2';

try
    
    % Open a fullscreen window
    backgroundcolor= [186 186 186];
    [window, screenRect] = Screen('OpenWindow',screenNumber,backgroundcolor,screenRect);
    %refresh = Screen('GetFlipInterval', window);
    
    %% create enough offscreen windows for each picture in the experiment
    for i = 1:(itemsPerBlock)
        offScrPtr(i) = Screen('OpenOffscreenWindow',window,  [255 255 255], pixRect);
    end
    
    fixation = Screen('OpenOffscreenWindow',window, [186 186 186], pixRect);
    Screen('FillOval',fixation,  [255 255 255], CenterRect([0 0 12 12], pixRect));
    Screen( 'FillOval',fixation, [0 0 0], CenterRect([0 0 8 8], pixRect));
    maskPtr =  Screen('OpenOffscreenWindow',window,  [186 186 186], pixRect);
    
    
    
    cd(stimuliDir);
    StimuliFile = dir('*.jpg');
    [numitems junk] = size(StimuliFile);
    if numitems~=itemsPerBlock, error('Not the right number of items.'); end
    [itemlist{1:numitems}] = deal(StimuliFile.name);
    for theitem = 1:itemsPerBlock
        filename = itemlist{theitem};
        [imgArray] = imread(filename, fmt);
        offScrPtr(theitem)=Screen('MakeTexture',window, imgArray);
    end
    
    cd(maskDir);
    StimuliFile = dir('*.jpg');
    [numitems junk] = size(StimuliFile);
    [itemlist{1:numitems}] = deal(StimuliFile.name);
    
    filename = itemlist{1};
    [imgArray] = imread(filename, fmt);
    maskPtr=Screen('MakeTexture',window, imgArray);
    cd(rootDir);
    
    
    %  'endpoint3'
    theorder{1} = zeros(itemsPerBlock*2, numBlocks);
    theorder{2} = zeros(itemsPerBlock*2, numBlocks);
    theorder{3} = zeros(itemsPerBlock*2, numBlocks);
    theorder{4} = zeros(itemsPerBlock*2, numBlocks);
    for i = 1:numBlocks
        firstpict = 1;
        lastpict = itemsPerBlock;
        interpict = [2:(itemsPerBlock-1)]';
        switch sequentCode
            case 1 % sequential
                thelist = [firstpict;interpict;lastpict];
            case 2 % nonsequential
                thelist = randperm(itemsPerBlock);
        end
        theorder{1}(1:itemsPerBlock, i) = thelist;
        theorder{1}(itemsPerBlock+1:itemsPerBlock*2, i) = flipud(thelist);
    end
    
    for i = 1:numBlocks
        firstpict = 1;
        lastpict = itemsPerBlock;
        interpict = [(itemsPerBlock-1):-1:2]';
        switch sequentCode
            case 1 % sequential
                thelist = [lastpict;interpict;firstpict];
            case 2 % nonsequential
                thelist = randperm(itemsPerBlock);
        end
        theorder{2}(1:itemsPerBlock, i) = thelist;
        theorder{2}(itemsPerBlock+1:itemsPerBlock*2, i) = flipud(thelist);
    end
    
    theorder{3} = theorder{1};
    theorder{4} = theorder{2};
    
    changeInterval=5;
    %defining fixation color change parameter. numBlocks*itemsPerBlock*2
    fcoloridx = zeros(1,numBlocks*itemsPerBlock*2);
    for changes = 1:1:floor(numBlocks*itemsPerBlock*2/changeInterval)-1 % how many changes there are in a learning session
        changepoint(changes) = randperm(changeInterval,1)+(changes-1)*changeInterval; % randomly choose the change point with the constraint of 8 images
    end
    changpoint(floor(numBlocks*itemsPerBlock*2/changeInterval)) = randperm(2,1)+(floor(numBlocks*itemsPerBlock*2/changeInterval)-1)*changeInterval;
    % last color change shouldn't be within the last three images of a
    % block
    
    for i=1:size(changepoint,2)-1
        if (i/2==round(i/2))==0
            fcoloridx(changepoint(i):changepoint(i+1)-1)=ones(1,changepoint(i+1)-changepoint(i));
            % indexing the color -- 0 is red, 1 is green
        end
    end
    
    responses = zeros(1,numBlocks*itemsPerBlock*2);
    
    
    'endpoint5';
    
    %% start display
    HideCursor;
    %% Cue word to remind task
    Screen('TextSize',window,30);
    Screen('TextFont',window,'Arial');
    Screen('TextStyle', window ,1);
    Screen('DrawText',window,'You will see different views of an object, pay attention to the object while doing the fixation task.',(screenRect(3)/2-700),screenRect(4)/2-80);
    Screen('DrawText',window,'Fixation task is to press "t" whenever there is a color change.',(screenRect(3)/2-700),screenRect(4)/2-80);
    Screen('DrawText',window, ['Now we will start the learning phase of Object' num2str(whichFamily) '. Press space key when you are ready.'],(screenRect(3)/2-600),screenRect(4)/2-34);
    %	Screen('CopyWindow', fixation, window, [], CenterRect(pixRect, screenRect));
    Screen('Flip',window);
    
    while KbCheck, end;
    while 1
        [keyIsDown,secs,keyCode] = KbCheck;
        if keyIsDown && keyCode(sKey)
            break; % start only when start key is pressed
        elseif keyIsDown && keyCode(escKey)
            IsQuit=1;
            break;
        end
    end
    'endpoint6';
    experimentStart = GetSecs;
    
    for theBlock = 1:numBlocks
        startTime = GetSecs;
        while ~IsQuit && ((GetSecs - startTime)<firstFixationDur)
            [keyIsDown,secs,keyCode] = KbCheck;
            if keyIsDown && keyCode(escKey),
                IsQuit=1;
                break;
            end
        end
        'endpoint7';
        
        
        
        for i = 1:itemsPerBlock*2
            endpointtest(i,1) = GetSecs;
            presStart = GetSecs;
            
            fixsize = 90; % size of the fixation circle
            alpha = 50; % how transparent the fixation circle is
            % display learning images
            thepic = theorder{learnRepeat}(i, theBlock);
            Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
            
            Screen('DrawTexture', window, offScrPtr(thepic), [], CenterRect(pixRect, screenRect));
            if fcoloridx(i+itemsPerBlock*2*(theBlock-1)) == 0
                Screen('fillOval', window, [255,0,0,alpha], [screenRect(3)/2-fixsize screenRect(4)/2-fixsize screenRect(3)/2+fixsize screenRect(4)/2+fixsize]);
            elseif fcoloridx(i+itemsPerBlock*2*(theBlock-1)) == 1
                Screen('fillOval', window, [0,255,0,alpha], [screenRect(3)/2-fixsize screenRect(4)/2-fixsize screenRect(3)/2+fixsize screenRect(4)/2+fixsize]);
            end
            'endpoint7.1';
            Screen('Flip',window);  % display learning pictures
            while ~IsQuit && ((GetSecs - presStart)<itemDur)
                [keyIsDown,secs,keyCode] = KbCheck;
                if (keyIsDown && ( keyCode(rspKey) || keyCode(escKey)) && length(find(keyCode))==1)
                    Response = 1;
                    switch (find(keyCode))
                        case rspKey
                            responses(i+(theBlock-1)*itemsPerBlock*2)=1;
                        case escKey
                            IsQuit=1;
                            break;
                    end;
                    %          'endpoint11'
                    
                    
                    while KbCheck;
                    end;
                end
            end
            
            if blankDur > 0
                Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
                Screen('DrawTexture', window, maskPtr, [], CenterRect(maskRect, screenRect));
                if fcoloridx(i+itemsPerBlock*2*(theBlock-1)) == 0
                    Screen('fillOval', window, [255,0,0,alpha], [screenRect(3)/2-fixsize screenRect(4)/2-fixsize screenRect(3)/2+fixsize screenRect(4)/2+fixsize]);
                elseif fcoloridx(i+itemsPerBlock*2*(theBlock-1)) == 1
                    Screen('fillOval', window, [0,255,0,alpha], [screenRect(3)/2-fixsize screenRect(4)/2-fixsize screenRect(3)/2+fixsize screenRect(4)/2+fixsize]);
                end
                Screen('Flip',window);  % display blank screen
                while ~IsQuit & ((GetSecs - presStart)<(itemDur+blankDur))
                    [keyIsDown,secs,keyCode] = KbCheck;
                    if keyIsDown & keyCode(escKey),
                        IsQuit=1;
                        break;
                    end
                end
            end
            %
            %
            %             while ~IsQuit & ((GetSecs-presStart) < itemDur+ISIDur)
            %                 [keyIsDown,secs,keyCode] = KbCheck;
            %                 if keyIsDown & keyCode(escKey)
            %                     IsQuit=1;
            %                     break;
            %                 end
            %             end
            if IsQuit==1
                break;
            end
            endpointtest(i,2) = GetSecs;
        end
        if IsQuit==1
            break;
        end
    end
    'endpoint7.2';
    hits = zeros(1,numBlocks*itemsPerBlock*2);
    changepoint
    for i=1:size(changepoint,2)
        if responses(changepoint(i))==1 || responses(changepoint(i)+1)==1 || responses(changepoint(i)+2)==1 || responses(changepoint(i)+3)==1
            hits(changepoint(i))=1
        end
    end
    'endpoint7.3';
    
    hit = size(find(hits==1),2)/size(changepoint,2);
    fa = (size(find(responses==1),2)-size(find(responses==1),2))/size(changepoint,2);
    performance = [hit fa];
    
    'endpoint8';
    experimentEnd = GetSecs;
    experimentDuration = experimentEnd - experimentStart;
    cd(dataDir);
    save([Filefix, '.mat']);
    Screen('CloseAll');
    ShowCursor;
    cd(rootDir);
    if IsQuit == 1
        disp('ESC is pressed to abort the program.');
        return;
    end
    
catch
    Screen('CloseAll');
    ShowCursor;
    cd(rootDir);
    disp('program error!!!.');
end % try ... catch %



