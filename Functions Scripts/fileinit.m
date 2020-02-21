%Skrypt inicjuj�cy pliki tekestowe
function filehandle = fileinit(filelist, opts, chsnchnl, Time, overlap)
    
%parametry wej�ciowe
%filelist   -  struktura przetrzymuj�ca dane o sygnale
%opts       - struktura przetrzymuj�ca opcje narz�dzia
%chsnchnl   - wybrany kana� 
%Time       - d�ugo�� fragmentu analizowanego sygna�u
%overlap    - poziom nak�adania sygna��w

%parametry wyj�ciowe:
%M      - wska�nik do pliku tekstowego

c = clock; 
mode = opts{1};

switch mode
    case 2
        lw = floor((filelist{4}/filelist{3})/Time); 
        flwrnm = sprintf('%s - %s - %s-%d-%d.txt',filelist{1},'FFT',date,c(4),c(5));
        firstline = sprintf('typ_analizy\t �r_syg\t cz_pr\t l_pr�b\t l_wierszy\n');
        secondline = sprintf('FFT\t %s\t %d\t %d\t %d\n\n',filelist{1,1},filelist{1,3},filelist{1,4},lw);
    case 3
        lw = floor((filelist{4}/filelist{3})/Time);
        flwrnm = sprintf('%s - %s - %s-%d-%d.txt',filelist{1},'MFCC',date,c(4),c(5));
        firstline = sprintf('typ_analizy\t �r_syg\t cz_pr\t l_pr�b\t l_macierzy\t l_wsp_MFCC\t roz_okna\t roz_nak�\t l_wsp_FFT\t l_filtr�w\n');
        secondline = sprintf('MFCC\t %s\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\n\n',filelist{1,1},filelist{1,3},filelist{1,4},lw,opts{3},opts{4},opts{5},opts{6},opts{7});
    case 4
        lw = floor((filelist{4}/filelist{3})/Time);
        flwrnm = sprintf('%s - %s - %s-%d-%d.txt',filelist{1},'HFCC',date,c(4),c(5));
        firstline = sprintf('typ_analizy\t �r_syg\t cz_pr\t l_pr�b\t l_macierzy\t l_wsp_MFCC\t roz_okna\t roz_nak�\t l_wsp_FFT\t l_filtr�w\n');
        secondline = sprintf('HFCC\t %s\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\n\n',filelist{1,1},filelist{1,3},filelist{1,4},lw,opts{3},opts{4},opts{5},opts{6},opts{7});
    case 5
        lw = floor((filelist{4}/filelist{3})/Time);
        flwrnm = sprintf('%s - %s - %s-%d-%d.txt',filelist{1},'FILTR',date,c(4),c(5));
        switch opts{3}
            case 1
                firstline = sprintf('typ_analizy\t �r_syg\t cz_pr\t l_pr�b\t l_wierszy\t typ_filtru\t rz_filtru\t cz_gr\n');
                secondline = sprintf('Filtr\t %s\t %d\t %d\t %d\t lowpass\t %d\t %d\n\n',filelist{1,1},filelist{1,3},filelist{1,4},lw,opts{4},opts{5});
            case 2
                firstline = sprintf('typ_analizy\t �r_syg\t cz_pr\t l_pr�b\t l_wierszy\t typ_filtru\t rz_filtru\t cz_gr\n');
                secondline = sprintf('Filtr\t %s\t %d\t %d\t %d\t highpass\t %d\t %d\n\n',filelist{1,1},filelist{1,3},filelist{1,4},lw,opts{4},opts{6});
            otherwise
                firstline = sprintf('typ_analizy\t �r_syg\t cz_pr\t l_pr�b\t l_wierszy\t typ_filtru\t rz_filtru\t 1_cz_gr\t 2_cz_gr\n');
                secondline = sprintf('Filtr\t %s\t %d\t %d\t %d\t bandpass\t %d\t %d\t %d\n\n',filelist{1,1},filelist{1,3},filelist{1,4},lw,opts{4},opts{5},opts{6});
        end
    case 6
        lw = floor((filelist{4}/filelist{3})/Time); 
        flwrnm = sprintf('%s - %s - %s-%d-%d.txt',filelist{1},'LPC',date,c(4),c(5));
        firstline = sprintf('typ_analizy\t �r_syg\t cz_pr\t l_pr�b\t dl_ok\t l_wsp\t l_wierszy\n');
        secondline = sprintf('LPC\t %s\t %d\t %d\t %d\t %d\t %d\n\n',filelist{1,1},filelist{1,3},filelist{1,4},Time*filelist{1,3},opts{3},lw);
    case 7
        lw = floor((filelist{4}/filelist{3})/Time);
        flwrnm = sprintf('%s - %s - %s-%d-%d.txt',filelist{1},'FORMANT',date,c(4),c(5));
        firstline = sprintf('typ_analizy\t �r_syg\t cz_pr\t l_pr�b\t l_wierszy\t l_formant�w\n');
        secondline = sprintf('Formanty\t %s\t %d\t %d\t %d\t %d\n\n',filelist{1,1},filelist{1,3},filelist{1,4},lw,opts{3});
    otherwise
end

filehandle = fopen(flwrnm,'w'); 
fprintf(filehandle,firstline);
fprintf(filehandle,secondline);
    
     
        