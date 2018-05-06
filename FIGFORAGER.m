%% FIGFORAGER

clc; close all; clear

[FileName,PathName,FilterIndex] = uigetfile({'*'},'Select Image File');

FILE.FileName = FileName;
FILE.PathName = PathName;
FILE.FullPath = [PathName FileName];


RGB = imread(FILE.FullPath);

IMG = imnorm(FILE.FullPath);

info.szRGB = size(RGB);
info.szIMG = size(IMG);
info.Ratio = info.szIMG(2)/info.szIMG(1);


clearvars -except FILE RGB IMG info


%% DISPLAY IMAGE

clc; close all
fh1 = figure('Units','normalized','OuterPosition',[.01 .04 .95 .93],'Color','w');
ax1 = axes('Position',[.05 .05 .9 .9],'Color','none','YDir','reverse');


% ph1 = imshow(RGB,'Border','tight'); pause(1)
ph1 = imagesc(IMG);
colormap bone
axis equal; axis tight

fig.fh1 = fh1;
fig.ax1 = ax1;
fig.ph1 = ph1;

clearvars -except FILE RGB IMG info fig


%% GET MIN AND MAX VALUES FOR EACH AXIS

prompt = {'Enter X-axis min value displayed on graph:',...
          'Enter X-axis max value displayed on graph:',...
          'Enter Y-axis min value displayed on graph:',...
          'Enter Y-axis max value displayed on graph:'};
dlg_title = 'Input'; num_lines = 1;
def = {'0','100','0','100'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
axvals = str2double(answer);


info.axvals = axvals;

clearvars -except FILE RGB IMG info fig


%% DRAW AXES

disp('Use pointer to draw line from x-axis min to x-axis max')
% [Xx,Xy] = ginput(2);
h = imline(fig.ax1);
xax = getPosition(h);



disp('Use pointer to draw line from y-axis min to y-axis max')
% [Yx,Yy] = ginput(2);
h = imline(fig.ax1);
yax = getPosition(h);



disp('Draw smallest possible box around data points;')
disp('try to avoid including axes ticks and other decor')
% hROI = imfreehand(fig.ax1, 'Closed',1);
% pos  = getPosition(hROI);
hROI = imrect(fig.ax1);
pos  = getPosition(hROI);


ax.xax = xax;
ax.yax = yax;
ax.pos = pos;


clc
disp('X-axis: ');     disp(ax.xax); disp(' ');
disp('Y-axis: ');     disp(ax.yax); disp(' ');
disp('Data bounds:'); disp(ax.pos); disp(' ');

clearvars -except FILE RGB IMG info fig ax





%% IDENTIFY DATAPOINTS

% Get data from inside bounds

xywh = ax.pos;
x = xywh(1);
y = xywh(2);
w = xywh(3);
h = xywh(4);

r1 = round(y);
r2 = round(y+h);

c1 = round(x);
c2 = round(x + w);

% IM = IMG(r1:r2,c1:c2);

IM = IMG;
IM(1:(r1-1),:)   = 1;
IM((r2+1):end,:) = 1;
IM(:,1:(c1-1))   = 1;
IM(:,(c2+1):end) = 1;



clc; try close(fh2);catch;end
fh2 = figure('Units','normalized','OuterPosition',[.05 .05 .8 .9],'Color','w');
ax2 = axes('Position',[.05 .05 .9 .9],'Color','none','YDir','reverse');
colormap hot;

ph2 = imagesc(IM);  disp('Original data')
axis equal; axis tight; pause(1)


bw = 1-imbinarize(IM);

ph3 = imagesc(IM);  disp('Binarized data')
axis equal; axis tight; pause(1)



[B,L,n,A] = bwboundaries(bw,'noholes');
IMB = B; IML = L; IBW = bw;


I = label2rgb(IML, @jet, [.5 .5 .5]);

ph4 = imagesc(I);  disp('Labeled data')
axis equal; axis tight; pause(1)




IMM = IBW+(1-imbinarize(IMG));

ph5 = imagesc(IMM);  disp('Orig + Labeled data')
axis equal; axis tight; pause(1)


hold on
for k = 1:length(IMB)
   boundary = IMB{k};
   plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2)
end


fig.fh2 = fh2;
fig.ax2 = ax2;

clearvars -except FILE RGB IMG info fig ax IMB IML IMW IMM


%% DISPLAY IMAGE

clc; try close(fh2);catch;end
clc; try close(fh10);catch;end
fh10 = figure('Units','normalized','OuterPosition',[.01 .04 .95 .93],'Color','w');
ax10 = axes('Position',[.05 .05 .9 .9],'Color','none','YDir','reverse');


% ph1 = imshow(RGB,'Border','tight'); pause(1)
ph10 = imagesc(IMG);
colormap gray
axis equal; axis tight


hold on
for k = 1:length(IMB)
   boundary = IMB{k};
   plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2)
end


fig.fh10 = fh10;
fig.ax10 = ax10;
fig.ph10 = ph10;


clearvars -except FILE RGB IMG info fig ax IMB IML IMW IMM



%% SCALE POINTS TO DRAWN AXES

