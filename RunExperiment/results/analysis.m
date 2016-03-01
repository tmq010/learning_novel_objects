clx;

% subjname = {'Abram','Agatha','Angel', 'Charlene',...
%     'Ernesto','Jack','Marie','Nicole','Nora','Peter','Will','Devangi', 'Kelsey Harbin'};

dataFile = dir('*.mat');
[numsubj, junk] = size(dataFile);
[itemlist{1:numsubj}] = deal(dataFile.name);


%% reading in the raw data

for i=1:numsubj
    subjname = itemlist{i};
    
    load(subjname);
    order(i) = whichorder; 
   for j=1:4
    data.pre.RT(i,j) = Results1{j}.RT;
    if Results1{j}.RT == 0
        data.pre.RT(i,j) = NaN;
    end
    data.pre.hit(i,j) = Results1{j}.hit;
    data.pre.miss(i,j) = Results1{j}.miss;
    data.pre.fa(i,j) = Results1{j}.fa;
    data.pre.cr(i,j) = Results1{j}.cr;
    Results1{j}.pc = (Results1{j}.hit+Results1{j}.cr)/2;%%%
    data.pre.pc(i,j) = Results1{j}.pc;%%%
   end
   
 
    inf = 0.001;
    for j=1:4
        
        if Results1{j}.hit==0 && Results1{j}.fa~=0
            Results1{j}.dprime=norminv(Results1{j}.hit+inf)-norminv(Results1{j}.fa);
        elseif Results1{j}.hit==1 && Results1{j}.fa~=1
            Results1{j}.dprime=norminv(Results1{j}.hit-inf)-norminv(Results1{j}.fa);
        elseif Results1{j}.fa==0 && Results1{j}.hit~=0
            Results1{j}.dprime=norminv(Results1{j}.hit)-norminv((Results1{j}.fa)+inf);
            
        elseif Results1{j}.fa==0&&Results1{j}.hit==1
            Results1{j}.dprime=norminv(Results1{j}.hit-inf)-norminv((Results1{j}.fa)+inf);
            
        elseif Results1{j}.hit==0&&Results1{j}.fa==0
            Results1{j}.dprime=0;
            
        elseif Results1{j}.hit==1&&Results1{j}.fa==1
            Results1{j}.dprime=0;
        elseif Results1{j}.fa==1
            Results1{j}.dprime=norminv(Results1{j}.hit)-norminv((Results1{j}.fa)-inf);
        else
            Results1{j}.dprime=norminv(Results1{j}.hit)-norminv(Results1{j}.fa);
        end
    end
    
    for j=1:4
    data.pre.dprime(i,j) = Results1{j}.dprime;
    end
   
   for j=1:4
       hit.pre(i,j) = data.pre.hit(i,find(Condition(whichorder,:)==j));
       fa.pre(i,j) = data.pre.fa(i,find(Condition(whichorder,:)==j));
       pc.pre(i,j) = data.pre.pc(i,find(Condition(whichorder,:)==j));
       dprime.pre(i,j) = data.pre.dprime(i,find(Condition(whichorder,:)==j));
       RT.pre(i,j) = data.pre.RT(i,find(Condition(whichorder,:)==j));
   end
        
    % post training
    for j=1:4
    data.post.RT(i,j) = Results2{j}.RT;
    if Results2{j}.RT == 0
        data.post.RT(i,j) = NaN;
    end
    data.post.hit(i,j) = Results2{j}.hit;
    data.post.miss(i,j) = Results2{j}.miss;
    data.post.fa(i,j) = Results2{j}.fa;
    data.post.cr(i,j) = Results2{j}.cr;
    Results2{j}.pc = (Results2{j}.hit+Results2{j}.cr)/2;%%%
    data.post.pc(i,j) = Results2{j}.pc;%%%
    end 

    
    inf = 0.001;
    for j=1:4
        if Results2{j}.hit==1 && Results2{j}.fa~=1 && Results2{j}.fa~=0
            Results2{j}.dprime=norminv(Results2{j}.hit-inf)-norminv(Results2{j}.fa);
        elseif Results2{j}.hit==0&&Results2{j}.fa~=0
            Results2{j}.dprime=norminv(Results2{j}.hit+inf)-norminv(Results2{j}.fa);
        elseif Results2{j}.hit==0&&Results2{j}.fa==0
            Results2{j}.dprime=0;
        elseif Results2{j}.fa==0 && Results2{j}.hit~=1
            Results2{j}.dprime=norminv(Results2{j}.hit)-norminv(Results2{j}.fa+inf);
        elseif Results2{j}.fa==0&&Results2{j}.hit==1
            Results2{j}.dprime=norminv(Results2{j}.hit-inf)-norminv(Results2{j}.fa+inf);
        elseif Results2{j}.hit==0&&Results2{j}.fa==0
            Results2{j}.dprime=0;
        elseif Results2{j}.hit==1&&Results2{j}.fa==1
            Results2{j}.dprime=0;
        elseif Results2{j}.fa==1
            Results2{j}.dprime=norminv(Results2{j}.hit)-norminv((Results2{j}.fa)-inf);
        elseif Results2{j}.hit==1 && Results2{j}.fa~=0
            Results2{j}.dprime=norminv(Results2{j}.hit-inf)-norminv((Results2{j}.fa));
        else
            Results2{j}.dprime=norminv(Results2{j}.hit)-norminv(Results2{j}.fa);
        end
    end
    
    for j=1:4
    data.post.dprime(i,j) = Results2{j}.dprime;
    data.post.dpc(i,j) = data.post.dprime(i,j)/data.post.RT(i,j);
    end
    
    for j=1:4
       hit.post(i,j) = data.post.hit(i,find(Condition(whichorder,:)==j));
       fa.post(i,j) = data.post.fa(i,find(Condition(whichorder,:)==j));
       pc.post(i,j) = data.post.pc(i,find(Condition(whichorder,:)==j));
       RT.post(i,j) = data.post.RT(i,find(Condition(whichorder,:)==j));
       dprime.post(i,j) = data.post.dprime(i,find(Condition(whichorder,:)==j));
    end

    
    data.hit.learn(i,:) = [learnPerformance{1}(1),learnPerformance{2}(1),...
        learnPerformance{3}(1),learnPerformance{4}(1)];
    data.fa.learn(i,:) = [learnPerformance{1}(2),learnPerformance{2}(2),...
        learnPerformance{3}(2),learnPerformance{4}(2)];
    data.pc.learn = 0.5+(data.hit.learn-data.fa.learn)/2;
    for j=1:4
       hit.learn(i,j) = data.hit.learn(i,find(Condition(whichorder,:)==j));
       fa.learn(i,j) = data.fa.learn(i,find(Condition(whichorder,:)==j));
       pc.learn(i,j) = data.pc.learn(i,find(Condition(whichorder,:)==j));
    end
