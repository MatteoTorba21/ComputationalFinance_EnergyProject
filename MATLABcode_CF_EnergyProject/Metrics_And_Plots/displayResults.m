function [] = displayResults(model_prices,T1,T2,prices,names,titlePlot)
% Function to display the model prices plotted against the market prices.
% 
% INPUTS:
% model_prices: Prices of the models
% T1:           Delivery start dates
% T2:           Settlement dates
% prices:       Market prices
% names:        Names of the Futures
% titlePlot:    String containing the title of the plot

% Plot the results
figure;

% Plot with the barplot
subplot(2,2,1:2);
% Bar chart (transposed to align with names)
bar([T1 T2], 'stacked','FaceAlpha',0.5);

% Label for the first y-axis
ylabel('$0 \rightarrow \tau_1 \rightarrow \tau_2$','Interpreter','latex')
hold on;

% Create a secondary y-axis (twin axis)
yyaxis right;
colors = ['r','b','g','y'];

% Plot the prices
plot(prices, '-o', 'LineWidth', 2, 'Color', 'k');   % Plot market prices
for i=1:size(model_prices,2)           
   plot(model_prices(:,i), '-o', 'LineWidth', 2, 'Color', colors(i)); % Plot model prices
end

% Set the clour
set(gca, 'YColor', 'k');

% Label for the secondary axis
ylabel('$F(0,\tau_1,\tau_2)$','Interpreter','latex');

% Configure x-axis ticks and labels
xticks(1:20);
xticklabels(names(1:20));  % Assign labels to the ticks
xtickangle(45);            % Rotate labels for better readability if necessary
xlabel('Contracts');       % Label for the x-axis

% Legend and title
legend('TTM', 'Tenors', 'Location', 'north');
title('Futures');
grid on;
hold off;


% Plot without the barplot
subplot(2,2,[3 4]);

% Sort the settlements
[~, sortedIndices] = sort(T1);

% Plot the sorted prices
plot(T1(sortedIndices),prices(sortedIndices),...
    '-o', 'LineWidth', 2, 'Color', 'k');
hold on;
for i=1:size(model_prices,2)
    points = model_prices(:,i);
    plot(T1(sortedIndices),points(sortedIndices), '-o', 'LineWidth', 2, 'Color', colors(i));
end

% Legend, labels and title
warning('off', 'all'); % to ignore extra legend entries
legend('Market', 'Model_1', 'Model_2', 'Location', 'north');
warning('on', 'all');  % renable warnings
ylabel('$F(0,\tau_1,\tau_2)$','Interpreter','latex')
xlabel('$\tau_1$','Interpreter','latex');
sgtitle(titlePlot);

end

