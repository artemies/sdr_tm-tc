Input = importdata('hex_test.txt','\r');  %Load Test File
Input = cell2mat(Input);  
DataMat = Input(:,1:65);   %Remove CRC or last 2 bytes
Input = vec2mat(strrep(sprintf(Input'),' ',''),48);
Data = vec2mat(strrep(sprintf(DataMat'),' ',''),44);  %Convert to String; Remove Spaces (Becomes a Vectr); Convert 2 Matrix


FinalHex = '0000';  %Final Value
PolyHex = '1021';  %Polynomial

Final = [hexToBinaryVector(FinalHex,16)];
CRC = [];
Poly = [1 hexToBinaryVector(PolyHex,16)];
Poly_l = length(Poly);
k = 0;
while strcmp(Data,Input) == 0
    CRC = [];
    Data = vec2mat(strrep(sprintf(DataMat'),' ',''),44);
    InitHex = string(dec2hex(k));
    Init = [hexToBinaryVector(InitHex,16) 0];
     %Check each frame of input data
    Msg = hexToBinaryVector([Data],176);
    Dividend = [Msg Final];
    n = length(Msg);
    Q = []; %Quotient
    M = []; %To be XOR
    R = Dividend(1:Poly_l); %Remainder
    R = xor(R,Init);
    for i = 1:n        %Modulo 2 Division
        if R(1) == 1
            Q = [Q 1];
            M = Poly;
        else
            Q = [Q 0];
            M = zeros(1,Poly_l);
        end
        R = xor(M,R);
        if i==n
            break;
        end
        R = [R(2:length(R)) Dividend(i+Poly_l)];
    end
    CRC = [CRC; binaryVectorToHex(R)];   %Final Remainder is the generated CRC

    CRC = CRC(:,2:5);
    Data = [Data CRC];  %Append CRC to Data
    Data = upper(Data);
    Input = upper(Input);
    if strcmp(Data,Input)
        a = sprintf('Correct CRC Parameters, Init value is:%s',string((dec2hex(k))));
        disp(a)
    else
        disp('Incorrect CRC Parameters');
    end
    k = k+1;
end
