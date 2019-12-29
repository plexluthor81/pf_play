%%
if ~exist('d','var')
    d = load('ern_vals.mat');
end

%% Try to replicate Schwab's findings
% https://www.schwab.com/resource-center/insights/content/does-market-timing-work
% All 20-year rolling periods starting 1926 and ending 2012
% $2k of new money each year
% Five strategies:
% Peter Perfect invests at lowest monthly close
% Ashley Action invests at start of year
% Matthew Monthly DCAs in 12 even chunks
% Rosie Rotten invests at highest monthly close
% Larry Linger holds T-Bills

i_1926 = find(d.fractional_date>=1926,1);
i_2012 = find(d.fractional_date<2013,1,'last');
duration_years = 20;
start_years = 1926:(floor(max(d.fractional_date))-duration_years);
peter_ending_balance = zeros(1,length(start_years));
ashley_ending_balance = zeros(1,length(start_years));
matthew_ending_balance = zeros(1,length(start_years));
rosie_ending_balance = zeros(1,length(start_years));
larry_ending_balance = zeros(1,length(start_years));
for i_start_year = 1:length(start_years)
  start_year = start_years(i_start_year);
  peter_stocks = 0;
  ashley_stocks = 0;
  matthew_stocks = 0;
  rosie_stocks = 0;
  larry_cash = 0;
  for year = start_year:(start_year+duration_years-1)
    i_jan1 = find(d.fractional_date>=year,1);
    ii_year = i_jan1:(i_jan1+12); % include jan1 of following year
    stock_vals = d.spx_tr(ii_year);
    cash_vals = d.cash(ii_year);
    
    [peter_price, i_peter] = min(stock_vals);
    peter_stocks = peter_stocks + (2000*cash_vals(i_peter)/cash_vals(1))/peter_price;    
    
    ashley_price = stock_vals(1);
    i_ashley = 1;
    ashley_stocks = ashley_stocks + (2000*cash_vals(i_ashley)/cash_vals(1))/ashley_price;    
    
    for i = 1:12
      matthew_stocks = matthew_stocks + (2000/12*cash_vals(i)/cash_vals(1))/stock_vals(i);
    end
    
    [rosie_price, i_rosie] = max(stock_vals);
    rosie_stocks = rosie_stocks + (2000*cash_vals(i_rosie)/cash_vals(1))/rosie_price;    
    
    larry_cash = larry_cash + 2000/cash_vals(1);
  end
  i_end = find(d.fractional_date>=start_year+duration_years,1);
  peter_ending_balance(i_start_year) = peter_stocks*d.spx_tr(i_end);  
  ashley_ending_balance(i_start_year) = ashley_stocks*d.spx_tr(i_end);  
  matthew_ending_balance(i_start_year) = matthew_stocks*d.spx_tr(i_end);  
  rosie_ending_balance(i_start_year) = rosie_stocks*d.spx_tr(i_end);  
  larry_ending_balance(i_start_year) = larry_cash*d.cash(i_end);
end

%% Then add in David Dip who invests immediately as long as the market is at least X% off it's all-time peak.
% Bigshovel wants to "Monthly DCA unless the market dips then put the rest in"
dip_sizes = linspace(0.00,0.3,31);

all_time_high = zeros(size(d.spx_tr));
for i = 1:length(d.spx_tr)
  all_time_high(i) = max(d.spx_tr(1:i));
end

