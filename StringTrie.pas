unit StringTrie;

{Author: Nicholas Sherlock, 2006.}

interface

uses sysutils, contnrs, math;

type
  TStringTrieNode = class
  private
    fKey: string;
    fOwnsObjects: boolean;
  public
    HasValue: boolean;
    Value: TObject;
    children: TObjectList;

    function Insert(const key: string; startindex: integer; value: TObject): boolean;
    function IsPrefix(const key: string; startindex: integer): Boolean;
    function Find(const key: string; startindex: integer; out value: TObject): Boolean;

    constructor CreateAssign(copyFrom: TStringTrieNode);
    constructor Create(ownsObjects: boolean);
    destructor Destroy; override;

    property Key: string read fkey write fkey;
  end;

  TStringTrie = class
  private
    fRoot: TStringTrieNode;
    fOwnsObjects, fCaseSensitive: boolean;
  public
    function PrintStructure: string;
    function PrintKeys: string;
    
    procedure Insert(const key: string; value: TObject);

    //Is the given key a prefix of a key/value pair in the tree?
    function IsPrefix(const key: string): Boolean;

    //Does the given key match a key/value pair in the tree?
    function Find(const key: string; out value: TObject): Boolean;

    constructor Create(ownsObjects: boolean; casesensitive: boolean);
    destructor Destroy; override;
  end;

implementation

constructor TStringTrieNode.createAssign(copyFrom: TStringTrieNode);
begin
  Self.HasValue := copyFrom.HasValue;
  Self.Value := copyFrom.Value;
  Self.Key := copyFrom.Key;
  Self.children := copyFrom.children; //Note that we just get a reference to the other's list!!
end;

constructor TStringTrieNode.Create(ownsObjects: boolean);
begin
  children := TObjectList.create;
  fOwnsObjects := ownsObjects;
end;

destructor TStringTrieNode.Destroy;
begin
  children.free;
  if fOwnsObjects and HasValue then
    Value.free;
  inherited;
end;

//Return true if key/value was inserted into this trie, otherwise false if it doesn't belong here.

function TStringTrieNode.Insert(const key: string; startindex: integer; value: TObject): boolean;
var i: integer;
  child: TStringTrieNode;