end


% %% pick out subjects who have zero or below zero learning effect
% ind = find(mean(data.post.pc,2)-mean(data.pre.pc,2)>0);
ind = [1:2,4:21]';
data.pre.hit = data.pre.hit(ind,:);
data.pre.fa = data.pre.fa(ind,:);
data.pre.miss = data.pre.miss(ind,:);
data.pre.cr = data.pre.cr(ind,:);
data.pre.pc = data.pre.pc(ind,:);
data.pre.dprime = data.pre.dprime(ind,:);

data.hit.learn = data.hit.learn(ind,:);
data.fa.learn= data.fa.learn(ind,:);
data.pc.learn = data.pc.learn(ind,:);

data.post.hit = data.post.hit(ind,:);
data.post.fa = data.post.fa(ind,:);
data.post.miss = data.post.miss(ind,:);
data.post.cr = data.post.cr(ind,:);
data.post.pc = data.post.pc(ind,:);
data.post.dprime = data.post.dprime(ind,:);

hit.pre = hit.pre(ind,:);
fa.pre = fa.pre(ind,:);
pc.pre = pc.pre(ind,:);
RT.pre = RT.pre(ind,:);
dprime.pre = dprime.pre(ind,:);

hit.learn = hit.learn(ind,:);
fa.learn = fa.learn(ind,:);
pc.learn = pc.learn(ind,:);

hit.post = hit.post(ind,:);
fa.post = fa.post(ind,:);
pc.post = pc.post(ind,:);
RT.post = RT.post(ind,:);
dprime.post = dprime.post(ind,:);

