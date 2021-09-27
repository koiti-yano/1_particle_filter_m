
function vecr = matVecProd(mat, vec)
%[Philosophy]
%tmp = kron(eye(3), [1 2 ; 4 3])  * reshape([1 2 ; 3 4 ; 1 3 ].', 6,1)
%res = reshape(tmp, 2, 3).'
%[Compare]
% [1 2 ; 4 3] * [1 2].' , [1 2 ; 4 3] * [3 4].' , [1 2 ; 4 3] * [1 3].'

[rr, cc] = size(vec);

tmp = kron(eye(rr), mat) * reshape(vec.', rr*cc, 1);

vecr = reshape(tmp, cc, rr).';

%===========================================

