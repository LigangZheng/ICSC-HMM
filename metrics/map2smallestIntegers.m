function z = map2smallestIntegers(z,K)

counts = histc(z,[1:K]);
[sorted sort_ind] = sort(counts,'descend');
z_temp = z;

ind = 1;
for ii=1:length(sort_ind)        
    z(find(z_temp==sort_ind(ii))) = ind;
    ind = ind + 1;
end

% for ii=sort_ind
%     z(find(z_temp==ii)) = ind;
%     ind = ind + 1;
% end