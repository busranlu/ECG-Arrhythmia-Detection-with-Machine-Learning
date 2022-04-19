%% PREPROCESSİNG
%sinyal değişimi
l=length(val);
data=zeros(l,1);
for i=1:l
    data(i,1)=val(1,i);
end

%to correct the baseline and remove unwanted high frequency noise. 
% A Butterworth high-pass filter (with a cutoff frequency νc = 0.5 Hz) and 
% a finite impulse response filter of 12th order (35 Hz, at 3-dB point) are used
fs=360;                           %örnekleme frekansı
Ws=2*pi*fs;                       %W olarak örnekleme frekansı
Ts= 1/fs;                         %periyot

%sinyalin ekrana çizdirilmesi
% time = (0:length(data)-1)/fs; 
% plot(time,data); title('ECG Signal');
% xlabel('Time (Seconds)')
% ylabel('Frequency (Amplitude)')
% title('Subject 01')

% %% highpass filter design
% N1=5;                            %filtre derecesi
% fc1=0.5;                         %cutoff frequency
% Wc1=2*pi*fc1;                    %W olarak cutoff frekansı
% fn1= fc1/(fs/2);                 %normalizasyon frekansı
% Wn1= Wc1/(Ws/2);                 %normalize değer
% [b,a] = butter(N1,Wn1,'high');   %filtre tasarımı butterworth
% highpassOut=filtfilt(b,a,d03);
% 
% %% lowpass filter design
% N2=5;
% fc2=80;
% Wc2=2*pi*fc2;                    %W olarak cutoff frekansı
% fn2= fc2/(fs/2);                 %normalizasyon frekansı
% Wn2= Wc2/(Ws/2);                 %normalize değer
% [b1,a1]=butter(N2,Wn2);
% lowpassOut=filtfilt(b1,a1,highpassOut);
% 
% %% notch filter design
% wo= 50/(500/2);
% bw= wo;
% [b3,a3] = iirnotch(wo,bw);
% notchOut=filter(b3,a3,lowpassOut);
% 
% subplot(2,2,1);
% plot(b02);
% subplot(2,2,2);
% plot(highpassOut);
% subplot(2,2,3);
% plot(lowpassOut);
% subplot(2,2,4);
% plot(notchOut);

%% R WAVE FINDING
%lowpass filter
N1=5;
fc3=12;
Wc3=2*pi*fc3; 
Wn3= Wc3/(Ws/2); 
[b3,a3] = butter(N1,Wn3);  %filtre tasarımı butterworth
lp=filtfilt(b3,a3,data);

%highpass filter
fc4=0.5;
Wc4=2*pi*fc4;
Wn4= Wc4/(Ws/2);
[b5,a5] = butter(N1,Wn4,'high');  %filtre tasarımı butterworth
hp=filtfilt(b5,a5,lp);

% %notch filter
% wo= 50/(500/2);
% bw= wo/35;
% [b6,a6] = iirnotch(wo,bw);
% notchOut=filtfilt(b6,a6,hp);
% 
% subplot(3,1,1)
% plot(data)
% subplot(3,1,2)
% plot(lp)
% subplot(3,1,3)
% plot(hp)


%sinyalin türevinin alınması
der = diff(hp,3);


%squaring
sqr=(der).^2;

%moving window averaging
%qrs complex is 0,12sec and equals apr. 120 samples for 360Hz sampling frequency
N=120;
aguSignal = zeros(length(sqr) + 2 * N - 1,1);
mwin = zeros(length(aguSignal),1);
for j =1:length(sqr)
    aguSignal(N - 1 + j,1) = sqr(j,1);
end

for i = 1:length(aguSignal)-N
    sum = 0;
    for j = i: N + i
        sum =sum+ aguSignal(j,1);
    end
    mwin(i,1) = sum / N;
end

mwin = movmean(sqr,40);


% R lerin bulunması için threshold belirleme
maxValue = 0;
maxIndex = 0;
temp=zeros(500,1);
for i = 1:500        
    temp(i,1) = mwin(i,1);    
    if (maxValue < temp(i,1))
        maxValue = temp(i,1);
         maxIndex = i;
    end
end          

signallvl = maxValue;
signallvl_pos = maxIndex;

temp2 = zeros(580,1);
maxValue2 = 0;
for i = signallvl_pos + 40: signallvl_pos + 72   
    temp2(i,1) = mwin(i,1);
    if (temp2(i,1) > maxValue2)
        maxValue2 = temp2(i,1);     
    end
end


noiselvl = maxValue2;         
threshold = (noiselvl + 0.2 * signallvl);
threshold=threshold-0.001;

