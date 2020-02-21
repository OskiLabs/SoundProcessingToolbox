%Wyznaczanie wsp�czynnik�w HFCC (Human-Factor Cepstral Coefficients) dla sygna�u jednowymirowego (x)
%autor: l.laszko@ita.wat.edu.pl 
%2015
function [H,FbHfcc] = hfcc (x, Noc, Ws, Ovr, Nfft, Fs, Nof)

%parametry wej�ciowe
%x      - sygna�
%Noc    - liczba wyznaczanych wsp�czynnik�w na fragment .....(dft. 20).....
%Ws     - rozmiar okna .....(dft. 512)..... 
%Ovr    - rozmiar nak�adania .....(dft. Ws/2 = 256)..... 
%Fs     - cz�stotliwo�� pr�bkowania wprowadzonego sygna�u .....(dft. 22050).....
%Nfft   - liczba wsp�czynnik�w FFT .....(dft. 1024).....
%Nof    - liczba filtr�w w banku filtr�w.....(dft. 30).....

%parametry wyj�ciowe:
%M      - macierz wsp�czynnik�w HFCC
%FbMfcc - macierz banku filtr�w

if(nargin<1),
    error ('Brak sygna�u do wyznaczenia wsp�czynnik�w HFCC!');     
end

if size(x,1)>1 && size(x,2)>1
   error('Wprowadzony sygna� nie jest wektorem jednowymiarowym');
end

if (nargin<2 || isempty(Noc)),
    Noc=20;
end
if (nargin<3 || isempty(Ws)),
    Ws=512; 
end
if (nargin<4 || isempty(Ovr)),
    Ovr=Ws/2; 
end
if (nargin<5 || isempty(Nfft)),
    Nfft=1024; 
end
if (nargin<6 || isempty(Fs)),
    Fs=11025; 
    
end
if (nargin<7 || isempty(Nof)),
    Nof=30; 
end

if (Noc >= Nof)
    error ('Liczba wsp�czynnik�w musi by� mniejsza ni� liczba filtr�w!');
end
if (Ovr >= Ws)
    error ('Rozmiar nak�adania musi by� mniejszy ni� rozmiar okna!');
end

fRange=[100 4600];

MinF=fRange(1);
MaxF=fRange(2);

%funkcja zmiany skali na melow�
mel=inline('2595*log10(1+f/700)');
melInv=inline('700*(10.^(m/2595)-1)');

%funkcja wyznaczania pasma ERB
ERB=inline('3*(6.23*(f/1000).^2 + 93.39*(f/1000) + 28.52)');

Nfft2=floor(Nfft/2);
Step=Ws-Ovr;

%%%
%%1. Podzia� wprowadzonego sygna�u x
%%%

xLp=length(x);

%obliczenie rozmiaru macierzy
nCols=floor(xLp/Step);
nRows=Ws;

%uzpe�nienie sygna�u zerami
x=[x ; zeros((nRows+Step*(nCols-1)-xLp),1)];

%przgotowanie nak�adania
indCols=1:Step:nCols*Step;
indRows=0:nRows-1;

indColsMat=repmat(indCols,nRows,1);
indRowsMat=repmat(indRows(:),1,nCols);

indRowCol=indColsMat+indRowsMat;

%podzia� sygna�u
X=x(indRowCol);

%wyg�adzanie sygna�u za pomoc� okna
X=X.*repmat(hamming(nRows),1,nCols);

%%%
%2. Wyznaczenie warto�ci bezwzgl�dnej transformaty Fourier'a
%%%

Y=fft(X,Nfft);
Y=abs(Y(1:Nfft2,:));

%%%
%3. Utwo�enie banku filtru
%%%

MelMinf=mel(MinF);
MelMaxf=mel(MaxF);

CfreqMel=linspace(MelMinf,MelMaxf,Nof);
Cfreq=melInv(CfreqMel);

%wyznaczenie macierzy banku filtr�w
ktSec=[1:Nfft2]*Fs/Nfft;
FbHfcc=zeros(Nof,Nfft2);

%przygotowanie macierzy cz�stotliwo�ci
kAid=repmat(ktSec,Nof-2,1);

%przygotowanie macierzy cz�stotliwo�ci �rodkowych
Lfreq=Cfreq(2:Nof-1)-0.5*ERB(Cfreq(2:Nof-1));
Hfreq=Cfreq(2:Nof-1)+0.5*ERB(Cfreq(2:Nof-1));
mAidLow=repmat(Lfreq',1,Nfft2);
mAidMid=repmat(Cfreq(2:Nof-1)',1,Nfft2);
mAidHigh=repmat(Hfreq',1,Nfft2);

%wyznaczenie indeks�w element�w macierzy spe�niaj�cych poni�sze kryteria: 
[indML,indKL]=find(kAid<mAidMid & kAid>=mAidLow);
[indMH,indKH]=find(kAid<mAidHigh & kAid>=mAidMid);

%zmiana adresacji kwadratowej na liniow�
indAidL=sub2ind(size(FbHfcc), indML, indKL);
indAidH=sub2ind(size(FbHfcc), indMH, indKH);

%za�adowanie macierzy banku filtr�w
FbHfcc(indAidL)=(ktSec(indKL)'-mAidLow(indML))./(mAidMid(indML)-mAidLow(indML));
FbHfcc(indAidH)=(ktSec(indKH)'-mAidHigh(indMH))./(mAidMid(indMH)-mAidHigh(indMH));

%%%
%4. Filtracja
%%%

Xs=FbHfcc*Y;

%smiana skali na logarytmiczn�
XsLog=log10(Xs);

%%%
%5. Odwr�cenie transformaty za pomoc� DCT
%%%

%unikni�cie za ma�ych liczb
H=dct(max(XsLog,eps));

%pobranie wymaganej ilo�ci rz�d�w macie�y HFCC
H=H(1:(Noc+1),:);

%usuni�cie niepotrzebnych wsp�czynnik�w
H=H(2:end,:);

end