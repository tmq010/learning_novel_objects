cd results
dataFile = dir('*.mat');
[numsubj, junk] = size(dataFile);
[itemlist{1:numsubj}] = deal(dataFile.name);
subjname = cell(numsubj,1);
for i=1:numsubj
[junk1,name,junk2] = fileparts(itemlist{i});
subjname{i}=[name];
end

cd ../data


for subj=1:numsubj
    
DataFile = dir([subjname{subj},'_Learning','*.mat']);
[numtests junk] = size(DataFile);
[testlist{1:numtests}] = deal(DataFile.name);
for item=1:numtests
load([testlist{item}]);

    
    for i=1:size(changepoint,2)
        if responses(changepoint(i))==1 || responses(changepoint(i)+1)==1 || responses(changepoint(i)+2)==1 
            hits(changepoint(i))=1;
        end
    end
    
    
    hit = size(find(hits==1),2)/size(changepoint,2);
    fa = (size(find(responses==1),2)-size(find(responses==1),2))/size(changepoint,2);
    performance = [hit fa];
    
learnHit(ceil(item/4),item-(ceil(item/4)-1)*4)=performance(1);
learnFa(ceil(item/4),item-(ceil(item/4)-1)*4)=performance(2);
end

cd ../results
load([subjname{subj},'.mat']);


save([subjname{subj},'.mat'],'subjID', 'Gender', 'EmailAdd', 'learnHit','learnFa','Results1', 'Results2','ObjectSet','Condition', 'whichorder','whichObject', 'counterbalance');
cd ..
cd data/
end
