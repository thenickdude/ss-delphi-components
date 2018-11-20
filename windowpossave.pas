unit windowpossave;

interface

uses windows, sysutils, forms, classes;

type TWindowPosSave = class(TComponent)
  public
    function save: string;
    procedure load(data: string);
  end;

procedure Register;

implementation

procedure Register;
begin
  registercomponents('Sherlock Software', [TWindowPosSave]);
end;

procedure TWindowPosSave.load(data: string);
var list: tstringlist;
  form: tform;
  r: trect;
begin
  try
    if owner is tform then begin
      form := tform(owner);
      list := tstringlist.create;
      try
        list.CommaText := data;
        if list.count = 5 then begin

          if strtoint(list[4]) = 1 then
            form.windowstate := wsMaximized else begin
            r.left := strtoint(list[0]);
            r.top := strtoint(list[1]);
            r.right := strtoint(list[2]);
            r.bottom := strtoint(list[3]);
            if (r.right > 0) and (r.bottom > 0) and (r.left < screen.width) and (r.top < screen.height) then begin
              form.left := r.left;
              form.top := r.top;
              form.width := r.right - r.left;
              form.height := r.bottom - r.top;
            end;
          end;
        end;
      finally
        list.free;
      end;
    end;
  except
  end;
end;

function TWindowPosSave.Save: string;
var list: tstringlist;
  form: tform;
begin
  result := '';

  try
    if owner is tform then begin
      form := tform(owner);
      list := tstringlist.create;
      try
        list.add(inttostr(form.left));
        list.add(inttostr(form.top));
        list.add(inttostr(form.left + form.width));
        list.add(inttostr(form.top + form.height));
        if form.windowstate = wsMaximized then
          list.add('1') else
          list.add('0');
        result := list.commatext;
      finally
        list.free;
      end;
    end;
  except
  end;
end;

end.