numsubj = size(ind,1);
order = order(ind);
%% average plot
figure('Color',[ 1 1 1],  'units','norm', 'position', [ .1 .1 .4 1.2])
title('Average Plot');
ConditionLabels={'stereo','shade','line','sil'}; 


subplot(4,1,1)
errorbarbar(1:4,[1-mean(hit.pre(:,1)),1-mean(hit.post(:,1));...
1-mean(hit.pre(:,2)),1-mean(hit.post(:,2));...
1-mean(hit.pre(:,3)),1-mean(hit.post(:,3));...
1-mean(hit.pre(:,4)),1-mean(hit.post(:,4))],...
[std(hit.pre(:,1))/sqrt(numsubj),std(hit.post(:,1))/sqrt(numsubj);...
std(hit.pre(:,2))/sqrt(numsubj),std(hit.post(:,2))/sqrt(numsubj);...
std(hit.pre(:,3))/sqrt(numsubj),std(hit.post(:,3))/sqrt(numsubj);...
std(hit.pre(:,4))/sqrt(numsubj),std(hit.post(:,4))/sqrt(numsubj)],...
{'grouped'});colormap(cool);
ylim([0 1]);
ylabel('miss','Fontsize',18,'FontWeight', 'BOLD');
set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')
legend('Pre','Post');


subplot(4,1,2)
errorbarbar(1:4,[mean(fa.pre(:,1)),mean(fa.post(:,1));...
mean(fa.pre(:,2)),mean(fa.post(:,2));...
mean(fa.pre(:,3)),mean(fa.post(:,3));...
mean(fa.pre(:,4)),mean(fa.post(:,4))],...
[std(fa.pre(:,1))/sqrt(numsubj),std(fa.post(:,1))/sqrt(numsubj);...
std(fa.pre(:,2))/sqrt(numsubj),std(fa.post(:,2))/sqrt(numsubj);...
std(fa.pre(:,3))/sqrt(numsubj),std(fa.post(:,3))/sqrt(numsubj);...
std(fa.pre(:,4))/sqrt(numsubj),std(fa.post(:,4))/sqrt(numsubj)],...
{'grouped'});colormap(cool);
ylim([0 1]);
ylabel('fa','Fontsize',18,'FontWeight', 'BOLD');
set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')

subplot(4,1,3)
errorbarbar(1:4,[mean(pc.pre(:,1)),mean(pc.post(:,1));...
mean(pc.pre(:,2)),mean(pc.post(:,2));...
mean(pc.pre(:,3)),mean(pc.post(:,3));...
mean(pc.pre(:,4)),mean(pc.post(:,4))],...
[std(pc.pre(:,1))/sqrt(numsubj),std(pc.post(:,1))/sqrt(numsubj);...
std(pc.pre(:,2))/sqrt(numsubj),std(pc.post(:,2))/sqrt(numsubj);...
std(pc.pre(:,3))/sqrt(numsubj),std(pc.post(:,3))/sqrt(numsubj);...
std(pc.pre(:,4))/sqrt(numsubj),std(pc.post(:,4))/sqrt(numsubj)],...
{'grouped'});colormap(cool);
ylim([0.5 1]);
ylabel('pc','Fontsize',18,'FontWeight', 'BOLD');
set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')

subplot(4,1,4)
starbar(mean(pc.learn), std(pc.learn)/sqrt(numsubj), 0);
set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')
ylim([0.5 1]);
ylabel('pc_learn','Fontsize',18,'FontWeight', 'BOLD');
set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')


%% plot across different stimulus set

figure('Color',[ 1 1 1],  'units','norm', 'position', [ .1 .1 .4 1.2])

ConditionLabels={'SET1','SET2','SET3','SET4'}; 


