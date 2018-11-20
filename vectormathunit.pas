unit vectormathunit;

interface
uses sysutils, math, fastgeo;

type
  TVector4d = record
    x, y, z, w: double;
  end;
  T3Matrix = array[0..2, 0..2] of double;
  T4Matrix = array[0..3, 0..3] of double;

function Identity3Matrix: T3Matrix;

function point3d(v: tvector4d): tpoint3d; overload;
function point3d(v: tvector3d): tpoint3d; overload;
function point3d(x, y, z: double): tpoint3d; overload;
function vector3d(x, y, z: double): TVector3D; overload;
function vector3d(const p: tpoint3D): TVector3D; overload;
function vector3d(v: tvector4d): tvector3d; overload;
function matrix(values: array of double): T3Matrix;
function matrix4(values: array of double): T4Matrix;
function make4matrix(w: tpoint3d): T4Matrix; overload;
function make4matrix(w: t3matrix; p: tvector3d): T4Matrix; overload;
function vector4d(w: tvector3d): tvector4d; overload;
function vector4d(w: tpoint3d): tvector4d; overload;
function vector4d(x, y, z, w: double): TVector4d; overload;

function matmul(v: tvector3d; matrix: t3matrix): tvector3d; overload;
function matmul(matrix: t4matrix; v: tvector4d): tvector4d; overload;
function matmul(m1, m2: t3matrix): t3matrix; overload;
function matmul(m1, m2: t4matrix): t4matrix; overload;
function crossproduct(a, b: tvector3d): tvector3d;

function VectorRotateAroundY(const v: TVector3D; alpha: Single): TVector3D;


implementation

function VectorRotateAroundY(const v: TVector3D; alpha: Single): TVector3D;
var
  c, s: Extended;
begin
  SinCos(alpha, s, c);
  Result.y := v.y;
  Result.x := c * v.x + s * v.z;
  Result.z := c * v.z - s * v.x;
end;

function vector3d(x, y, z: double): TVector3D;
begin
  result.x := x;
  result.y := y;
  result.z := z;
end;

function vector4d(x, y, z, w: double): TVector4d;
begin
  result.x := x;
  result.y := y;
  result.z := z;
  result.w := w;
end;

function vector3d(const p: tpoint3D): TVector3D;
begin
  Move(p, result, sizeof(tpoint3d));
{  result.x := p.x;
  result.y := p.y;
  result.z := p.z;}
end;

function point3d(v: tvector3d): tpoint3d;
begin
  Move(v,result,SizeOf(TVector3d));
{  result.x := v.x;
  result.y := v.y;
  result.z := v.z;}
end;

function point3d(v: tvector4d): tpoint3d;
begin
  result.x := v.x / v.w;
  result.y := v.y / v.w;
  result.z := v.z / v.w;
end;

function point3d(x, y, z: double): tpoint3d;
begin
  result.x := x;
  result.y := y;
  result.z := z;
end;

function Identity3Matrix: T3Matrix;
begin
  result[0, 0] := 1;
  result[0, 1] := 0;
  result[0, 2] := 0;
  result[1, 0] := 0;
  result[1, 1] := 1;
  result[1, 2] := 0;
  result[2, 0] := 0;
  result[2, 1] := 0;
  result[2, 2] := 1;
end;

function std4matrix: t4matrix;
begin
  result[0, 0] := 1;
  result[0, 1] := 0;
  result[0, 2] := 0;
  result[0, 3] := 0;
  result[1, 0] := 0;
  result[1, 1] := 1;
  result[1, 2] := 0;
  result[1, 3] := 0;
  result[2, 0] := 0;
  result[2, 1] := 0;
  result[2, 2] := 1;
  result[2, 3] := 0;
  result[3, 0] := 0;
  result[3, 1] := 0;
  result[3, 2] := 0;
  result[3, 3] := 1;
end;


function make4matrix(w: tpoint3d): T4Matrix;
begin
  result := std4matrix;
  result[0, 0] := w.x;
  result[1, 1] := w.y;
  result[2, 2] := w.z;
end;

