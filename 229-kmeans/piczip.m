% K-Means for Picture compression

function [] = piczip()
% Initialization for 16 clusters
U = rand(16,3) * 256;

%Load Data from Small Picture & select centers
X = double(imread('mandrill-small.tiff'));
m = size(X, 1);
n = size(X, 2);
belong = zeros(m,n);
old_belong = belong;


itr = 0;
while 1
    
itr=itr+1;

belong = locatePoints(X, U);

%Update new clustering centers
U=zeros(16,3);
count = zeros(16);
for i=1:m
    for j=1:n
        U(belong(i,j),1) = U(belong(i,j),1) + X(i,j,1);
        U(belong(i,j),2) = U(belong(i,j),2) + X(i,j,2);
        U(belong(i,j),3) = U(belong(i,j),3) + X(i,j,3);
        count(belong(i,j)) = count(belong(i,j)) + 1;
    end
end
for i=1:16
    U(i,1) = U(i,1)/count(i);
    U(i,2) = U(i,2)/count(i);
    U(i,3) = U(i,3)/count(i);
end


if isequal(old_belong, belong)
    break;
end

old_belong = belong;
%display(belong);

end

fprintf('converge after %d iterations\n', itr);

X = double(imread('mandrill-large.tiff'));
belong = locatePoints(X, U);
for i=1:size(X,1)
    for j=1:size(X,2)
        X(i,j,1) = U(belong(i,j),1);
        X(i,j,2) = U(belong(i,j),2);
        X(i,j,3) = U(belong(i,j),3);
    end
end

fprintf('show picture after compression\n');
imshow(uint8(round(X)));



function rBelong = locatePoints(P, C)
    m = size(P, 1);
    n = size(P, 2);
    rBelong = ones(m,n) * (-1);
    distance = ones(m,n) * 255^4;%255^4 is enough for INF_MAX

    tu = ones(16, m, n, 3);
    for i=1:16
        tu(i,:,:,1) = C(i,1) .* tu(i,:,:,1);
        tu(i,:,:,2) = C(i,2) .* tu(i,:,:,2);
        tu(i,:,:,3) = C(i,3) .* tu(i,:,:,3);
    end
    
    for i=1:16
        x1 = P(:,:,1)-reshape(tu(i,:,:,1),m,n);
        x1 = x1.*x1;
        x2 = P(:,:,2)-reshape(tu(i,:,:,2),m,n);
        x2 = x2.*x2;
        x3 = P(:,:,3)-reshape(tu(i,:,:,3),m,n);
        x3 = x3.*x3;
        x0 = x1 + x2 + x3;
        for j=1:m
            for k=1:n
                if x0(j,k) < distance(j,k)
                    distance(j,k) = x0(j,k);
                    rBelong(j,k) = i;
                end
            end
        end
    end