subplot(4,1,1)
errorbarbar(1:4,[1-mean(data.pre.hit(:,1)),1-mean(data.post.hit(:,1));...
1-mean(data.pre.hit(:,2)),1-mean(data.post.hit(:,2));...
1-mean(data.pre.hit(:,3)),1-mean(data.post.hit(:,3));...
1-mean(data.pre.hit(:,4)),1-mean(data.post.hit(:,4))],...
[std(data.pre.hit(:,1))/sqrt(numsubj),std(data.post.hit(:,1))/sqrt(numsubj);...
std(data.pre.hit(:,2))/sqrt(numsubj),std(data.post.hit(:,2))/sqrt(numsubj);...
std(data.pre.hit(:,3))/sqrt(numsubj),std(data.post.hit(:,3))/sqrt(numsubj);...
std(data.pre.hit(:,4))/sqrt(numsubj),std(data.post.hit(:,4))/sqrt(numsubj)],...
{'grouped'});colormap(cool);
ylim([0 1]);
ylabel('miss','Fontsize',18,'FontWeight', 'BOLD');
set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')
legend('Pre','Post');


subplot(4,1,2)
errorbarbar(1:4,[mean(data.pre.fa(:,1)),mean(data.post.fa(:,1));...
mean(data.pre.fa(:,2)),mean(data.post.fa(:,2));...
mean(data.pre.fa(:,3)),mean(data.post.fa(:,3));...
mean(data.pre.fa(:,4)),mean(data.post.fa(:,4))],...
[std(data.pre.fa(:,1))/sqrt(numsubj),std(data.post.fa(:,1))/sqrt(numsubj);...
std(data.pre.fa(:,2))/sqrt(numsubj),std(data.post.fa(:,2))/sqrt(numsubj);...
std(data.pre.fa(:,3))/sqrt(numsubj),std(data.post.fa(:,3))/sqrt(numsubj);...
std(data.pre.fa(:,4))/sqrt(numsubj),std(data.post.fa(:,4))/sqrt(numsubj)],...
{'grouped'});colormap(cool);
ylim([0 1]);
ylabel('fa','Fontsize',18,'FontWeight', 'BOLD');
set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')


subplot(4,1,3)
errorbarbar(1:4,[mean(data.pre.pc(:,1)),mean(data.post.pc(:,1));...
mean(data.pre.pc(:,2)),mean(data.post.pc(:,2));...
mean(data.pre.pc(:,3)),mean(data.post.pc(:,3));...
mean(data.pre.pc(:,4)),mean(data.post.pc(:,4))],...
[std(data.pre.pc(:,1))/sqrt(numsubj),std(data.post.pc(:,1))/sqrt(numsubj);...
std(data.pre.pc(:,2))/sqrt(numsubj),std(data.post.pc(:,2))/sqrt(numsubj);...
std(data.pre.pc(:,3))/sqrt(numsubj),std(data.post.pc(:,3))/sqrt(numsubj);...
std(data.pre.pc(:,4))/sqrt(numsubj),std(data.post.pc(:,4))/sqrt(numsubj)],...
{'grouped'});colormap(cool);
ylim([0.5 1]);
ylabel('pc','Fontsize',18,'FontWeight', 'BOLD');
set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')

subplot(4,1,4)
starbar(mean(data.pc.learn), std(data.pc.learn)/sqrt(numsubj), 0);
set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')
ylim([0.5 1]);
ylabel('pc_learn','Fontsize',18,'FontWeight', 'BOLD');
set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')


% %% plot data for each subject
% for m=1:numsubj
% figure('Color',[ 1 1 1],  'units','norm', 'position', [ .1 .1 .4 1.2])
% 
% ConditionLabels={'stereo','shade','line','sil'}; 
% 
% 
% subplot(4,1,1)
% errorbarbar(1:4,[hit.pre(m,1),hit.post(m,1);...
% hit.pre(m,2),hit.post(m,2);...
% hit.pre(m,3),hit.post(m,3);...
% hit.pre(m,4),hit.post(m,4)],...
% [0,0;0,0;0,0;0,0],...
% {'grouped'});colormap(cool);
% ylim([0 1]);
% ylabel('hit','Fontsize',18,'FontWeight', 'BOLD');
% set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')
% legend('Pre','Post');
% title(num2str(order(m)));
% 
% 
% subplot(4,1,2)
% errorbarbar(1:4,[fa.pre(m,1),fa.post(m,1);...
% fa.pre(m,2),fa.post(m,2);...
% fa.pre(m,3),fa.post(m,3);...
% fa.pre(m,4),fa.post(m,4)],...
% [0,0;0,0;0,0;0,0],...
% {'grouped'});colormap(cool);
% ylim([0 1]);
% ylabel('fa','Fontsize',18,'FontWeight', 'BOLD');
% set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')
% legend('Pre','Post');
% 
% subplot(4,1,3)
% errorbarbar(1:4,[pc.pre(m,1),pc.post(m,1);...
% pc.pre(m,2),pc.post(m,2);...
% pc.pre(m,3),pc.post(m,3);...
% pc.pre(m,4),pc.post(m,4)],...
% [0,0;0,0;0,0;0,0],...
% {'grouped'});colormap(cool);
% ylim([0 1]);
% ylabel('pc','Fontsize',18,'FontWeight', 'BOLD');
% set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')
% 
% subplot(4,1,4)
% starbar(pc.learn(m,:), [0 0 0 0], 0);
% ylabel('learn_pc','Fontsize',18,'FontWeight', 'BOLD');
% ylim([0.5 1]);
% set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')
% 
% end


