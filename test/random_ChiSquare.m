
function [product_chi, in_A_chi, in_B_chi] = random_ChiSquare(degreesOfFreedom, numSamples, plot_histogram)
    % Generate uint64 numbers from a Chi-square distribution
    %
    % Parameters:
    % degreesOfFreedom - Degrees of freedom for the Chi-square distribution
    % numSamples - Number of samples to generate
    %
    % Returns:
    % uint64Numbers - Array of uint64 numbers with Chi-square distribution
    
    % Generate Chi-square distributed random numbers (double precision)
    in_A_chi = chi2rnd(degreesOfFreedom, numSamples, 1);
    in_B_chi = chi2rnd(degreesOfFreedom, numSamples, 1);

    % Adjust to specific range
    min_val = 0; % Minimum allowed value
    max_val = 2^64 - 1; % Maximum allowed value
    in_A_chi = uint64(max(min(round(in_A_chi), max_val), min_val));
    in_B_chi = uint64(max(min(round(in_B_chi), max_val), min_val));

    % Multiply input_A and input_B
    product_chi = uint64(in_A_chi) .* uint64(in_B_chi);

    % Find indices where the product is out of range
    for i=1:length(product_chi)
        if (product_chi < 0)
            in_A_chi(i) = uint64(0);
            in_B_chi(i) = uint64(0);
        elseif (product_chi(i) > intmax('uint64'))
            in_A_chi(i) = uint64(1);
            in_B_chi(i) = uint64(2^64 -1);
        end
    end
    product_chi = uint64(in_A_chi) .* uint64(in_B_chi);

    % Optional: Plot the histogram
    if plot_histogram
        figure;
        histogram(in_A_chi, 50); % 50 bins for visualization
        xlabel('Value');
        ylabel('Frequency');
        title('Chi_Squared Distributed Random Integers');
        grid on;

        figure;
        histogram(in_B_chi, 50); % 50 bins for visualization
        xlabel('Value');
        ylabel('Frequency');
        title('Chi_Squared Distributed Random Integers');
        grid on;
    end

    % Open a file for writing
    fileA = fopen('ran_A_chi.txt', 'w');
    fileB = fopen('ran_B_chi.txt', 'w');
    
    % Write data to file
    fprintf(fileA, '%u\n', in_A_chi); % Save each number on a new line
    fprintf(fileB, '%u\n', in_B_chi);
    
    % Close the file
    fclose(fileA);
    fclose(fileB);
    
    disp('Data written to ran_A_chi.txt and ran_B_chi.txt');
   
end