% %other threshold finding way-- not used
% tem = zeros(580,1); 
% for j = 1:580
%     tem(j,1) = mwin(j,1);
% end
% m_val = max(tem);
% signallvl = 0.13 * m_val;         
% noiselvl = 0.1 * signallvl;      
% threshold2 = (signallvl * 0.25 + noiselvl * 0.75)*10;
% 
% subplot(2,1,1);
% plot(mwin);
% hold 
% yline(threshold2);
% subplot(2,1,2);
% plot(d03);
% 
% %other one, too small
% TH1 = 0.3125;
% TH2 = 0.475;
% threshold1 = noiselvl + TH2 * (signallvl - noiselvl);

% subplot(2,1,1);
% plot(data);
% subplot(2,1,2);
% plot(mwin);
% hold 
% yline(threshold);


%% thresholdu geçen yerleri bulmak için threshold üzerindeki verilere 1 atama
onesZeros=zeros(length(mwin),1);
for i = 1:length(mwin)
    if (mwin(i,1) >= threshold)
     onesZeros(i,1) = 1;
    end
end

%ecg sinyalinde threshold geçen yerlerin samplelarını belirleme
ones=zeros(length(mwin),1);
boolen = true;
p = 1;

for i = 1:length(onesZeros)
   if onesZeros(i,1) == 1 && boolen == true    
     ones(p,1) = i;
     boolen = false;
     p=p+1;   
   elseif onesZeros(i,1) == 0 && boolen==false     
    boolen = true;
    end
end


count=0;
for i=1:length(ones)
    if ones(i,1) ~=0
        count=count+1;
    end
end
 one=zeros(count,1);
 for i=1:length(ones)
    if ones(i,1) ~=0
        one(i,1)=ones(i,1);
    end
end

%kontrol için ekrana çizdirme
% plot(time(data),one(data), 'o');
% plot(time,d03,time(one),d03(one),'rv','MarkerFaceColor','r'); grid on
%     xlabel('Time'); ylabel('Voltage');
%     title('Find Prominent Peaks');

%% Thresholdu geçen yerelere atanan 1lerin belirli aralığında ana sinyalde Rleri arama
a=length(one);
rValueArray = zeros(a,1);
rIndexArray = zeros(a,1);
tempValue = 0;
first1 = 0;
interval=60;
 k=1;

for i = 1:length(one)
   
    if one(i,1) ~= 0
        first1 = one(i,1);
        tempValue = data(first1,1);
        for j =first1 - interval:first1 + interval
            if (j >= length(data))
                break;

            elseif j > 0 && tempValue <= data(j,1)
                tempValue = data(j,1);
                rValueArray(k,1) = data(j,1);
                rIndexArray(k,1) = j;
              
            elseif j < 0
                j = 1;
                tempValue = data(j,1);
                rValueArray(k,1) = data(j,1);
                rIndexArray(k,1) = j;
                
            end
        end  
    else
        break;
    end 
    k=k+1;
end
  

%ekrana bütün basamakların çizdirilmesi
subplot(2,2,1);
plot(der);

subplot(2,2,2);
plot(sqr);

subplot(2,2,3);
plot(mwin);
hold 
yline(threshold);

subplot(2,2,4);
plot(data,'-p','MarkerIndices',rIndexArray,...
    'MarkerFaceColor','red',...
    'MarkerSize',9);

%% Q bulma algortiması
q1Index = 0;
q2Index = 0;
interval1=55;
interval2=111;
tempList=zeros(length(rIndexArray),1);
qPointIndex=zeros(length(rIndexArray),1);

for z=1:length(rIndexArray)
   q1Value = data(z);
   q2Value = data(z);
   MVqq = 0;
   Tv = 0.18;
   rSample=rIndexArray(z,1);

   if rSample - interval1 >= 0
      for k = rSample - interval1:rSample      
         if data(k,1) <= q1Value
            q1Value = data(k,1);
            q1Index = k;
         end
       end
    end

    if rSample - interval2 >= 0
       for m = rSample - interval2:rSample       
          if data(m,1) < q2Value
             q2Value = data(m,1);
             q2Index = m;
          end
        end
    end

    if rSample - interval2 <= 0
        for n = 1:rSample       
          if data(n,1) < q2Value
             q2Value = data(n,1);
             q2Index = n;
          end
        end
    end

   Vq1 = data(q1Index,1);
   Vq2 = data(q2Index,1);

      if Vq1== Vq2
            
            qPointIndex(z,1) = q1Index;
      else
             for i = q1Index:q2Index
                tempList(i,1)=data(i,1);
             end
                MVqq = max(tempList);
             
            if  MVqq > (Vq1 + Tv)
                   qPointIndex(z,1) = q2Index;
            else
                  if Vq2 > Vq1
                    qPointIndex(z,1) = q1Index;
                  else
                    qPointIndex(z,1) = q2Index;
                  end
            end
      end
     