RT.delta = RT.post-RT.pre;
RT.delta_mean = mean(RT.delta);
RT.delta_ste = std(RT.delta)/sqrt(numsubj);

dprime.delta = dprime.post-dprime.pre;
dprime.delta_mean = mean(dprime.delta);
dprime.delta_ste = std(dprime.delta)/sqrt(numsubj);

hit.delta = hit.post-hit.pre;
hit.delta_mean = mean(hit.delta);
hit.delta_ste = std(hit.delta)/sqrt(numsubj);

fa.delta = fa.post-fa.pre;
fa.delta_mean = mean(fa.delta);
fa.delta_ste = std(fa.delta)/sqrt(numsubj);

pc.delta = pc.post-pc.pre;
pc.delta_mean = mean(pc.delta);
pc.delta_ste = std(pc.delta)/sqrt(numsubj);

figure('Color',[ 1 1 1], 'units','norm', 'position', [ .1 .1 .8 .4])

ConditionLabels={'stereo','shade','line','sil'}; 
subplot(1,4,1)
starbar(hit.delta_mean*-1, hit.delta_ste, 0);
% YLIM([0.5 0.9]);
%title('hit');
ylabel('miss post - pre','Fontsize',18,'FontWeight', 'BOLD');
% xlabel('condition', 'Fontsize',18,'FontWeight', 'BOLD');
set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')
% set(gca,'YLim',[0 1])

subplot(1,4,2)
starbar(fa.delta_mean, fa.delta_ste, 0);
% YLIM([0.5 0.9]);
%title('hit');
ylabel('fa post - pre','Fontsize',18,'FontWeight', 'BOLD');
% xlabel('condition', 'Fontsize',18,'FontWeight', 'BOLD');
set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')
% set(gca,'YLim',[0 1])

subplot(1,4,3)
starbar(pc.delta_mean, pc.delta_ste, 0);
% YLIM([0.5 0.9]);
%title('hit');
ylabel('pc post - pre','Fontsize',18,'FontWeight', 'BOLD');
% xlabel('condition', 'Fontsize',18,'FontWeight', 'BOLD');
set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')
% set(gca,'YLim',[0 1])

subplot(1,4,4)
starbar(dprime.delta_mean, dprime.delta_ste, 0);
% YLIM([0.5 0.9]);
%title('hit');
ylabel('dprime post - pre','Fontsize',18,'FontWeight', 'BOLD');
% xlabel('condition', 'Fontsize',18,'FontWeight', 'BOLD');
set(gca,'XtickLabel',ConditionLabels, 'Fontsize',12,'box','off')
% set(gca,'YLim',[-.5 .5],'Ytick', [-.5:.2:.5])

numsubj = size(ind,1);
prepost = [repmat(1,[numsubj*4,1]);repmat(2,[numsubj*4,1])];
order1 = [repmat(1,[numsubj,1]);repmat(2,[numsubj,1]);repmat(3,[numsubj,1]);repmat(4,[numsubj,1]);repmat(1,[numsubj,1]);repmat(2,[numsubj,1]);repmat(3,[numsubj,1]);repmat(4,[numsubj,1])];
group2 = [prepost,order1];
% X2= [reshape(data.pre.pc,numsubj*4,1);reshape(data.post.pc,numsubj*4,1)];
X3= [reshape(data.pre.dprime,numsubj*4,1);reshape(data.post.dprime,numsubj*4,1)];
% mes2way(X2,group2, 'partialeta2');
mes2way(X3,group2, 'partialeta2');


