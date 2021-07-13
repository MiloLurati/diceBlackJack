function output = recognize_word() 
%RECOGNIZE_WORD In this function we record 2.5 seconds of audio and then
%process into 12 MFCC. Then we input the result in a trained
%neural network function and determine if the work is "NEXT", "STOP",  
%or noise. If all the outputs of the NN function are under 0.8, the
%function outputs noise. If they are bigger than 0.8 it determines the
%biggest one.

    rec = audiorecorder(8000,16,1);
    recordblocking (rec, 2.5); 
    y = getaudiodata (rec);
    cep_vector = ifft(log(abs(fft(y))));
    cep_vector = cep_vector(1:12).';
    outputNN = myNeuralNetworkFunction(cep_vector);
    if outputNN(1) > outputNN(2:3) & outputNN(1) > 0.8 
        output = "next";
    elseif (outputNN(2) > outputNN(1) & outputNN(2) > outputNN(3)) & outputNN(2) > 0.8
        output = "stop";
    else
        output = "noise";
    end
end