end

% plot(data,'-o','MarkerIndices',qPointIndex,...
%     'MarkerFaceColor','green',...
%     'MarkerSize',5);

%% S bulma algortiması
q3Index = 0;
q4Index = 0;
interval3=55;
interval4=111;
tempList=zeros(length(rIndexArray),1);
sPointIndex=zeros(length(rIndexArray),1);

for z=1:length(rIndexArray)
   q3Value = data(z);
   q4Value = data(z);
   MVqq = 0;
   Tv = 0.18;
   rSample=rIndexArray(z,1);

   if rSample + interval3 <= length(data)
      for k = rSample :rSample + interval3     
         if data(k,1) <= q3Value
            q3Value = data(k,1);
            q3Index = k;
         end
       end
    end

    if rSample + interval4 <= length(data)
       for m = rSample :rSample + interval4      
          if data(m,1) <= q4Value
             q4Value = data(m,1);
             q4Index = m;
          end
        end
    end

    if rSample + interval4 > length(data)
        for n = rSample:length(data)       
          if data(n,1) <= q4Value
             q4Value = data(n,1);
             q4Index = n;
          end
        end
    end

   Vq1 = data(q3Index,1);
   Vq2 = data(q4Index,1);

      if Vq1== Vq2
            
            sPointIndex(z,1) = q3Index;
      else
             for i = q3Index:q4Index
                tempList(i,1)=data(i,1);
             end
                MVqq = max(tempList);
             
            if  MVqq > (Vq1 + Tv)
                   sPointIndex(z,1) = q4Index;
            else
                  if Vq2 > Vq1
                    sPointIndex(z,1) = q3Index;
                  else
                    sPointIndex(z,1) = q4Index;
                  end
            end
      end
     
end

%ekrana Q,R,ve S noktalarının ana sinyalde çizdirilmesi
 hold on
plot(data,'-o','MarkerIndices',sPointIndex,...
    'MarkerFaceColor','blue',...
    'MarkerSize',5);
plot(data,'-o','MarkerIndices',qPointIndex,...
    'MarkerFaceColor','green',...
    'MarkerSize',5);
plot(data,'-p','MarkerIndices',rIndexArray,...
    'MarkerFaceColor','red',...
    'MarkerSize',9);
hold off

%% Baseline Filtering, baseline filtrelenmiş sinyal üstünde Q,R,S noktalarının gösterilmesi
%Highpass filter design

N=5;                %filtre derecesi
fcb=0.67;             %cutoff frequency
Wcb=2*pi*fcb;         %W olarak cutoff frekansı
fnb= fcb/(fs/2);       %normalizasyon frekansı
Wnb= Wcb/(Ws/2);       %normalize değer
Wnb= fcb/(fs/2);                %W olarak normalizasyon frekansı

[bb,ab] = butter(N,Wnb,'high');  %filtre tasarımı butterworth
data2=filtfilt(bb,ab,data);
 
%ekrana çizdirilmesi
hold on
plot(data2,'-o','MarkerIndices',sPointIndex,...
    'MarkerFaceColor','blue',...
    'MarkerSize',5);

plot(data2,'-o','MarkerIndices',qPointIndex,...
    'MarkerFaceColor','green',...
    'MarkerSize',5);
plot(data2,'-p','MarkerIndices',rIndexArray,...
    'MarkerFaceColor','red',...
    'MarkerSize',9);
hold off

%% Feature çıkarılması aşamasına geçilmesi
%y ekseninin normalize edilmesi, R amplitude değerlerinin bulunması için

maxPoint=max(data2);
data3=zeros(length(data2),1);
for i=1:length(data2)
    data3(i,1)=data2(i,1)/maxPoint;
end

%% R dalgaları arasındaki intervali bulmak için R indexlerinin saniyeye çevirilmesi
rTime=zeros(length(rIndexArray),1);
for i=1:length(rIndexArray)
    rTime(i,1)=rIndexArray(i,1)/360;
end

%% R Amplitude Finding (sn)
rAmplitude=zeros(length(rIndexArray),1);
for i=1:length(rIndexArray)
    initial=rIndexArray(i,1);
    rAmplitude(i,1)=data3(initial,1);
end

%% QRS Wide Finding (sn)
qrsInterval=zeros(length(rIndexArray),1);
for i=1:length(qPointIndex)
qrsInterval(i,1)=(sPointIndex(i,1)-qPointIndex(i,1))/360;
end

%% RR Interval Finding (sn)
rrIntervals=zeros(length(rIndexArray)-1,1);
for i=1:(length(rIndexArray)-1)
    rrIntervals(i,1)=rTime(i+1,1)-rTime(i,1);
end
