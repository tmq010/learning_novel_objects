

function [IsQuit, Performance] = test_half(subjID, whichObjectSet,whichCondition, itemsPerBlock, counterbalance)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Moqian 2011 Feb
%%
%%f
%% subjID: subject name (string)
%% nonsequenInter: the steps between two shapes. For the task difficulty
%% consideration, the nonsequenInter should be around 30, at least >=15.
%% whichSquare: 1st, 2nd or 3th square.
%%

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isDone = 0;

%'endpoint1'
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'VisualDebugLevel', 1);

Screen('Preference', 'Verbosity', 5);
if nargin ~= 5
    error('Please input all the parameter for learning: subjID, nonsequenInter whichSquare');
end
AssertOpenGL; % check for Opengl compatibility, abort otherwise (to verify PTB3)
Screen('Preference', 'SkipSyncTests',1);

%% Experiment parameter
firstFixationDurDefine = 1; % Unit: second
itemDurDefine = 0.5; % Unit: second
maskDurDefine = 0.5; % Unit: second
responseDurDefine = 3; % Unit: second
% nonsequenInter = 30; %% the minimum interval between two nonsequential
%stimuli. %%% defined in the function on the top
% itemsPerBlock = 48;
pixRect = [0 0 800 800]; 

jit = 50; %%max amount of jitter along cardinal axis for stims
numBlocks = 1;
sKey = KbName('space');
leftKey = KbName('f');  %% press 'f' if same 
rightKey = KbName('j');  %% press 'j' if different
escKey = KbName('escape');
trialunit = 8; %%the unit of trial number

rootDir = pwd;
fmt = 'bmp';

BeginTime=clock;
Filefix = [subjID,'_Test_3DSTIM','_',num2str(BeginTime(1)), ...
	num2str(BeginTime(2),'%02d'),num2str(BeginTime(3),'%02d'),'_H',int2str(BeginTime(4)),'M',int2str(BeginTime(5))];

% Duration for each picture
itemDur =  itemDurDefine;  

% Duration for mask
maskDur = maskDurDefine;
firstFixationDur = firstFixationDurDefine;
responseDur = responseDurDefine;

% Initial screen
screens = Screen('Screens');
screenNumber = max(screens);
%screenNumber = 1;
screenRect  = Screen(screenNumber, 'rect');

stimuliDir = char([rootDir '/3DStim']);
maskDir = char([rootDir '/3DStim/mask']);
dataDir = char([rootDir, '/data/']);

% 'endpoint2'

IsQuit = 0;
try		

	% Open a fullscreen window
	backgroundcolor= [0 0 0];
	[window, screenRect] = Screen('OpenWindow',screenNumber,backgroundcolor,screenRect);
%	refresh = Screen('GetFlipInterval', window);


% 'endpoint3'

	%% create enough offscreen windows for each picture in the experiment
	for i = 1:itemsPerBlock
        for lines = 1:3
	  offScrPtr(lines,i) = Screen('OpenOffscreenWindow',window,  [0 0 0], pixRect);
        end
    end
%    'endpoint4'
	maskScrPtr = Screen('OpenOffscreenWindow',window,  [0 0 0], pixRect);

	fixation = Screen('OpenOffscreenWindow',window, [0 0 0], screenRect);
	Screen( 'FillOval',fixation, [0 0 0], CenterRect([0 0 12 12], screenRect));
	fixation2 = Screen('OpenOffscreenWindow',window, [0 0 0], screenRect);
	Screen( 'FillOval',fixation2, [0 0 0], CenterRect([0 0 8 8], screenRect));
	blank =    Screen('OpenOffscreenWindow',window,  [0 0 0], screenRect);
    
%  'endpoint4' 
    
%% read stimuli image
	cd(stimuliDir);
    for lines=1:2
    cd(['objectset', num2str(whichObjectSet),'/object', num2str(lines), 'condition', num2str(whichCondition), '_test']);
	StimuliFile = dir('*.bmp');
	[numitems junk] = size(StimuliFile);
	if numitems~=itemsPerBlock, error('Not the right number of items.'); end
	[itemlist{1:numitems}] = deal(StimuliFile.name);

	for theitem = 1:itemsPerBlock
		filename = itemlist{theitem};
		[imgArray] = imread(filename, fmt);
		Screen('PutImage',offScrPtr(lines, theitem), imgArray, pixRect);
	end
	cd(stimuliDir);
    end
    