david_ending_balance = zeros(length(dip_sizes),length(start_years));
shovel_ending_balance = zeros(length(dip_sizes),length(start_years));
for i_dip_size = 1:length(dip_sizes)
  dip_size = dip_sizes(i_dip_size);
  for i_start_year = 1:length(start_years)
    start_year = start_years(i_start_year);
    david_stocks = 0;
    david_cash = 0;
    shovel_stocks = 0;
    for year = start_year:(start_year+duration_years-1)
      i_jan1 = find(d.fractional_date>=year,1);
      ii_year = i_jan1:(i_jan1+12); % include jan1 of following year
      stock_vals = d.spx_tr(ii_year);
      cash_vals = d.cash(ii_year);      
      
      david_cash = david_cash + 2000/cash_vals(1);
      
      dip_price = all_time_high(ii_year)*(1-dip_size);
      i_david = find(stock_vals<dip_price,1);
      if ~isempty(i_david)
        david_stocks = david_stocks + david_cash*cash_vals(i_david)/stock_vals(i_david); 
        david_cash = 0;
        
        i_shovel = i_david;
        for i = 1:(i_shovel-1)
          shovel_stocks = shovel_stocks + (2000/12*cash_vals(i)/cash_vals(1))/stock_vals(i);
        end
        shovel_stocks = shovel_stocks + max(0,(12-i_shovel))*2000/12*cash_vals(i_shovel)/cash_vals(1)/stock_vals(i_shovel);
      else
        for i = 1:12
          shovel_stocks = shovel_stocks + (2000/12*cash_vals(i)/cash_vals(1))/stock_vals(i);
        end 
      end
    end
    i_end = find(d.fractional_date>=start_year+duration_years,1);
    david_ending_balance(i_dip_size,i_start_year) = david_stocks*d.spx_tr(i_end);  
    shovel_ending_balance(i_dip_size,i_start_year) = shovel_stocks*d.spx_tr(i_end);  
  end
end

%% Plot Bar Chart comparing Schwab's results to mine
figure
i_comparison = find(start_years==1993);
comparison_data = [87004 peter_ending_balance(i_comparison);...
                   81650 ashley_ending_balance(i_comparison);...
                   79510 matthew_ending_balance(i_comparison);...
                   72487 rosie_ending_balance(i_comparison);...
                   51291 larry_ending_balance(i_comparison);];
b = bar(comparison_data);
set(gca,'XTickLabel',{sprintf('Peter\n(Perfect\nTiming)'),sprintf('Ashley\n(Invest\nimmediately)'),...
    sprintf('Matthew\n(Monthly\nDCA)'),sprintf('Rosie\n(Rotten\nTiming)'),sprintf('Larry\n(Cash)')});
set(b(1),'FaceColor',[0 .5 1])
set(b(2),'FaceColor',[1 9/16 3/16])
title('Replicating Schwab''s Results')
ylabel('2012 Ending Balance ($)')
grid on

%% Plot David's returns
deb_norm = david_ending_balance./matthew_ending_balance;
seb_norm = shovel_ending_balance./matthew_ending_balance;
figure
plot(dip_sizes,mean(deb_norm,2)')
hold all
plot(dip_sizes,median(deb_norm,2)')
plot(dip_sizes,mean(seb_norm,2)')
plot(dip_sizes,median(seb_norm,2)')
title(sprintf('Average Results for David over %d %d-year Intervals',length(start_years),duration_years))
xlabel('Dip Size')
ylabel('Normalized return (Matthew=1)')
l = legend('David Mean', 'David Median', 'Shovel Mean', 'Shovel Median');
set(l,'Location','SouthWest')
grid on

%% Show one example of when it doesn't work out
figure
plot(start_years(end-19:end)+duration_years, deb_norm(6, end-19:end))
hold all
plot(start_years(end-19:end)+duration_years, deb_norm(11, end-19:end))
plot(start_years(end-19:end)+duration_years, deb_norm(16, end-19:end))
grid on
legend('5% dip', '10% dip', '15% dip')
xlabel('Ending Year')
ylabel(sprintf('Normalized return\n(Ashley=0%%, Matthew=1)'))
title('An Example of When David Under-performs (this is uncommon)')

%% Distribution of the David 10% parameter's returns:
figure
hist(deb_norm(11,:),linspace(0.98,1.04,25))
xlabel(sprintf('Normalized Value, Matthew=1\n0.25%% bin width'))
ylabel('Number of Occurences out of 78')
title('Distribution of David''s returns waiting for 10% dips')