function make4matrix(w: t3matrix; p: tvector3d): T4Matrix;
var x, y: integer;
begin
  result := std4matrix;

  for y := 0 to 2 do
    for x := 0 to 2 do
      result[x, y] := w[x, y];

  result[3, 0] := p.x;
  result[3, 1] := p.y;
  result[3, 2] := p.z;
end;

function vector4d(w: tpoint3d): tvector4d;
begin
  result.x := w.x;
  result.y := w.y;
  result.z := w.z;
  result.w := 1;
end;

function vector4d(w: tvector3d): tvector4d;
begin
  result.x := w.x;
  result.y := w.y;
  result.z := w.z;
  result.w := 1;
end;

function vector3d(v: tvector4d): tvector3d;
begin
  result.x := v.x / v.w;
  result.y := v.y / v.w;
  result.z := v.z / v.w;
end;

function crossproduct(a, b: tvector3d): tvector3d; //Checks out okay
begin
  result.x := (a.y * b.z) - (a.z * b.y);
  result.y := (a.z * b.x) - (a.x * b.z);
  result.z := (a.x * b.y) - (a.y * b.x);
end;

function matmul(v: tvector3d; matrix: t3matrix): tvector3d;
begin
  result.x := v.x * matrix[0, 0] + v.y * matrix[1, 0] + v.z * matrix[2, 0];
  result.y := v.x * matrix[0, 1] + v.y * matrix[1, 1] + v.z * matrix[2, 1];
  result.z := v.x * matrix[0, 2] + v.y * matrix[1, 2] + v.z * matrix[2, 2];
end;

function matmul(matrix: t4matrix; v: tvector4d): tvector4d;
begin
  result.x := v.x * matrix[0, 0] + v.y * matrix[1, 0] + v.z * matrix[2, 0] + v.w * matrix[3, 0];
  result.y := v.x * matrix[0, 1] + v.y * matrix[1, 1] + v.z * matrix[2, 1] + v.w * matrix[3, 1];
  result.z := v.x * matrix[0, 2] + v.y * matrix[1, 2] + v.z * matrix[2, 2] + v.w * matrix[3, 2];
  result.w := v.x * matrix[0, 3] + v.y * matrix[1, 3] + v.z * matrix[2, 3] + v.w * matrix[3, 3];
end;

function matmul(m1, m2: t3matrix): t3matrix;
var x, y, i: integer;
begin
  for y := 0 to 2 do
    for x := 0 to 2 do begin
      result[x, y] := 0;
      for i := 0 to 2 do
        result[x, y] := result[x, y] + m1[x, i] * m2[i, y];
    end;
end;

function matmul(m1, m2: t4matrix): t4matrix;
var x, y, i: integer;
begin
  for y := 0 to 3 do
    for x := 0 to 3 do begin
      result[x, y] := 0;
      for i := 0 to 3 do
        result[x, y] := result[x, y] + m1[x, i] * m2[i, y];
    end;
end;

function matrix(values: array of double): T3Matrix;
begin
  assert(length(values) = 9, '!!');
  result[0, 0] := values[0];
  result[1, 0] := values[1];
  result[2, 0] := values[2];
  result[0, 1] := values[3];
  result[1, 1] := values[4];
  result[2, 1] := values[5];
  result[0, 2] := values[6];
  result[1, 2] := values[7];
  result[2, 2] := values[8];
end;

function matrix4(values: array of double): T4Matrix;
begin
  assert(length(values) = 16, '!!');
  result[0, 0] := values[0];
  result[1, 0] := values[1];
  result[2, 0] := values[2];
  result[3, 0] := values[3];

  result[0, 1] := values[4];
  result[1, 1] := values[5];
  result[2, 1] := values[6];
  result[3, 1] := values[7];

  result[0, 2] := values[8];
  result[1, 2] := values[9];
  result[2, 2] := values[10];
  result[3, 2] := values[11];

  result[0, 3] := values[12];
  result[1, 3] := values[13];
  result[2, 3] := values[14];
  result[3, 3] := values[15];
end;

end.