% 'endpoint5'
    
% %% read mask image
% 	cd(maskDir);
% 	StimuliFile = dir('*.jpg');
% 	[numitems junk] = size(StimuliFile);
% 	[itemlist{1:numitems}] = deal(StimuliFile.name);
% 
% 	filename = itemlist{1};
% 	[imgArray] = imread(filename, fmt);
% 	Screen('PutImage',maskScrPtr, imgArray, pixRect);
% 	cd(rootDir);

% %% design(numBlocks, 16*8*2, 6): 
% 1: condition. 1 for same; 2 for different.
% 2: first picture axis
% 3: second picture axis
% 4: subject response. 1 for leftKey; 2 for rightKey.
% 5: response time
% 6: hit
% 7: correct reject
% 8: false alarm
% 9: miss
% 10: first picture code
% 11: second picture code

% 'endpoint6'
	design = zeros(numBlocks, trialunit*4, 11);  
    
    axis = zeros(2,2); %% rows represent 6 different combinations(counterbalance), columns represent 6 axes.
    axis(1,:) = [1,2];
    axis(2,:) = [2,1];

    
	for i = 1:numBlocks
		design(i, :, 1) =  [ones(trialunit*2,1);2*ones(trialunit*2,1)];
        % first half trials are same trials, second half trials are
		% different trials    
		design(i, :, 2) = [repmat(axis(counterbalance,1), [trialunit,1]);... %same
            repmat(axis(counterbalance,2), [trialunit,1]);... %same
            repmat(axis(counterbalance,1), [trialunit,1]);... %diff
            repmat(axis(counterbalance,2), [trialunit,1])]; %diff
    
        design(i, :, 3) = [repmat(axis(counterbalance,1), [trialunit,1]);... %same 
            repmat(axis(counterbalance,2), [trialunit,1]);... %same
            repmat(axis(counterbalance,2), [trialunit,1]);... %diff
            repmat(axis(counterbalance,1), [trialunit,1])]; %diff
        
        
%         halftrial = [2:1+trialunit]';
%         [b,index] = Shuffle(halftrial(:,1));
%         halfindex = [1:2:index];
% 		halftrial(:,1) = halftrial(index,1);
%         index2 = [1:2:length(index)];
%         halftrial1(:,1) = halftrial(index2,1);
%         halfqueue1 = [halftrial1; halftrial1+nonsequenInter];
%         halfqueue2 = [halftrial1+nonsequenInter; halftrial1];
        
        dd(:,1) = [1:8, 10:17, 1:8, 10:17];
        dd(:,2) = [10:17, 1:8, 10:17, 1:8];
        for ii =1:32
        ee(ii,:) = dd(ii,randperm(2));
        end
        
        design(i,:,10:11) = ee;
    end
  
%  'endpoint7'
	
	%% start display
	HideCursor;
	experimentStart = GetSecs;
	for theBlock = 1:numBlocks
    %Cue word to remind task and press 'space' to start


        
        Screen('TextSize',window,30);
		Screen('TextFont',window,'Arial');
		Screen('TextStyle', window ,1);
