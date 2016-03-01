
function RunExp_half(whichorder)

isDone = 0;
subjID = [];
subjID = [];
Gender = [];
EmailAdd = [];
%% let subjects input their name, subjnumber, gender and email address
while isempty(subjID)
    subjID = input('Please enter your first name: ','s');
end

while isempty(Gender)
    Gender = input('Please enter your Gender, 1 for male, 2 for female: ');
end
while isempty(EmailAdd)
    EmailAdd = input('Please enter your email address: ','s');
end

IsQuit = 0;
escKey = KbName('ESCAPE');




ObjectSet = [1,2,3,4];
Condition = [1,2,3,4;...
    2,1,4,3;...
    3,4,1,2;...
    4,3,2,1];
%condition 1: stereo
%condition 2: shading
%condition 3: line
%condition 4: sil

counterbalance = randperm(2);
whichObject = randperm(2);


for j=1:4
    
    square = ObjectSet(j);
    
    [IsQuit, Performance1] = test_half(subjID, ObjectSet(j),Condition(whichorder,j), 17, counterbalance(1));
    
    for  repeat=1:2
        for i=1:2
            

                [IsQuit, learnPerformance{i+(repeat-1)*2}] = learn_fixation(subjID, whichObject(i)+(square-1)*4, whichObject(i),1, repeat,0.667,0);

            
        end
    end
    
    
%     if IsQuit==1
%         return;
%     end
    
    [IsQuit, Performance2] = test_half(subjID,ObjectSet(j),Condition(whichorder,j), 17, counterbalance(1));
    
    
    
    Results1{square} = Performance1;
    Results2{square} = Performance2;
    
%     if IsQuit==1
%         return;
%     end
end




save([subjID, '.mat'], 'subjID', 'Gender', 'EmailAdd', 'learnPerformance','Results1', 'Results2','ObjectSet','Condition', 'whichorder','whichObject', 'counterbalance');
