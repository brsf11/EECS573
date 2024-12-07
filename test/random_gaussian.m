
function [product,in_A,in_B] = random_gaussian(mean_val, stddev, num_samples, plot_histogram)
    % GENERATE_AND_COUNT: Generate Gaussian-distributed random integers, count zeros.
    % 
    % INPUTS:
    %   mean_val       - Mean of the Gaussian distribution
    %   stddev         - Standard deviation of the Gaussian distribution
    %   num_samples    - Number of random integers to generate
    %   plot_histogram - Boolean flag to plot the histogram (true/false)
    % 
    % OUTPUT:
    %   num_zeros      - Number of zeros in the generated random integers

    % Generate Gaussian-distributed random numbers
    in_A = mean_val + stddev * randn(num_samples, 1);
    in_B = mean_val + stddev * randn(num_samples, 1);

    % Convert to integers
    %random_integers = round(random_values);

    % Adjust to specific range
    min_val = 0; % Minimum allowed value
    max_val = 2^64 - 1; % Maximum allowed value
    in_A = uint64(max(min(round(in_A), max_val), min_val));
    in_B = uint64(max(min(round(in_B), max_val), min_val));

    % Multiply input_A and input_B
    product = uint64(in_A) .* uint64(in_B);

    % Step 4: Find indices where the product is out of range
    %out_of_max_idx = (product > max_val);
    %out_of_min_idx = (product < min_val);

    for i=1:length(product)
        if (product < 0)
            in_A(i) = uint64(0);
            in_B(i) = uint64(0);
        elseif (product(i) > intmax('uint64'))
            in_A(i) = uint64(1);
            in_B(i) = uint64(2^64 -1);
        end
    end
    product = uint64(in_A) .* uint64(in_B);

    % Display the result
    fprintf('Number of zeros in the generated data: %d\n', num_zeros);
    fprintf('Number of max in the generated data: %d\n', num_max);

    % Optional: Plot the histogram
    if plot_histogram
        figure;
        histogram(in_A, 50); % 50 bins for visualization
        xlabel('Value');
        ylabel('Frequency');
        title('Gaussian-Distributed Random Integers');
        grid on;

        figure;
        histogram(in_B, 50); % 50 bins for visualization
        xlabel('Value');
        ylabel('Frequency');
        title('Gaussian-Distributed Random Integers');
        grid on;
    end

    % Open a file for writing
    fileA = fopen('ran_A.txt', 'w');
    fileB = fopen('ran_B.txt', 'w');
    
    % Write data to file
    fprintf(fileA, '%u\n', in_A); % Save each number on a new line
    fprintf(fileB, '%u\n', in_B);
    
    % Close the file
    fclose(fileA);
    fclose(fileB);
    
    disp('Data written to ran_A.txt and ran_B.txt');
end

