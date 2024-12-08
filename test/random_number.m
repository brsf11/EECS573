function [A,B1,B2,B3,B4] = random_number(plot_histogram)

    % For Gaussian-distributed random numbers
    mean_val = 2^8;
    stddev = 2^7;
    num_samples = 10000;
    % For Chi-Squared distributed
    k = 3;
    scale_factor= 1e6;

    A = chi2rnd(k, num_samples, 1);
    %A = A * scale_factor; % Scale the values to make them larger
    A = uint64(max(min(round(A), 2^64 - 1), 0));

    % Plot the PDF
    % Normalize histogram to show probability density
    [counts, edges] = histcounts(double(A), 'Normalization', 'pdf');
    bin_centers = edges(1:end-1) + diff(edges) / 2;
    
    figure;
    bar(bin_centers, counts, 'FaceColor', [0.2, 0.7, 0.9], 'EdgeColor', 'none');
    hold on;
    
    % Overlay theoretical chi-square PDF
    x = linspace(0, max(bin_centers), 1000);
    theoretical_pdf = chi2pdf(x, k);
    plot(x, theoretical_pdf, 'r-', 'LineWidth', 1.5);
    
    % Customize plot
    title('PDF of Chi-Square Distributed uint64 Random Numbers (k=3)');
    xlabel('Value');
    ylabel('Probability Density');
    legend('Empirical PDF', 'Theoretical PDF');
    grid on;
    ylim([0, 1]); % Set y-axis limits to [0, 1]

    % Generate Gaussian-distributed random numbers
    B1 = mean_val + stddev * randn(num_samples, 1);
    B2 = mean_val + stddev * randn(num_samples, 1);
    B3 = mean_val + stddev * randn(num_samples, 1);
    B4 = mean_val + stddev * randn(num_samples, 1);

    % Convert to integers
    %random_integers = round(random_values);

    % Adjust to specific range
    min_val = 0; % Minimum allowed value
    max_val = 2^16 - 1; % Maximum allowed value

    B1 = uint16(max(min(round(B1), max_val), min_val));
    B2 = uint16(max(min(round(B2), max_val), min_val));
    B3 = uint16(max(min(round(B3), max_val), min_val));
    B4 = uint16(max(min(round(B4), max_val), min_val));

    % Optional: Plot the histogram
    if plot_histogram
        figure;
        histogram(B1, 50); % 50 bins for visualization
        xlabel('Value');
        ylabel('Frequency');
        title('Gaussian-Distributed Random Integers');
        grid on;

        figure;
        histogram(B2, 50); % 50 bins for visualization
        xlabel('Value');
        ylabel('Frequency');
        title('Gaussian-Distributed Random Integers');
        grid on;
    end

    data = [A,B1,B2,B3,B4];
    writematrix(data, 'A_B.txt', 'Delimiter',';');

    % Open a file for writing
    fileA = fopen('A.txt', 'w');
    fileB1 = fopen('B1.txt', 'w');
    fileB2 = fopen('B2.txt', 'w');
    fileB3 = fopen('B3.txt', 'w');
    fileB4 = fopen('B4.txt', 'w');
   
    
    % Write data to file
    fprintf(fileA, '%u\n', A); % Save each number on a new line
    fprintf(fileB1, '%u\n', B1);
    fprintf(fileB2, '%u\n', B2);
    fprintf(fileB3, '%u\n', B3);
    fprintf(fileB4, '%u\n', B4);
    
    % Close the file
    fclose(fileA);
    fclose(fileB1);
    fclose(fileB2);
    fclose(fileB3);
    fclose(fileB4);
    
end