%% plot for the paper
figure('Color',[ 1 1 1], 'units','norm', 'position', [ .1 .1 1 .4])
pc.pre = pc.pre*100;
pc.post = pc.post*100;
ConditionLabels={'Stereo', 'Shade', 'Line', 'Sil'};
subplot(1,2,1);
[b,e]=errorbarbar(1:4,[mean(pc.pre(:,1)),mean(pc.post(:,1));...
    mean(pc.pre(:,2)),mean(pc.post(:,2));...
    mean(pc.pre(:,3)),mean(pc.post(:,3));...
    mean(pc.pre(:,4)),mean(pc.post(:,4))],...
    [std(pc.pre(:,1))/sqrt(numsubj),std(pc.post(:,1))/sqrt(numsubj);...
    std(pc.pre(:,2))/sqrt(numsubj),std(pc.post(:,2))/sqrt(numsubj);...
    std(pc.pre(:,3))/sqrt(numsubj),std(pc.post(:,3))/sqrt(numsubj);...
    std(pc.pre(:,4))/sqrt(numsubj),std(pc.post(:,4))/sqrt(numsubj)],...
    {'grouped'});colormap(gray);
set(b(1), 'facecolor', [0 0 0],'edgecolor',[0 0 0],'linewidth',3);
set(b(2), 'facecolor', [.5 .5 .5],'edgecolor',[.5 .5 .5],'linewidth',3);
set(e(1), 'linestyle','none','linewidth',5,'color',[0 0 0]);
set(e(2), 'linestyle','none','linewidth',5,'color',[.5 .5 .5]);
set(gca,'YLim',[50 90]);
set(gca,'Ytick', 50:10:90);
set(gca,'Xtick', [0.8 2.1 3.1 4],'LineWidth',4);
set(gca,'XtickLabel',ConditionLabels,'FontName','Gill Sans','Fontsize',30,'FontWeight', 'BOLD','box','off');
ylabel('% correct','FontName','Gill Sans','Fontsize',30,'FontWeight', 'BOLD');
h=legend('Pre-learning','Post-learning');
set(h,'box','off','position',[0.3 0.85 0.3 0.1] );



fc = [0.2 0.2 0.2]; %face color
ec = [0.2 0.2 0.2]; %edge color
lc = [0.2 0.2 0.2]; %line color
subplot(1,2,2);
[b,e]=errorbarbar(1, 100*mean(pc.delta(:,1)), 100*pc.delta_ste(1));
set(gca,'YLim',[0 30]);
set(gca,'XLim',[0 9]);
%title('hit');
ylabel('%correct post-pre','FontName','Gill Sans','Fontsize',30,'FontWeight', 'BOLD');
% xlabel('condition', 'Fontsize',18,'FontWeight', 'BOLD');
set(b, 'facecolor', fc,'edgecolor',ec,'linewidth',3);
set(e, 'linestyle','-','linewidth',5,'color',lc);
hold on;
[b,e]=errorbarbar(3, 100*mean(pc.delta(:,2)), 100*pc.delta_ste(2));
set(b, 'facecolor', fc,'edgecolor',ec,'linewidth',3);
set(e, 'linestyle','-','linewidth',5, 'color', lc);
hold on;
[b,e]=errorbarbar(5, 100*mean(pc.delta(:,3)), 100*pc.delta_ste(3));
set(b, 'facecolor', fc,'edgecolor',ec,'linewidth',3);
set(e, 'linestyle','-','linewidth',5, 'color', lc);
hold on;
[b,e]=errorbarbar(7, 100*mean(pc.delta(:,4)), 100*pc.delta_ste(4));
set(b, 'facecolor', fc,'edgecolor',ec,'linewidth',3);
set(e, 'linestyle','-','linewidth',5, 'color', lc);
set(gca,'Xtick', [1 3 5 7], 'Ytick', 0:5:30,'LineWidth',4);
set(gca,'XtickLabel',ConditionLabels,'FontName','Gill Sans', 'Fontsize',30,'FontWeight', 'BOLD','box','off');
hold off;