lintrans = @(x,a,b,c,d) (c*(1-(x-a)/(b-a)) + d*((x-a)/(b-a)));

fx = @(x) mean(x);

posi = cell2mat(cellfun(fx,IMB,'UniformOutput',0));


basebottom = info.szIMG(1) - mean(ax.xax(:,2));
baseleft   = mean(ax.yax(:,1));

pos = [posi(:,1)-basebottom  posi(:,2)-baseleft];


posx = zeros(size(posi,1),1);
posy = zeros(size(posi,1),1);

for nn = 1:size(posi,1)

    posx(nn) = lintrans(posi(nn,2), ax.xax(1,1), ax.xax(2,1),...
                        info.axvals(1),info.axvals(2));

    posy(nn) = lintrans(posi(nn,1), ax.yax(1,2), ax.yax(2,2),...
                        info.axvals(3),info.axvals(4));

end
pos = [posx posy];
disp(pos)



clc; try close(fh2);catch;end
clc; try close(fh10);catch;end
clc; try close(fh20);catch;end
clc; try close(fh21);catch;end
fh20 = figure('Units','normalized','OuterPosition',[.01 .04 .7 .8],'Color','w');
ax20 = axes('Position',[.05 .05 .9 .9],'Color','none');

ph20 = scatter(pos(:,1),pos(:,2),150,'filled');
ylim([info.axvals(3:4)])
xlim([info.axvals(1:2)])
grid on
ax20.FontSize = 16;
ax20.FontWeight = 'bold';


fh21=figure('Units','normalized','OuterPosition',[.70 .04 .15 .8],'Color','w','MenuBar','none');
t = uitable(fh21,'Data',[{'X','Y'}; num2cell(pos)],...
'Units','normalized','Position',[.01 .01 .98 .95]);


% save('pos.mat','pos','posx','posy')
% load('pos.mat')


%% MAKE POINTS MONOTONIC ASCENDING AND INTERPOLATE DRAWN POINTS
%{
posx = sort(posx);

[X,iposx,iX] = unique(posx);
Y = posy(iposx);

xv = X(1):1/(numel(X)*10):X(end);

yv = interp1(X,Y,xv);

plot(xv,yv)


%% RESAMPLE TO DESIRED SAMPLE RATE OR TOTAL NUMBER OF SAMPLES

pospairs = numel(xv);
currentsamplerate = pospairs / (axvals(2) - axvals(1));

spf1 = sprintf('\n the pos vector currently contains % 2.0f xy pairs \n',pospairs);
spf2 = sprintf('\n that is approximately % 2.1f pairs per graph unit \n',currentsamplerate);

h = msgbox({spf1, spf2});
uiwait(h)

% Construct a questdlg with three options
choice = questdlg('Which value do you want to specify for a sampling rate', ...
	'Sampling Rate', ...
	'Samples per unit','Total samples','Total samples');
% Handle response
switch choice
    case 'Samples per unit'
        disp([choice ' was the choice, maybe this will work.'])
        sr = 1;
    case 'Total samples'
        disp([choice ' is a good choice.'])
        sr = 0;
end

prompt = {['Enter desired ',choice]};
dlg_title = 'Input'; num_lines = 1;
if sr
def = {int2str(currentsamplerate)};
else
def = {int2str(pospairs)};
end
answer = inputdlg(prompt,dlg_title,num_lines,def);
newsr = str2double(answer);


if sr
    
    
    axrange = axvals(2) - axvals(1);
    
    nsr = newsr * axrange;
    
    nx = numel(xv);

    x = xv(1:nx/nsr:end);

    if numel(x) > nsr

        x(end+1-(numel(x) - nsr):end) = [];

    elseif numel(x) < nsr

        x = xv(1:floor(nx/nsr):end);
        x(end+1-(numel(x) - nsr):end) = [];

    end
    
    
else
    
    nsr = newsr;

    nx = numel(xv);

    x = xv(1:nx/nsr:end);

    if numel(x) > nsr

        x(end+1-(numel(x) - nsr):end) = [];

    elseif numel(x) < nsr

        x = xv(1:floor(nx/nsr):end);
        x(end+1-(numel(x) - nsr):end) = [];

    end

end


y = interp1(xv,yv,x);


fh3=figure('Units','normalized','OuterPosition',[.05 .05 .8 .9],'Color','w');
hax3 = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[]);
plot(x,y);


xy = [x;y]';

disp(' ')
disp('''xy'' is your new variable of xy pairs,')
spf1 = sprintf(' and has % 2.0f xy pairs \n',numel(xy(:,1)));
disp(spf1)



%%

save('xy.mat','xy')
load('xy.mat')


%%

xxyy = [xy(1:1000:end,1),xy(1:1000:end,2)];

plot(xxyy(1:5:end,1),xxyy(1:5:end,2))


xxyy(:,1) = xxyy(:,1)-(60+1.723076923076922)


se = xxyy.*0 + .1;

se = se + (linspace(0,.1,420))'


sm = se + rand(420,1).*.05

sm = sm + (linspace(0,.1,420))';

sm = sm + rand(420,1).*.05


xxy = sqrt(xxyy(:,2)) + rand(420,1).*.05

sm = sm./2

%}
%%