begin
  result := length(fKey) = 0; //special case for root node

  //Find the bits of our key that match the key provided...

  i := 1;
  while (i <= length(fkey)) and (startindex <= length(key)) do //check that Key matches fKey
    if AnsiCompareStr(fkey[i], key[startindex]) = 0 then begin
      result := true;
      inc(i);
      inc(startindex);
    end else break;

  {None of the provided key matched our key, provided key shouldn't be one of our children}
  if not result then
    exit;

  (*now i is the index of the first non-matched character in our key,
    startindex the index of the first non-matched in provided key.*)

  {If the whole provided key matches our key, then startindex>length(key)
     and i>length(fkey). Replace our value with the provided one}
  if (startIndex > length(key)) and (i > length(fKey)) then begin
    HasValue := true;
    Self.Value := value;
  end else
    if (i > length(fkey)) then begin
    {provided key matched our complete key, but there is still some provided key
     left over. Insert in one of our children or make a new child}

      for i := 0 to children.count - 1 do
        if TStringTrieNode(children[i]).Insert(key, startindex, value) then
          Exit; //job done

    //we must add a child
      child := TStringTrieNode.Create(fOwnsObjects);
      child.Key := Copy(key, startindex, length(key));
      child.HasValue := true;
      child.value := value;
      children.add(child);
    end else
      if (startindex > length(key)) then begin
    //complete provided key matches only part of our key. We must split up

    //Take our contents and put into a new child
        child := TStringTrieNode.createAssign(self);
        child.fKey := copy(fkey, i, length(fkey));

        children := TObjectList.create; //since they stole ours
        children.add(child);

    //we take the new values
        Self.Key := copy(Self.key, 1, i - 1);
        hasvalue := true;
        self.value := value;
      end else begin
       {some of the provided key matches some of our key.}

    //Take our contents and put into a new child
        child := TStringTrieNode.createAssign(self); //Take our contents
        child.fKey := copy(fkey, i, length(fkey));

        children := TObjectList.create; //Since our new child stole ours
        children.add(child);

    //We take the shared parts of the key, but lose our value to become a branch
        Self.Key := copy(Self.Key, 1, i - 1);
        HasValue := false;
        Value := nil;

    //The provided key becomes our child too...
        child := TStringTrieNode.create(fownsobjects);
        child.Key := copy(key, startindex, length(key));
        child.HasValue := true;
        child.Value := value;
        children.add(child);
      end;
end;

function TStringTrieNode.IsPrefix(const key: string; startindex: integer): Boolean;
var i: integer;
begin
  result := false;

  i := 1;
  while (i <= length(fkey)) and (startindex <= length(key)) do begin //check that Key matches fKey
    if AnsiCompareStr(fkey[i], key[startindex]) = 0 then begin
      inc(i);
      inc(startindex);
    end else
      exit;
  end;

  if startIndex > length(key) then begin //we have matched the whole key
    result := true;
    exit;
  end else //we haven't matched the whole key yet. Let's ask our children
    for i := 0 to children.count - 1 do
      if TStringTrieNode(children[i]).IsPrefix(key, startindex) then begin
        result := true;
        exit;
      end;
end;

function TStringTrieNode.Find(const key: string; startindex: integer; out value: TObject): Boolean;
var i: integer;
begin
  result := false;

  if length(key) - startindex + 1 < length(fkey) then exit; //can't match, it's too short!

  i := 1;
  while i <= length(fkey) do begin //check that Key matches fKey
    if AnsiCompareStr(fkey[i], key[startindex]) = 0 then begin
      inc(i);
      inc(startindex);
    end else
      exit; //key doesn't match, key can't be us or one of our children
  end;

  //if we're here, (the start of) Key matches our key
  if (startIndex > length(key)) and HasValue then begin //we have matched the whole key
    value := Self.Value;
    result := true;
    exit;
  end else //we haven't matched the whole key yet. Let's ask our children
    for i := 0 to children.count - 1 do
      if TStringTrieNode(children[i]).Find(key, startindex, value) then begin
        result := true;
        exit;
      end;
end;

function RecursePrintStructure(node: TStringTrieNode; indent: integer): string;
var t1: integer;
begin
  if node.HasValue then
    result := stringofchar(' ', indent) + node.fKey + ' (' + inttostr(integer(node.value)) + ')' + #13#10 else
    result := stringofchar(' ', indent) + node.fKey + #13#10;
  for t1 := 0 to node.children.count - 1 do
    result := result + RecursePrintStructure(TStringTrieNode(node.children[t1]), indent + 2);
end;

function RecursePrintKeys(node: TStringTrieNode; const key: string): string;
var t1: integer;
begin

  if node.HasValue then
    result := key + node.fKey + ' (' + inttostr(integer(node.value)) + ')' + #13#10 else
    result := '';

  for t1 := 0 to node.children.count - 1 do
    result := result + RecursePrintKeys(TStringTrieNode(node.children[t1]), key + node.fkey);
end;

function TStringTrie.PrintKeys: string;
begin
  result := RecursePrintkeys(froot, '');
end;

function TStringTrie.PrintStructure: string;
begin
  result := RecursePrintStructure(froot, 0);
end;

procedure TStringTrie.Insert(const key: string; value: TObject);
begin
  fRoot.Insert(key, 1, value);
end;

function TStringTrie.IsPrefix(const key: string): Boolean;
begin
  result := froot.IsPrefix(key, 1);
end;

function TStringTrie.Find(const key: string; out value: TObject): Boolean;
begin
  result := fRoot.find(key, 1, value);
end;

constructor TStringTrie.Create(ownsobjects: boolean; casesensitive: boolean);
begin
  fRoot := TStringTrieNode.Create(true);
  fOwnsObjects := ownsObjects;
  fCaseSensitive := caseSensitive;
end;

destructor TStringTrie.Destroy;
begin
  fRoot.free;
  inherited;
end;


end.