%% plot for the paper
figure('Color',[ 1 1 1], 'units','norm', 'position', [ .1 .1 1 .4])
dprime.pre = dprime.pre;
dprime.post = dprime.post;
ConditionLabels={'Sil', 'Line', 'Shade', 'Stero'};
subplot(1,2,1);
[b,e]=errorbarbar(1:4,[mean(dprime.pre(:,4)),mean(dprime.post(:,4));...
    mean(dprime.pre(:,3)),mean(dprime.post(:,3));...
    mean(dprime.pre(:,1)),mean(dprime.post(:,2));...
    mean(dprime.pre(:,1)),mean(dprime.post(:,1))],...
    [std(dprime.pre(:,4))/sqrt(numsubj),std(dprime.post(:,4))/sqrt(numsubj);...
    std(dprime.pre(:,3))/sqrt(numsubj),std(dprime.post(:,3))/sqrt(numsubj);...
    std(dprime.pre(:,2))/sqrt(numsubj),std(dprime.post(:,2))/sqrt(numsubj);...
    std(dprime.pre(:,1))/sqrt(numsubj),std(dprime.post(:,1))/sqrt(numsubj)],...
    {'grouped'});colormap(gray);
set(b(1), 'facecolor', [0 0 0],'edgecolor',[0 0 0],'linewidth',3);
set(b(2), 'facecolor', [.5 .5 .5],'edgecolor',[.5 .5 .5],'linewidth',3);
set(e(1), 'linestyle','none','linewidth',5,'color',[0 0 0]);
set(e(2), 'linestyle','none','linewidth',5,'color',[.5 .5 .5]);
set(gca,'YLim',[0 2.5]);
set(gca,'Ytick', 0:0.5:2.5);
set(gca,'Xtick', [0.8 2.1 3.1 4],'LineWidth',4);
set(gca,'XtickLabel',ConditionLabels,'FontName','Gill Sans','Fontsize',30,'FontWeight', 'BOLD','box','off');
ylabel('d prime','FontName','Gill Sans','Fontsize',30,'FontWeight', 'BOLD');
% h=legend('Pre-learning','Post-learning');
set(h,'box','off','position',[0.32 0.85 0.3 0.1] );



fc = [0.2 0.2 0.2]; %face color
ec = [0.2 0.2 0.2]; %edge color
lc = [0.2 0.2 0.2]; %line color
subplot(1,2,2);
[b,e]=errorbarbar(1, mean(dprime.delta(:,4)), dprime.delta_ste(4));
set(gca,'YLim',[-0.4 2]);
set(gca,'XLim',[0 9]);
%title('hit');
ylabel('d prime post-pre','FontName','Gill Sans','Fontsize',30,'FontWeight', 'BOLD');
% xlabel('condition', 'Fontsize',18,'FontWeight', 'BOLD');
set(b, 'facecolor', fc,'edgecolor',ec,'linewidth',3);
set(e, 'linestyle','-','linewidth',5,'color',lc);
hold on;
[b,e]=errorbarbar(3, mean(dprime.delta(:,3)), dprime.delta_ste(3));
set(b, 'facecolor', fc,'edgecolor',ec,'linewidth',3);
set(e, 'linestyle','-','linewidth',5, 'color', lc);
hold on;
[b,e]=errorbarbar(5, mean(dprime.delta(:,2)), dprime.delta_ste(2));
set(b, 'facecolor', fc,'edgecolor',ec,'linewidth',3);
set(e, 'linestyle','-','linewidth',5, 'color', lc);
hold on;
[b,e]=errorbarbar(7, mean(dprime.delta(:,1)), dprime.delta_ste(1));
set(b, 'facecolor', fc,'edgecolor',ec,'linewidth',3);
set(e, 'linestyle','-','linewidth',5, 'color', lc);
set(gca,'Xtick', [1 3 5 7], 'Ytick', -0.4:0.4:2,'LineWidth',4);
set(gca,'XtickLabel',ConditionLabels,'FontName','Gill Sans', 'Fontsize',30,'FontWeight', 'BOLD','box','off');
hold off;



