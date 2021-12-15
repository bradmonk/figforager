%% FIGFORAGER
%==========================================================================
clc; close all; clear; rng('shuffle');
P.home  = 'C:\Path\To\Project\Folder';
cd(P.home);
P.fun   = [P.home filesep 'figs'];
addpath( join(string(struct2cell(P)),pathsep,1) )
cd(P.home); P.f = filesep;




%% SELECT AN IMAGE OF A FIGURE
%==========================================================================
clearvars -except P



[FileName,PathName,FilterIndex] = uigetfile({'*'},'Select Image File');

P.FigFileName = FileName;
P.FigPathName = PathName;
P.FigFullPath = [PathName FileName];






%% READ IMAGE OF FIGURE
%==========================================================================
clc; close all; clearvars -except P



RGB = imread(P.FigFullPath);

IMG = imnorm(P.FigFullPath);

%imshow(RGB)


INFO.szRGB = size(RGB);
INFO.szIMG = size(IMG);

INFO.WidthByHeightRatio = size(IMG,2)/size(IMG,1);








%% GET MIN AND MAX VALUES FOR EACH AXIS
%==========================================================================
clc; close all; clearvars -except P RGB IMG INFO


close all; imshow(RGB,'InitialMagnification','fit')
truesize([700 1200]);

prompt = {'Enter X-axis min value displayed on graph:',...
          'Enter X-axis max value displayed on graph:',...
          'Enter Y-axis min value displayed on graph:',...
          'Enter Y-axis max value displayed on graph:'};
dlg_title = 'Input'; num_lines = 1;
def = {'0','1','0','1'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
axvals = str2double(answer);


INFO.axvals = axvals;




%% DRAW AXES
%==========================================================================
clc; close all; clearvars -except P RGB IMG INFO

% Get computer monitor screen dimensions (UI.ScreenSize)
UI=groot;

ss = [ 50, 50, round(UI.ScreenSize(3)*.85), round(UI.ScreenSize(4)*.85) ];

fig = figure('Units','pixels','Position',ss,'Color','w');
ax1 = axes('Position',[.12 .14 .82 .8],'Color','none');
ph1 = image(RGB); axis equal; axis off;



disp('Use mouse to draw a line along the full x-axis (min to max)')
AX.X = drawline(ax1);

disp('Use mouse to draw a line along the full y-axis (min to max)')
AX.Y = drawline(ax1);

AX.Xpos = AX.X.Position;
AX.Ypos = AX.Y.Position



disp('Draw smallest possible box around data points;')
disp('  (try to avoid including axes ticks and other decor)')
AX.R = drawrectangle(ax1);

AX.POS = AX.R.Position;


clc
disp('X-axis: ');     disp(AX.X.Position); disp(' ');
disp('Y-axis: ');     disp(AX.Y.Position); disp(' ');
disp('Data bounds:'); disp(AX.POS); disp(' ');








%% IDENTIFY DATAPOINTS
%==========================================================================
clc; clearvars -except P RGB IMG INFO AX




% Get data from inside bounds

xywh = AX.POS;
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




%% DISPLAY IMAGE
clc; close all; clearvars -except P RGB IMG INFO AX IMB IML IMW IMM

clc; try close(fh2);catch;end
clc; try close(fh10);catch;end
fh10 = figure('Units','normalized','OuterPosition',[.01 .04 .95 .93],'Color','w');
ax10 = axes('Position',[.05 .05 .9 .9],'Color','none','YDir','reverse');


% ph1 = imshow(RGB,'Border','tight'); pause(1)
ph10 = imagesc(IMG);
colormap gray
axis equal
axis tight
axis off



hold on
for k = 1:length(IMB)
   boundary = IMB{k};
   plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2)
end


fig.fh10 = fh10;
fig.ax10 = ax10;
fig.ph10 = ph10;






%% SCALE POINTS TO DRAWN AXES
clc; close all; clearvars -except P RGB IMG INFO AX IMB IML IMW IMM

lintrans = @(x,a,b,c,d) (c*(1-(x-a)/(b-a)) + d*((x-a)/(b-a)));

fx = @(x) mean(x);

posi = cell2mat(cellfun(fx,IMB,'UniformOutput',0));


basebottom = INFO.szIMG(1) - mean(AX.Xpos(:,2));
baseleft   = mean(AX.Ypos(:,1));

pos = [posi(:,1)-basebottom  posi(:,2)-baseleft];


posx = zeros(size(posi,1),1);
posy = zeros(size(posi,1),1);

for nn = 1:size(posi,1)

    posx(nn) = lintrans(posi(nn,2), AX.Xpos(1,1), AX.Xpos(2,1),...
                        INFO.axvals(1),INFO.axvals(2));

    posy(nn) = lintrans(posi(nn,1), AX.Ypos(1,2), AX.Ypos(2,2),...
                        INFO.axvals(3),INFO.axvals(4));

end
pos = [posx posy];
disp(pos)



clc; try close(fh2);catch;end
clc; try close(fh10);catch;end
clc; try close(fh20);catch;end
clc; try close(fh21);catch;end
fh20 = figure('Units','normalized','OuterPosition',[.01 .04 .7 .85],'Color','w');
ax20 = axes('Position',[.10 .12 .8 .8],'Color','none');

ph20 = scatter(pos(:,1),pos(:,2),150,'filled');
ylim([INFO.axvals(3:4)])
xlim([INFO.axvals(1:2)])
grid on
ax20.FontSize = 16;
ax20.FontWeight = 'bold';

fh21=figure('Units','normalized','OuterPosition',[.70 .04 .15 .85],'Color','w','MenuBar','none');
t = uitable(fh21,'Data',[{'X','Y'}; num2cell(pos)],...
'Units','normalized','Position',[.03 .01 .95 .95], 'FontSize', 11, 'FontName', 'Calibri');

