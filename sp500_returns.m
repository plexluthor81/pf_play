%%
if ~exist('d','var')
    d = load('ern_vals.mat');
end

%%
i_oldest = 1;
i_1926 = find(d.fractional_date>1926,1); % Was 90 stocks
i_1957 = find(d.fractional_date>1957,1); % Was 500 stocks
i_last = length(d.fractional_date);

nominal_fh = @(d,i1,i2)((d.spx_tr(i2)/d.spx_tr(i1))^(1/(d.fractional_date(i2)-d.fractional_date(i1))));
cpi_fh = @(d,i1,i2)((d.cpi(i2)/d.cpi(i1))^(1/(d.fractional_date(i2)-d.fractional_date(i1))));
real_fh = @(d,i1,i2)(((d.spx_tr(i2)/(d.cpi(i2)))/(d.spx_tr(i1)/(d.cpi(i1))))^(1/(d.fractional_date(i2)-d.fractional_date(i1))));

for i = [i_oldest i_1926 i_1957]
%  fprintf('S&P 500 Nominal Return since %d: %.2f%%\n',...
%           floor(d.fractional_date(i)),...
%           100*(nominal_fh(d,i,i_last)-1));
%  fprintf('CPI since %d: %.2f%%\n',...
%           floor(d.fractional_date(i)),...
%           100*(cpi_fh(d,i,i_last)-1));
  fprintf('S&P 500 Real Return since %d: %.2f%%\n',...
           floor(d.fractional_date(i)),...
           100*(real_fh(d,i,i_last)-1));      
end
        