%          if whichCondition ==1
%             Screen('TextColor', window, [128 0 0]);
%             Screen('DrawText',window,'Please put on the google!',(screenRect(3)/2-700),screenRect(4)/2-120);
%          else 
%             Screen('TextColor', window, [128 0 0]);
%             Screen('DrawText',window,'Please take off the google!',(screenRect(3)/2-700),screenRect(4)/2-120);
%          end
         if whichCondition ==1
            Screen('TextColor', window, [128 0 0]);
            Screen('DrawText',window,'Please put on the google!',(screenRect(3)/2-700),screenRect(4)/2-120);
         else 
            Screen('TextColor', window, [128 0 0]);
            Screen('DrawText',window,'Please take off the google!',(screenRect(3)/2-700),screenRect(4)/2-120);
         end
        Screen('TextColor', window, [128 128 128]);
		Screen('DrawText',window,'Now we will start the test block.' ,(screenRect(3)/2-275),screenRect(4)/2-150);
        Screen('DrawText',window,'In each trial you will see two different views of objects presented sequentially.' ,(screenRect(3)/2-500),screenRect(4)/2-100);
        Screen('DrawText',window, 'Press "f" key if two views are from the same object, Press "j" key if they are from the different objects.' ,(screenRect(3)/2-750),screenRect(4)/2-50);
        Screen('DrawText',window,'Please respond to every trial. Press Space key when you are ready.' ,(screenRect(3)/2)-500,screenRect(4)/2);
		Screen('Flip',window);
        
        
		while KbCheck, end;
		while 1
		    [keyIsDown,secs,keyCode] = KbCheck;
		    if keyIsDown & keyCode(sKey) 
			break; % start only when start key is pressed
		    elseif keyIsDown & keyCode(escKey)  
			IsQuit=1;
			break;
		    end
        end

        %% shuffle design matrix
        [b,index] = Shuffle(design(theBlock,:,10));
		design(theBlock,:,1:11) = design(theBlock,index,1:11);

		for i = 1:trialunit*4
			theFirstPic = design(theBlock,i,10);
			theSecondPic = design(theBlock,i,11);
            theFirstPicAxis = design(theBlock,i,2);
            theSecondPicAxis = design(theBlock,i,3);

            %% present a fixation screen before stimulus
            Screen('CopyWindow', fixation, window, [], screenRect);
            startTime = GetSecs;
            Screen('Flip',window); % display first fixation 

            while ~IsQuit & ((GetSecs - startTime)<firstFixationDur) 
                [keyIsDown,secs,keyCode] = KbCheck;
                if keyIsDown & keyCode(escKey),
                        IsQuit=1;
                    break;
                end
            end
% 'endpoint8'
            
% Screen('TextSize',window,30);
% 		Screen('TextFont',window,'Arial');
% 		Screen('TextStyle', window ,1);
% 		Screen('DrawText',window,num2str(theFirstPicAxis) ,(screenRect(3)/2-700),screenRect(4)/2-100);
% 		Screen('Flip',window);
        
%         while KbCheck, end;
% 		while 1
% 		    [keyIsDown,secs,keyCode] = KbCheck;
% 		    if keyIsDown & keyCode(sKey) 
% 			break; % start only when start key is pressed
% 		    elseif keyIsDown & keyCode(escKey)  
% 			IsQuit=1;
% 			break;
% 		    end
%         end

%% present 1st picture
            Screen('CopyWindow', offScrPtr(theFirstPicAxis,theFirstPic), window, [], CenterRect(pixRect, screenRect));
           
           
            
			presStart = GetSecs;
			Screen('Flip',window);  % display first stimulus
			while ~IsQuit & ((GetSecs - presStart)<itemDur)
				[keyIsDown,secs,keyCode] = KbCheck;
				if keyIsDown & keyCode(escKey),
					IsQuit=1;
					break;
				end
                	end
			
            %% present mask
			Screen('CopyWindow', maskScrPtr, window, [], CenterRect(pixRect, screenRect));
			Screen('Flip',window); % display mask
		    	while ~IsQuit & ((GetSecs-presStart) < itemDur+maskDur) 
				[keyIsDown,secs,keyCode] = KbCheck;
				if keyIsDown & keyCode(escKey)  
	    				IsQuit=1;
					break;
				end
			end
			
            %% present 2nd picture
			xjitter = randsample(-jit:jit,1);
            yjitter = randsample(-jit:jit,1);
            Screen('CopyWindow', offScrPtr(theSecondPicAxis,theSecondPic), window, [], CenterRect(pixRect, [screenRect(1)+xjitter screenRect(2)+yjitter screenRect(3)+xjitter screenRect(4)+yjitter]));
			secondPicStart = GetSecs;
			Screen('Flip',window);  % display second stimulus
            
             
            
        'endpoint9'   
         %% record response
            Response = 0;
		    while ~IsQuit & ((GetSecs-secondPicStart) < itemDur) 
                [keyIsDown,secs,keyCode] = KbCheck;
                if (keyIsDown & ( keyCode(leftKey) | keyCode(rightKey) | keyCode(escKey)) & length(find(keyCode))==1)
                    Response = 1;
                    switch (find(keyCode))
                        case leftKey
                            design(theBlock,i,4) = 1;
                        case rightKey
                            design(theBlock,i,4) = 2;
                        case escKey
                            IsQuit=1;
                            break;
                    end;
                    design(theBlock,i, 5) = (secs - secondPicStart)*1000;
                    design(theBlock,i, 6) = (design(theBlock,i,4)==1&design(theBlock,i,1)==1); %% hit stim:same/response:same
                    design(theBlock,i, 7) = (design(theBlock,i,4)==2&design(theBlock,i,1)==2); %% correct reject stim:diff/response:diff
                    design(theBlock,i, 8) = (design(theBlock,i,4)==1&design(theBlock,i,1)==2); %% false alarm stim:diff/response:same
                    design(theBlock,i, 9) = (design(theBlock,i,4)==2&design(theBlock,i,1)==1); %% miss stim:same/response:diff
                end
            end