%% plot for the paper
figure('Color',[ 1 1 1], 'units','norm', 'position', [ .1 .1 1 .4])
dprime.pre = dprime.pre;
dprime.post = dprime.post;
ConditionLabels={'Sil', 'Line', 'Shade', 'Stero'};
subplot(1,2,1);
[b,e]=errorbarbar(1:4,[mean(dprime.pre(:,4)),mean(dprime.post(:,4));...
    mean(dprime.pre(:,3)),mean(dprime.post(:,3));...
    mean(dprime.pre(:,2)),mean(dprime.post(:,2));...
    mean(dprime.pre(:,1)),mean(dprime.post(:,1))],...
    [std(dprime.pre(:,4))/sqrt(numsubj),std(dprime.post(:,4))/sqrt(numsubj);...
    std(dprime.pre(:,3))/sqrt(numsubj),std(dprime.post(:,3))/sqrt(numsubj);...
    std(dprime.pre(:,2))/sqrt(numsubj),std(dprime.post(:,2))/sqrt(numsubj);...
    std(dprime.pre(:,1))/sqrt(numsubj),std(dprime.post(:,1))/sqrt(numsubj)],...
    {'grouped'});colormap(gray);
set(b(1), 'facecolor', [0 0 0],'edgecolor',[0 0 0],'linewidth',3);
set(b(2), 'facecolor', [.5 .5 .5],'edgecolor',[.5 .5 .5],'linewidth',3);
set(e(1), 'linestyle','none','linewidth',5,'color',[0 0 0]);
set(e(2), 'linestyle','none','linewidth',5,'color',[.5 .5 .5]);
set(gca,'YLim',[0 1]);
set(gca,'Ytick', 0:0.2:1);
set(gca,'Xtick', [0.8 2.1 3.1 4],'LineWidth',4);
set(gca,'XtickLabel',ConditionLabels,'FontName','Gill Sans','Fontsize',30,'FontWeight', 'BOLD','box','off');
ylabel('d prime','FontName','Gill Sans','Fontsize',30,'FontWeight', 'BOLD');
% h=legend('Pre-learning','Post-learning');
set(h,'box','off','position',[0.32 0.85 0.3 0.1] );



fc = [0.2 0.2 0.2]; %face color
ec = [0.2 0.2 0.2]; %edge color
lc = [0.2 0.2 0.2]; %line color
subplot(1,2,2);
[b,e]=errorbarbar(1, mean(dprime.delta(:,4)), dprime.delta_ste(4));
set(gca,'YLim',[-0.4 0.8]);
set(gca,'XLim',[0 9]);
%title('hit');
ylabel('d prime post-pre','FontName','Gill Sans','Fontsize',30,'FontWeight', 'BOLD');
% xlabel('condition', 'Fontsize',18,'FontWeight', 'BOLD');
set(b, 'facecolor', fc,'edgecolor',ec,'linewidth',3);
set(e, 'linestyle','-','linewidth',5,'color',lc);
hold on;
[b,e]=errorbarbar(3, mean(dprime.delta(:,3)), dprime.delta_ste(3));
set(b, 'facecolor', fc,'edgecolor',ec,'linewidth',3);
set(e, 'linestyle','-','linewidth',5, 'color', lc);
hold on;
[b,e]=errorbarbar(5, mean(dprime.delta(:,2)), dprime.delta_ste(2));
set(b, 'facecolor', fc,'edgecolor',ec,'linewidth',3);
set(e, 'linestyle','-','linewidth',5, 'color', lc);
hold on;
[b,e]=errorbarbar(7, mean(dprime.delta(:,1)), dprime.delta_ste(1));
set(b, 'facecolor', fc,'edgecolor',ec,'linewidth',3);
set(e, 'linestyle','-','linewidth',5, 'color', lc);
set(gca,'Xtick', [1 3 5 7], 'Ytick', -0.4:0.2:0.8,'LineWidth',4);
set(gca,'XtickLabel',ConditionLabels,'FontName','Gill Sans', 'Fontsize',30,'FontWeight', 'BOLD','box','off');
hold off;