% 'endpoint10'
             %% fixation screen waiting for response
            Screen('CopyWindow', fixation2, window, [], CenterRect(pixRect, screenRect));
			Screen('Flip',window); % display fixation
		    	
            %% record response while fixation
            while ~Response & ~IsQuit  
				[keyIsDown,secs,keyCode] = KbCheck;
				if (keyIsDown & ( keyCode(leftKey) | keyCode(rightKey) | keyCode(escKey)) & length(find(keyCode))==1)
					Response = 1;
					switch (find(keyCode))
						case leftKey
							design(theBlock,i,4) = 1;
						case rightKey
							design(theBlock,i,4) = 2;
						case escKey
							IsQuit=1;
							break;
					end;
%          'endpoint11'
					design(theBlock,i, 5) = (secs - secondPicStart)*1000;
					design(theBlock,i, 6) = (design(theBlock,i,4)==1&design(theBlock,i,1)==1); %% hit stim:same/response:same
                    design(theBlock,i, 7) = (design(theBlock,i,4)==2&design(theBlock,i,1)==2); %% correct reject stim:diff/response:diff
                    design(theBlock,i, 8) = (design(theBlock,i,4)==1&design(theBlock,i,1)==2); %% false alarm stim:diff/response:same
                    design(theBlock,i, 9) = (design(theBlock,i,4)==2&design(theBlock,i,1)==1); %% miss stim:same/response:diff
					while KbCheck;
					end;
				end
			end
			if IsQuit==1
				break;
			end
            	end		
		if IsQuit==1
			break;
		end
    end
    
    
    
%     'endpoint12'
	experimentEnd = GetSecs;
	experimentDuration = experimentEnd - experimentStart;
    
        a=zeros(numBlocks,trialunit*4,4);
  
       
       for j=1:numBlocks
           for i=1:trialunit*4
               if (design(j,i, 6)==1|design(j,i, 7)==1)&& design(j,i,5)<=1600000
                   a(j,i,1)=design(j,i,5);
               end
           end
       end
       
       
       
%        'endpoint14'
    RT = mean(squeeze(a(:,:,1)));
	hit = length(find(squeeze(design(:,:,6))==1))/(trialunit*2);
	miss = length(find(squeeze(design(:,:,9))==1))/(trialunit*2);
	
    
	falsal = length(find(squeeze(design(:,:,8))==1))/(trialunit*2);
	correj = length(find(squeeze(design(:,:,7))==1))/(trialunit*2);
                
    
    
       
    
    
  
subjectdata.RT=RT;
subjectdata.hit=hit;
subjectdata.miss=miss;
subjectdata.fa=falsal;
subjectdata.cr=correj;





subjectdata.dprime=norminv(subjectdata.hit)-norminv(subjectdata.fa);


subjectdata.CorrA=(subjectdata.hit - subjectdata.fa)/(1-subjectdata.fa);

    

  
  
    Performance = subjectdata;
  
    
    
    
    

    cd(dataDir);
%     'endpoint13'
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


fprintf(1,'sbj=%s FA= %5.2f\n', subjID, subjectdata.fa);
  fprintf(1,'sbj=%s CR= %5.2f\n', subjID, subjectdata.cr);
  fprintf(1,'sbj=%s RT= %5.2f\n', subjID, subjectdata.RT);
  fprintf(1,'sbj=%s hit= %5.2f\n', subjID, subjectdata.hit);
  fprintf(1,'sbj=%s miss= %5.2f\n', subjID, subjectdata.miss);
  fprintf(1,'sbj=%s dprime= %5.2f\n', subjID, subjectdata.dprime);
  fprintf(1,'sbj=%s CorrA= %5.2f\n', subjID, subjectdata.CorrA);


